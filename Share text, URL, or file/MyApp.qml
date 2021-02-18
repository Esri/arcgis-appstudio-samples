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

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736

    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 16 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < 400 * scaleFactor
    property bool isIOS: Qt.platform.os === "ios"
    property bool isWin: Qt.platform.os === "windows"
    property bool isAndroid: Qt.platform.os === "android"
    property url shareURL
    property FileFolder destFolder: AppFramework.userHomeFolder.folder("ArcGIS/AppStudio/Data")

    function copyFile(fileName) {
        if (!destFolder.exists) destFolder.makeFolder();
        shareURL.copyFile(fileName, destFolder.filePath(fileName));
        console.log(destFolder.filePath(fileName));
        return destFolder.filePath(fileName);
    }

    Page {
        anchors.fill: parent
        header: ToolBar {
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle {
            anchors.top:header.bottom

            ColumnLayout {
                anchors.fill: parent
                spacing: 8 * scaleFactor

                Item {
                    Layout.preferredHeight: 16 * scaleFactor
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: col1.height
                    Layout.leftMargin: 16 * scaleFactor
                    Layout.rightMargin: 16 * scaleFactor

                    Pane {
                        anchors.fill: parent
                        Material.elevation: 1
                        padding: 0

                        ColumnLayout {
                            id: col1
                            width: parent.width
                            spacing: 0

                            Label {
                                text: qsTr("Share Text or URL")
                                font.pixelSize: baseFontSize
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.topMargin: 16 * scaleFactor
                                Layout.rightMargin: 16 * scaleFactor
                                Layout.leftMargin: 16 * scaleFactor
                            }

                            TextField {
                                id:inputText
                                placeholderText: AppFramework.clipboard.supportsShare?"Enter Text or Url":qsTr("Sharing via Clipboard is not supported.")
                                font.pixelSize: baseFontSize
                                Material.accent: "#8f499c"
                                Layout.fillWidth: true
                                Layout.topMargin: 8 * scaleFactor
                                Layout.rightMargin: 16 * scaleFactor
                                Layout.leftMargin: 16 * scaleFactor
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: row1.height
                                Layout.topMargin: 8 * scaleFactor
                                Layout.rightMargin: 16 * scaleFactor
                                Layout.leftMargin: 16 * scaleFactor
                                Layout.bottomMargin: 16 * scaleFactor

                                RowLayout {
                                    id: row1
                                    width: parent.width
                                    spacing: 0

                                    Button {
                                        text: "Share as text"

                                        enabled: AppFramework.clipboard.supportsShare === true

                                        onClicked: {
                                            if (inputText.text.length > 0) {
                                                AppFramework.clipboard.share(inputText.text)
                                            } else {
                                                toast.displayToast("Enter a valid text")
                                            }
                                        }
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    Button {
                                        text: "Share as Url"

                                        enabled: AppFramework.clipboard.supportsShare === true

                                        onClicked: {
                                            if (inputText.text.length > 0) {
                                                shareURL = inputText.text
                                                AppFramework.clipboard.share(shareURL)
                                            } else {
                                                toast.displayToast("Enter a valid URL")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.margins: 16 * scaleFactor
                    Layout.preferredHeight: pane.height

                    Pane {
                        id: pane
                        width: parent.width
                        height: col2.height
                        Material.elevation: 3
                        padding: 0

                        ColumnLayout {
                            id: col2
                            width: parent.width
                            spacing: 0

                            Label {
                                text: qsTr("View and Share a File")
                                font.pixelSize: baseFontSize
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.topMargin: 16 * scaleFactor
                                Layout.rightMargin: 16 * scaleFactor
                                Layout.leftMargin: 16 * scaleFactor
                                Layout.bottomMargin: 8 * scaleFactor
                            }

                            Button {
                                id: selectFile
                                text: qsTr("Select a File")
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: 16 * scaleFactor
                                Layout.bottomMargin: 8 * scaleFactor

                                onClicked: {
                                    if (Permission.checkPermission(Permission.PermissionTypeStorage) !== Permission.PermissionResultGranted) {
                                        permissionDialog.open()
                                    } else {
                                        doc.open()
                                    }
                                }
                            }

                            Label {
                                id: selectedFileName
                                wrapMode: Label.Wrap
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.leftMargin: 16 * scaleFactor
                                Layout.rightMargin: 16 * scaleFactor
                                visible: false
                                font.pixelSize: baseFontSize * 0.8
                            }

                            Item {
                                Layout.preferredHeight: 8 * scaleFactor
                            }

                            Label {
                                id: selectedFilePath
                                wrapMode: Label.Wrap
                                elide: Label.ElideRight
                                Layout.fillWidth: true
                                Layout.leftMargin: 16 * scaleFactor
                                Layout.rightMargin: 16 * scaleFactor
                                visible: false
                                font.pixelSize: baseFontSize * 0.8
                            }

                            Item {
                                Layout.preferredHeight: 8 * scaleFactor
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: 16 * scaleFactor
                            }

                            Button {
                                id: viewFile
                                text: qsTr("View File")
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: 16 * scaleFactor
                                enabled: selectedFilePath.text.length > 0

                                onClicked: {
                                    AppFramework.openUrlExternally(shareURL)
                                }
                            }

                            Item {
                                Layout.preferredHeight: 8 * scaleFactor
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: 16 * scaleFactor
                            }

                            Button {
                                id: shareFile
                                text: qsTr("Share File")
                                Layout.alignment: Qt.AlignLeft
                                Layout.leftMargin: 16 * scaleFactor
                                enabled: selectedFilePath.text.length > 0

                                onClicked: {
                                    AppFramework.clipboard.share(shareURL)
                                }
                            }

                            Item {
                                Layout.preferredHeight: 16 * scaleFactor
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    PermissionDialog {
        id: permissionDialog
        openSettingsWhenDenied: true
        permission: PermissionDialog.PermissionDialogTypeStorage

        onAccepted: {
            doc.open()
        }

        onRejected: {
            toast.displayToast("Permission Not Granted")
        }
    }

    DocumentDialog {
        id: doc

        onAccepted: {
            shareURL = fileUrl

            selectedFilePath.visible = true
            var fileInfo = AppFramework.fileInfo(shareURL.toString().replace(Qt.platform.os == "windows"? "file:///": "file://",""));
            var fileFolder = AppFramework.fileFolder(shareURL.toString().replace(Qt.platform.os == "windows"? "file:///": "file://",""))
            selectedFileName.text = "Selected File Name: " + fileInfo.fileName

            //in android system, document dialog returns the content uri of the file instead of file url
            if(isAndroid)
                selectedFilePath.text = "Selected Content Uri: " + fileInfo.filePath
            else
                selectedFilePath.text = "Selected File Path: " + fileInfo.filePath
            selectedFileName.visible = true
        }

        onRejected: {
            if (status == DocumentDialog.DocumentDialogCancelledByUser) {
                toast.displayToast("File not selected")
            }

            if (status == DocumentDialog.DocumentDialogPermissionDenied) {
                toast.displayToast("Storage permission not granted")
            }

            if (status == DocumentDialog.DocumentDialogNotSupported) {
                toast.displayToast("Operation not supported")
            }

            if (status == DocumentDialog.DocumentDialogFileReadError) {
                toast.displayToast("Error while reading file")
            }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }

    Controls.ToastMessage {
        id: toast
    }
}

