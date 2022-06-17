import QtQuick 2.3
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Controls.Material.impl 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15

import Esri.ArcGISRuntime 100.13

import '../controls' as Controls
import '../utility'

Rectangle {
    id: rootRectangle

    property bool ready: mapView.map.loadStatus === Enums.LoadStatusLoaded
    property var selectedFeature: null
    property var popupDef:null
    property real curIndx: -1
    property int mouseX: 0
    property int mouseY: 0
    property PopupManager popupManager: null
    property var popupManagers: []
    property string popupTitle: ""
    property var htmlRichText: null
    property Feature hiddenFeature: null
    property FeatureLayer hiddenFeaturelayer: null

    ListModel{
        id:popupListModel
    }

    clip: true
    anchors.fill: parent

    PointBuilder {
        id: pointBuilder
    }

    PointBuilder {
        id: initialPoint
    }


    MapView {
        id: mapView
        anchors.fill: parent

        Component.onCompleted: {
            // Set the focus on MapView to initially enable keyboard navigation
            forceActiveFocus()
        }

        Map {
            initUrl: "http://melbournedev.maps.arcgis.com/sharing/rest/content/items/eeb05b10a4d948c792bb883df8b021b3"
        }

        GraphicsOverlay {
            id: graphicsOverlay
        }


        PictureMarkerSymbol {
            id: markerSymbol
            url:"../assets/blue_symbol.png"
            width: 64.0
            height: 64.0
            offsetY: height/4
        }

        //On mouse click on Map View,
        //reset feature layer graphics,
        //identify layers under the moust click coordinates,
        //Get the results and return popups only
        onMouseClicked: {
            if(!ready){
                return
            }
            resetFeatureLayerGraphics()

            identifyLayersWithMouse(mouse)
        }

        //When layers are identified
        onIdentifyLayersStatusChanged: {
            //Once the task is complete, do stuff
            if(identifyLayersStatus === Enums.TaskStatusCompleted) {
                //Clear any graphics and clear popup manager list
                //when a new layer is identified (New selection made)
                popupListModel.clear()
                popupManagers = []


                //If there are no results then return out
                if(identifyLayersResults && identifyLayersResults.length === 0){
                    console.log("No results...")
                    closePopup()
                    return
                } else if(identifyLayersResults && identifyLayersResults.length > 0) {
                    //Go through all layers identified from FeatureLayer or MapServiceLayer
                    for(let i = 0; i < identifyLayersResults.length; i++) {
                        //Iterate through each layer result and check for sublayers
                        var identifyLayerResult = identifyLayersResults[i]

                        //Iterate through features in feature layer results
                        for(let j = 0; j < identifyLayerResult.popups.length; j++){

                            //Get popup from result and set definition from popup
                            var popup = identifyLayerResult.popups[j]
                            var popupDef = popup.popupDefinition

                            //Get feature, feature table, and feature layer
                            selectedFeature = popup.geoElement
                            var featureTable = selectedFeature.featureTable
                            var featureLayer = featureTable.layer

                            //FIND Feature geometry attributes
                            var featureGeometry = selectedFeature.geometry

                            //Change viewpoint
                            updateViewpointCenter(featureGeometry)

                            //place marker on at feature location
                            setMarkerSymbol(featureLayer, selectedFeature,featureGeometry)

                            popupDef = featureTable.layer.popupDefinition

                            //Create a popup definition that a popup will contain
                            if(!popupDef) {
                                popupDef = ArcGISRuntimeEnvironment.createObject("PopupDefinition", {
                                                                                     initGeoElement: selectedFeature
                                                                                 })
                            }
                            //Create a popup object that a popup manager will manage
                            if(!popup){
                                popup = ArcGISRuntimeEnvironment.createObject("Popup", {
                                                                                  initGeoElement: selectedFeature,
                                                                                  initPopupDefinition: popupDef
                                                                              })
                            }

                            //Create a popup manager for the popup and add to the list for tracking
                            popupManager = ArcGISRuntimeEnvironment.createObject("PopupManager", {
                                                                                     popup: popup
                                                                                 })
                            popupManager.objectName = featureLayer.name
                            popupManagers.push(popupManager)

                            //Get expression from definition
                            var expressions = popupDef.expressions

                            //If there are expressions, evaluate them
                            if(expressions) {
                                popupManager.evaluateExpressions()
                            } else {
                                console.log("2. No expressions found")
                            }
                        }
                    }
                }
            }
        }




        Connections {
            target: popupManager

            //When popup manager expressions are evaluated, call populateModel method
            function onEvaluateExpressionsStatusChanged() {
                if(popupManager.evaluateExpressionsStatus === Enums.TaskStatusCompleted){
                    if(popupManager.evaluateExpressionsStatus === Enums.TaskStatusCompleted){
                        populateModel()
                    }
                }
            }

            //Function for creating model to use for displaying data
            function populateModel() {
                for(let w = 0; w < popupManagers.length; w++) {
                    if(popupManagers[w].showCustomHtmlDescription){
                        //Get the custom html from the popup and go through utility to better support rich text.
                        var customHtml = popupManagers[w].customHtmlDescription
                        htmlRichText = utilityFunctions.getHtmlSupportedByRichText(customHtml, expressionPane.width)
                        popupTitle = popupManagers[w].popup.title
                        expressionPane.visible = true
                        switchBtn.visible = false
                        break
                    } else {
                        popupTitle = "No arcade expressions to display"
                        htmlRichText = ""
                        expressionPane.visible = false
                        switchBtn.visible = true
                    }
                }
            }
        }

        //Popup pane to display expression. Adjusts position and size based on screen size
        Pane {
            id: expressionPane
            property bool expanded: true
            property real mouseChanged: 0.0
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: !isSmallScreen ? 15 : 0
            anchors.bottomMargin: !isSmallScreen ? 30 : 0
            //Size will dynamically adjust based on screen size
            height: !expanded ? 75 - mouseChanged: (isSmallScreen && parent.height >= 450 ? (parent.height * 0.4) : parent.height - 45) - mouseChanged
            width: isSmallScreen ? parent.width : (parent.width <= 800 ? parent.width * 0.45 : 360)
            visible: false
            background: Rectangle {
                radius: 6
            }
            Column {
                anchors.fill: parent
                spacing: 2
                Item {
                    id: expander
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 20
                    height: 20
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 35
                        height: 5
                        color: "lightgrey"
                        radius: 10
                    }
                }
                //Display title in popup
                Rectangle {
                    width: parent.width
                    height: 40
                    color: "transparent"
                    Text {
                        font.pixelSize: 16
                        text: popupTitle
                    }
                }
                //Display html rich text
                Rectangle {
                    width: parent.width
                    height: parent.height * 0.75
                    color: "transparent"
                    visible: expressionPane.expanded ? true : false
                    Text {
                        anchors.fill: parent
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                        text: htmlRichText
                    }
                }

            }

            //Area used for expanding and shrinking pane with a click/press or swipe
            MouseArea {
                anchors.fill: parent
                property bool held: false
                property real mouseYStart
                enabled: expressionPane.visible
                onPressAndHold: {
                    held = true
                    var relativeMouse = mapToItem(mainPage.contentItem, mouse.x, mouse.y)
                    mouseYStart = relativeMouse.y
                }
                onMouseYChanged: {
                    if(held){
                        var relativeMouse = mapToItem(mainPage.contentItem, mouse.x, mouse.y)
                        var diffInMouse = relativeMouse.y - mouseYStart
                        expressionPane.mouseChanged = diffInMouse
                    }
                }
                onReleased: {
                    held = false
                    if(expressionPane.mouseChanged < -25) {
                        expressionPane.expanded = true
                    } else if (expressionPane.mouseChanged > 25) {
                        expressionPane.expanded = false
                    } else if (expressionPane.mouseChanged === 0) {
                        expressionPane.expanded = !expressionPane.expanded
                    }
                    expressionPane.mouseChanged = 0.0
                }
            }
        }

        /*************Functions used within MapView**************/

        //Updates the viepoint center based on the feature geometry provided
        function updateViewpointCenter(featureGeometry){
            if(featureGeometry.json.x && featureGeometry.json.y){
                pointBuilder.setXY(featureGeometry.json.x, featureGeometry.json.y)
                mapView.setViewpointCenter(pointBuilder.geometry)
            }
        }


        //Sets a marker symbol on the feature layer, where the selected feature is
        function setMarkerSymbol(featureLayer, selectedFeature, featureGeometry){

            if(featureGeometry.json.x && featureGeometry.json.y){

                featureLayer.setFeatureVisible(selectedFeature, false)
                hiddenFeature = selectedFeature
                hiddenFeaturelayer = featureLayer

                pointBuilder.setXY(featureGeometry.json.x, featureGeometry.json.y)
                var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {
                                                                        geometry: pointBuilder.geometry,
                                                                        symbol: markerSymbol,
                                                                    })
                graphicsOverlay.graphics.append(graphic)
            }
        }

        //Removes marker symbols and if a feature is hidden, make it visible again
        function resetFeatureLayerGraphics(){
            if(hiddenFeature && hiddenFeaturelayer){
                hiddenFeaturelayer.setFeatureVisible(hiddenFeature, true)
            }
            graphicsOverlay.graphics.clear()
        }


        //Based on mouse click, identify layers
        function identifyLayersWithMouse(mouse){
            var tolerance = 10
            var returnPopupsOnly = true
            var maximumResults = 5
            mapView.identifyLayersWithMaxResults(mouse.x, mouse.y, tolerance, returnPopupsOnly, maximumResults)
        }


        //Get utility functions for creating proper rich text html
        UtilityFunctions{
            id:utilityFunctions
        }

    }

    //Close popup and display floating action button
    function closePopup() {
        mapView.setViewpointCenter(initialPoint.geometry)
        expressionPane.visible = false
        switchBtn.visible = true
    }

}

