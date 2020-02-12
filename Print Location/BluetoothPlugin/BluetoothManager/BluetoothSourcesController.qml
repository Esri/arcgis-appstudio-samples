import QtQuick 2.12
import QtQuick.Controls 2.12

import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Positioning 1.0

Item {
    // -------------------------------------------------------------------------
    readonly property var eConnectionType: {
        "internal": 0
    }

    // -------------------------------------------------------------------------

    property BluetoothSources sources

    readonly property PositionSource positionSource: sources.positionSource
    readonly property DeviceDiscoveryAgent discoveryAgent: sources.discoveryAgent
    property Device currentDevice: sources.currentDevice
    readonly property bool isConnecting: false
    readonly property bool isConnected: true

    property bool discoverBluetooth: true
    property int connectionType: eConnectionType.internal
    property string storedDeviceName: ""
    property string storedDeviceJSON: ""

    readonly property bool useInternalGPS: true
    readonly property bool useExternalGPS: false

    readonly property string currentName: ""

    property bool errorWhileConnecting
    property bool onDetailedSettingsPage
    property bool onSettingsPage
    property bool stayConnected
    property bool initialized

    signal startPositionSource()
    signal stopPositionSource()
    signal startDiscoveryAgent()
    signal stopDiscoveryAgent()

    signal deviceError(string errorString)
    signal discoveryAgentError(string errorString)

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

    onReconnect: {
        if (!reconnectTimer.running) {
            reconnectTimer.start();
        }
    }

    function reconnectNow() {
        deviceSelected(currentDevice)
    }

    // -------------------------------------------------------------------------

    onStartPositionSource:  {
        positionSource.start();
    }

    // -------------------------------------------------------------------------

    onStopPositionSource:  {
        positionSource.stop();
    }

    // -------------------------------------------------------------------------

    onStartDiscoveryAgent: {
        discoveryTimer.start();
    }

    // -------------------------------------------------------------------------

    onStopDiscoveryAgent: {
        discoveryAgent.stop();
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
        target: currentDevice

        onErrorChanged: {
            console.log("Device connection error:", currentDevice.error)
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: discoveryAgent

        onDiscoverDevicesCompleted: {
            console.log("Device discovery completed");
        }

        onRunningChanged: {
            console.log("DeviceDiscoveryAgent running", discoveryAgent.running);
            if (useExternalGPS && !discoveryAgent.running && !isConnecting && !isConnected && stayConnected && !onSettingsPage) {
                if (!discoveryAgent.devices || discoveryAgent.devices.count == 0) {
                    discoveryTimer.start();
                }
            }
        }

        onErrorChanged: {
            console.log("Device discovery agent error:", discoveryAgent.error)
            if (useExternalGPS || onSettingsPage) {
                discoveryAgentError(discoveryAgent.error);
            }
        }

        onDeviceDiscovered: {
            if (discoveryAgent.deviceFilter(device)) {
                console.log("Device discovered - Name:", device.name, "Type:", device.deviceType);
                deviceSelected(device);
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

        interval: 100
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
}
