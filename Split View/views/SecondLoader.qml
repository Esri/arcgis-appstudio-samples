/**********************************************************
Second loader contains scene that contains
a topographic base map. When user moves camera view,
it updates the current graphic marker symbol
position and sends the Viewpoint to the first loader item.
**********************************************************/

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.3
import QtQuick.Controls.Material.impl 2.12

import Esri.ArcGISRuntime 100.13

Item {
    id: secondLoaderItem

    signal updateCamera(real cameraX, real cameraY, real cameraZ)

    anchors.fill: parent
    SceneView {
        id:secondSceneView
        anchors.fill: parent

        // create a scene, which is a default property of scene view
        Scene {
            // add a basemap
            BasemapTopographic {}

            // set an initial viewpoint
            ViewpointCenter {
                id: secondViewCenter
                Point {
                    x: app.viewPointX
                    y: app.viewPointY
                    z: 0
                    spatialReference: Factory.SpatialReference.createWgs84()
                }
                targetScale: 62.013264927081764

                Camera {
                    id: camera
                    location: Point {
                        x: app.viewPointX
                        y: app.viewPointY
                        z: app.viewPointZ
                        spatialReference: Factory.SpatialReference.createWgs84()
                    }
                    heading: 0
                    pitch: 0
                    roll: 0
                }
            }
        }

        //When viewpoint is updated, send signal to right loader to update
        onViewpointChanged: {

            console.log("secondItem area is " + secondItem.itemArea)
            console.log("camera elevation is ")

            var itemArea = secondItem.itemArea;

            //Used to dynamically resize marker scene symbol
            var cameraElevation = secondSceneView.currentViewpointCamera.location.z;

            console.log("secondItem area is " + itemArea)
            console.log("camera elevation is " + cameraElevation)

            //Get current center viewpoint and send it to right scene
            var camX = secondSceneView.currentViewpointCenter.center.x
            var camY = secondSceneView.currentViewpointCenter.center.y
            var camZ = secondSceneView.currentViewpointCenter.center.z

            secondLoaderItem.updateCamera(camX, camY, camZ);

            //Update point marker on current scene
            //Create scene marker
            const simpleMarkerSceneSymbol = ArcGISRuntimeEnvironment.createObject("SimpleMarkerSceneSymbol", {
                                                                                      style: Enums.SimpleMarkerSceneSymbolStyleDiamond,
                                                                                      color: "#8f499c",
                                                                                      width: (cameraElevation / 20),
                                                                                      height: (cameraElevation / 20),
                                                                                      depth: (cameraElevation / 20),
                                                                                      anchorPosition: Enums.SceneSymbolAnchorPositionBottom
                                                                                  });

            //New marker point
            var newMarkerPoint = ArcGISRuntimeEnvironment.createObject("Point", {
                                                                           x: camX,
                                                                           y: camY,
                                                                           z: 0,
                                                                           spatialReference: Factory.SpatialReference.createWgs84()
                                                                       });

            //New graphic
            const graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {
                                                                      geometry: newMarkerPoint,
                                                                      symbol: simpleMarkerSceneSymbol
                                                                  });

            //Clear current graphic
            sceneGraphicsOverlay.graphics.clear();

            //Add new graphic to overlay
            sceneGraphicsOverlay.graphics.append(graphic);

        }

        //For adding point on scene view
        GraphicsOverlay {
            id: sceneGraphicsOverlay
            LayerSceneProperties {
                surfacePlacement: Enums.SurfacePlacementRelative
            }
        }

        //Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (secondSceneView.drawStatus === Enums.DrawStatusInProgress)
        }

        //Bottom tool tip note
        Pane {
            id: toolTip
            width: Math.min((parent.width - 2 * app.defaultMargin), app.maximumScreenWidth)
            anchors{
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 18 * app.scaleFactor + ( app.isIphoneX ? app.heightOffset + app.defaultMargin : 0 )
            }

            background: Rectangle {
                radius: 8 * app.scaleFactor
                color: "#8f499c"

                layer.enabled: true
                layer.effect: ElevationEffect {
                    elevation: 2
                }
            }

            Label {
                anchors.fill: parent
                font.pixelSize: 14 * app.scaleFactor
                font.bold: true
                color: "white"
                text: qsTr("Move the diamond using the %1 scene".arg(app.isLandscape ? "right" : "bottom"))
                wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Label.AlignLeft
            }
        }
    }
}



