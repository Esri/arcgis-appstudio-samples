/* Copyright 2021 Esri
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

            // Map view UI presentation at top
            MapView {
                id: mapView

                anchors.fill: parent
                wrapAroundMode: Enums.WrapAroundModeDisabled

                Map {
                    BasemapTopographic {}

                    // create the feature layer
                    FeatureLayer {
                        id: featureLayer

                        // feature table
                        ServiceFeatureTable {
                            id: featureTable
                            url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/PoolPermits/FeatureServer/0"
                        }
                    }

                    onLoadStatusChanged: {
                        if (loadStatus === Enums.LoadStatusLoaded) {
                            mapView.setViewpoint(viewPoint);
                        }
                    }
                }

                SimpleRenderer {
                    id: renderer

                    SimpleLineSymbol {
                        style: Enums.SimpleLineSymbolStyleSolid
                        color: "blue"
                        antiAlias: true
                        width: 2 * scaleFactor
                    }
                }

                ViewpointExtent {
                    id: viewPoint
                    extent: Envelope {
                        xMin: -13075816.4047166
                        yMin: 4014771.46954516
                        xMax: -13073005.6797177
                        yMax: 4016869.78617381
                        spatialReference: SpatialReference {
                            wkid: 102100
                        }
                    }
                }
            }

            Row {
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    margins: 20 * scaleFactor
                    //         bottomMargin: 25 * scaleFactor
                }
                spacing: 5

                // button to change renderer
                Button {
                    Material.background: "#8f499c"
                    Material.foreground: "white"
                    font.pixelSize: 14 * scaleFactor
                    text: "Change Renderer"
                    enabled: featureTable.loadStatus === Enums.LoadStatusLoaded
                    onClicked: {
                        featureLayer.renderer = renderer;
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

