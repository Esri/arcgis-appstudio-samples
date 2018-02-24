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

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Speech 1.0

import "../controls" as Controls

Item {
    id: devicePage

    property Device currentDevice

    property string hostname: hostnameTF.text
    property string port: portTF.text

    property bool showDevices: true
    property bool isConnecting
    property bool isConnected

    readonly property string disconnectedText: qsTr("Device disconnected")
    readonly property string connectedText: qsTr("Device connected")
    readonly property bool bluetoothOnly: Qt.platform.os === "ios" || Qt.platform.os === "android"

    signal deviceSelected(string name, Device device)
    signal networkHostSelected(string hostname, int port)
    signal disconnect()
    signal showLocationPage()

    //--------------------------------------------------------------------------

    Component.onDestruction: {
        disconnect();
    }

    //--------------------------------------------------------------------------

    onDeviceSelected: {
        console.log("Connecting to device:", name, device, device.name, "type:", device.deviceType, "address:", device.address);

        disconnect();

        currentDevice = device;
        nmeaSource.source = currentDevice;

        // allow for a short delay before connecting so that the listview has time to update
        deviceConnectionTimer.interval = 1000;
        deviceConnectionTimer.start();
    }

    //--------------------------------------------------------------------------

    onNetworkHostSelected: {
        console.log("Connecting to remote host:", hostname, "port:", port);

        disconnect();

        app.settings.setValue("hostname", hostname);
        app.settings.setValue("port", port);

        nmeaSource.source = tcpSocket;
        tcpSocket.connectToHost(hostname, port);
    }

    //--------------------------------------------------------------------------

    onDisconnect: {
        if (tcpSocket.valid && tcpSocket.state === AbstractSocket.StateConnected) {
            console.log("Disconnecting from remote host:", tcpSocket.remoteName);
            tcpSocket.disconnectFromHost();
        }

        if (currentDevice && currentDevice.connected) {
            console.log("Disconnecting device:", currentDevice.name);
            currentDevice.connected = false;
            currentDevice = null;
        }

        isConnected = false;
        isConnecting = false;
    }

    //--------------------------------------------------------------------------

    onShowLocationPage: {
        locationPage.clear();
        debugPage.clear();
        footer.currentIndex = 1;
    }

    //--------------------------------------------------------------------------

    ButtonGroup {
        id: buttonGroup

        buttons: [tcpRadioButton, deviceRadioButton]
    }

    //--------------------------------------------------------------------------

    ColumnLayout {
        enabled: !isConnecting

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
            height: 180 * scaleFactor
            color: navBarColor

            GridLayout {
                columns: 4
                rows: 5
                rowSpacing: 0

                anchors.fill: parent
                anchors.leftMargin: 8 * scaleFactor
                anchors.rightMargin: 8 * scaleFactor
                Material.accent: primaryColor

                //--------------------------------------------------------------------------

                RadioButton {
                    id: tcpRadioButton

                    Layout.row: 0
                    Layout.column: 0
                    Layout.columnSpan: 4
                    Layout.fillWidth: true

                    text: "TCP Connection"
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
                        showDevices = checked
                        disconnect();
                        if (checked && discoverySwitch.checked) {
                            discoveryAgent.start();
                        } else {
                            discoveryAgent.stop();
                        }
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

                    text: "Discovery %1".arg(checked ? "active" : "off")
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor

                    Component.onCompleted: {
                        checked = true;
                    }

                    onCheckedChanged: {
                        if (checked) {
                            discoveryAgent.start();
                        } else {
                            discoveryAgent.stop();
                        }
                    }
                }

                CheckBox {
                    id: bluetoothCheckBox

                    enabled: showDevices && !discoverySwitch.checked
                    visible: showDevices

                    Layout.row: 4
                    Layout.column: 2

                    text: "Bluetooth"
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor

                    checked: true
                }

                CheckBox {
                    id: usbCheckBox

                    enabled: showDevices && !discoverySwitch.checked
                    visible: showDevices && !bluetoothOnly

                    Layout.row: 4
                    Layout.column: 3

                    text: "USB"
                    font.pixelSize: baseFontSize
                    Material.accent: primaryColor

                    checked: false
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

            Layout.row: 3
            Layout.column: 0
            Layout.columnSpan: 4
            Layout.fillWidth: true

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

            enabled: showDevices && !isConnecting
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

    BusyIndicator {
        running: isConnecting
        visible: running

        height: 48 * scaleFactor
        width: height
        anchors.centerIn: parent

        Material.accent:"#8f499c"
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

                        ColorOverlay {
                            anchors.fill: deviceImage
                            source: deviceImage
                            color: currentDevice && (currentDevice.name === name) ? app.primaryColor : "black"
                        }
                    }

                    Item {
                        width: 2 * scaleFactor
                    }

                    Text {
                        Layout.fillWidth: true

                        text: isConnecting && currentDevice && (currentDevice.name === name) ? "Connecting..." : name
                        font.pixelSize: baseFontSize * 0.9
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color:  currentDevice && (currentDevice.name === name) ? app.primaryColor : "black"
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
                        color: currentDevice && (currentDevice.name === name) ? app.primaryColor : "black"
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
                    if (index != deviceListView.currentIndex) {
                        deviceListView.currentIndex = index;
                        deviceSelected(name, discoveryAgent.devices.get(index));
                    } else {
                        deviceListView.currentIndex = -1;
                        disconnect();
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    DeviceDiscoveryAgent {
        id: discoveryAgent

        deviceFilter: function(device) {
            var types = [];

            if (bluetoothCheckBox.checked) {
                types.push(Device.DeviceTypeBluetooth);
            }

            if (usbCheckBox.checked) {
                types.push(Device.DeviceTypeSerialPort);
            }

            for (var i in types) {
                if (device.deviceType === types[i]) {
                    return true;
                }
            }

            return false;
        }

        onDeviceDiscovered: {
            console.log("Device discovered: ", device.name);
        }

        onDiscoverDevicesCompleted: {
            console.log("Device discovery completed");
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: tcpSocket

        onStateChanged: {
            switch (tcpSocket.state) {
            case AbstractSocket.StateUnconnected:
                isConnected = false;
                isConnecting = false;

                // XXX workaround for https://devtopia.esri.com/Melbourne/appstudio-framework/issues/455
                // tcpSocket.error does not fire changed events
                // XXX https://devtopia.esri.com/Melbourne/appstudio-framework/issues/456
                // tcpSocket.error should be cleared on reconnect
                if (tcpSocket.error !== AbstractSocket.ErrorUnknown) {
                    tcpSocket.errorChanged();
                }
                break;
            case AbstractSocket.StateHostLookup:
                isConnected = false;
                isConnecting = true;
                break;
            case AbstractSocket.StateConnecting:
                break;
            case AbstractSocket.StateConnected:
                console.log("Connected to", tcpSocket.remoteName, tcpSocket.remotePort)
                isConnected = true;
                isConnecting = false;
                showLocationPage();
                break;
            case AbstractSocket.StateBound:
                break;
             case AbstractSocket.StateListening:
                break;
             case AbstractSocket.StateClosing:
                 break;
            }
        }

        onErrorChanged: {
            if (tcpSocket.error !== tcpSocket.ErrorUnknown) {
                console.log("Connection error", tcpSocket.error, tcpSocket.errorString)
                errorDialog.text = tcpSocket.errorString;
                errorDialog.open();
            }
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: currentDevice

        onConnectedChanged: {
            if (currentDevice) {
                console.log("Device connected changed:", currentDevice.name, currentDevice.connected);

                if (!currentDevice.connected) {
                    textToSpeech.say(disconnectedText)

                    if (deviceListView.currentIndex != -1) {
                        deviceConnectionTimer.interval = 5000;
                        deviceConnectionTimer.start();
                    }
                }
            }
        }

        onErrorChanged: {
            if (currentDevice) {
                console.log("Connection error:", currentDevice.error)

                deviceConnectionTimer.stop();
                deviceConnectionCheckTimer.stop();

                errorDialog.text = currentDevice.error;
                errorDialog.open();

                currentDevice = null;
                isConnected = false;
                isConnecting = false;
            }
        }
    }

    // -------------------------------------------------------------------------

    Timer {
        id: deviceConnectionTimer

        interval: 5000
        running: false
        repeat: false

        onRunningChanged: {
            if (running) {
                isConnected = false;
                isConnecting = true;
                discoveryAgent.stop();
            }
        }

        onTriggered: {
            // try to connect
            if (currentDevice) {
                currentDevice.connected = true;
                deviceConnectionCheckTimer.running = true;
            }
        }
    }

    Timer {
        id: deviceConnectionCheckTimer

        interval: 10000
        running: false
        repeat: false

        onTriggered: {
            // check if connection attempt was successful
            if (currentDevice && currentDevice.connected === true) {
                textToSpeech.say(connectedText);

                isConnected = true;
                isConnecting = false;
                discoveryAgent.stop();

                if (footer.currentIndex === 0) {
                    showLocationPage();
                }
            } else if (discoverySwitch.checked) {
                isConnected = false;
                isConnecting = false;
                discoveryAgent.start();
            }
        }
    }

    TextToSpeech {
        id: textToSpeech
    }

    // -------------------------------------------------------------------------

    Dialog {
        id: errorDialog

        property alias text: label.text

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true

        standardButtons: Dialog.Ok
        title: qsTr("Unable to connect");
        text: ""

        Label {
            id: label

            Layout.fillWidth: true
            font.pixelSize: baseFontSize
            Material.accent: primaryColor
        }
    }

    //--------------------------------------------------------------------------
}
