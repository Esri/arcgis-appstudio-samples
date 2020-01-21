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

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736

    readonly property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize: app.info.propertyValue("baseFontSize", 12 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < scaleFactor * 400
    property bool isIOS: Qt.platform.os === "ios"
    property bool isDesktop: Qt.platform.os === "windows" || Qt.platform.os === "macos" || Qt.platform.os === "linux"

    Page {
        id: page
        anchors.fill: parent
        header: ToolBar {
            id: header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar {}
        }

        Rectangle {
            anchors.margins: 12 * scaleFactor
            anchors.fill: parent
            color: "#F5F5F5"

            Pane {
                anchors.fill: parent
                Material.elevation: 1
                padding: 0

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12 * scaleFactor
                    spacing: 0

                    RowLayout {
                        spacing: 10

                        CheckBox {
                            id: openSettings
                            checkState: Qt.Unchecked
                            Layout.leftMargin: 10 * scaleFactor
                            Material.accent: "#8f499c"
                        }

                        Label {
                            text: "Open Settings When Denied"
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor

                        Controls.FloatActionButton {
                            id: microphoneButton

                            onIconClicked: {
                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeMicrophone;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: microphonePermissionStatusLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor

                        Controls.FloatActionButton {
                            id: cameraButton

                            onIconClicked: {
                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeCamera;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: cameraPermissionStatusLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor
                        visible: !isIOS || true

                        Controls.FloatActionButton {
                            id: storagePermissionButton
                            onIconClicked: {
                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeStorage;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: storagePermissionStatusLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor

                        Controls.FloatActionButton {
                            id: locationWhenInUseButton

                            onIconClicked: {
                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeLocationWhenInUse;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: locationWhenInUsePermissionStatusLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor
                        visible: isIOS

                        Controls.FloatActionButton {
                            id: locationAlwaysInUseButton

                            onIconClicked: {
                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeLocationAlwaysInUse;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: locationAlwaysInUsePermissionStatusLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                        }
                    }

                    Label {
                        text: "Note: this functionality is designed on iOS and Android"
                        Layout.leftMargin: 15 * scaleFactor
                        Layout.preferredWidth: parent.width - 15
                        maximumLineCount: 2
                        wrapMode: Label.WordWrap
                        color: "#8f499c"
                        font.bold: true
                    }
                }
            }
        }
    }

    function processPermission(permission) {
        return getResultToString(Permission.checkPermission(permission));
    }

    function getResultToString(result) {
        switch (result) {
        case Permission.PermissionResultGranted:
            return "Granted";
        case Permission.PermissionResultDenied:
            return "Denied";
        case Permission.PermissionResultRestricted:
            return "Restricted";
        case Permission.PermissionResultUnknown:
            return "Unknown";
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage {
        id: descPage
        visible: false
    }

    PermissionDialog {
        id: permissionDialog
        openSettingsWhenDenied: openSettings.checkState === Qt.Checked

        onRejected: {
            processPermissionResult(permission, false)
        }

        onAccepted: {
            processPermissionResult(permission, true)
        }
    }

    function processPermissionResult(perm, result) {
        switch(perm) {
        case PermissionDialog.PermissionDialogTypeMicrophone:
            microphoneButton.imageSource = result ? "./assets/microphone.png" : "./assets/microphone_off.png"
            microphonePermissionStatusLabel.text = "Microphone Permission Status: %1".arg(result ?  "Granted" : "Denied")
            break;

        case PermissionDialog.PermissionDialogTypeLocationAlwaysInUse:
            locationWhenInUseButton.imageSource = result ? "./assets/location.png" : "./assets/location_off.png"
            locationWhenInUsePermissionStatusLabel.text = "Location Permission Status: %1".arg(result ?  "Granted" : "Denied")
            locationAlwaysInUseButton.imageSource = result ? "./assets/location.png" : "./assets/location_off.png"
            locationAlwaysInUsePermissionStatusLabel.text = "Location Always In Use Permission Status: %1".arg(result ?  "Granted" : "Denied")
            break;

        case PermissionDialog.PermissionDialogTypeBluetooth:
            bluetoothButton.imageSource = result ? "./assets/bluetooth.png" : "./assets/bluetooth_off.png"
            bluetoothPermissionStatusText.text = "Bluetooth Permission Status: %1".arg(result ?  "Granted" : "Denied")
            break;

        case PermissionDialog.PermissionDialogTypeCamera:
            cameraButton.imageSource = result ? "./assets/camera.png" : "./assets/camera_off.png"
            cameraPermissionStatusLabel.text = "Camera Permission Status: %1".arg(result ?  "Granted" : "Denied")
            break;

        case PermissionDialog.PermissionDialogTypeLocationWhenInUse:
            locationWhenInUseButton.imageSource =  result? "./assets/location.png" : "./assets/location_off.png"
            locationWhenInUsePermissionStatusLabel.text = "Location Permission Status: %1".arg(result ?  "Granted" : "Denied")
            break;

        case PermissionDialog.PermissionDialogTypeStorage:
            storagePermissionButton.imageSource = result ? "./assets/storage.png" : "./assets/storage_off.png"
            storagePermissionStatusLabel.text = "Storage Permission Status: %1".arg(result ?  "Granted" : "Denied")
            break;
        }
    }

    Component.onCompleted: {
        microphoneButton.imageSource = Permission.checkPermission(Permission.PermissionTypeMicrophone) === Permission.PermissionResultGranted ? "./assets/microphone.png" : "./assets/microphone_off.png"
        microphonePermissionStatusLabel.text = "Microphone Permission Status: %1".arg(processPermission(Permission.PermissionTypeMicrophone))
        cameraButton.imageSource = Permission.checkPermission(Permission.PermissionTypeCamera) === Permission.PermissionResultGranted ? "./assets/camera.png" : "./assets/camera_off.png"
        cameraPermissionStatusLabel.text = "Camera Permission Status: %1".arg(processPermission(Permission.PermissionTypeCamera))
        storagePermissionButton.imageSource = Permission.checkPermission(Permission.PermissionTypeStorage) === Permission.PermissionResultGranted ? "./assets/storage.png" : "./assets/storage_off.png"
        storagePermissionStatusLabel.text = "Storage Permission Status: %1".arg(processPermission(Permission.PermissionTypeStorage))
        locationWhenInUseButton.imageSource = Permission.checkPermission(Permission.PermissionTypeLocationWhenInUse) === Permission.PermissionResultGranted ? "./assets/location.png" : "./assets/location_off.png"
        locationWhenInUsePermissionStatusLabel.text = "Location Permission Status: %1".arg(processPermission(Permission.PermissionTypeLocationWhenInUse))
        locationAlwaysInUseButton.imageSource = Permission.checkPermission(Permission.PermissionTypeLocationAlwaysInUse) === Permission.PermissionResultGranted ? "./assets/location.png" : "./assets/location_off.png"
        locationAlwaysInUsePermissionStatusLabel.text = "Background Location Permission Status: %1".arg(processPermission(Permission.PermissionTypeLocationAlwaysInUse))
    }
}
