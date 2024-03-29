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

import ArcGIS.AppFramework.Positioning 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0

Item {
    property alias positionSource: positionSource
    property alias satelliteInfoSource: satelliteInfoSource
    property alias nmeaSource: nmeaSource
    property alias tcpSocket: tcpSocket
    property alias discoveryAgent: discoveryAgent

    property Device currentDevice
    property bool isConnecting
    property bool isConnected

    property int connectionType: 0
    property bool discoverBluetooth: true
    property bool discoverBluetoothLE: false
    property bool discoverSerialPort: false

    property string currentNetworkAddress
    property string integratedProviderName: "Integrated Provider"

    signal networkHostSelected(string hostname, int port)
    signal deviceSelected(Device device)
    signal disconnect()

    // -------------------------------------------------------------------------

    PositionSource {
        id: positionSource

        active: true
        nmeaSource: connectionType > 0 ? nmeaSource : null

        onNameChanged: {
            if (connectionType == 0 && name > "") {
                integratedProviderName = name;
            }
        }
    }

    // -------------------------------------------------------------------------

    SatelliteInfoSource {
        id: satelliteInfoSource

        active: valid && positionSource.active
        nmeaSource: connectionType > 0 ? nmeaSource : null
    }

    // -------------------------------------------------------------------------

    NmeaSource {
        id: nmeaSource

        onReceivedNmeaData: {
            if (!isConnected && receivedSentence.trim() > "") {
                isConnected = true;
                isConnecting = false;
            }
        }
    }

    // -------------------------------------------------------------------------

    TcpSocket {
        id: tcpSocket

        onErrorChanged: disconnect()
    }

    // -------------------------------------------------------------------------

    Connections {
        target: currentDevice

        onConnectedChanged: {
            // cleanup in case the connection to the device is lost
            if (currentDevice && !currentDevice.connected) {
                disconnect();
            }
        }

        onErrorChanged: disconnect()
    }

    // -------------------------------------------------------------------------

    DeviceDiscoveryAgent {
        id: discoveryAgent

        deviceFilter: function(device) { return filter(device); }
        sortCompare: function(device1, device2) { return sort(device1, device2); }

        onDiscoverDevicesCompleted: stop()

        onErrorChanged: stop()

        function filter(device) {
            var types = [];

            if (discoverBluetooth) {
                types.push(Device.DeviceTypeBluetooth);
            }

            if (discoverBluetoothLE) {
                types.push(Device.DeviceTypeBluetoothLE);
            }

            if (discoverSerialPort) {
                types.push(Device.DeviceTypeSerialPort);
            }

            for (var i in types) {
                if (device && device.deviceType === types[i]) {
                    if (device.deviceType === Device.DeviceTypeBluetooth) {
                        if (device.pairingStatus === Device.PairingStatusPaired || device.pairingStatus === Device.PairingStatusAuthorizedPaired) {
                            return true;
                        }
                    } else if (device.deviceType === Device.DeviceTypeBluetoothLE) {
                        return true;
                    } else if (device.deviceType === Device.DeviceTypeSerialPort) {
                        return true;
                    }
                }
            }

            return false;
        }

        function sort(device1, device2) {
            switch (device1.deviceType) {
            case Device.DeviceTypeBluetooth:
                if (device2.deviceType === Device.DeviceTypeBluetooth) {
                    return device1.name.localeCompare(device2.name) < 0 ? true : false;
                }
                return true;
            case Device.DeviceTypeBluetoothLE:
                if (device2.deviceType === Device.DeviceTypeBluetooth) {
                    return false;
                }
                if (device2.deviceType === Device.DeviceTypeBluetoothLE) {
                    return device1.name.localeCompare(device2.name) < 0 ? true : false;
                }
                return true;
            case Device.DeviceTypeSerialPort:
                if (device2.deviceType === Device.DeviceTypeBluetooth) {
                    return false;
                }
                if (device2.deviceType === Device.DeviceTypeBluetoothLE) {
                    return false;
                }
                if (device2.deviceType === Device.DeviceTypeSerialPort) {
                    return device1.name.localeCompare(device2.name) < 0 ? true : false;
                }
                return true;
            case Device.DeviceTypeUnknown:
                if (device2.deviceType === Device.DeviceTypeUnknown) {
                    return device1.name.localeCompare(device2.name) < 0 ? true : false;
                }
                return false;
            }
        }
    }

    // -------------------------------------------------------------------------

    onNetworkHostSelected: {
        console.log("Connecting to remote host:", hostname, "port:", port);

        disconnect();

        isConnected = false;
        isConnecting = true;

        currentNetworkAddress = hostname + ":" + port;
        nmeaSource.source = tcpSocket;
        tcpSocket.connectToHost(hostname, port);
    }

    // -------------------------------------------------------------------------

    onDeviceSelected: {
        console.log("Connecting to device:", device.name, "address:", device.address, "type:", device.deviceType, device);

        disconnect();

        isConnected = false;
        isConnecting = true;

        currentDevice = device;
        nmeaSource.source = currentDevice;
        currentDevice.connected = true;
    }

    // -------------------------------------------------------------------------

    onDisconnect: {
        if (tcpSocket.valid && tcpSocket.state !== AbstractSocket.StateUnConnected) {
            tcpSocket.disconnectFromHost();
        }

        if (currentDevice && currentDevice.connected) {
            currentDevice.connected = false;
        }

        isConnected = false;
        isConnecting = false;

        nmeaSource.source = null;
    }

    // -------------------------------------------------------------------------
}

