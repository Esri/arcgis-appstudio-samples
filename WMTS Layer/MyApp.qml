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


    property url wmtsServiceUrl: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/WorldTimeZones/MapServer/WMTS"
    property WmtsService service;

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
            MapView {
                id: mapView
                anchors.fill: parent

                Component.onCompleted: createWmtsLayer();


                function createWmtsLayer() {
                    // create the service
                    service = ArcGISRuntimeEnvironment.createObject("WmtsService", { url: wmtsServiceUrl });

                    // connect to loadStatusChanged signal of the service
                    service.loadStatusChanged.connect(function() {
                        if (service.loadStatus === Enums.LoadStatusLoaded) {
                            // get the layer info list
                            var serviceInfo = service.serviceInfo;
                            var layerInfos = serviceInfo.layerInfos;
                            // get the first layer id from the list
                            var layerId = layerInfos[0].wmtsLayerId;
                            // create WMTS layer
                            var wmtsLayer = ArcGISRuntimeEnvironment.createObject("WmtsLayer", {
                                                                                      url: wmtsServiceUrl,
                                                                                      layerId: layerId
                                                                                  });
                            // create a basemap from the layer
                            var basemap = ArcGISRuntimeEnvironment.createObject("Basemap");
                            basemap.baseLayers.append(wmtsLayer);
                            // create a map
                            var map = ArcGISRuntimeEnvironment.createObject("Map", {
                                                                                basemap: basemap
                                                                            });
                            // set the map on the mapview
                            mapView.map = map;
                        }
                    });

                    // load the service
                    service.load();
                }
                //Busy Indicator
                BusyIndicator {
                    anchors.centerIn: parent
                    height: 48 * scaleFactor
                    width: height
                    running: true
                    Material.accent:"#8f499c"
                    visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
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

