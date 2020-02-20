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

import QtQuick 2.12
import QtPositioning 5.8

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Positioning 1.0

Item {
    id: bluetoothSourceManager

    property alias controller: controller
    property alias positionSource: controller.positionSource
    property alias discoveryAgent: controller.discoveryAgent

    //--------------------------------------------------------------------------
    // Configuration properties

    property bool discoverBluetooth: true

    property int connectionType: controller.eConnectionType.internal
    property string storedDeviceName: ""
    property string storedDeviceJSON: ""

    property alias stayConnected: controller.stayConnected
    property alias onSettingsPage: controller.onSettingsPage
    property alias onDetailedSettingsPage: controller.onDetailedSettingsPage

    //--------------------------------------------------------------------------

    readonly property var systemInfo: {
        "pluginName": controller.integratedProviderName,
    }

    readonly property var deviceInfo: {
        "deviceType": controller.currentDevice ? controller.currentDevice.deviceType : Device.DeviceTypeUnknown,
        "deviceName": controller.currentDevice ? controller.currentDevice.name : "",
        "deviceAddress": controller.currentDevice ? controller.currentDevice.address : "",
    }

    //--------------------------------------------------------------------------

    property bool debug: false

    //--------------------------------------------------------------------------

    signal startPositionSource()
    signal stopPositionSource()

    Component.onCompleted: {
        AppFramework.environment.setValue("APPSTUDIO_POSITION_DESIRED_ACCURACY", "HIGHEST");
        AppFramework.environment.setValue("APPSTUDIO_POSITION_ACTIVITY_MODE", "OTHERNAVIGATION");
        AppFramework.environment.setValue("APPSTUDIO_POSITION_UPDATE_MODE", "ALL")
        AppFramework.environment.setValue("APPSTUDIO_POSITION_POWER_MODE", "HIGHEST")
        AppFramework.environment.setValue("APPSTUDIO_POSITION_GPS_WAIT_TIME", 5000)
        AppFramework.environment.setValue("APPSTUDIO_POSITION_PRIORITY_MODE", "HIGH_ACCURACY")
    }

    //--------------------------------------------------------------------------


    onStartPositionSource: {
        controller.startPositionSource();
        controller.reconnect();
    }

    //-------------------------------------------------------------------------

    onStopPositionSource: {
        controller.stopPositionSource();
    }

    //-------------------------------------------------------------------------

    BluetoothSources {
        id: sources
        connectionType: 0
        discoverBluetooth: true
    }

    BluetoothSourcesController {
        id: controller

        sources: sources
        stayConnected: true

        discoverBluetooth: bluetoothSourceManager.discoverBluetooth

        connectionType: bluetoothSourceManager.connectionType
        storedDeviceName: bluetoothSourceManager.storedDeviceName
        storedDeviceJSON: bluetoothSourceManager.storedDeviceJSON
    }
    //--------------------------------------------------------------------------
}
