/* Copyright 2019 Esri
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
import ArcGIS.AppFramework.Controls 1.0
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

    property double pointX: 44.975
    property double pointY: 34
    property double pointZ: 500

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
            SceneView {
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
                }

                // add a graphics overlay
                GraphicsOverlay {
                    id: graphicsOverlay
                    LayerSceneProperties {
                        surfacePlacement: Enums.SurfacePlacementAbsolute
                    }
                }

                Component.onCompleted: {
                    // set viewpoint to the specified camera
                    setViewpointCameraAndWait(camera);
                    addSymbols();
                }


                // create the camera to be used as the scene view's viewpoint
                Camera {
                    id: camera
                    location: Point {
                        x: 45
                        y: 34
                        z: 6000
                        spatialReference: SpatialReference.createWgs84()
                    }
                    heading: 0
                    pitch: 0
                    roll: 0
                }

                // listmodel to store the symbol colors and styles
                ListModel {
                    id: symbolModel

                    ListElement {
                        symbolStyle: Enums.SimpleMarkerSceneSymbolStyleCone
                        color: "red"
                    }
                    ListElement {
                        symbolStyle: Enums.SimpleMarkerSceneSymbolStyleCube
                        color: "white"
                    }
                    ListElement {
                        symbolStyle: Enums.SimpleMarkerSceneSymbolStyleCylinder
                        color: "purple"
                    }
                    ListElement {
                        symbolStyle: Enums.SimpleMarkerSceneSymbolStyleDiamond
                        color: "turquoise"
                    }
                    ListElement {
                        symbolStyle: Enums.SimpleMarkerSceneSymbolStyleSphere
                        color: "blue"
                    }
                    ListElement {
                        symbolStyle: Enums.SimpleMarkerSceneSymbolStyleTetrahedron
                        color: "yellow"
                    }
                }

                // function to dynamically create the graphics and add them to the graphics overlay
                function addSymbols() {
                    for (var i = 0; i < symbolModel.count; i++) {
                        var elem = symbolModel.get(i);

                        // create a simple marker scene symbol
                        var smss = ArcGISRuntimeEnvironment.createObject("SimpleMarkerSceneSymbol", {
                                                                             style: elem.symbolStyle,
                                                                             color: elem.color,
                                                                             width: 200,
                                                                             height: 200,
                                                                             depth: 200,
                                                                             anchorPosition: Enums.SceneSymbolAnchorPositionCenter
                                                                         });

                        smss.style = elem.symbolStyle;
                        // create a new point geometry
                        var point = ArcGISRuntimeEnvironment.createObject("Point", {
                                                                              x: pointX + 0.01 * i,
                                                                              y: pointY,
                                                                              z: pointZ,
                                                                              spatialReference: SpatialReference.createWgs84()
                                                                          });

                        // create a graphic using the point and the symbol
                        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {
                                                                                geometry: point,
                                                                                symbol: smss
                                                                            });

                        // add the graphic to the graphics overlay
                        graphicsOverlay.graphics.append(graphic);
                    }
                }
            }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

