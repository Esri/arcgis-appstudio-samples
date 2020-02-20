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

import ArcGIS.AppFramework 1.0

QtObject {
    property Settings settings

    //--------------------------------------------------------------------------

    // default settings - allow the user to set the GNSS defaults needed in the app
    property bool defaultDiscoverBluetooth: true
    property bool defaultDiscoverBluetoothLE: false
    property bool defaultDiscoverSerialPort: false

    // current settings state
    property bool discoverBluetooth: defaultDiscoverBluetooth
    property bool discoverBluetoothLE: defaultDiscoverBluetoothLE
    property bool discoverSerialPort: defaultDiscoverSerialPort

    property string lastUsedDeviceLabel: ""
    property string lastUsedDeviceName: ""
    property string lastUsedDeviceJSON: ""

    property var knownDevices: ({})

    //--------------------------------------------------------------------------

    // this is used to access the integrated provider settings, DO NOT CHANGE
    readonly property string kInternalPositionSourceName: "IntegratedProvider"

    // this is the (translated) name of the integrated provider as it appears on the settings page
    readonly property string kInternalPositionSourceNameTranslated: qsTr("Integrated Provider")

    readonly property string kKeyLocationPrefix: "Location/"
    readonly property string kKeyLocationKnownDevices: kKeyLocationPrefix + "knownDevices"
    readonly property string kKeyLocationLastUsedDevice: kKeyLocationPrefix + "lastUsedDevice"
    readonly property string kKeyLocationDiscoverBluetooth: kKeyLocationPrefix + "discoverBluetooth"

    readonly property int kConnectionTypeInternal: 0
    readonly property int kConnectionTypeExternal: 1
    readonly property int kConnectionTypeNetwork: 2

    //--------------------------------------------------------------------------

    property bool updating

    signal receiverAdded(string name)
    signal receiverRemoved(string name)

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        read();
    }

    //--------------------------------------------------------------------------

    // update the current global settings on receiver change
    onLastUsedDeviceNameChanged: {
        updating = true;

        if (knownDevices && lastUsedDeviceName > "") {
            var receiverSettings = knownDevices[lastUsedDeviceName];

            if (receiverSettings) {
                switch (receiverSettings.connectionType) {
                case kConnectionTypeExternal:
                    lastUsedDeviceLabel = receiverSettings.label;
                    lastUsedDeviceJSON = receiverSettings.receiver > "" ? JSON.stringify(receiverSettings.receiver) : "";
                    break;

                default:
                    console.log("Error: unknown connectionType", receiverSettings.connectionType);
                    updating = false;
                    return;
                }

                function receiverSetting(name, defaultValue) {
                    if (!receiverSettings) {
                        return defaultValue;
                    }

                    var value = receiverSettings[name];
                    if (value !== null && value !== undefined) {
                        return value;
                    } else {
                        return defaultValue;
                    }
                }
            }
        }

        updating = false;
    }

    //--------------------------------------------------------------------------

    function read() {
        // don't use the previous printer
        settings.clear();
        try {
            knownDevices = JSON.parse(settings.value(kKeyLocationKnownDevices, "{}"));
        } catch (e) {
            console.log("Error while parsing settings file.", e);
        }

        lastUsedDeviceName = settings.value(kKeyLocationLastUsedDevice, kInternalPositionSourceName)
        log();
    }

    //--------------------------------------------------------------------------

    function write() {
        console.log("Writing app settings");

        settings.setValue(kKeyLocationDiscoverBluetooth, discoverBluetooth, defaultDiscoverBluetooth);
        settings.setValue(kKeyLocationLastUsedDevice, lastUsedDeviceName, kInternalPositionSourceName);
        settings.setValue(kKeyLocationKnownDevices, JSON.stringify(knownDevices), ({}));

        log();
    }

    //--------------------------------------------------------------------------

    function log() {
        console.log("GNSS settings -");
        console.log("* discoverBluetooth:", discoverBluetooth);
        console.log("* lastUsedDeviceName:", lastUsedDeviceName);
        console.log("* lastUsedDeviceLabel:", lastUsedDeviceLabel);
        console.log("* knownDevices:", JSON.stringify(knownDevices));
    }

    //--------------------------------------------------------------------------

    function createDefaultSettingsObject(connectionType) {
        return {
            "connectionType": connectionType
        }
    }

    //--------------------------------------------------------------------------

    function createExternalReceiverSettings(deviceName, device) {
        if (knownDevices && device && deviceName > "") {

            if (!knownDevices[deviceName]) {
                var receiverSettings = createDefaultSettingsObject(kConnectionTypeExternal);
                receiverSettings["receiver"] = device;
                receiverSettings["label"] = deviceName;

                knownDevices[deviceName] = receiverSettings;
                receiverAdded(deviceName);
            }

            lastUsedDeviceName = deviceName;

            return deviceName;
        }

        return "";
    }

    //--------------------------------------------------------------------------

    function deleteKnownDevice(deviceName) {
        try {
            delete knownDevices[deviceName];
            receiverRemoved(deviceName);
        }
        catch(e){
            console.log(e);
        }
    }

    //--------------------------------------------------------------------------
}
