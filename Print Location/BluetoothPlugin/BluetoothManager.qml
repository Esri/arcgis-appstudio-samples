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

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Positioning 1.0

import "./controls"
import "./BluetoothManager"

Item {
    id: bluetoothManager

    //-------------------------------------------------------------------------
    // Public properties

    // Reference to BluetoothettingsPages (required)
    property var bluetoothSettingsPages

    //-------------------------------------------------------------------------
    // Public signals

    // Start/stop position source & connect to bluetooth pinters
    signal start()
    signal stop()

    // Name of current position provider
    readonly property string name: bluetoothSettings.lastUsedDeviceLabel > "" ? bluetoothSettings.lastUsedDeviceLabel : bluetoothSettings.lastUsedDeviceName;

    // Optional AppSettings component
    property alias appSettings: bluetoothSettings.settings

    //-------------------------------------------------------------------------
    // Internal state properties

    // Provide direct access to internal components
    readonly property BluetoothSourceManager bluetoothSourceManager: bluetoothSourceManager
    readonly property BluetoothSettings bluetoothSettings: bluetoothSettings
    readonly property AppDialog gnssDialog: gnssDialog

    //-------------------------------------------------------------------------
    // Internal signals

    signal startDiscoveryAgent()
    signal stopDiscoveryAgent()
    signal receiverListUpdated()

    // needed for AppDialog to appear in the correct location
    anchors.fill: parent

    // make sure alerts are on top
    z: 99999

    //-------------------------------------------------------------------------

     onStart: {
         bluetoothSourceManager.startPositionSource();
     }

     //-------------------------------------------------------------------------

     onStop: {
         bluetoothSourceManager.stopPositionSource();
     }

    //-------------------------------------------------------------------------

    BluetoothSourceManager {
        id: bluetoothSourceManager
        discoverBluetooth: bluetoothSettings.discoverBluetooth
        storedDeviceName: bluetoothSettings.lastUsedDeviceName
        storedDeviceJSON: bluetoothSettings.lastUsedDeviceJSON
    }

    //--------------------------------------------------------------------------

    BluetoothSettings {
        id: bluetoothSettings

        settings: Settings {
        }

        onReceiverAdded: {
            bluetoothManager.receiverListUpdated();
        }

        onReceiverRemoved: {
            bluetoothManager.receiverListUpdated();
        }
    }

    //--------------------------------------------------------------------------

    AppDialog {
        id: gnssDialog

        backgroundColor: bluetoothSettingsPages.listBackgroundColor
        buttonColor: bluetoothSettingsPages.selectedTextColor
        titleColor: bluetoothSettingsPages.textColor
        textColor: bluetoothSettingsPages.textColor
        fontFamily: bluetoothSettingsPages.fontFamily
    }

    //--------------------------------------------------------------------------
}
