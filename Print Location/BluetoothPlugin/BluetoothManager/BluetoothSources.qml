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

import QtQuick 2.12

import ArcGIS.AppFramework.Positioning 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0

Item {
    property alias positionSource: positionSource
    property alias discoveryAgent: discoveryAgent
    property Device currentDevice
    property bool isConnecting
    property bool isConnected

    property int connectionType: 0
    property bool discoverBluetooth: true

    property string currentNetworkAddress
    property string integratedProviderName: "Integrated Provider"

    signal deviceSelected(Device device)
    signal disconnect()

    // -------------------------------------------------------------------------

    PositionSource {
        id: positionSource
        active: true

        onNameChanged: {
            if (connectionType == 0 && name > "") {
                integratedProviderName = name;
            }
        }
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

            for (var i in types) {
                if (device.name.includes("iMZ") || device.name.includes("Zebra")) {
                    return true;
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

    onDeviceSelected: {
        if (device !== null) {
            console.log("Connecting to device:", device.name, "address:", device.address, "type:", device.deviceType, device);

            // call disconnect on windows cause the app hanging
            if (Qt.platform.os !== "windows") {
                disconnect();
            } else {
                if (currentDevice !== device) {
                    disconnect();
                }
            }

            isConnected = false;
            isConnecting = true;

            // the following destroy is copied from gnss discover and needed to fix the freeze on windows
            if (currentDevice && currentDevice !== device) {
                currentDevice.destroy();
            }

            currentDevice = device;
            currentDevice.connected = true;
        }
    }

    // -------------------------------------------------------------------------

    onDisconnect: {
        if (currentDevice && currentDevice.connected) {
            currentDevice.connected = false;
        }

        isConnected = false;
        isConnecting = false;
    }

    // -------------------------------------------------------------------------
}
