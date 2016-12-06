/* Copyright 2015 Esri
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

import QtQuick 2.3
import QtQuick.Controls 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 800
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor
    property int fontSize: 15 * scaleFactor
    property bool isOnline: true
    property string featuresUrl: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Sync/WildfireSync/FeatureServer"
    property string gdbPath: "~/ArcGIS/Runtime/Data/Test/offlineSample.geodatabase"
    property var selectedFeatureId: null

    Envelope {
        id: sfExtent
        xMin: -13643665.582273144
        yMin: 4533030.152110769
        xMax: -13618899.985108782
        yMax: 4554203.2089457335
    }

    Map {
        id: mainMap
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: msgRow.top
        }
        extent: sfExtent
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer"
        }

        FeatureLayer {
            id: offLineLayer
            featureTable: app.isOnline ? featureServiceTable : local
            selectionColor: "cyan"

            function hitTestFeatures(x,y) {
                var featureIds = offLineLayer.findFeatures(x, y, 1, 1);
                if (featureIds.length > 0) {
                    selectedFeatureId = featureIds[0];
                    selectFeature(selectedFeatureId);
                    statusText.text = "Tap anywhere to move the feature";
                }
            }
        }

        onMouseClicked: {
            if (!app.isOnline) {
                if (offLineLayer.isFeatureSelected(selectedFeatureId)) {
                    var featureToEdit = offLineLayer.featureTable.feature(selectedFeatureId);
                    featureToEdit.geometry = mouse.mapPoint;
                    offLineLayer.featureTable.updateFeature(selectedFeatureId, featureToEdit);
                    offLineLayer.unselectFeature(selectedFeatureId);
                    selectedFeatureId = null;
                    syncButton.enabled = true;
                    statusText.text = "Tap on Sync to update the Feature Service with the edits";
                } else
                    offLineLayer.hitTestFeatures(mouse.x, mouse.y);
            }
        }
    }

    GeodatabaseFeatureTable {
        id: local
        geodatabase: gdb.valid ? gdb : null
        featureServiceLayerId: 0
    }

    GeodatabaseFeatureServiceTable {
        id: featureServiceTable
        url: featuresUrl + "/0"
    }

    ServiceInfoTask {
        id: serviceInfoTask
        url: featuresUrl

        onFeatureServiceInfoStatusChanged: {

            if (featureServiceInfoStatus === Enums.FeatureServiceInfoStatusCompleted) {
                statusText.text = "Service info received. Tap on the Generate Geodatabase Button";

                generateButton.enabled = true;
            } else if (featureServiceInfoStatus === Enums.FeatureServiceInfoStatusErrored) {
                statusText.text = "Error:" + errorString;
                generateButton.enabled = false;
                cancelButton.text = "Start Over";
            }
        }
    }

    Feature {
        id: featureToEdit
    }

    Rectangle {
        anchors {
            fill: controlsColumn
            margins: -10 * scaleFactor
        }
        color: "lightgrey"
        radius: 5 * scaleFactor
        border.color: "black"
        opacity: 0.77

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse.accepted = true)
        }
    }

    Column {
        id: controlsColumn
        anchors {
            left: parent.left
            top: parent.top
            margins: 20 * scaleFactor
        }
        spacing: 7

        Button {
            text: "Generate Geodatabase"
            id: generateButton
            enabled: false

            onClicked: {
                generateGeodatabaseParameters.initialize(serviceInfoTask.featureServiceInfo);
                generateGeodatabaseParameters.extent = mainMap.extent;
                generateGeodatabaseParameters.returnAttachments = false;
                statusText.text = "Starting generate geodatabase task";
                busyIndicator.visible = true;
                geodatabaseSyncTask.generateGeodatabase(generateGeodatabaseParameters, gdbPath);
            }
        }

        Button {
            id: syncButton
            text: "Sync"
            width: generateButton.width
            enabled: false

            onClicked: {
                enabled = false;
                geodatabaseSyncTask.syncGeodatabase(gdb.syncGeodatabaseParameters, gdb);
                busyIndicator.visible = true;
                statusText.text = "Starting sync task";
            }
        }

        Button {
            id: cancelButton
            text: "Cancel"
            width: generateButton.width
            enabled: false

            onClicked: {
                geodatabaseSyncTask.cancelJob(syncStatusInfo);
                enabled = false;
                text = "Cancel";
            }
        }

        Row {
            id: toggleOnlineOffline
            spacing: 10

            Text {
                id: onlineStatus
                text: app.isOnline ? "  Online " : "  Offline "
            }

            Switch {
                id: switchToggle
                checked: app.isOnline
                enabled: false

                onCheckedChanged: {
                    app.isOnline = checked;
                    if (checked === true && Enums.GenerateStatusCompleted)
                        statusText.text = "Switch to Offline Mode to continue editing.";
                    else if (checked === false && Enums.GenerateStatusCompleted)
                        statusText.text = "Select a feature.";
                }
            }
        }
    }

    Geodatabase {
        id: gdb
        path: geodatabaseSyncTask.geodatabasePath

        onValidChanged: {
            if (valid) {
                var gdbtables = gdb.geodatabaseFeatureTables;
                for(var i in gdbtables) {
                    console.log (gdbtables[i].featureServiceLayerName);
                }
            }
        }
    }

    GeodatabaseSyncStatusInfo {
        id: syncStatusInfo
    }

    GeodatabaseSyncTask {
        id: geodatabaseSyncTask
        url: featuresUrl

        onGenerateStatusChanged: {
            statusText.text = generateStatus;
            if (generateStatus === Enums.GenerateStatusCompleted) {
                statusText.text = geodatabasePath;
                cancelButton.enabled = false;
                busyIndicator.visible = false;
                generateButton.enabled = false;
                app.isOnline = false;
                statusText.text = "Select a feature";
            } else if (generateStatus === GeodatabaseSyncTask.GenerateError) {
                statusText.text = "Error: " + generateGeodatabaseError.message + " Code= "  + generateGeodatabaseError.code.toString() + " "  + generateGeodatabaseError.details;
                generateButton.enabled = false;
                cancelButton.text = "Start Over";
            }
        }

        onGeodatabaseSyncStatusInfoChanged: {
            if (geodatabaseSyncStatusInfo.status === Enums.GeodatabaseStatusUploadingDelta) {
                var deltaProgress = geodatabaseSyncStatusInfo.deltaUploadProgress/1000;
                var deltaSize = geodatabaseSyncStatusInfo.deltaSize/1000;
                statusText.text = geodatabaseSyncStatusInfo.statusString + " " + String(deltaProgress) + " of " + String(deltaSize) + " KBs...";
            } else
                statusText.text = geodatabaseSyncStatusInfo.statusString + " " + geodatabaseSyncStatusInfo.lastUpdatedTime.toString() + " " + geodatabaseSyncStatusInfo.jobId.toString();
            if (geodatabaseSyncStatusInfo.status !== GeodatabaseSyncStatusInfo.Cancelled)
                cancelButton.enabled = true;
            syncStatusInfo.json = geodatabaseSyncStatusInfo.json;
        }

        onSyncStatusChanged: {
            featureServiceTable.refreshFeatures();
            if (syncStatus === Enums.SyncStatusCompleted) {
                cancelButton.enabled = false;
                syncButton.enabled = false;
                statusText.text = "Sync completed. You may continue editing the features.";
                busyIndicator.visible = false;
                switchToggle.enabled = true;
            }
            if (syncStatus === Enums.SyncStatusErrored)
                statusText.text = "Error: " + syncGeodatabaseError.message + " Code= "  + syncGeodatabaseError.code.toString() + " "  + syncGeodatabaseError.details;
        }
    }

    GenerateGeodatabaseParameters {
        id: generateGeodatabaseParameters
    }

    Rectangle {
        anchors {
            fill: msgRow
            leftMargin: -10 * scaleFactor
        }
        color: "lightgrey"
        border.color: "black"
        opacity: 0.77
    }

    Row {
        id: msgRow
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: 10 * scaleFactor
            right: parent.right
        }
        spacing: 10 * scaleFactor

        BusyIndicator {
            id: busyIndicator
            anchors.verticalCenter: parent.verticalCenter
            enabled: false
            visible: enabled
            height: (parent.height * 0.5) * scaleFactor
            width: height * scaleFactor
        }

        Text {
            id: statusText
            anchors.bottom: parent.bottom
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: fontSize
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }

    Component.onCompleted: {
        statusText.text = "Getting service info";
        serviceInfoTask.fetchFeatureServiceInfo();
    }
}

