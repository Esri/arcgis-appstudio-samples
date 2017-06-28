/* Copyright 2017 Esri
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
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1

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

            // Map view UI presentation at top
            // add a mapView component
            MapView {
                anchors.fill: parent

                // add map to the mapview
                Map {

                    // add the topographic basemap to the map
                    BasemapTopographic {}

                    // create feature layer using service feature table
                    FeatureLayer {
                        ServiceFeatureTable {
                            url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/USA/MapServer/2"
                        }

                        // override the renderer of the feature layer with a new unique value renderer
                        UniqueValueRenderer {
                            // set fields. Multiple fields can be set. In this sample, we only use one.
                            fieldNames: ["STATE_ABBR"]
                            defaultSymbol: SimpleFillSymbol {
                                style: Enums.SimpleFillSymbolStyleNull
                                color: "black"

                                SimpleLineSymbol {
                                    style: "SimpleLineSymbolStyleSolid"
                                    color: "grey"
                                    width: 2
                                }
                            }

                            // set value for California
                            UniqueValue {
                                label: "California"
                                description: "The State of California"
                                values: ["CA"]

                                SimpleFillSymbol {
                                    id: californiaFillSymbol
                                    style: Enums.SimpleFillSymbolStyleSolid
                                    color: "#ed9e84"

                                    SimpleLineSymbol {
                                        style: "SimpleLineSymbolStyleSolid"
                                        color: "#ed9e84"
                                        width: 2
                                    }
                                }
                            }

                            // set value for Arizona
                            UniqueValue {
                                label: "Arizona"
                                description: "The State of Arizona"
                                values: ["AZ"]

                                SimpleFillSymbol {
                                    id: arizonaFillSymbol
                                    style: Enums.SimpleFillSymbolStyleSolid
                                    color: "#6d5e51"

                                    SimpleLineSymbol {
                                        style: "SimpleLineSymbolStyleSolid"
                                        color: "#6d5e51"
                                        width: 2
                                    }
                                }
                            }

                            // set value for Nevada
                            UniqueValue {
                                label: "Nevada"
                                description: "The State of Nevada"
                                values: ["NV"]

                                SimpleFillSymbol {
                                    id: nevadaFillSymbol
                                    style: Enums.SimpleFillSymbolStyleSolid
                                    color: "#1e9577"

                                    SimpleLineSymbol {
                                        style: "SimpleLineSymbolStyleSolid"
                                        color: "#1e9577"
                                        width: 2
                                    }
                                }
                            }
                        }
                    }

                    // set initial viewpoint
                    ViewpointExtent {

                        Envelope {
                            xMin: -13893029.0
                            yMin: 3573174.0
                            xMax: -12038972.0
                            yMax: 5309823.0
                            spatialReference: SpatialReference.createWebMercator()
                        }
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

