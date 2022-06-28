import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.3
import QtQuick.Controls.Material.impl 2.12
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.14

import "../../UIControls" as Controls

Rectangle {
    id: overviewMapBorder

    //Adjusts the dimensions based on screen size and orientation
    width: deviceManager.isLandscape && deviceManager.isCompact ? geoView.width * 0.25 : Math.min(geoView.width * 0.45, 400)
    height: width * (3/4)

    //Positioning is based on relative position of main mapview
    radius: 4
    clip: true
    border.color: "black"
    border.width: 2

    //Drag attributes for allowing overview map to be moved
    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: width
    Drag.hotSpot.y: height

    property alias overviewMap: overviewMap
    property alias overviewMapGraphicsOverlay: overviewMapGraphicsOverlay
    property alias reticle: reticle
    property alias popUp: popUp
    property alias map: map

    property real currentOverviewMapRelativeX: 0
    property real currentOverviewMapRelativeY: 0

    property int overviewMapMultiplier: 10


    property var geoView: null
    property bool intiViewpointCenter: false

    property bool isLoading: true
    property bool geoViewUpdateViewpointTaskInProgress: false
    property int overviewMapStyle: Enums.BasemapStyleArcGISTopographic

    /*
     *  @desc:  When overview map x position changes,
     *          update property overview map relative x position
     */
    onXChanged: {
        if ( geoView && geoView.width > 0 ){
            currentOverviewMapRelativeX = overviewMapBorder.x / geoView.width
        }
    }
    /*
     *  @desc:  When overview map y position changes,
     *          update property overview map relative y position
     */
    onYChanged: {
        if ( geoView && geoView.height > 0 ){
            currentOverviewMapRelativeY = overviewMapBorder.y / geoView.height
        }
    }

    //Mapview for Overview Map
    MapView {
        id: overviewMap
        anchors {
            fill: parent
            margins: 3
        }
        attributionTextVisible: false
        interactionEnabled: !popUpContent.overviewMapUnlocked


        property bool updateViewpointTaskInProgress: false
        property bool zoomedIn: false

        /*
         *  @desc:  When viewpoint is complete, update bool to not in progress
         */
        onSetViewpointCompleted: {
            updateViewpointTaskInProgress = false
            isLoading = false
        }

        /*
         *  @desc:  On viewpoint change, update main map viewpoint center based
         *          on new viewpoint center of overview map. Update reticle graphic
         */
        onViewpointChanged: {
            if(!updateViewpointTaskInProgress && intiViewpointCenter){

                const currViewPointCenter = overviewMap.currentViewpointCenter
                if(!geoViewUpdateViewpointTaskInProgress){
                    const updateViewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter", {
                                                                                            center: currViewPointCenter.center,
                                                                                            targetScale: currViewPointCenter.targetScale / overviewMapMultiplier,
                                                                                            rotation: geoView.rotation
                                                                                        })

                    geoViewUpdateViewpointTaskInProgress = true
                    isLoading = true
                    const taskID = geoView.setViewpointAndSeconds(updateViewPointCenter, 0)
                    reticle.geometry = geoView.visibleArea
                    overviewMapGraphicsOverlay.graphics.append(reticle)
                }
            }
        }

        BusyIndicator {
            running: isLoading
            anchors.centerIn: parent
        }

        GraphicsOverlay {
            id: overviewMapGraphicsOverlay
        }

        /*
         *  @desc:  Graphic for creating the red rectangular reticle inside the overview map
         */
        Graphic {
            id: reticle
            symbol: SimpleFillSymbol {
                id: overviewReticleSymbol
                style: Enums.SimpleFillSymbolStyleNull
                SimpleLineSymbol {
                    style: Enums.SimpleLineSymbolStyleSolid
                    color: "red"
                    width: 2.0
                }
            }
        }

        Map {
            id: map

            Basemap {
                initStyle: overviewMapStyle
            }
        }

        /*
         *  @desc: Connect with main mapview to adjust viewpoint as needed
         */
        Connections {
            target: geoView
            /*
             *  @desc:  When viewpoint changes, update viewpoint center of overview map
             *          and update the reticle graphic.
             */
            function onViewpointChanged() {
                if(geoView.navigating && !overviewMap.updateViewpointTaskInProgress) {
                    overviewMapGraphicsOverlay.graphics.clear()
                    const currViewPointCenter = geoView.currentViewpointCenter
                    const updateViewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter", {
                                                                                            center: currViewPointCenter.center,
                                                                                            targetScale: currViewPointCenter.targetScale * overviewMapMultiplier,
                                                                                            rotation: geoView.rotation
                                                                                        })

                    overviewMap.updateViewpointTaskInProgress = true
                    isLoading = true

                    const taskID = overviewMap.setViewpointAndSeconds(updateViewPointCenter, 0)
                    reticle.geometry = geoView.visibleArea
                    overviewMapGraphicsOverlay.graphics.append(reticle)
                }
            }

            /*
             *  @desc:  When main map view viewpoint is completed, update overview map reticleic.
             */
            function onSetViewpointCompleted() {
                isLoading = false
                geoViewUpdateViewpointTaskInProgress = false
                reticle.geometry = geoView.visibleArea
                overviewMapGraphicsOverlay.graphics.append(reticle)
            }
        }


        /*
         *  @desc: Connect with main mapview to initialize overview map
         *         viewpoint center. Once initialized, set connection target to null
         */
        Connections {
            id: geoViewInitialization
            target: geoView

            /*
             *  @desc:  When the geoView draw status is complete, get the mapView
             *          viewpoint center and set to overviewmap
             */
            function onDrawStatusChanged() {
                if (geoView.drawStatus === Enums.DrawStatusCompleted) {
                    const currViewPointCenter = geoView.currentViewpointCenter
                    const updateViewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter", {
                                                                                            center: currViewPointCenter.center,
                                                                                            targetScale: currViewPointCenter.targetScale * overviewMapMultiplier,
                                                                                            rotation: geoView.rotation
                                                                                        })
                    overviewMap.updateViewpointTaskInProgress = true
                    isLoading = false

                    const taskID = overviewMap.setViewpointAndSeconds(updateViewPointCenter, 0)
                    reticle.geometry = geoView.visibleArea
                    overviewMapGraphicsOverlay.graphics.append(reticle)

                    intiViewpointCenter = true
                    geoViewInitialization.target = null
                } else if(geoView.drawStatus === Enums.DrawStatusInProgress) {
                    isLoading = true
                }
            }
        }

    }

    /*
     *  @desc:  Display overview map menu
     */
    RoundButton {
        id: overviewMapMenuButton
        anchors{
            bottom: parent.bottom
            right: parent.right
        }
        z: 2
        radius: 4 * deviceManager.scaleFactor
        width: Math.min(parent.width * 0.15, 35 * deviceManager.scaleFactor)
        height: width * 3/2
        Material.background: "#8f499c"

        property bool expanded: false

        /*
         *  @desc:  On button click, display popup
         */
        onClicked: {
            uiStackView.push(popUp)
        }


        Image {
            id: menuHandle
            anchors.centerIn: parent
            mipmap: true
            smooth: true
            width: height
            height: parent.height / 1.5
            source: "./Assets/Images/handle-vertical.png"
        }
        ColorOverlay {
            anchors.fill: menuHandle
            source: menuHandle
            color: "white"
        }
    }

    /*
     *  @desc:  Mouse area that allows to drag and move overview map area
     *          Enabled when menu toggle is one in PopUpPage.qml
     */
    MouseArea {
        id: dragArea
        anchors.fill: parent
        enabled: popUpContent.overviewMapUnlocked
        drag{
            target: parent
            smoothed: true
            minimumX: 0
            minimumY: 0
            maximumX: geoView.width - parent.width
            maximumY: geoView.height - parent.height
        }
    }

    /*
     *  @desc: Connect with root component so when orientation or screen size asjusts,
     *         overview map position will adjust
     */
    Connections {

        target: parent

        /*
         *  @desc:  On App width change call adjustOverviewPosition()
         */
        function onWidthChanged() {
            adjustOverviewPosition()
        }

        /*
         *  @desc:  On App height change call adjustOverviewPosition()
         */
        function onHeightChanged() {
            adjustOverviewPosition()
        }

        /*
         *  @desc:  Adjust the vertical and horizontal position of the overview map
         *          Offsets position based on if device has a notch, status bar, and/or
         *          page contains a header
         */
        function adjustOverviewPosition() {
            var relativeXPosition  = currentOverviewMapRelativeX * geoView.width
            var endXPosition = relativeXPosition + overviewMapBorder.width
            if(endXPosition >= geoView.width){
                overviewMapBorder.x = geoView.width - overviewMapBorder.width
            } else {
                overviewMapBorder.x = Math.max(relativeXPosition, deviceManager.iOSWidthOffset)
            }

            var relativeYPosition  = currentOverviewMapRelativeY * geoView.height
            var endYPosition = relativeYPosition + overviewMapBorder.height
            if(endYPosition >= geoView.height){
                overviewMapBorder.y = geoView.height - overviewMapBorder.height
            } else {
                if(parent.parent.parent.header && parent.parent.parent.header.height > 0){
                    overviewMapBorder.y = Math.max(relativeYPosition, 0)
                } else {

                    overviewMapBorder.y = Math.max(relativeYPosition, deviceManager.iOSHeightOffset)
                }
            }
        }
    }

    Controls.BasePageControl {
        id: popUp
        visible: false
        pageContentItem: OverviewMapSettingsPage {
            id: popUpContent
            onCloseSettingsPage: {
                uiStackView.pop()
            }
        }
    }
}
