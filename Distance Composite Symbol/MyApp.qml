/* Copyright 2020 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.2

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    property string dataPath:  AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data")

    property string inputdata: "SkyCrane.lwo"
    property string outputdata: dataPath + "/" + inputdata

    function copyLocalData(input, output) {
        var resourceFolder = AppFramework.fileFolder(app.folder.folder("data").path);
        AppFramework.userHomeFolder.makePath(dataPath);
        resourceFolder.copyFile(input, output);
        return output
    }


    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle{
            anchors.top:header.bottom
            // Create a scene view
            SceneView {
                id: sceneView
                anchors.fill: parent

                // create a scene...scene is a default property of sceneview
                // and thus will get added to the sceneview
                Scene {
                    // add a basemap
                    BasemapImagery {}

                    // add a surface...surface is a default property of scene
                    Surface {
                        // add an arcgis tiled elevation source...elevation source is a default property of surface
                        ArcGISTiledElevationSource {
                            url: "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
                        }
                    }

                    onLoadStatusChanged: {
                        if (loadStatus === Enums.LoadStatusLoaded) {
                            // create a graphic using the composite symbol
                            var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {
                                                                                    geometry: point,
                                                                                    symbol: distanceCompositeSceneSymbol
                                                                                });
                            // add the graphic to the graphics overlay
                            graphicsOverlay.graphics.append(graphic);
                        }
                    }
                }

                Component.onCompleted: {
                    // set viewpoint to the specified camera
                    setViewpointCameraAndWait(camera)
                }

                GraphicsOverlay {
                    id: graphicsOverlay

                    LayerSceneProperties {
                        surfacePlacement: Enums.SurfacePlacementRelative
                    }
                }
            }

            Point {
                id: point
                x: -2.708471
                y: 56.096575
                z: 5000
                spatialReference: SpatialReference.createWgs84()
            }

            // create the camera to be used as the scene view's viewpoint
            Camera {
                id: camera
                location: point
                distance: 1500
                heading: 0
                pitch: 80.0
                roll: 0
            }

            //! [create a distance composite scene symbol]
            DistanceCompositeSceneSymbol {
                id: distanceCompositeSceneSymbol

                // create a distance symbol range with a model scene symbol
                DistanceSymbolRange {
                    minDistance: 0
                    maxDistance: 999

                    //! [model scene symbol]
                    ModelSceneSymbol {
                        id: mms
                        url:AppFramework.resolvedPathUrl(copyLocalData(inputdata, outputdata))
                        scale: 0.01
                        heading: 180
                    }
                    //! [model scene symbol]
                }

                // create a distance symbol range with a simple marker scene symbol
                DistanceSymbolRange {
                    minDistance: 1000
                    maxDistance: 1999

                    //! [simple marker scene symbol]
                    SimpleMarkerSceneSymbol {
                        style: Enums.SimpleMarkerSceneSymbolStyleCone
                        color: "white"
                        height: 75
                        width: 75
                        depth: 75
                    }
                    //! [simple marker scene symbol]
                }

                // create a distance symbol range with a simple marker symbol
                DistanceSymbolRange {
                    minDistance: 2000
                    maxDistance: 0

                    SimpleMarkerSymbol {
                        style: Enums.SimpleMarkerSymbolStyleCircle
                        color: "red"
                        size: 10
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
                visible: (sceneView.drawStatus === Enums.DrawStatusInProgress)
            }
        }
    }


    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

