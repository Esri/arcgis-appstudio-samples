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
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0

import "./controls"

Item {
    id: devicePage

    property PositioningSources sources
    property PositioningSourcesController controller

    property color foregroundColor: "black"
    property color secondaryForegroundColor: "green"
    property color backgroundColor: "#FAFAFA"
    property color secondaryBackgroundColor: "#F0F0F0"
    property color connectedColor: "green"

    property int sideMargin: 15 * AppFramework.displayScaleFactor

    // Internal properties -----------------------------------------------------

    readonly property DeviceDiscoveryAgent discoveryAgent: controller.discoveryAgent
    readonly property Device currentDevice: controller.currentDevice
    readonly property bool isConnecting: controller.isConnecting
    readonly property bool isConnected: controller.isConnected

    readonly property string hostname: hostnameTF.text
    readonly property string port: portTF.text

    readonly property bool bluetoothOnly: Qt.platform.os === "ios" || Qt.platform.os === "android"
    readonly property bool selectionValid: bluetoothCheckBox.checked || usbCheckBox.checked

    property bool showInternal
    property bool showNetwork
    property bool showDevices
    property bool initialized

    signal networkHostSelected(string hostname, int port)
    signal deviceSelected(Device device)
    signal deviceDeselected()
    signal disconnect()

    // -------------------------------------------------------------------------

    Component.onCompleted: {
        showInternal = controller.useInternalGPS;
        showNetwork = controller.useTCPConnection;
        showDevices = controller.useExternalGPS;
        initialized = true;

        if (!isConnecting && !isConnected && showDevices && selectionValid && (discoveryAgent.running || !discoveryAgent.devices || discoveryAgent.devices.count == 0)) {
            discoverySwitch.checked = true;
        } else {
            discoverySwitch.checked = false;
        }
    }

    // -------------------------------------------------------------------------

    onNetworkHostSelected: {
        app.settings.setValue("hostname", hostname);
        app.settings.setValue("port", port);

        controller.networkHostSelected(hostname, port);
    }

    // -------------------------------------------------------------------------

    onDeviceSelected: {
        app.settings.setValue("deviceName", device.name);
        app.settings.setValue("deviceDescriptor", JSON.stringify(device.toJson()));

        controller.deviceSelected(device);
    }

    // -------------------------------------------------------------------------

    onDeviceDeselected: {
        app.settings.remove("deviceName");
        app.settings.remove("deviceDescriptor");

        controller.disconnect();
    }

    // -------------------------------------------------------------------------

    onDisconnect: {
        controller.disconnect();
    }

    // -------------------------------------------------------------------------

    ButtonGroup {
        id: buttonGroup

        buttons: [internalRadioButton.radioButton, tcpRadioButton.radioButton, deviceRadioButton.radioButton]
    }

    // -------------------------------------------------------------------------

    Rectangle {
        anchors.fill: parent
        color: showDevices ? backgroundColor : secondaryBackgroundColor
        Accessible.role: Accessible.Pane

        Flickable {
            anchors.fill: parent

            Accessible.role: Accessible.Pane

            interactive: true
            flickableDirection: Flickable.VerticalFlick
            clip: true

            ColumnLayout {
                anchors.fill: parent
                Accessible.role: Accessible.Pane

                spacing: 0

                // -------------------------------------------------------------------------

                Rectangle {
                    id: connectionTitleRect

                    Layout.fillWidth: true
                    Layout.preferredHeight: 50 * AppFramework.displayScaleFactor

                    color: secondaryBackgroundColor
                    Accessible.role: Accessible.Pane

                    Text {
                        id: connectionTitle

                        anchors.fill: parent
                        anchors.leftMargin: sideMargin
                        anchors.bottomMargin: 5 * AppFramework.displayScaleFactor

                        text: qsTr("POSITION SOURCE")
                        verticalAlignment: Text.AlignBottom
                        color: foregroundColor

                        Accessible.role: Accessible.Heading
                        Accessible.name: text
                        Accessible.description: qsTr("Choose the position source type")
                    }
                }

                // -------------------------------------------------------------------------

                Rectangle {
                    id: connectionTypeGridRect

                    Layout.fillWidth: true
                    Layout.preferredHeight: connectionTypeGrid.height

                    color: backgroundColor
                    Accessible.role: Accessible.Pane

                    GridLayout {
                        id: connectionTypeGrid

                        columns: 3
                        rows: 6

                        anchors.left: parent.left
                        anchors.right: parent.right
                        Accessible.role: Accessible.Pane

                        // -------------------------------------------------------------------------

                        GNSSRadioButton {
                            id: internalRadioButton

                            Layout.row: 0
                            Layout.column: 0
                            Layout.columnSpan: 3
                            Layout.leftMargin: sideMargin
                            Accessible.role: Accessible.RadioButton

                            foregroundColor: devicePage.foregroundColor
                            secondaryForegroundColor: devicePage.secondaryForegroundColor
                            backgroundColor: devicePage.backgroundColor
                            secondaryBackgroundColor: devicePage.secondaryBackgroundColor

                            text: qsTr("Built-in location sensor")
                            checked: showInternal ? true : false

                            onCheckedChanged: {
                                if (initialized) {
                                    showInternal = checked ? true : false;
                                    if (checked) {
                                        controller.connectionType = controller.eConnectionType.internal;
                                        discoverySwitch.checked = false;
                                        disconnect();
                                    }
                                }
                            }
                        }

                        // -------------------------------------------------------------------------

                        GNSSRadioButton {
                            id: tcpRadioButton

                            Layout.row: 1
                            Layout.column: 0
                            Layout.columnSpan: 3
                            Layout.leftMargin: sideMargin
                            Accessible.role: Accessible.RadioButton

                            foregroundColor: devicePage.foregroundColor
                            secondaryForegroundColor: devicePage.secondaryForegroundColor
                            backgroundColor: devicePage.backgroundColor
                            secondaryBackgroundColor: devicePage.secondaryBackgroundColor

                            text: qsTr("TCP/UDP connection")
                            checked: showNetwork ? true : false

                            onCheckedChanged: {
                                if (initialized) {
                                    showNetwork = checked ? true : false;
                                    if (checked) {
                                        controller.connectionType = controller.eConnectionType.network;
                                        discoverySwitch.checked = false;
                                        disconnect();
                                    }
                                }
                            }
                        }

                        // -------------------------------------------------------------------------

                        Label {
                            enabled: showNetwork
                            visible: showNetwork

                            Layout.row: 2
                            Layout.column: 0
                            Layout.leftMargin: sideMargin

                            text: qsTr("Hostname")
                            color: foregroundColor
                        }

                        TextField {
                            id: hostnameTF

                            enabled: showNetwork
                            visible: showNetwork

                            Layout.row: 2
                            Layout.column: 1
                            Layout.fillWidth: true

                            text: controller.hostname
                            placeholderText: qsTr("Hostname")
                        }

                        // -------------------------------------------------------------------------

                        Label {
                            enabled: showNetwork
                            visible: showNetwork

                            Layout.row: 3
                            Layout.column: 0
                            Layout.leftMargin: sideMargin

                            text: qsTr("Port")
                            color: foregroundColor
                        }

                        TextField {
                            id: portTF

                            enabled: showNetwork
                            visible: showNetwork

                            Layout.row: 3
                            Layout.column: 1
                            Layout.fillWidth: true

                            text: controller.port
                            placeholderText: qsTr("Port")
                        }

                        Button {
                            id: connectBtn

                            enabled: showNetwork && hostname && port
                            visible: showNetwork

                            Layout.row: 3
                            Layout.column: 2
                            Layout.rightMargin: sideMargin
                            Accessible.role: Accessible.Button

                            text: qsTr("Connect")

                            onClicked: networkHostSelected(hostname, port)
                        }

                        // -------------------------------------------------------------------------

                        GNSSRadioButton {
                            id: deviceRadioButton

                            Layout.row: 4
                            Layout.column: 0
                            Layout.columnSpan: 3
                            Layout.leftMargin: sideMargin
                            Accessible.role: Accessible.RadioButton

                            foregroundColor: devicePage.foregroundColor
                            secondaryForegroundColor: devicePage.secondaryForegroundColor
                            backgroundColor: devicePage.backgroundColor
                            secondaryBackgroundColor: devicePage.secondaryBackgroundColor

                            text: qsTr("External GNSS receiver")
                            checked: showDevices ? true : false

                            onCheckedChanged: {
                                if (initialized) {
                                    showDevices = checked ? true : false;
                                    if (checked) {
                                        controller.connectionType = controller.eConnectionType.external;
                                        disconnect();
                                        discoverySwitch.checked = discoveryAgent.devices.count == 0;
                                    }
                                }
                            }
                        }

                        // -------------------------------------------------------------------------

                        GNSSSwitch {
                            id: discoverySwitch

                            enabled: showDevices && selectionValid
                            visible: showDevices

                            Layout.row: 5
                            Layout.column: 0
                            Layout.fillWidth: true
                            Layout.leftMargin: sideMargin
                            Accessible.role: Accessible.CheckBox

                            foregroundColor: devicePage.foregroundColor
                            secondaryForegroundColor: devicePage.secondaryForegroundColor
                            backgroundColor: devicePage.backgroundColor
                            secondaryBackgroundColor: devicePage.secondaryBackgroundColor

                            text: qsTr("Discover")

                            onCheckedChanged: {
                                if (initialized) {
                                    if (checked) {
                                        disconnect();
                                        if (!discoveryAgent.running) {
                                            discoveryAgent.start();
                                        }
                                    } else {
                                        discoveryAgent.stop();
                                    }
                                }
                            }

                            Connections {
                                target: discoveryAgent

                                onRunningChanged: discoverySwitch.checked = discoveryAgent.running
                            }
                        }

                        GNSSCheckBox {
                            id: bluetoothCheckBox

                            enabled: showDevices && !discoverySwitch.checked
                            visible: showDevices && !bluetoothOnly

                            Layout.row: 5
                            Layout.column: 1
                            Accessible.role: Accessible.CheckBox

                            foregroundColor: devicePage.foregroundColor
                            secondaryForegroundColor: devicePage.secondaryForegroundColor
                            backgroundColor: devicePage.backgroundColor
                            secondaryBackgroundColor: devicePage.secondaryBackgroundColor

                            text: qsTr("Bluetooth")

                            checked: controller.discoverBluetooth ? true : false
                            onCheckedChanged: {
                                if (initialized) {
                                    controller.discoverBluetooth = checked ? true : false
                                }
                            }
                        }

                        GNSSCheckBox {
                            id: usbCheckBox

                            enabled: showDevices && !discoverySwitch.checked
                            visible: showDevices && !bluetoothOnly

                            Layout.row: 5
                            Layout.column: 2
                            Layout.rightMargin: sideMargin
                            Accessible.role: Accessible.CheckBox

                            foregroundColor: devicePage.foregroundColor
                            secondaryForegroundColor: devicePage.secondaryForegroundColor
                            backgroundColor: devicePage.backgroundColor
                            secondaryBackgroundColor: devicePage.secondaryBackgroundColor

                            text: qsTr("USB/COM")

                            checked: controller.discoverSerialPort ? true : false
                            onCheckedChanged: {
                                if (initialized) {
                                    controller.discoverSerialPort = checked ? true : false
                                }
                            }
                        }
                    }
                }

                // -------------------------------------------------------------------------

                Rectangle {
                    id: deviceTitleRowRect

                    enabled: showDevices
                    visible: showDevices

                    Layout.fillWidth: true;
                    Layout.preferredHeight: 50 * AppFramework.displayScaleFactor

                    color: secondaryBackgroundColor
                    Accessible.role: Accessible.Pane

                    RowLayout {
                        id: deviceTitleRow

                        anchors.fill: parent
                        spacing: 0
                        Accessible.role: Accessible.Pane

                        Text {
                            id: deviceTitle

                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.leftMargin: sideMargin
                            Layout.bottomMargin: 5 * AppFramework.displayScaleFactor

                            text: qsTr("SELECT A DEVICE")
                            verticalAlignment: Text.AlignBottom
                            color: foregroundColor

                            Accessible.role: Accessible.Heading
                            Accessible.name: text
                            Accessible.description: qsTr("Choose an external GNSS receiver")
                        }

                        Rectangle {
                            id: discoveryIndicatorRect

                            Layout.fillHeight: true
                            Layout.preferredWidth: 30 * AppFramework.displayScaleFactor
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: sideMargin
                            color: secondaryBackgroundColor
                            Accessible.role: Accessible.Pane

                            BusyIndicator {
                                id: discoveryIndicator

                                anchors.fill: parent
                                Accessible.role: Accessible.Pane

                                running: discoveryAgent.running
                            }

                            ColorOverlay {
                                anchors.fill: discoveryIndicator
                                source: discoveryIndicator
                                color: connectedColor
                            }
                        }
                    }
                }

                // -------------------------------------------------------------------------

                ListView {
                    id: deviceListRect

                    enabled: showDevices
                    visible: showDevices

                    Layout.fillWidth: true;
                    Layout.fillHeight: true;

                    Accessible.role: Accessible.Pane

                    clip: true

                    model: discoveryAgent.devices
                    delegate: deviceDelegate
                }

                Rectangle {
                    id: fillerRect

                    enabled: !deviceListRect.enabled
                    visible: !deviceListRect.visible

                    Layout.fillWidth: true;
                    Layout.fillHeight: true;

                    color: "transparent"
                    Accessible.role: Accessible.Pane
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    Component {
        id: deviceDelegate

        Rectangle {
            id: delegateRect

            height: deviceLayout.height
            width: deviceListRect.width
            Accessible.role: Accessible.Pane

            color: backgroundColor
            opacity: parent.enabled ? 1.0 : 0.7

            ColumnLayout {
                id: deviceLayout

                height: rowLayout.height + separator.height
                width: delegateRect.width
                Accessible.role: Accessible.Pane
                spacing: 0

                RowLayout {
                    id: rowLayout

                    Layout.fillWidth: true
                    height: 45 * AppFramework.displayScaleFactor

                    spacing: 10 * AppFramework.displayScaleFactor

                    Accessible.role: Accessible.StaticText
                    Accessible.name: deviceName.text

                    Item {
                        width: 25 * AppFramework.displayScaleFactor
                        height: width

                        Layout.preferredWidth: leftImage.width
                        Layout.preferredHeight: leftImage.height
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: sideMargin
                        Accessible.ignored: true

                        Image {
                            id: leftImage

                            anchors.fill: parent
                            Accessible.ignored: true

                            source: "./images/deviceType-%1.png".arg(deviceType)
                            fillMode: Image.PreserveAspectFit
                        }

                        ColorOverlay {
                            anchors.fill: leftImage
                            source: leftImage
                            color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? connectedColor : foregroundColor
                        }
                    }

                    Text {
                        id: deviceName

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Accessible.ignored: true

                        text: currentDevice && (currentDevice.name === name) ? isConnecting ? name + qsTr(" (Connecting...)") : isConnected ? name + qsTr(" (Connected)") : name : name
                        color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? connectedColor : foregroundColor
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        verticalAlignment: Text.AlignVCenter
                    }

                    Item {
                        width: 25 * AppFramework.displayScaleFactor
                        height: rowLayout.height
                        Layout.preferredWidth: rightImage.width
                        Layout.preferredHeight: rightImage.height
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 10 * AppFramework.displayScaleFactor
                        Accessible.ignored: true

                        Image {
                            id: rightImage

                            anchors.fill: parent
                            Accessible.ignored: true

                            source: "./images/right.png"
                            fillMode: Image.PreserveAspectFit
                        }

                        ColorOverlay {
                            anchors.fill: rightImage
                            source: rightImage
                            color: currentDevice && (currentDevice.name === name) && (isConnecting || isConnected) ? connectedColor : foregroundColor
                        }
                    }
                }

                Rectangle {
                    id: separator

                    height: 1 * AppFramework.displayScaleFactor
                    Layout.fillWidth: true
                    Accessible.ignored: true
                    color: secondaryBackgroundColor
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (!isConnecting && !isConnected || currentDevice && currentDevice.name !== name) {
                        deviceSelected(discoveryAgent.devices.get(index));
                    } else {
                        deviceDeselected();
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    BusyIndicator {
        id: connectingIndicator

        height: 48 * AppFramework.displayScaleFactor
        width: height
        anchors.centerIn: parent

        running: isConnecting
        visible: running
    }

    ColorOverlay {
        anchors.fill: connectingIndicator
        source: connectingIndicator
        color: connectedColor
    }

    // -------------------------------------------------------------------------
}
