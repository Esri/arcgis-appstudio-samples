/* Copyright 2018 Esri
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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework.Devices 1.0

Item {
    id: devicePage

    property DeviceDiscoveryAgent discoveryAgent
    property Device currentDevice
    property bool isConnecting
    property bool isConnected

    property string hostname: hostnameTF.text
    property string port: portTF.text

    property bool showDevices: true
    property bool bluetoothOnly: Qt.platform.os === "ios" || Qt.platform.os === "android"

    signal networkHostSelected(string hostname, int port)
    signal deviceSelected(Device device)
    signal disconnect()

    //--------------------------------------------------------------------------

    onNetworkHostSelected: {
        app.settings.setValue("hostname", hostname);
        app.settings.setValue("port", port);

        sources.networkHostSelected(hostname, port);
    }

    //--------------------------------------------------------------------------

    onDeviceSelected: {
        app.settings.setValue("device", device.name);

        sources.deviceSelected(device);
    }

    //--------------------------------------------------------------------------

    onDisconnect: {
        sources.disconnect();
    }

    //--------------------------------------------------------------------------

    ButtonGroup {
        id: buttonGroup

        buttons: [tcpRadioButton, deviceRadioButton]
    }

    //--------------------------------------------------------------------------

    ColumnLayout {
        anchors.fill: parent
        Layout.fillHeight: true
        Layout.fillWidth: true
        spacing: 0

        Label {
            Layout.fillWidth: true

            text: qsTr("DISCOVERY SETTINGS")
            font.pixelSize: baseFontSize
            topPadding: 30 * scaleFactor
            bottomPadding: 8 * scaleFactor
            leftPadding: 12 * scaleFactor
            color: "grey"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1 * scaleFactor
            color: "lightgrey"
        }

        //--------------------------------------------------------------------------

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 200 * scaleFactor
            color: navBarColor

            GridLayout {
                columns: 4
                rows: 5
                rowSpacing: 0

                anchors.fill: parent
                anchors.leftMargin: 12 * scaleFactor
                anchors.rightMargin: 12 * scaleFactor
                Material.accent: primaryColor

                //--------------------------------------------------------------------------

                RadioButton {
                    id: tcpRadioButton

                    Layout.row: 0
                    Layout.column: 0
                    Layout.columnSpan: 4
                    Layout.fillWidth: true

                    text: "TCP/UDP Connection"
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor

                    checked: false
                }

                //--------------------------------------------------------------------------

                Label {
                    enabled: !showDevices
                    visible: !showDevices

                    Layout.row: 1
                    Layout.column: 0

                    text: "Hostname"
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor
                }

                TextField {
                    id: hostnameTF

                    enabled: !showDevices
                    visible: !showDevices

                    Layout.row: 1
                    Layout.column: 1
                    Layout.columnSpan: 2
                    Layout.fillWidth: true

                    text: app.settings.value("hostname", "");
                    placeholderText: "Hostname"
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor
                }

                //--------------------------------------------------------------------------

                Label {
                    enabled: !showDevices
                    visible: !showDevices

                    Layout.row: 2
                    Layout.column: 0

                    text: "Port"
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor
                }

                TextField {
                    id: portTF

                    enabled: !showDevices
                    visible: !showDevices

                    Layout.row: 2
                    Layout.column: 1
                    Layout.columnSpan: 2
                    Layout.fillWidth: true

                    text: app.settings.value("port", "").toString();
                    placeholderText: "Port"
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor
                }

                Button {
                    id: connectBtn

                    enabled: !showDevices && hostname && port
                    visible: !showDevices

                    Layout.row: 2
                    Layout.column: 3
                    Layout.alignment: Qt.AlignHCenter

                    text: qsTr("Connect")
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor

                    onClicked: networkHostSelected(hostname, port)
                }

                //--------------------------------------------------------------------------

                RadioButton {
                    id: deviceRadioButton

                    Layout.row: 3
                    Layout.column: 0
                    Layout.columnSpan: 4
                    Layout.fillWidth: true

                    text: "External device"
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor

                    checked: true

                    onCheckedChanged: {
                        disconnect();
                        showDevices = checked
                        discoverySwitch.checked = false;
                    }
                }

                //--------------------------------------------------------------------------

                Switch {
                    id: discoverySwitch

                    enabled: showDevices && (bluetoothCheckBox.checked || usbCheckBox.checked)
                    visible: showDevices

                    Layout.row: 4
                    Layout.column: 0
                    Layout.columnSpan: 2
                    Layout.fillWidth: true

                    text: "Discovery %1".arg(checked ? "on" : "off")
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor

                    Component.onCompleted: {
                        checked = true;
                    }

                    onCheckedChanged: {
                        if (checked) {
                            disconnect();
                            discoveryAgent.start();
                        } else {
                            discoveryAgent.stop();
                        }
                    }

                    Connections {
                        target: discoveryAgent

                        onRunningChanged: discoverySwitch.checked = discoveryAgent.running
                    }
                }

                CheckBox {
                    id: bluetoothCheckBox

                    enabled: showDevices && !discoverySwitch.checked
                    visible: showDevices && !bluetoothOnly

                    Layout.row: 4
                    Layout.column: 2

                    text: "Bluetooth"
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor

                    checked: true

                    onCheckedChanged: discoveryAgent.detectBluetooth = checked
                }

                CheckBox {
                    id: usbCheckBox

                    enabled: showDevices && !discoverySwitch.checked
                    visible: showDevices && !bluetoothOnly

                    Layout.row: 4
                    Layout.column: 3

                    text: "USB/COM"
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor

                    checked: false

                    onCheckedChanged: discoveryAgent.detectSerialPort = checked
                }
            }
        }

        //--------------------------------------------------------------------------

        Rectangle {
            Layout.fillWidth: true
            height: 1 * scaleFactor
            color: "lightgrey"
        }

        Item {
            height: 20 * scaleFactor
        }

        //--------------------------------------------------------------------------

        RowLayout {
            id: deviceRowLayout

            Label {
                Layout.fillWidth: true

                text: qsTr("SELECT A DEVICE")
                font.pixelSize: baseFontSize
                leftPadding: 12 * scaleFactor
                color: "grey"
            }

            Item {
                height: 25 * scaleFactor
                width: height

                BusyIndicator {
                    anchors.fill: parent

                    running: discoveryAgent.running
                    Material.accent: "#8f499c"
                }
            }
        }

        Item {
            height: 5 * scaleFactor
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1 * scaleFactor
            color: "lightgrey"
        }

        ListView {
            id: deviceListView

            enabled: showDevices
            visible: showDevices

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            clip: true

            model: discoveryAgent.devices
            delegate: deviceDelegate
        }

        Item {
            visible: !deviceListView.visible

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: deviceDelegate

        Rectangle {
            width: ListView.view.width
            height: deviceLayout.height

            color: navBarColor
            opacity: parent.enabled ? 1.0 : 0.7

            ColumnLayout {
                id: deviceLayout

                width: parent.width
                spacing: 20 * scaleFactor

                RowLayout {
                    Layout.fillWidth: true
                    anchors.verticalCenter: parent.verticalCenter

                    Item {
                        width: 12 * scaleFactor
                    }

                    Image {
                        id: deviceImage

                        width: 25 * scaleFactor
                        height: width
                        Layout.preferredWidth: 25 * scaleFactor
                        Layout.preferredHeight: Layout.preferredWidth

                        source:"../assets/deviceType-%1.png".arg(deviceType)
                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: deviceImage
                        source: deviceImage
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? app.primaryColor : "black"
                    }

                    Item {
                        width: 2 * scaleFactor
                    }

                    Text {
                        Layout.fillWidth: true

                        text: currentDevice && (currentDevice.name === name) ? isConnecting ? name + qsTr(" (Connecting...)") : isConnected ? name + qsTr(" (Connected)") : name : name
                        font.pixelSize: baseFontSize * 0.9
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? app.primaryColor : "black"
                    }

                    Image {
                        id:rightImage

                        anchors.right: parent.right
                        width: 25 * scaleFactor
                        height: width
                        Layout.preferredWidth: 25 * scaleFactor
                        Layout.preferredHeight: Layout.preferredWidth

                        source:"../assets/right.png"
                        fillMode: Image.PreserveAspectFit
                    }

                    ColorOverlay {
                        anchors.fill: rightImage
                        source: rightImage
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? app.primaryColor : "black"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1 * scaleFactor
                    color: "lightgrey"
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (!isConnecting && !isConnected || currentDevice && currentDevice.name !== name) {
                        deviceListView.currentIndex = index;
                        deviceSelected(discoveryAgent.devices.get(index));
                    } else {
                        app.settings.remove("device");

                        deviceListView.currentIndex = -1;
                        disconnect();
                    }
                }

                Component.onCompleted: {
                    var stored = app.settings.value("device", "");

                    if (showDevices && !isConnecting && !isConnected && stored > "" && stored === name) {
                        deviceListView.currentIndex = index;
                        deviceSelected(discoveryAgent.devices.get(index));
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    BusyIndicator {
        running: isConnecting
        visible: running

        height: 48 * scaleFactor
        width: height
        anchors.centerIn: parent

        Material.accent:"#8f499c"
    }

    // -------------------------------------------------------------------------
}
