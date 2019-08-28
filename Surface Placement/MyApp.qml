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
            // Add a scene view
            SceneView {
                id: sceneView
                anchors.fill: parent

                // Add a scene with the imagery basemap and world elevation surface
                Scene {
                    BasemapImagery {}

                    Surface {
                        ArcGISTiledElevationSource {
                            url: "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
                        }
                    }

                    // set an initial viewpoint
                    ViewpointCenter {
                        Point {
                            x: -4.04
                            y: 53.04
                            z: 1300
                            spatialReference: SpatialReference.createWgs84()
                        }
                        targetScale: 62.013264927081764

                        Camera {
                            id: camera
                            location: Point {
                                x: -4.04
                                y: 53.04
                                z: 1300
                                spatialReference: SpatialReference.createWgs84()
                            }
                            heading: 0
                            pitch: 90.0
                            roll: 0
                        }
                    }
                }

                // Graphics overlay with draped surface placement
                GraphicsOverlay {
                    id: drapedOverlay
                    sceneProperties.surfacePlacement: Enums.SurfacePlacementDraped

                    // Graphics will be draped on the surface of the scene
                    Graphic {
                        geometry: point

                        SimpleMarkerSymbol {
                            color: "white"
                            style: Enums.SimpleMarkerSymbolStyleCircle
                            size: 20
                        }
                    }

                    Graphic {
                        geometry: point

                        TextSymbol {
                            size: 20
                            text: "DRAPED"
                            color: "white"
                            horizontalAlignment: Enums.HorizontalAlignmentLeft
                            verticalAlignment: Enums.VerticalAlignmentMiddle
                            offsetX: 20
                        }
                    }
                }

                // Graphics overlay with relative surface placement
                GraphicsOverlay {
                    id: relativeOverlay
                    sceneProperties.surfacePlacement: Enums.SurfacePlacementRelative

                    // Graphics will be placed at z value relative to the surface
                    Graphic {
                        geometry: point

                        SimpleMarkerSymbol {
                            color: "white"
                            style: Enums.SimpleMarkerSymbolStyleCircle
                            size: 20
                        }
                    }

                    Graphic {
                        geometry: point

                        TextSymbol {
                            size: 20
                            text: "RELATIVE"
                            color: "white"
                            horizontalAlignment: Enums.HorizontalAlignmentLeft
                            verticalAlignment: Enums.VerticalAlignmentMiddle
                            offsetX: 20
                        }
                    }
                }

                // Graphics overlay with absolute surface placement
                GraphicsOverlay {
                    id: absoluteOverlay
                    sceneProperties.surfacePlacement: Enums.SurfacePlacementAbsolute

                    // Graphics will be placed at absolute z value
                    Graphic {
                        geometry: point

                        SimpleMarkerSymbol {
                            color: "white"
                            style: Enums.SimpleMarkerSymbolStyleCircle
                            size: 20
                        }
                    }

                    Graphic {
                        geometry: point

                        TextSymbol {
                            size: 20
                            text: "ABSOLUTE"
                            color: "white"
                            horizontalAlignment: Enums.HorizontalAlignmentLeft
                            verticalAlignment: Enums.VerticalAlignmentMiddle
                            offsetX: 20
                        }
                    }
                }
            }

            // create a point with a z value of 1000
            Point {
                id: point
                x: -4.04
                y: 53.06
                z: 1000
                spatialReference: SpatialReference.createWgs84()
            }
        }
    }
    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

