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

    property bool busy: false
    property string message: ""
    property var facilities: []
    property var facilityParams: null

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

                Map {
                    BasemapStreets {}

                    initialViewpoint: ViewpointCenter {
                        Point {
                            x: -13041154
                            y: 3858170
                            spatialReference: SpatialReference.createWebMercator()
                        }
                        targetScale: 1e5
                    }

                    onLoadStatusChanged: {

                        createFacilities();
                        task.load();

                        function createFacilities() {
                            facilitiesOverlay.graphics.forEach(function(graphic) {
                                var facility = ArcGISRuntimeEnvironment.createObject("Facility", {geometry: graphic.geometry});
                                facilities.push(facility);
                            });
                        }
                    }
                }

                GraphicsOverlay {
                    id: facilitiesOverlay

                    renderer: SimpleRenderer {
                        symbol: PictureMarkerSymbol {
                            url: "http://static.arcgis.com/images/Symbols/SafetyHealth/Hospital.png"
                            height: 30
                            width: 30
                        }
                    }

                    Graphic {
                        geometry: Point {
                            x: -1.3042129900625112E7
                            y: 3860127.9479775648
                            spatialReference: SpatialReference.createWebMercator()
                        }
                    }

                    Graphic {
                        geometry: Point {
                            x: -1.3042129900625112E7
                            y: 3860127.9479775648
                            spatialReference: SpatialReference.createWebMercator()
                        }
                    }

                    Graphic {
                        geometry: Point {
                            x: -1.3042193400557665E7
                            y: 3862448.873041752
                            spatialReference: SpatialReference.createWebMercator()
                        }
                    }

                    Graphic {
                        geometry: Point {
                            x: -1.3046882875518233E7
                            y: 3862704.9896770366
                            spatialReference: SpatialReference.createWebMercator()
                        }
                    }

                    Graphic {
                        geometry: Point {
                            x: -1.3040539754780494E7
                            y: 3862924.5938606677
                            spatialReference: SpatialReference.createWebMercator()
                        }
                    }

                    Graphic {
                        geometry: Point {
                            x: -1.3042571225655518E7
                            y: 3858981.773018156
                            spatialReference: SpatialReference.createWebMercator()
                        }
                    }

                    Graphic {
                        geometry: Point {
                            x: -1.3039784633928463E7
                            y: 3856692.5980474586
                            spatialReference: SpatialReference.createWebMercator()
                        }
                    }

                    Graphic {
                        geometry: Point {
                            x: -1.3049023883956768E7
                            y: 3861993.789732541
                            spatialReference: SpatialReference.createWebMercator()
                        }
                    }
                }

                GraphicsOverlay {
                    id: resultsOverlay
                }

                onMouseClicked: {
                    if (busy === true)
                        return;

                    if (facilityParams === null)
                        return;

                    resultsOverlay.graphics.clear();

                    var incidentGraphic = ArcGISRuntimeEnvironment.createObject(
                                "Graphic", {geometry: mouse.mapPoint, symbol: incidentSymbol});
                    resultsOverlay.graphics.append(incidentGraphic);

                    solveRoute(mouse.mapPoint);

                    function solveRoute(incidentPoint) {
                        var incident = ArcGISRuntimeEnvironment.createObject("Incident", {geometry: incidentPoint});
                        facilityParams.setIncidents( [ incident ] );

                        busy = true;
                        message = "";
                        task.solveClosestFacility(facilityParams);
                    }
                }
            }

            SimpleMarkerSymbol {
                id: incidentSymbol
                style: "SimpleMarkerSymbolStyleCross"
                color: "black"
                size: 20
            }

            SimpleLineSymbol {
                id: routeSymbol
                style: "SimpleLineSymbolStyleSolid"
                color: "#8f499c"
                width: 2.0
            }

            ClosestFacilityTask {
                id: task
                url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/NetworkAnalysis/SanDiego/NAServer/ClosestFacility"

                onLoadStatusChanged: {
                    if (loadStatus !== Enums.LoadStatusLoaded)
                        return;

                    setupRouting();

                    function setupRouting() {
                        busy = true;
                        message = "";
                        task.createDefaultParameters();
                    }
                }

                onCreateDefaultParametersStatusChanged: {
                    if (createDefaultParametersStatus !== Enums.TaskStatusCompleted)
                        return;

                    busy = false;
                    facilityParams = createDefaultParametersResult;
                    facilityParams.setFacilities(facilities);
                }

                onSolveClosestFacilityStatusChanged: {
                    if (solveClosestFacilityStatus !== Enums.TaskStatusCompleted)
                        return;

                    busy = false;

                    if (solveClosestFacilityResult === null || solveClosestFacilityResult.error)
                        message = "Incident not within San Diego Area!";

                    var rankedList = solveClosestFacilityResult.rankedFacilityIndexes(0);
                    var closestFacilityIdx = rankedList[0];

                    var incidentIndex = 0; // 0 since there is just 1 incident at a time
                    var route = solveClosestFacilityResult.route(closestFacilityIdx, incidentIndex);

                    var routeGraphic = ArcGISRuntimeEnvironment.createObject(
                                "Graphic", { geometry: route.routeGeometry, symbol: routeSymbol});
                    resultsOverlay.graphics.append(routeGraphic);
                }

                onErrorChanged: message = error.message;
            }

            BusyIndicator {
                Material.accent: "#8f499c"
                anchors.centerIn: parent
                running: busy
            }

            MessageDialog {
                id: messageDialog
                title: "Route Error"
                text: message
                visible: text.length > 0
            }
        }
    }


    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

