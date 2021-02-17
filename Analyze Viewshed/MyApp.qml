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
import QtQuick.Dialogs 1.2

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

    property bool viewshedInProgress: false
    property GeoprocessingJob viewshedJob: null
    property string statusText: ""

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

                // Create map with topographic basemap and initial viewpoint
                Map {
                    BasemapTopographic {}

                    ViewpointCenter {
                        Point {
                            x: 6.84905317262762
                            y: 45.3790902612337
                            spatialReference: Factory.SpatialReference.createWgs84()
                        }
                        targetScale: 100000
                    }
                }

                // Create the graphics overlays for the input and output
                GraphicsOverlay {
                    id: inputOverlay

                    // Set the size and color properties for the simple renderer
                    SimpleRenderer {
                        SimpleMarkerSymbol {
                            color: "red"
                            style: Enums.SimpleMarkerSymbolStyleCircle
                            size: 12
                        }
                    }
                }

                GraphicsOverlay {
                    id: resultsOverlay

                    // Set the size and color properties for the simple renderer
                    SimpleRenderer {
                        SimpleFillSymbol {
                            color: Qt.rgba(0.88, 0.46, 0.16, 0.4)
                        }
                    }
                }

                // Set up signal handler for the mouse clicked signal
                onMouseClicked: {
                    // The geoprocessing task is still executing, don't do anything else (i.e. respond to
                    // more user taps) until the processing is complete.
                    if (viewshedInProgress)
                        return;

                    // Indicate that the geoprocessing is running
                    viewshedInProgress = true;

                    // Clear previous user click location and the viewshed geoprocessing task results
                    inputOverlay.graphics.clear();
                    resultsOverlay.graphics.clear();

                    // Create a marker graphic where the user clicked on the map and add it to the existing graphics overlay
                    var inputGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: mouse.mapPoint});
                    inputOverlay.graphics.append(inputGraphic);

                    // Execute the geoprocessing task
                    viewshedTask.calculateViewshed(mouse.mapPoint);
                }
            }

            // Create the GeoprocessingTask
            GeoprocessingTask {
                id: viewshedTask
                url: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/Elevation/ESRI_Elevation_World/GPServer/Viewshed"

                onErrorChanged: {
                    viewshedInProgress = false;
                    if (error)
                        showErrorDialog(error);
                }

                // function to caclulate the viewshed
                function calculateViewshed(location) {
                    // Create a new feature collection table based upon point geometries using the current map view spatial reference
                    var inputFeatures = ArcGISRuntimeEnvironment.createObject("FeatureCollectionTable", {
                                                                                  geometryType: Enums.GeometryTypePoint,
                                                                                  spatialReference: Factory.SpatialReference.createWebMercator()
                                                                              });

                    // Create a new feature from the feature collection table. It will not have a coordinate location (x,y) yet
                    var inputFeature = inputFeatures.createFeature();

                    // Assign a physical location to the new point feature based upon where the user clicked on the map view
                    inputFeature.geometry = location;

                    // connect to addFeature status changed signal
                    inputFeatures.addFeatureStatusChanged.connect(function() {
                        if (inputFeatures.addFeatureStatus === Enums.TaskStatusCompleted) {
                            // Create the parameters that are passed to the used geoprocessing task
                            var viewshedParameters = ArcGISRuntimeEnvironment.createObject("GeoprocessingParameters", {
                                                                                               executionType: Enums.GeoprocessingExecutionTypeSynchronousExecute
                                                                                           });

                            // Request the output features to use the same SpatialReference as the map view
                            viewshedParameters.outputSpatialReference = Factory.SpatialReference.createWebMercator();

                            // Add an input location to the geoprocessing parameters
                            var inputs = {};
                            inputs["Input_Observation_Point"] = ArcGISRuntimeEnvironment.createObject("GeoprocessingFeatures", { features: inputFeatures });
                            viewshedParameters.inputs = inputs;

                            // Create the job that handles the communication between the application and the geoprocessing task
                            viewshedJob = viewshedTask.createJob(viewshedParameters);

                            // Create signal handler for the job
                            viewshedJob.jobStatusChanged.connect(viewshedJobHandler);

                            // start the job
                            viewshedJob.start();
                        }
                    });

                    // Add the new feature with (x,y) location to the feature collection table
                    inputFeatures.addFeature(inputFeature);
                }

                // function to handle the job as it changes its status
                function viewshedJobHandler() {
                    if (viewshedJob.jobStatus === Enums.JobStatusFailed) {
                        showErrorDialog(viewshedJob.error);
                        viewshedInProgress = false;
                        statusText = "Job failed.";
                    } else if (viewshedJob.jobStatus === Enums.JobStatusStarted) {
                        viewshedInProgress = true;
                        statusText = "Job in progress...";
                    } else if (viewshedJob.jobStatus === Enums.JobStatusPaused) {
                        viewshedInProgress = false;
                        statusText = "Job paused...";
                    } else if (viewshedJob.jobStatus === Enums.JobStatusSucceeded) {
                        // handle the results
                        processResults(viewshedJob.result);
                        viewshedInProgress = false;
                        statusText = "Job succeeded.";
                    }
                }

                // function to handle the results from the GeoprocessingJob
                function processResults(result) {
                    // Get the results from the outputs as GeoprocessingFeatures
                    var viewshedResultFeatures = result.outputs["Viewshed_Result"];

                    // Add all the features from the result feature set as a graphics to the map
                    var viewshedAreas = viewshedResultFeatures.features.iterator;
                    while (viewshedAreas.hasNext) {
                        var feat = viewshedAreas.next();
                        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {
                                                                                geometry: feat.geometry
                                                                            });
                        resultsOverlay.graphics.append(graphic);
                    }
                }

                function showErrorDialog(error) {
                    messageDialog.title = "Error";
                    messageDialog.text = "Executing geoprocessing failed.";
                    messageDialog.detailedText = error ? error.message : "Unknown error";
                    messageDialog.open();
                }
            }

            // Create rectangle to display the status
            Rectangle {
                anchors {
                    margins: -10 * scaleFactor
                    fill: statusColumn
                }
                color: "lightgrey"
                radius: 5
                border.color: "black"
                opacity: 0.85
            }

            Column {
                id: statusColumn
                anchors {
                    right: parent.right
                    top: parent.top
                    margins: 20 * scaleFactor
                }

                Text {
                    anchors.margins: 5 * scaleFactor
                    visible: !viewshedInProgress
                    text: "Click map to execute viewshed analysis"
                    font.pixelSize: 12 * scaleFactor
                }

                Row {
                    anchors.margins: 5 * scaleFactor
                    visible: viewshedInProgress
                    spacing: 10 * scaleFactor

                    BusyIndicator {
                        Material.accent:"#8f499c"
                        anchors.verticalCenter: parent.verticalCenter
                        width: 30 * scaleFactor
                        height: width
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: statusText
                        font.pixelSize: 12 * scaleFactor
                    }
                }
            }

            // Dialog to display errors
            MessageDialog {
                id: messageDialog
                title: "Error"
                text: "Executing geoprocessing failed."
            }

        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

