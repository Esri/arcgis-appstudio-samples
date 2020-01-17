import QtQuick 2.9
import QtQuick.Controls 2.2

import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Positioning 1.0

Item {
    readonly property var eConnectionType: {
        "internal": 0,
        "external": 1,
        "network": 2
    }

    property PositioningSources sources

    readonly property PositionSource positionSource: sources.positionSource
    readonly property SatelliteInfoSource satelliteInfoSource: sources.satelliteInfoSource
    readonly property NmeaSource nmeaSource: sources.nmeaSource
    readonly property TcpSocket tcpSocket: sources.tcpSocket
    readonly property DeviceDiscoveryAgent discoveryAgent: sources.discoveryAgent
    readonly property Device currentDevice: sources.currentDevice

    readonly property string currentNetworkAddress: sources.currentNetworkAddress
    readonly property string integratedProviderName: sources.integratedProviderName

    readonly property bool isConnecting: positionSource.valid && !useInternalGPS && sources.isConnecting
    readonly property bool isConnected: positionSource.valid && (useInternalGPS || sources.isConnected)

    property bool discoverBluetooth: app.settings.boolValue("discoverBluetooth", true)
    property bool discoverBluetoothLE: app.settings.boolValue("discoverBluetoothLE", false)
    property bool discoverSerialPort: app.settings.boolValue("discoverSerialPort", false)

    property int connectionType: app.settings.numberValue("connectionType", eConnectionType.internal);
    property string storedDeviceName: app.settings.value("deviceName", "");
    property string storedDeviceJSON: app.settings.value("deviceDescriptor", "");
    property string hostname: app.settings.value("hostname", "");
    property int port: app.settings.numberValue("port", Number.NaN);

    readonly property bool useInternalGPS: connectionType === eConnectionType.internal
    readonly property bool useExternalGPS: connectionType === eConnectionType.external
    readonly property bool useTCPConnection: connectionType === eConnectionType.network

    readonly property string currentName:
        useInternalGPS ? integratedProviderName :
        useExternalGPS && currentDevice ? currentDevice.name :
        useTCPConnection && currentNetworkAddress > "" ? currentNetworkAddress : ""

    property bool stayConnected
    property bool initialized

    signal networkHostSelected(string hostname, int port)
    signal deviceSelected(Device device)
    signal deviceDeselected()
    signal disconnect()
    signal reconnect()
    signal fullDisconnect()

    // -------------------------------------------------------------------------

    Component.onCompleted: {
        // prepare to connect to device that was used previously
        if (storedDeviceJSON > "") {
            sources.currentDevice = Device.fromJson(storedDeviceJSON);
        }

        initialized = true;
    }

    // -------------------------------------------------------------------------

    onIsConnectedChanged: {
        if (initialized) {
            if (isConnected) {
                if (connectionType === eConnectionType.external && currentDevice) {
                    console.log("Connected to device:", currentDevice.name, "address:", currentDevice.address);
                } else if (connectionType === eConnectionType.network) {
                    console.log("Connected to remote host:", tcpSocket.remoteName, "port:", tcpSocket.remotePort);
                } else if (connectionType === eConnectionType.internal) {
                    console.log("Connected to system location source:", integratedProviderName);
                }
            } else {
                if (connectionType === eConnectionType.external && currentDevice) {
                    console.log("Disconnecting device:", currentDevice.name, "address", currentDevice.address);
                } else if (connectionType === eConnectionType.network) {
                    console.log("Disconnecting from remote host:", tcpSocket.remoteName, "port:", tcpSocket.remotePort);
                } else if (connectionType === eConnectionType.internal) {
                    console.log("Disconnecting from system location source:", integratedProviderName);
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    onReconnect: {
        if (!reconnectTimer.running) {
            reconnectTimer.start();
        }
    }

    function reconnectNow() {
        if (useExternalGPS) {
            if (!discoveryAgent.running && !isConnecting && !isConnected) {
                if (currentDevice) {
                    var isBT = currentDevice.deviceType === Device.DeviceTypeBluetooth;
                    var isBTLE = currentDevice.deviceType === Device.DeviceTypeBluetoothLE;
                    var isSerial = currentDevice.deviceType === Device.DeviceTypeSerialPort;

                    if (isBT && discoverBluetooth || isBTLE && discoverBluetoothLE || isSerial && discoverSerialPort) {
                        deviceSelected(currentDevice)
                    }
                }
            }
        } else if (useTCPConnection) {
            if (!isConnecting && !isConnected) {
                if (hostname > "" && port > "") {
                    sources.networkHostSelected(hostname, port);
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: app.settings

        onValueChanged: {
            storedDeviceName = app.settings.value("deviceName", "")
            storedDeviceJSON = app.settings.value("deviceDescriptor", "")
            hostname = app.settings.value("hostname", "")
            port = app.settings.value("port", "")
        }
    }

    // -------------------------------------------------------------------------

    onDiscoverBluetoothChanged: {
        if (initialized) {
            app.settings.setValue("discoverBluetooth", discoverBluetooth);
        }
    }

    // -------------------------------------------------------------------------

    onDiscoverBluetoothLEChanged: {
        if (initialized) {
            app.settings.setValue("discoverBluetoothLE", discoverBluetoothLE);
        }
    }

    // -------------------------------------------------------------------------

    onDiscoverSerialPortChanged: {
        if (initialized) {
            app.settings.setValue("discoverSerialPort", discoverSerialPort);
        }
    }

    // -------------------------------------------------------------------------

    onConnectionTypeChanged: {
        if (initialized) {
            app.settings.setValue("connectionType", connectionType);
        }
    }

    // -------------------------------------------------------------------------

    onNetworkHostSelected: {
        sources.networkHostSelected(hostname, port);
    }

    // -------------------------------------------------------------------------

    onDeviceSelected: {
        sources.deviceSelected(device);
    }

    // -------------------------------------------------------------------------

    onDeviceDeselected: {
        sources.disconnect();
    }

    // -------------------------------------------------------------------------

    onDisconnect: {
        sources.disconnect();
    }

    // -------------------------------------------------------------------------

    onFullDisconnect: {
        sources.disconnect();
        discoveryAgent.stop();
        discoveryTimer.stop();
        reconnectTimer.stop();
    }

    // -------------------------------------------------------------------------

    Connections {
        target: tcpSocket

        onErrorChanged: {
            console.log("TCP connection error:", tcpSocket.error, tcpSocket.errorString)
            showError(tcpSocket.errorString);

//            if (useTCPConnection && stayConnected && !isConnecting && !isConnected) {
//                reconnect();
//            }
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: currentDevice

        onConnectedChanged: {
            if (currentDevice && useExternalGPS) {
                if (stayConnected) {
                    reconnect();
                }
            }
        }

        onErrorChanged: {
            if (currentDevice && useExternalGPS) {
                console.log("Device connection error:", currentDevice.error)
                showError(currentDevice.error);

                if (stayConnected) {
                    reconnect();
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: discoveryAgent

        property string lastError

        onDiscoverDevicesCompleted: {
            console.log("Device discovery completed");
        }

        onRunningChanged: {
            console.log("DeviceDiscoveryAgent running", discoveryAgent.running);
            if (useExternalGPS && !discoveryAgent.running && !isConnecting && !isConnected && stayConnected) {
                if (!discoveryAgent.devices || discoveryAgent.devices.count == 0) {
                    discoveryTimer.start();
                }
            }
        }

        onErrorChanged: {
            if (discoveryAgent.error !== lastError) {
                console.log("Device discovery agent error:", discoveryAgent.error)
                showError(discoveryAgent.error);

                lastError = discoveryAgent.error;
            }
        }

        onDeviceDiscovered: {
            if (discoveryAgent.filter(device)) {
                console.log("Device discovered - Name:", device.name, "Type:", device.deviceType);

                if (useExternalGPS && !isConnecting && !isConnected && storedDeviceName === device.name) {
                    deviceSelected(device);
                }
            }
        }
    }

    // -------------------------------------------------------------------------

    Timer {
        id: reconnectTimer

        interval: 1000
        running: false
        repeat: false

        onTriggered: {
            reconnectNow();
        }
    }

    // -------------------------------------------------------------------------

    Timer {
        id: discoveryTimer

        interval: 1000
        running: false
        repeat: false

        onTriggered: {
            discoveryAgent.start();
        }
    }

    // -------------------------------------------------------------------------

    Timer {
        id: connectionTimeOutTimer

        interval: 60000
        running: isConnecting
        repeat: false

        onTriggered: {
            console.log("Connection attempt timed out");
            fullDisconnect();
            reconnect();
        }
    }

    // -------------------------------------------------------------------------

    Dialog {
        id: errorDialog

        property alias text: errorMessage.text

        x: (app.width - width) / 2
        y: (app.height - height) / 2
        modal: true

        standardButtons: Dialog.Ok
        title: qsTr("Unable to connect");

        Text {
            id: errorMessage

            width: errorDialog.width
            wrapMode: Text.WordWrap

            text: ""
        }
    }

    function showError(error) {
        errorDialog.text = error;
        errorDialog.open();
    }

    // -------------------------------------------------------------------------
}
