/**********************************************************
First loader receives the second loader view point and positions
the graphic and camera based on it. The scene displays the
3d city buildings of Berlin, Germany.
**********************************************************/
import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.3

import Esri.ArcGISRuntime 100.13

Item {
    id: firstLoaderItem

    readonly property real distance: 300

    anchors.fill: parent

    //To set camera to view diamondPoint and doesn't allow
    //user interaction with camera
    OrbitGeoElementCameraController {
        id: diamondLocationCameraController
        targetGeoElement: sceneMarker
        cameraDistance: distance
        minCameraDistance: distance / 4
        maxCameraDistance: distance
    }

    SceneView {
        id:firstSceneView
        anchors.fill: parent

        // create a scene, which is a default property of scene view
        Scene {
            id:firstScene

            BasemapTopographic {}

            //! [add a scene service with ArcGISSceneLayer]
            ArcGISSceneLayer {
                url: "https://tiles.arcgis.com/tiles/P3ePLMYs2RVChkJx/arcgis/rest/services/Buildings_Berlin/SceneServer"
            }
            //! [add a scene service with ArcGISSceneLayer]

            //add a surface, which is a default property of scene
            Surface {
                navigationConstraint: Enums.NavigationConstraintStayAbove
                backgroundGrid: BackgroundGrid {
                    visible: false
                }
                // add an arcgis tiled elevation source...elevation source is a default property of surface
                ArcGISTiledElevationSource {
                    url: "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
                }
            }

            // set an initial viewpoint
            ViewpointCenter {
                id: secondViewCenter
                Point {
                    x: app.viewPointX
                    y: app.viewPointY
                    z: app.viewPointZ
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

        //For adding point on scene view
        GraphicsOverlay {
            id: sceneGraphicsOverlay
            LayerSceneProperties {
                surfacePlacement: Enums.SurfacePlacementRelative
            }
            Graphic {
                id: sceneMarker
                geometry: Point {
                    id: sceneMarkerPoint
                    x: app.viewPointX
                    y: app.viewPointY
                    z: 0
                    spatialReference: Factory.SpatialReference.createWgs84()
                }
                symbol: SimpleMarkerSceneSymbol {
                    style: Enums.SimpleMarkerSceneSymbolStyleDiamond
                    color: "#8f499c"
                    width: 15
                    height: 15
                    depth: 15
                    anchorPosition: Enums.SceneSymbolAnchorPositionBottom
                }
            }
        }

        //Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (firstSceneView.drawStatus === Enums.DrawStatusInProgress)
        }

        Component.onCompleted: {
            forceActiveFocus();
            //Set the cameraController to look at the diamond location and prevent interaction
            firstSceneView.cameraController = diamondLocationCameraController;
        }

        //Connect with second loader to receie the view point
        Connections {
            target: secondLoader.item
            //Receive second loader view point and update current viewpoint
            function onUpdateCamera(cameraX, cameraY, cameraZ){
                //Create scene marker
                const simpleMarkerSceneSymbol = ArcGISRuntimeEnvironment.createObject("SimpleMarkerSceneSymbol", {
                                                                                          style: Enums.SimpleMarkerSceneSymbolStyleDiamond,
                                                                                          color: "#8f499c",
                                                                                          width: 15,
                                                                                          height: 15,
                                                                                          depth: 15,
                                                                                          anchorPosition: Enums.SceneSymbolAnchorPositionBottom
                                                                                      });

                //New marker point
                var newMarkerPoint = ArcGISRuntimeEnvironment.createObject("Point", {
                                                                               x: cameraX,
                                                                               y: cameraY,
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
        }
    }
}
