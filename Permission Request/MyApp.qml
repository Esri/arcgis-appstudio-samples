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
    property bool isAndroid: Qt.platform.os === "android"
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

            Rectangle {
                anchors.fill: parent
                Material.elevation: 1
                border.color: "lightgrey"
                color: "#FAFAFA"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20*scaleFactor
                    spacing: 0


                    Label {
                        text: "Permission Status"
                        font.pointSize: baseFontSize *1.1
                        Layout.alignment: Qt.AlignLeft
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: 10
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        Switch {
                            id: openSettings
                            checked: true
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
                        id:microphoneRow
                        spacing: 10 * scaleFactor
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        Controls.FloatActionButton {
                            id: microphoneButton

                            onIconClicked: {
                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeMicrophone;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: microphonePermissionLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideLeft
                            text: "Microphone"
                            Layout.alignment: Qt.AlignRight
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            id: microphonePermissionStatusLabel
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            font.pointSize: baseFontSize * 0.9
                        }
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        Controls.FloatActionButton {
                            id: bluetoothButton

                            onIconClicked: {
                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeBluetooth;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: bluetoothPermissionLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideLeft
                            text: "Bluetooth"
                            Layout.alignment: Qt.AlignRight
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            id: bluetoothPermissionStatusLabel
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            font.pointSize: baseFontSize * 0.9
                        }
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        Controls.FloatActionButton {
                            id: cameraButton

                            onIconClicked: {
                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeCamera;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: cameraPermissionLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideLeft
                            text: "Camera"
                            Layout.alignment: Qt.AlignRight
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            id: cameraPermissionStatusLabel
                            font.pointSize: baseFontSize * 0.9
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        }
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor
                        visible: !isIOS || true
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        Controls.FloatActionButton {
                            id: storagePermissionButton
                            onIconClicked: {
                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeStorage;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: storagePermissionLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideLeft
                            text: "Storage"
                            Layout.alignment: Qt.AlignRight
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            id: storagePermissionStatusLabel
                            font.pointSize: baseFontSize * 0.9
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        }
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        Controls.FloatActionButton {
                            id: locationWhenInUseButton

                            onIconClicked: {
                                if (isIOS)
                                    if(getServiceStatusToString(Permission.serviceStatus(Permission.LocationService)) === "PoweredOff")
                                        locationServiceNotification.open();

                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeLocationWhenInUse;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: locationWhenInUsePermissionLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideLeft
                            text: isIOS?"Location When in Use":"Location"
                            Layout.alignment: Qt.AlignRight
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            id: locationWhenInUsePermissionStatusLabel
                            font.pointSize: baseFontSize * 0.9
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        }
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor
                        visible: isIOS || isAndroid
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        Controls.FloatActionButton {
                            id: locationAlwaysInUseButton

                            onIconClicked: {
                                if (isIOS)
                                    if(getServiceStatusToString(Permission.serviceStatus(Permission.LocationService)) === "PoweredOff")
                                        locationServiceNotification.open();

                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeLocationAlwaysInUse;
                                permissionDialog.open()
                            }
                        }

                        Label {
                            id: locationAlwaysInUsePermissionLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideLeft
                            text: "Location Always In Use"
                            Layout.alignment: Qt.AlignRight
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            id: locationAlwaysInUsePermissionStatusLabel
                            font.pointSize: baseFontSize * 0.9
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        }
                    }

                    Label {
                        text: "Service Status"
                        font.pointSize: baseFontSize *1.1
                        Layout.alignment: Qt.AlignLeft
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: 10 * scaleFactor
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        Image {
                            id: services

                            Layout.preferredWidth: 56 * scaleFactor
                            Layout.preferredHeight: Layout.preferredWidth
                            Material.elevation: 6
                            source: "./assets/service.svg"
                            fillMode: Image.Pad
                        }

                        Label {
                            id: servicesStatusLabel
                            font.pointSize: baseFontSize * 0.9
                            elide: Text.ElideMiddle
                            Layout.fillWidth: true
                            text: "Location Service: %1\nBluetooth Service: %2".arg(getServiceStatusToString(Permission.serviceStatus(Permission.LocationService)))
                            .arg(getServiceStatusToString(Permission.serviceStatus(Permission.BluetoothService)))
                        }

                        Controls.FloatActionButton {
                            id: serviceRefreshButton

                            imageSource: "./assets/refresh-24px.png"
                            onIconClicked: {
                                servicesStatusLabel.text = "Location Service: %1\nBluetooth Service: %2".arg(getServiceStatusToString(Permission.serviceStatus(Permission.LocationService)))
                                .arg(getServiceStatusToString(Permission.serviceStatus(Permission.BluetoothService)))
                            }
                        }
                    }

                    Label {
                        id: notificationLabel
                        Layout.alignment: Qt.AlignCenter
                        font.pointSize: baseFontSize * 0.9
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: "(You can manage the services via device settings)"
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

    function getServiceStatusToString(status) {
        switch (status) {
        case Permission.ServiceStatusUnknown:
            return "Unknown";
        case Permission.ServiceStatusReset:
            return "Reset";
        case Permission.ServiceStatusUnsupported:
            return "Unsupported";
        case Permission.ServiceStatusUnauthorized:
            return "Unauthorized";
        case Permission.ServiceStatusPoweredOff:
            return "PoweredOff";
        case Permission.ServiceStatusPoweredOn:
            return "PoweredOn";
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage {
        id: descPage
        visible: false
    }

    PermissionDialog {
        id: permissionDialog
        openSettingsWhenDenied: openSettings.checked === true

        onRejected: {
            processPermissionResult(permission, false)
        }

        onAccepted: {
            processPermissionResult(permission, true)
        }
    }

    Dialog{
        id: locationServiceNotification
        clip: true
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Ok
        width: Math.min(0.9 * app.width, 400*AppFramework.displayScaleFactor)
        Material.accent: "#8f499c"
        Text {
            id:textLabel
            anchors.fill: parent
            anchors.centerIn: parent
            text: qsTr( "The location service needs to be turned on in the device settings in order to make permission request." )
            wrapMode: Text.WordWrap
        }
    }

    function processPermissionResult(perm, result) {
        switch(perm) {
        case PermissionDialog.PermissionDialogTypeMicrophone:
            microphoneButton.imageSource = result ? "./assets/microphone.png" : "./assets/microphone_off.png"
            microphonePermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeMicrophone))
            break;

        case PermissionDialog.PermissionDialogTypeLocationAlwaysInUse:
            locationAlwaysInUseButton.imageSource = result ? "./assets/location.png" : "./assets/location_off.png"
            locationAlwaysInUsePermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeLocationAlwaysInUse))
            refreshPermissions();
            break;

        case PermissionDialog.PermissionDialogTypeBluetooth:
            bluetoothButton.imageSource = result ? "./assets/bluetooth.png" : "./assets/bluetooth_off.png"
            bluetoothPermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeBluetooth))
            refreshPermissions();
            break;

        case PermissionDialog.PermissionDialogTypeCamera:
            cameraButton.imageSource = result ? "./assets/camera.png" : "./assets/camera_off.png"
            cameraPermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeCamera))
            break;

        case PermissionDialog.PermissionDialogTypeLocationWhenInUse:
            locationWhenInUseButton.imageSource =  result? "./assets/location.png" : "./assets/location_off.png"
            locationWhenInUsePermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeLocationWhenInUse))
            refreshPermissions();
            break;

        case PermissionDialog.PermissionDialogTypeStorage:
            storagePermissionButton.imageSource = result ? "./assets/storage.png" : "./assets/storage_off.png"
            storagePermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeStorage))
            break;
        }
    }

    function refreshPermissions(){
        microphoneButton.imageSource = Permission.checkPermission(Permission.PermissionTypeMicrophone) === Permission.PermissionResultGranted ? "./assets/microphone.png" : "./assets/microphone_off.png"
        microphonePermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeMicrophone))
        bluetoothButton.imageSource = Permission.checkPermission(Permission.PermissionTypeBluetooth) === Permission.PermissionResultGranted ? "./assets/bluetooth.png" : "./assets/bluetooth_off.png"
        bluetoothPermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeBluetooth))
        cameraButton.imageSource = Permission.checkPermission(Permission.PermissionTypeCamera) === Permission.PermissionResultGranted ? "./assets/camera.png" : "./assets/camera_off.png"
        cameraPermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeCamera))
        storagePermissionButton.imageSource = Permission.checkPermission(Permission.PermissionTypeStorage) === Permission.PermissionResultGranted ? "./assets/storage.png" : "./assets/storage_off.png"
        storagePermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeStorage))
        locationWhenInUseButton.imageSource = Permission.checkPermission(Permission.PermissionTypeLocationWhenInUse) === Permission.PermissionResultGranted ? "./assets/location.png" : "./assets/location_off.png"
        locationWhenInUsePermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeLocationWhenInUse))
        locationAlwaysInUseButton.imageSource = Permission.checkPermission(Permission.PermissionTypeLocationAlwaysInUse) === Permission.PermissionResultGranted ? "./assets/location.png" : "./assets/location_off.png"
        locationAlwaysInUsePermissionStatusLabel.text = "%1".arg(processPermission(Permission.PermissionTypeLocationAlwaysInUse))
    }

    Component.onCompleted: {
        refreshPermissions();
    }
}
