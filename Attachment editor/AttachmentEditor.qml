//------------------------------------------------------------------------------
// AttachmentEditor.qml

// Copyright 2015 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the Sample code usage restrictions document for further information.
//
//------------------------------------------------------------------------------


import QtMultimedia 5.3
import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
App {
    id: app
    width: 800
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor
    property bool isOnline: featureLayer.featureTable.featureTableType === Enums.FeatureTableTypeGeodatabaseFeatureServiceTable
    property bool taskInProgress: geodatabaseSyncTask.generateStatus === Enums.GenerateStatusInProgress ||
                                  geodatabaseSyncTask.syncStatus === Enums.SyncStatusInProgress
    property var selectedFeatureId: null

    Envelope {
        id: initialExtent
        xMax: -13622897
        yMax: 4553183
        xMin: -13641663
        yMin: 4540667
    }

    Map {
        id: map
        anchors.fill: parent
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        FeatureLayer {
            id: featureLayer
            featureTable: featureServiceTable

            function hitTestFeatures(x,y) {
                var featureIds = featureLayer.findFeatures(x, y, 1, 1);

                if (featureIds.length > 0) {
                    selectedFeatureId = featureIds[0];
                    selectFeature(selectedFeatureId);

                    if (featureTable.featureTableStatus === Enums.FeatureTableStatusInitialized) {
                        queryAttachments(featureIds[0]);
                    }
                }
            }
        }


        onMouseClicked: {
            if (mouse.button === Qt.LeftButton) {
                attachmentsList.model.clear();
                selectedFeatureId = null;
                featureLayer.clearSelection();

                if (!taskInProgress) {
                    if (featureLayer.status === Enums.LayerStatusInitialized)
                        featureLayer.hitTestFeatures(mouse.x, mouse.y);
                }
            }
        }

        onStatusChanged: {
            if (status === Enums.MapStatusReady)
                extent = initialExtent;
        }
    }

    Geodatabase {
        id: gdb
    }

    GeodatabaseSyncTask {
        id: geodatabaseSyncTask
        url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Sync/WildfireSync/FeatureServer"

        onGenerateStatusChanged: {
            if (generateStatus === Enums.GenerateStatusCompleted) {
                statusText.text = geodatabasePath;
                gdb.path = geodatabasePath;
                featureLayer.featureTable = gdb.geodatabaseFeatureTableByLayerId(0);
                timer.start();
            }

            if (generateStatus === GeodatabaseSyncTask.GenerateError)
                statusText.showTextAndDelayHide("Error:" + generateGeodatabaseError.message + " Code="  + generateGeodatabaseError.code.toString() + " "  + generateGeodatabaseError.details);
        }

        onGeodatabaseSyncStatusInfoChanged: {
            if (geodatabaseSyncStatusInfo.status === Enums.GeodatabaseStatusUploadingDelta) {
                var deltaProgress = geodatabaseSyncStatusInfo.deltaUploadProgress/1000;
                var deltaSize = geodatabaseSyncStatusInfo.deltaSize/1000;
                statusText.text = geodatabaseSyncStatusInfo.statusString + " " + String(deltaProgress) + " of " + String(deltaSize) + " KBs...";
            } else {
                if (isOnline)
                    statusText.text = "Generating geodatabase: " + geodatabaseSyncStatusInfo.statusString + "...";
                else
                    statusText.text = "Syncing geodatabase: " + geodatabaseSyncStatusInfo.statusString + "...";
            }
        }

        onSyncStatusChanged: {
            if (syncStatus === Enums.SyncStatusCompleted) {
                statusText.text = "Sync completed."

                if (syncErrors !== null) {
                    var errorString = "";
                    for (var j = 0; j < syncErrors.featureEditErrors.length; j++) {
                        var error = syncErrors.featureEditErrors[j];
                        errorString += "\nLayer Id: " + error.layerId + "\nObject Id: " + error.objectId + "\nGlobal Id: " + error.globalId + "\nEdit operation: " + error.editOperationString + "\nError: " + error.error.description;
                    }
                    statusText.text = errorString;
                }
            }

            if (syncStatus === Enums.SyncStatusErrored)
                statusText.text = "Error:" + syncGeodatabaseError.message + " Code="  + syncGeodatabaseError.code.toString() + " "  + syncGeodatabaseError.details;

            if (syncStatus === Enums.SyncStatusCompleted || syncStatus === Enums.SyncStatusErrored) {
                featureLayer.featureTable = featureServiceTable;
                featureServiceTable.refreshFeatures();
                timer.start();
            }
        }

        function generate() {
            generateGeodatabaseParameters.extent = map.extent;
            generateGeodatabase(generateGeodatabaseParameters, tempFolder.path + "/attachment_editor.geodatabase", false);
            statusText.text = "Preparing to generate geodatabase...";
        }

        function sync() {
            syncGeodatabase(gdb.syncGeodatabaseParameters, gdb);
            statusText.text = "Preparing to sync geodatabase...";
        }
    }

    GenerateGeodatabaseParameters {
        id: generateGeodatabaseParameters
        layerIds: [0]
        returnAttachments: true
        syncModel: Enums.SyncModelLayer

    }

    GeodatabaseFeatureServiceTable {
        id: featureServiceTable
        url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Sync/WildfireSync/FeatureServer/0"

        onApplyAttachmentEditsStatusChanged: {
            if (applyAttachmentEditsStatus === Enums.ApplyEditsStatusCompleted) {
                attachmentsList.model.clear();
                queryAttachmentInfos(selectedFeatureId);
            } else if (applyAttachmentEditsStatus === Enums.ApplyEditsStatusErrored) {
                statusText.showTextAndDelayHide("Error applying attachments");
            }
        }
    }

    Connections {
        target: featureLayer.featureTable

        onQueryAttachmentInfosStatusChanged: {
            if (featureLayer.featureTable.queryAttachmentInfosStatus === Enums.QueryAttachmentInfosStatusCompleted) {
                var count = 0;

                for (var attachmentInfo in featureLayer.featureTable.attachmentInfos) {
                    var info = featureLayer.featureTable.attachmentInfos[attachmentInfo];

                    attachmentsList.model.insert(count,
                                              {
                                                  "attachmentId": info["attachmentId"],
                                                  "contentType": info["contentType"],
                                                  "name": info["name"],
                                                  "size": info["size"]
                                              })
                }

                if (attachmentsList.count > 0)
                    attachmentsList.currentIndex = 0;

                count++;
            }
        }

        onAddAttachmentStatusChanged: {
            if (featureLayer.featureTable.addAttachmentStatus === Enums.AttachmentEditStatusCompleted) {
                if (featureLayer.featureTable.featureTableType === Enums.FeatureTableTypeGeodatabaseFeatureServiceTable) {
                    featureServiceTable.applyAttachmentEdits();
                } else {
                    attachmentsList.model.clear();
                    featureLayer.featureTable.queryAttachmentInfos(selectedFeatureId);
                }
            } else if (featureLayer.featureTable.addAttachmentStatus === Enums.AttachmentEditStatusErrored) {
                statusText.showTextAndDelayHide("Attachment add failed: " + featureLayer.featureTable.addAttachmentResult.error.description);
            }
        }

        onDeleteAttachmentStatusChanged: {
            if (featureLayer.featureTable.deleteAttachmentStatus === Enums.AttachmentEditStatusCompleted) {
                if (featureLayer.featureTable.featureTableType === Enums.FeatureTableTypeGeodatabaseFeatureServiceTable) {
                    featureServiceTable.applyAttachmentEdits();
                } else {
                    attachmentsList.model.clear();
                    featureLayer.featureTable.queryAttachmentInfos(selectedFeatureId);
                }
            } else if (featureLayer.featureTable.deleteAttachmentStatus === Enums.AttachmentEditStatusErrored) {
                statusText.showTextAndDelayHide("Attachment delete failed: " + featureLayer.featureTable.deleteAttachmentResult.error.description);
            }
        }

        onRetrieveAttachmentStatusChanged: {
            if (featureLayer.featureTable.retrieveAttachmentStatus === Enums.RetrieveAttachmentStatusCompleted) {
                if (featureLayer.featureTable.retrieveAttachmentResult !== null) {
                    if (featureLayer.featureTable.retrieveAttachmentResult !== null) {
                        if (Qt.platform.os === "windows") {
                            var tempPath = tempFolder.path.split(":")[1];
                            var str = featureLayer.featureTable.retrieveAttachmentResult.saveToFile("file://" + tempPath, true);
                            attachmentImage.source = "file://" + str.split(":")[1];
                        } else {
                            var str2 = featureLayer.featureTable.retrieveAttachmentResult.saveToFile("file://" + tempFolder.path, true);
                            attachmentImage.source = "file://" + str2;
                        }
                    }
                }
            } else if (featureLayer.featureTable.retrieveAttachmentStatus === Enums.RetrieveAttachmentStatusErrored) {
                statusText.showTextAndDelayHide("Retrieve Attachment error: " + featureLayer.featureTable.retrieveAttachmentError);
            }
        }
    }

    function queryAttachments(featureId) {
        featureLayer.featureTable.queryAttachmentInfos(featureId);
    }

    function viewAttachment(attachmentId) {
        featureLayer.featureTable.retrieveAttachment(selectedFeatureId, attachmentId);
    }

    function addAttachmentFile(geodatabaseAttachment) {
        featureLayer.featureTable.addAttachment(selectedFeatureId, geodatabaseAttachment);
    }

    function removeAttachment(attachmentId) {
        featureLayer.featureTable.deleteAttachment(selectedFeatureId, attachmentId);
    }

    Rectangle {
        anchors {
            fill: controlsColumn
            margins: -10 * scaleFactor
        }
        color: "lightgrey"
        radius: 5
        border.color: "black"
        opacity: 0.77
    }

    Column {
        id: controlsColumn
        anchors {
            left: parent.left
            top: parent.top
            margins: 20 * scaleFactor
        }
        spacing: 10 * scaleFactor

        Button {
            text: isOnline ? "Go Offline" : "Go Online";
            enabled: !taskInProgress
            width: controlsColumn.width

            onClicked: {
                attachmentsList.model.clear();
                selectedFeatureId = null;
                featureLayer.clearSelection();

                if (isOnline) {
                    if (gdb.valid)
                        featureLayer.featureTable = gdb.geodatabaseFeatureTableByLayerId(0);
                    else
                        geodatabaseSyncTask.generate();
                } else {
                    geodatabaseSyncTask.sync();
                }
            }
        }

        Grid {
            columns: 3
            spacing: 5 * scaleFactor

            Button {
                text: "View";
                enabled: attachmentsList.currentIndex != -1 ? true : false

                onClicked: {
                    var item = attachmentsList.model.get(attachmentsList.currentIndex);
                    viewAttachment(item["attachmentId"]);
                }
            }
            Button {
                text: "Add";
                enabled: selectedFeatureId !== null ? true : false

                onClicked: {
                    if (Qt.platform.os === "ios" || Qt.platform.os === "android") {
                        videoOutput.visible = true;
                    } else {
                        fileDialog.title = "Choose a file"
                        fileDialog.open();
                    }
                }
            }
            Button {
                text: "Delete";
                enabled: attachmentsList.currentIndex != -1 ? true : false

                onClicked: {
                    var item = attachmentsList.model.get(attachmentsList.currentIndex);
                    removeAttachment(item["attachmentId"]);
                }
            }
        }
    }

    Rectangle {
        anchors {
            left: controlsColumn.left
            right: controlsColumn.right
            top: controlsColumn.bottom
            margins: -10 * scaleFactor
            topMargin: 15 * scaleFactor
        }
        height: 200 * scaleFactor
        visible: attachmentsList.currentIndex != -1 ? true : false
        color: "lightgrey"
        radius: 5
        border.color: "black"
        opacity: 0.77
        clip: true

        ListView {
            id: attachmentsList
            property int itemHeight: 20
            anchors {
                fill: parent
                margins: 5 * scaleFactor
            }
            visible: currentIndex != -1 ? true : false

            header: Item {
                height: attachmentsList.itemHeight * scaleFactor
                width: parent.width
                clip: true

                Text {
                    text: "Attachments"; font { bold: true }
                }
            }

            model: attachmentsModel
            delegate: Item {
                height: attachmentsList.itemHeight * scaleFactor
                width: parent.width
                clip: true

                Text {
                    text: name
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }

                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    onClicked: {
                        attachmentsList.currentIndex = index
                    }
                }
            }

            highlightFollowsCurrentItem: true
            highlight: Rectangle {
                height: attachmentsList.currentItem.height
                color: "lightsteelblue"
            }
            focus: true
        }
    }

    ListModel {
        id: attachmentsModel
    }

    Rectangle {
        anchors {
            fill: attachmentImage
            margins: -10 * scaleFactor
        }
        visible: attachmentImage.visible
        color: "black"
        radius: 5
        border.color: "black"
        opacity: 0.77
    }

    Image {
        id: attachmentImage
        anchors {
            fill: parent
            margins: 20 * scaleFactor
        }
        visible: attachmentImage.source != "" ? true : false
        fillMode: Image.PreserveAspectFit

        MouseArea {
            anchors.fill: parent

            onClicked: {
                attachmentImage.source = ""
            }
        }
    }

    Rectangle {
        id: textStatusRectangle
        anchors {
            fill: statusText
            margins: -10 * scaleFactor
        }
        visible: statusText.text.length > 0
        color: "lightgrey"
        radius: 5
        border.color: "black"
        opacity: 0.77
    }

    Text {
        id: statusText
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 20 * scaleFactor
        }
        wrapMode: Text.WrapAnywhere

        function showTextAndDelayHide(str) {
            text = str;
            timer.start();
        }
    }

    Camera {
        id: camera
        cameraState: videoOutput.visible ? Camera.ActiveState : Camera.UnloadedState

        imageCapture {
            resolution: Qt.size(288, 432)

            onCapturedImagePathChanged: {
                videoOutput.visible = false;

                var geodatabaseAttachment = ArcGISRuntime.createObject("GeodatabaseAttachment");
                if (geodatabaseAttachment.loadFromFile(camera.imageCapture.capturedImagePath, "application/octet-stream"))
                    addAttachmentFile(geodatabaseAttachment);
                else
                    statusText.showTextAndDelayHide("Failed to load GeodatabaseAttachment.");
            }
        }
    }

    Rectangle {
        anchors {
            fill: videoOutput
            margins: -10 * scaleFactor
        }
        visible: videoOutput.visible
        color: "black"
        radius: 5
        border.color: "black"
        opacity: 0.77
    }

    VideoOutput {
        id: videoOutput
        anchors {
            fill: parent
            margins: 20 * scaleFactor
        }
        source: camera
        visible: false
        focus : visible
        autoOrientation: true

        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true
        }

        Rectangle {
            anchors {
                fill: imageCaptureControlsColumn
                margins: -10 * scaleFactor
            }
            color: "lightgrey"
            radius: 5
            border.color: "black"
            opacity: 0.77
        }

        Column {
            id: imageCaptureControlsColumn
            anchors {
                left: parent.left
                bottom: parent.bottom
                margins: 20 * scaleFactor
            }
            spacing: 10 * scaleFactor

            Button {
                text: "Capture Image"
                onClicked: camera.imageCapture.capture()
            }

            Button {
                text: "Cancel"
                onClicked: videoOutput.visible = false
            }
        }
    }

    FileDialog {
        id: fileDialog
        selectExisting: true
        selectMultiple: false

        onAccepted: {
            var geodatabaseAttachment = ArcGISRuntime.createObject("GeodatabaseAttachment");
            if (geodatabaseAttachment.loadFromFile(fileDialog.fileUrl, "application/octet-stream"))
                addAttachmentFile(geodatabaseAttachment);
        }
    }

    FileFolder {
        id: tempFolder
    }

    Timer {
        id: timer
        interval: 10000;
        repeat: false

        onTriggered: statusText.text = ""
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }
}

