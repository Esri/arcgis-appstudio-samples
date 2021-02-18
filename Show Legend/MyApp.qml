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

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

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
            MapView{
                id:mapView
                anchors.fill: parent

                // Nest the Map as a child of the MapView
                Map {
                    id: map
                    // automatically fetch the legend infos for all operational layers
                    autoFetchLegendInfos: true

                    // Nest the Basemap to add it as the Map's Basemap
                    BasemapTopographic {}

                    // Add a tiled layer as an operational layer
                    ArcGISTiledLayer {
                        id: tiledLayer
                        url: "http://services.arcgisonline.com/ArcGIS/rest/services/Specialty/Soil_Survey_Map/MapServer"
                    }

                    // Add a map image layer as an operational layer
                    ArcGISMapImageLayer {
                        id: mapImageLayer
                        url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Census/MapServer"
                    }

                    // Add a feature layer as an operational layer
                    FeatureLayer {
                        id: featureLayer
                        featureTable: ServiceFeatureTable {
                            url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Recreation/FeatureServer/0"
                        }
                    }

                    //  Set the initial viewpoint
                    initialViewpoint: ViewpointCenter {
                        center: Point {
                            x: -11e6
                            y: 6e6
                            spatialReference: SpatialReference {wkid: 102100}
                        }
                        targetScale: 9e7
                    }
                }

                // Busy Indicator
                BusyIndicator {
                    id:mapDrawingWindow
                    anchors.centerIn: parent
                    height: 48 * scaleFactor
                    width: height
                    running: true
                    Material.accent:"#8f499c"
                    visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
                }

                // Create outter rectangle for the legend
                Rectangle {
                    id: legendRect
                    anchors {
                        margins: 10 * scaleFactor
                        left: parent.left
                        top: mapView.top
                    }
                    property bool expanded: true
                    height: app.height/2 - 30 * scaleFactor
                    width: 175 * scaleFactor
                    color: "lightgrey"
                    opacity: 0.95
                    radius: 10
                    clip: true
                    border {
                        color: "darkgrey"
                        width: 1
                    }

                    // Animate the expand and collapse of the legend
                    Behavior on height {
                        SpringAnimation {
                            spring: 3
                            damping: .8
                        }
                    }

                    // Catch mouse signals so they don't propagate to the map
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mouse.accepted = true
                        onWheel: wheel.accepted = true
                    }

                    // Create UI for the user to select the layer to display
                    Column {
                        anchors {
                            fill: parent
                            margins: 10 * scaleFactor
                        }
                        spacing: 2 * scaleFactor

                        Row {
                            spacing: 55 * scaleFactor

                            Text {
                                text: qsTr("Legend")
                                font {
                                    pixelSize: 18 * scaleFactor
                                    bold: true
                                }
                            }

                            // Legend icon to allow expanding and collapsing
                            Image {
                                source: legendRect.expanded ? "./assets/ic_menu_legendpopover_light_d.png" : "./assets/ic_menu_legendpopover_light.png"
                                width: 28 * scaleFactor
                                height: width

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (legendRect.expanded) {
                                            legendRect.height = 40 * scaleFactor;
                                            legendRect.expanded = false;
                                        } else {
                                            legendRect.height = 200 * scaleFactor;
                                            legendRect.expanded = true;
                                        }
                                    }
                                }
                            }
                        }

                        // Create a list view to display the legend
                        ListView {
                            id: legendListView
                            anchors.margins: 10 * scaleFactor
                            width: 165 * scaleFactor
                            height: app.height/2 - 55 * scaleFactor
                            clip: true
                            model: map.legendInfos

                            // Create delegate to display the name with an image
                            delegate: Item {
                                width: parent.width
                                height: 35 * scaleFactor
                                clip: true

                                Row {
                                    spacing: 10

                                    Image {
                                        width: symbolWidth
                                        height: symbolHeight
                                        source: symbolUrl
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        width: 125 * scaleFactor
                                        text: name
                                        wrapMode: Text.WordWrap
                                        font.pixelSize: 12 * scaleFactor
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            section {
                                property: "layerName"
                                criteria: ViewSection.FullString
                                labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels
                                delegate: Rectangle {
                                    width: 180 * scaleFactor
                                    height: childrenRect.height
                                    color: "lightsteelblue"

                                    Text {
                                        text: section
                                        font.bold: true
                                        font.pixelSize: 13 * scaleFactor
                                    }
                                }
                            }
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


