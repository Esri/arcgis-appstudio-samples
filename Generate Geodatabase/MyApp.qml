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
    Material.accent: "#8f499c"
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    property url outputGdb: AppFramework.temporaryFolder.url + "/WildfireQml_%1.geodatabase".arg(new Date().getTime().toString())
    property string featureServiceUrl: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Sync/WildfireSync/FeatureServer"
    property Envelope generateExtent: null
    property var generateLayerOptions: []
    property string statusText: ""

    property string dataPath:  AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data")

    property string inputdata: "SanFrancisco.tpk"
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

            // Map view UI presentation at top
            MapView {
                id: mapView
                anchors.fill: parent

                Map {
                    id: map

                    //! [display tiled layer from tile cache]
                    Basemap {
                        ArcGISTiledLayer {
                            TileCache {
                                path: AppFramework.resolvedPathUrl(copyLocalData(inputdata, outputdata))
                            }
                        }
                    }
                    //! [display tiled layer from tile cache]

                    onLoadStatusChanged: {
                        if (loadStatus === Enums.LoadStatusLoaded) {
                            // add the feature layers
                            geodatabaseSyncTask.load();
                        }
                    }

                    // set an initial viewpoint
                    ViewpointExtent {
                        Envelope {
                            xMax: -122.43843016064368
                            xMin: -122.50017717584528
                            yMax: 37.81638388695054
                            yMin: 37.745000054347535
                            spatialReference: Factory.SpatialReference.createWgs84()
                        }
                    }
                }
            }

            //! [Features GenerateGeodatabase Create GeodatabaseSyncTask]
            // create the GeodatabaseSyncTask to generate the local geodatabase
            GeodatabaseSyncTask {
                id: geodatabaseSyncTask
                url: featureServiceUrl
                property var generateJob

                onLoadStatusChanged: {
                    if (loadStatus === Enums.LoadStatusLoaded) {
                        var idInfos = featureServiceInfo.layerInfos;
                        for (var i = 0; i < idInfos.length; i++) {
                            // add the layer to the map
                            var featureLayerUrl = featureServiceInfo.url + "/" + idInfos[i].infoId;
                            var serviceFeatureTable = ArcGISRuntimeEnvironment.createObject("ServiceFeatureTable", {url: featureLayerUrl});
                            var featureLayer = ArcGISRuntimeEnvironment.createObject("FeatureLayer", {featureTable: serviceFeatureTable});
                            map.operationalLayers.append(featureLayer);

                            // add a new GenerateLayerOption to array for use in the GenerateGeodatabaseParameters
                            var layerOption = ArcGISRuntimeEnvironment.createObject("GenerateLayerOption", {layerId: idInfos[i].infoId});
                            generateLayerOptions.push(layerOption);
                            generateParameters.layerOptions = generateLayerOptions;
                        }
                    }
                }

                function executeGenerate() {
                    // execute the asynchronous task and obtain the job
                    generateJob = generateGeodatabase(generateParameters, outputGdb);

                    // check if the job is valid
                    if (generateJob) {

                        // show the generate window
                        generateWindow.visible = true;

                        // connect to the job's status changed signal to know once it is done
                        generateJob.jobStatusChanged.connect(updateGenerateJobStatus);

                        // start the job
                        generateJob.start();
                    } else {
                        // a valid job was not obtained, so show an error
                        generateWindow.visible = true;
                        statusText = "Generate failed";
                        generateWindow.hideWindow(5000);
                    }
                }

                function updateGenerateJobStatus() {
                    switch(generateJob.jobStatus) {
                    case Enums.JobStatusFailed:
                        statusText = "Generate failed";
                        generateWindow.hideWindow(5000);
                        break;
                    case Enums.JobStatusNotStarted:
                        statusText = "Job not started";
                        break;
                    case Enums.JobStatusPaused:
                        statusText = "Job paused";
                        break;
                    case Enums.JobStatusStarted:
                        statusText = "In progress...";
                        break;
                    case Enums.JobStatusSucceeded:
                        statusText = "Complete";
                        generateWindow.hideWindow(1500);
                        displayLayersFromGeodatabase(generateJob.geodatabase);
                        break;
                    default:
                        break;
                    }
                }

                function displayLayersFromGeodatabase(geodatabase) {
                    // remove the original online feature layers
                    map.operationalLayers.clear();

                    // load the geodatabase to access the feature tables
                    geodatabase.loadStatusChanged.connect(function() {
                        if (geodatabase.loadStatus === Enums.LoadStatusLoaded) {
                            // create a feature layer from each feature table, and add to the map
                            for (var i = 0; i < geodatabase.geodatabaseFeatureTables.length; i++) {
                                var featureTable = geodatabase.geodatabaseFeatureTables[i];
                                var featureLayer = ArcGISRuntimeEnvironment.createObject("FeatureLayer");
                                featureLayer.featureTable = featureTable;
                                map.operationalLayers.append(featureLayer);
                            }

                            // unregister geodatabase since there will be no edits uploaded
                            geodatabaseSyncTask.unregisterGeodatabase(geodatabase);

                            // hide the extent rectangle and download button
                            extentRectangle.visible = false;
                            downloadButton.visible = false;
                        }
                    });
                    geodatabase.load();
                }

                Component.onDestruction: {
                    generateJob.jobStatusChanged.disconnect(updateGenerateJobStatus);
                }
            }

            // create the generate geodatabase parameters
            GenerateGeodatabaseParameters {
                id: generateParameters
                extent: generateExtent
                outSpatialReference: Factory.SpatialReference.createWebMercator()
                returnAttachments: false
            }
            //! [Features GenerateGeodatabase Create GeodatabaseSyncTask]

            // create an extent rectangle for the output geodatabase
            Rectangle {
                id: extentRectangle
                anchors.centerIn: parent
                width: parent.width - (50 * scaleFactor)
                height: parent.height - (125 * scaleFactor)
                color: "transparent"
                border {
                    color: "red"
                    width: 3 * scaleFactor
                }
            }

            // Create the download button to generate geodatabase
            Rectangle {
                id: downloadButton
                property bool pressed: false
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: 23 * scaleFactor
                }

                width: 200 * scaleFactor
                height: 35 * scaleFactor
                color: pressed ? "#959595" : "#D6D6D6"
                radius: 8
                border {
                    color: "#585858"
                    width: 1 * scaleFactor
                }

                Row {
                    anchors.fill: parent
                    spacing: 5
                    Image {
                        width: 38 * scaleFactor
                        height: width
                        source: "./data/download.png"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Generate Geodatabase"
                        font.pixelSize: 14 * scaleFactor
                        color: "#474747"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: downloadButton.pressed = true
                    onReleased: downloadButton.pressed = false
                    onClicked: {
                        getRectangleEnvelope();
                        geodatabaseSyncTask.executeGenerate();
                    }

                    function getRectangleEnvelope() {
                        var corner1 = mapView.screenToLocation(extentRectangle.x, extentRectangle.y);
                        var corner2 = mapView.screenToLocation((extentRectangle.x + extentRectangle.width), (extentRectangle.y + extentRectangle.height));
                        var envBuilder = ArcGISRuntimeEnvironment.createObject("EnvelopeBuilder");
                        envBuilder.setCorners(corner1, corner2);
                        generateExtent = GeometryEngine.project(envBuilder.geometry, Factory.SpatialReference.createWebMercator());
                    }
                }
            }

            // Create a window to display the generate window
            Rectangle {
                id: generateWindow
                anchors.fill: parent
                color: "transparent"
                clip: true
                visible: false

                RadialGradient {
                    anchors.fill: parent
                    opacity: 0.7
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "lightgrey" }
                        GradientStop { position: 0.7; color: "black" }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse.accepted = true
                    onWheel: wheel.accepted = true
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 125 * scaleFactor
                    height: 100 * scaleFactor
                    color: "lightgrey"
                    opacity: 0.8
                    radius: 5
                    border {
                        color: "#4D4D4D"
                        width: 1 * scaleFactor
                    }

                    Column {
                        anchors {
                            fill: parent
                            margins: 10 * scaleFactor
                        }
                        spacing: 10

                        BusyIndicator {
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: statusText
                            font.pixelSize: 16 * scaleFactor
                        }
                    }
                }

                Timer {
                    id: hideWindowTimer

                    onTriggered: generateWindow.visible = false;
                }

                function hideWindow(time) {
                    hideWindowTimer.interval = time;
                    hideWindowTimer.restart();
                }
            }
        }
    }

    Component.onCompleted: {
        AppFramework.fileFolder(dataPath).makeFolder();
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

