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
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.11
import ArcGIS.AppFramework.Platform 1.0

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
    property double mousePointX
    property double mousePointY
    property string damageType
    property var selectedFeature: null

    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        BusyIndicator{
            id: busy
            anchors.centerIn: parent
            Material.accent: "#8f499c"
            running: false
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle{
            anchors.top:header.bottom

            MapView {
                id: mapView
                anchors.fill: parent
                wrapAroundMode: Enums.WrapAroundModeDisabled

                Map {
                    // Set the initial basemap to Streets
                    BasemapStreets { }

                    ViewpointCenter {
                        Point {
                            x: -10800000
                            y: 4500000
                            spatialReference: SpatialReference {
                                wkid: 102100
                            }
                        }
                        targetScale: 3e7
                    }

                    FeatureLayer {
                        id: featureLayer

                        selectionColor: "cyan"
                        selectionWidth: 3

                        // declare as child of feature layer, as featureTable is the default property
                        ServiceFeatureTable {
                            id: featureTable
                            url: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0"

                            onApplyEditsStatusChanged: {
                                if (applyEditsStatus === Enums.TaskStatusCompleted) {
                                    console.log("successfully applied attachment edits to service");

                                    // update the selected feature with attributes
                                    featureLayer.selectFeaturesWithQuery(params, Enums.SelectionModeNew);
                                }
                            }
                        }

                        // signal handler for selecting features
                        onSelectFeaturesStatusChanged: {
                            if (selectFeaturesStatus === Enums.TaskStatusInProgress) {
                                // busy.running = true
                                console.log("######################TaskStatusInProgress")
                            }

                            if (selectFeaturesStatus === Enums.TaskStatusCompleted) {
                                busy.running = false
                                if (!selectFeaturesResult.iterator.hasNext)
                                    return;

                                selectedFeature = selectFeaturesResult.iterator.next();
                                damageType = selectedFeature.attributes.attributeValue("typdamage");

                                // show the callout
                                callout.x = mousePointX;
                                callout.y = mousePointY;
                                callout.visible = true;
                            }
                        }
                    }
                }

                QueryParameters {
                    id: params
                    maxFeatures: 1
                }

                // hide the callout after navigation
                onViewpointChanged: {
                    callout.visible = false;
                    attachmentWindow.visible = false;
                }

                onMouseClicked: {
                    // reset to defaults
                    featureLayer.clearSelection();
                    callout.visible = false;
                    attachmentWindow.visible = false;
                    selectedFeature = null;
                    mousePointX = mouse.x;
                    mousePointY = mouse.y - callout.height;

                    // call identify on the mapview
                    mapView.identifyLayer(featureLayer, mouse.x, mouse.y, 10, false);
                }

                onIdentifyLayerStatusChanged: {
                    if (identifyLayerStatus === Enums.TaskStatusCompleted) {
                        if (identifyLayerResult.geoElements.length > 0) {
                            // get the objectid of the identifed object
                            params.objectIds = [identifyLayerResult.geoElements[0].attributes.attributeValue("objectid")];
                            // query for the feature using the objectid
                            featureLayer.selectFeaturesWithQuery(params, Enums.SelectionModeNew);
                        }
                    }
                }
            }

            // map callout window
            Rectangle {
                id: callout
                width: col.width + (10 * scaleFactor) // add 10 for padding
                height: 60 * scaleFactor
                radius: 5
                border {
                    color: "lightgrey"
                    width: .5
                }
                visible: false

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse.accepted = true
                }

                Column {
                    id: col
                    anchors {
                        top: parent.top
                        left: parent.left
                        margins: 5 * scaleFactor
                    }
                    spacing: 10

                    Row {
                        spacing: 10

                        Text {
                            text: damageType
                            font.pixelSize: 18 * scaleFactor
                        }

                        Rectangle {
                            radius: 100
                            width: 22 * scaleFactor
                            height: width
                            color: "transparent"
                            border.color: "blue"
                            antialiasing: true

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "i"
                                font.pixelSize: 18 * scaleFactor
                                color: "blue"
                            }

                            // create a mouse area over the (i) text to open the update window
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    attachmentWindow.visible = true;
                                }
                            }
                        }
                    }

                    Row {
                        spacing: 10

                        Text {
                            id: attachmentText
                            text: selectedFeature === null ? "" : "Number of attachments: %1".arg(selectedFeature.attachments.count)
                            font.pixelSize: 12 * scaleFactor
                        }
                    }
                }

            }

            // attachment window
            Rectangle {
                id: attachmentWindow
                anchors.centerIn: parent
                height: 200 * scaleFactor
                width: 250 * scaleFactor
                visible: false
                radius: 10
                color: "lightgrey"
                border.color: "darkgrey"
                opacity: 0.90
                clip: true

                // accept mouse events so they do not propogate down to the map
                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse.accepted = true
                    onWheel: wheel.accepted = true
                }

                Rectangle {
                    id: titleText
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    height: 40 * scaleFactor
                    color: "transparent"

                    Text {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            margins: 10 * scaleFactor
                        }

                        text: "Attachments"; font {bold: true; pixelSize: 20 * scaleFactor;}
                    }

                    Row {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            margins: 10 * scaleFactor
                        }
                        spacing: 15
                        Text {
                            text: "+"; font {bold: true; pixelSize: 40 * scaleFactor;} color: "green"

                            // open a file dialog whenever the add button is clicked
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    fileDialog.open();
                                }
                            }
                        }
                        Text {
                            text: "-"; font {bold: true; pixelSize: 40 * scaleFactor;} color: "red"

                            // make sure an item is selected and if so, delete it from the service
                            MouseArea {
                                anchors.fill: parent

                                function doDeleteAttachment(){
                                    if (selectedFeature.loadStatus === Enums.LoadStatusLoaded) {
                                        selectedFeature.onLoadStatusChanged.disconnect(doDeleteAttachment);
                                        selectedFeature.attachments.deleteAttachmentWithIndex(attachmentsList.currentIndex);
                                    }
                                }

                                onClicked: {
                                    if (attachmentsList.currentIndex === -1)  {
                                        msgDialog.text = "Please first select an attachment to delete.";
                                        msgDialog.open();
                                    } else {
                                        // delete the attachment from the table
                                        if (selectedFeature.loadStatus === Enums.LoadStatusLoaded) {
                                            selectedFeature.attachments.deleteAttachmentWithIndex(attachmentsList.currentIndex);
                                        } else {
                                            selectedFeature.onLoadStatusChanged.connect(doDeleteAttachment);
                                            selectedFeature.load();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: attachmentsList
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: titleText.bottom
                        bottom: parent.bottom
                        margins: 10 * scaleFactor
                    }
                    clip: true
                    spacing: 5
                    // set the model equal to the currently selected feature's attachment list model
                    model: selectedFeature === null ? null : selectedFeature.attachments
                    // create the delegate to specify how the view is arranged
                    delegate: Item {
                        height: 45* scaleFactor
                        width: parent.width
                        clip: true

                        // show the attachment name
                        Text {
                            id: label
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                right: attachment.left
                            }
                            text: name
                            wrapMode: Text.WrapAnywhere
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            font.pixelSize: 16 * scaleFactor
                        }

                        // show the attachment's URL if it is an image
                        Image {
                            id: attachment
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                            }
                            width: 44 * scaleFactor
                            height: width
                            fillMode: Image.PreserveAspectFit
                            source: attachmentUrl
                            onSourceChanged: {
                                busy.running = false
                                console.log(source)
                            }
                        }

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            onClicked: {
                                attachmentsList.currentIndex = index;
                            }
                        }
                    }

                    highlightFollowsCurrentItem: true
                    highlight: Rectangle {
                        height: 0
                        color: "lightsteelblue"

                        Component.onCompleted: {
                            busy.running = false
                            if (typeof attachmentsList.currentItem.height !== "undefined") {
                                 attachmentsList.height = attachmentsList.currentItem.height
                            }
                        }
                    }
                }
            }

            // file dialog for selecting a file to add as an attachment
            //! [EditFeatures add attachment from a file dialog]
            DocumentDialog {
                id: fileDialog
                folder: {
                    const locs = StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
                    return locs.length > 0 ? locs[locs.length - 1] : "";
                }

                function doAddAttachment(){
                    if (selectedFeature.loadStatus === Enums.LoadStatusLoaded) {
                        selectedFeature.onLoadStatusChanged.disconnect(doAddAttachment);
                        selectedFeature.attachments.addAttachment(fileDialog.fileUrl, "application/octet-stream", fileInfo.fileName);
                    }
                }

                onAccepted: {
                    // add the attachment to the feature table
                    busy.running = true
                    fileInfo.url = fileDialog.fileUrl;

                    if(!(Qt.platform.os == "android")) {
                        if (selectedFeature.loadStatus === Enums.LoadStatusLoaded) {
                            selectedFeature.attachments.addAttachment(fileDialog.fileUrl, "application/octet-stream", fileInfo.fileName);
                        } else {
                            selectedFeature.onLoadStatusChanged.connect(doAddAttachment);
                            selectedFeature.load();
                        }
                        console.log(fileDialog.fileUrl)

                    } else {
                        fileFolder.makeFolder();

                        fileFolder.copyFile(fileDialog.fileUrl, fileFolder.filePath(fileInfo.fileName));
                        if (selectedFeature.loadStatus === Enums.LoadStatusLoaded) {
                            selectedFeature.attachments.addAttachment(fileFolder.filePath(fileInfo.fileName), "application/octet-stream", fileInfo.fileName);
                        } else {
                            selectedFeature.onLoadStatusChanged.connect(doAddAttachment);
                            selectedFeature.load();
                        }
                        console.log(fileFolder.filePath(fileInfo.fileName))
                    }
                }
            }
            //! [EditFeatures add attachment from a file dialog]

            MessageDialog {
                id: msgDialog
            }

            // file info used for obtaining the file name
            FileInfo {
                id: fileInfo
            }

            //Show storage permission pop-up on Android

            FileFolder {
                id: fileFolder
                path: "~/attachments"
            }

            Component.onCompleted: {
                fileFolder.makeFolder()
            }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

