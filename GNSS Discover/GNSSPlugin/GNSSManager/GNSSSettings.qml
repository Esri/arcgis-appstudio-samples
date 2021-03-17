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

import QtQml 2.15
import QtQuick 2.15

import ArcGIS.AppFramework 1.0

QtObject {
    id: object

    //--------------------------------------------------------------------------

    property Settings settings

    //--------------------------------------------------------------------------

    // default settings - allow the user to set the GNSS defaults needed in the app
    property bool defaultLocationAlertsVisualInternal: false
    property bool defaultLocationAlertsSpeechInternal: false
    property bool defaultLocationAlertsVibrateInternal: false

    property bool defaultLocationAlertsVisualExternal: true
    property bool defaultLocationAlertsSpeechExternal: true
    property bool defaultLocationAlertsVibrateExternal: true

    property bool defaultLocationAlertsMonitorNmeaData: false

    property int defaultLocationMaximumDataAge: 5000
    property int defaultLocationMaximumPositionAge: 5000
    property int defaultLocationSensorConnectionType: kConnectionTypeInternal
    property int defaultLocationAltitudeType: kAltitudeTypeMSL
    property int defaultLocationConfidenceLevelType: kConfidenceLevelType68

    property real defaultLocationGeoidSeparation: Number.NaN
    property real defaultLocationAntennaHeight: Number.NaN

    // current settings state
    property bool locationAlertsVisual: defaultLocationAlertsVisualInternal
    property bool locationAlertsSpeech: defaultLocationAlertsSpeechInternal
    property bool locationAlertsVibrate: defaultLocationAlertsVibrateInternal

    property bool locationAlertsMonitorNmeaData: defaultLocationAlertsMonitorNmeaData

    property int locationMaximumDataAge: defaultLocationMaximumDataAge
    property int locationMaximumPositionAge: defaultLocationMaximumPositionAge
    property int locationSensorConnectionType: defaultLocationSensorConnectionType
    property int locationAltitudeType: defaultLocationAltitudeType
    property int locationConfidenceLevelType: defaultLocationConfidenceLevelType

    property real locationGeoidSeparation: defaultLocationGeoidSeparation
    property real locationAntennaHeight: defaultLocationAntennaHeight

    property string lastUsedDeviceLabel: ""
    property string lastUsedDeviceName: ""
    property string lastUsedDeviceJSON: ""
    property string hostname: ""
    property string port: ""

    property string nmeaLogFile: ""
    property int updateInterval: 0
    property bool repeat: false

    property var knownDevices: ({})

    //--------------------------------------------------------------------------

    // this is used to access the integrated provider settings, DO NOT CHANGE
    readonly property string kInternalPositionSourceName: "IntegratedProvider"

    // this is the (translated) name of the integrated provider as it appears on the settings page
    readonly property string kInternalPositionSourceNameTranslated: qsTr("Integrated Provider")

    readonly property string kKeyLocationPrefix: "Location/"
    readonly property string kKeyLocationKnownDevices: kKeyLocationPrefix + "knownDevices"
    readonly property string kKeyLocationLastUsedDevice: kKeyLocationPrefix + "lastUsedDevice"

    readonly property int kConnectionTypeInternal: 0
    readonly property int kConnectionTypeExternal: 1
    readonly property int kConnectionTypeNetwork: 2
    readonly property int kConnectionTypeFile: 3

    readonly property int kAltitudeTypeMSL: 0
    readonly property int kAltitudeTypeHAE: 1

    readonly property int kConfidenceLevelType68: 0
    readonly property int kConfidenceLevelType95: 1

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
            var receiver = knownDevices[lastUsedDeviceName];

            if (receiver) {
                switch (receiver.connectionType) {
                case kConnectionTypeInternal:
                    lastUsedDeviceLabel = receiver.label;
                    lastUsedDeviceJSON = "";
                    hostname = "";
                    port = "";
                    nmeaLogFile = "";
                    updateInterval = 0;
                    repeat = false;
                    break;

                case kConnectionTypeExternal:
                    lastUsedDeviceLabel = receiver.label;
                    lastUsedDeviceJSON = receiver.receiver > "" ? JSON.stringify(receiver.receiver) : "";
                    hostname = "";
                    port = "";
                    nmeaLogFile = "";
                    updateInterval = 0;
                    repeat = false;
                    break;

                case kConnectionTypeNetwork:
                    lastUsedDeviceLabel = receiver.label;
                    lastUsedDeviceJSON = ""
                    hostname = receiver.hostname;
                    port = receiver.port;
                    nmeaLogFile = "";
                    updateInterval = 0;
                    repeat = false;
                    break;

                case kConnectionTypeFile:
                    lastUsedDeviceLabel = receiver.label;
                    lastUsedDeviceJSON = ""
                    hostname = "";
                    port = "";
                    nmeaLogFile = receiver.filename;
                    updateInterval = receiver.updateinterval;
                    repeat = receiver.repeat;
                    break;

                default:
                    console.log("Error: unknown connectionType", receiver.connectionType);
                    updating = false;
                    return;
                }

                function receiverSetting(name, defaultValue) {
                    if (!receiver) {
                        return defaultValue;
                    }

                    var value = receiver[name];
                    if (value !== null && value !== undefined) {
                        return value;
                    } else {
                        return defaultValue;
                    }
                }

                locationAlertsVisual = receiverSetting("locationAlertsVisual", defaultLocationAlertsVisualInternal);
                locationAlertsSpeech = receiverSetting("locationAlertsSpeech", defaultLocationAlertsSpeechInternal);
                locationAlertsVibrate = receiverSetting("locationAlertsVibrate", defaultLocationAlertsVibrateInternal);
                locationAlertsMonitorNmeaData = receiverSetting("locationAlertsMonitorNmeaData", defaultLocationAlertsMonitorNmeaData);
                locationMaximumDataAge = receiverSetting("locationMaximumDataAge", defaultLocationMaximumDataAge);
                locationMaximumPositionAge = receiverSetting("locationMaximumPositionAge", defaultLocationMaximumPositionAge);
                locationSensorConnectionType = receiverSetting("connectionType", defaultLocationSensorConnectionType);
                locationAltitudeType = receiverSetting("altitudeType", defaultLocationAltitudeType);
                locationConfidenceLevelType = receiverSetting("confidenceLevelType", defaultLocationConfidenceLevelType);
                locationGeoidSeparation = receiverSetting("geoidSeparation", defaultLocationGeoidSeparation);
                locationAntennaHeight = receiverSetting("antennaHeight", defaultLocationAntennaHeight);
            }
        }

        updating = false;
    }

    //--------------------------------------------------------------------------

    function read() {
        console.log("Reading GNSS settings -", settings.path);

        try {
            knownDevices = JSON.parse(settings.value(kKeyLocationKnownDevices, "{}"));
        } catch (e) {
            console.log("Error while parsing settings file.", e);
        }

        var internalFound = false;
        for (var deviceName in knownDevices) {
            // add default internal position source if necessary
            if (deviceName === kInternalPositionSourceName) {
                internalFound = true;
                break;
            }
        }

        if (!internalFound) {
            createInternalSettings();
        } else {
            // update the label of the internal position source provider in case the system
            // language has changed since last using the app
            var receiverSettings = knownDevices[kInternalPositionSourceName];
            if (receiverSettings && receiverSettings["label"] !== kInternalPositionSourceNameTranslated) {
                receiverSettings["label"] = kInternalPositionSourceNameTranslated;
            }

            // this triggers an update of the global settings using the last known receiver
            lastUsedDeviceName = settings.value(kKeyLocationLastUsedDevice, kInternalPositionSourceName)
        }

        log();
    }

    //--------------------------------------------------------------------------

    function write() {
        console.log("Writing GNSS settings -", settings.path);

        settings.setValue(kKeyLocationLastUsedDevice, lastUsedDeviceName, kInternalPositionSourceName);
        settings.setValue(kKeyLocationKnownDevices, JSON.stringify(knownDevices), ({}));

        //log();
    }

    //--------------------------------------------------------------------------

    function log() {
        console.log("GNSS settings -");

        console.log("* locationAlertsVisual:", locationAlertsVisual);
        console.log("* locationAlertsSpeech:", locationAlertsSpeech);
        console.log("* locationAlertsVibrate:", locationAlertsVibrate);

        console.log("* locationAlertsMonitorNmeaData:", locationAlertsMonitorNmeaData);

        console.log("* locationMaximumDataAge:", locationMaximumDataAge);
        console.log("* locationMaximumPositionAge:", locationMaximumPositionAge);
        console.log("* locationSensorConnectionType:", locationSensorConnectionType);
        console.log("* locationAltitudeType:", locationAltitudeType);
        console.log("* locationConfidenceLevelType:", locationConfidenceLevelType);

        console.log("* locationGeoidSeparation:", locationGeoidSeparation);
        console.log("* locationAntennaHeight:", locationAntennaHeight);

        console.log("* lastUsedDeviceName:", lastUsedDeviceName);
        console.log("* lastUsedDeviceLabel:", lastUsedDeviceLabel);

        console.log("* knownDevices:", JSON.stringify(knownDevices));
    }

    //--------------------------------------------------------------------------

    function createDefaultSettingsObject(connectionType) {
        return {
            "locationAlertsVisual": connectionType === kConnectionTypeInternal ? defaultLocationAlertsVisualInternal : defaultLocationAlertsVisualExternal,
            "locationAlertsSpeech": connectionType === kConnectionTypeInternal ? defaultLocationAlertsSpeechInternal : defaultLocationAlertsSpeechExternal,
            "locationAlertsVibrate": connectionType === kConnectionTypeInternal ? defaultLocationAlertsVibrateInternal : defaultLocationAlertsVibrateExternal,
            "locationAlertsMonitorNmeaData": defaultLocationAlertsMonitorNmeaData,
            "locationMaximumDataAge": defaultLocationMaximumDataAge,
            "locationMaximumPositionAge": defaultLocationMaximumPositionAge,
            "altitudeType": defaultLocationAltitudeType,
            "confidenceLevelType": defaultLocationConfidenceLevelType,
            "antennaHeight": defaultLocationAntennaHeight,
            "geoidSeparation": defaultLocationGeoidSeparation,
            "connectionType": connectionType
        }
    }

    //--------------------------------------------------------------------------

    function createInternalSettings() {
        if (knownDevices) {
            // use the fixed internal provider name as the identifier
            var name = kInternalPositionSourceName;

            if (!knownDevices[name]) {
                var receiverSettings = createDefaultSettingsObject(kConnectionTypeInternal);

                // use the localised internal provider name as the label
                receiverSettings["label"] = kInternalPositionSourceNameTranslated;

                knownDevices[name] = receiverSettings;
                receiverAdded(name);
            }

            lastUsedDeviceName = name;

            return name;
        }

        return "";
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

    function createNetworkSettings(hostname, port) {
        if (knownDevices && hostname > "" && port > "") {
            var networkAddress = hostname + ":" + port;

            if (!knownDevices[networkAddress]) {
                var receiverSettings = createDefaultSettingsObject(kConnectionTypeNetwork);
                receiverSettings["hostname"] = hostname;
                receiverSettings["port"] = port;
                receiverSettings["label"] = networkAddress;

                knownDevices[networkAddress] = receiverSettings;
                receiverAdded(networkAddress);
            }

            lastUsedDeviceName = networkAddress;

            return networkAddress;
        }

        return "";
    }

    //--------------------------------------------------------------------------

    function createNmeaLogFileSettings(fileUrl) {
        if (knownDevices && fileUrl > "") {
            var label = fileUrlToLabel(fileUrl);

            if (!knownDevices[fileUrl]) {
                var receiverSettings = createDefaultSettingsObject(kConnectionTypeFile);
                receiverSettings["filename"] = fileUrl;
                receiverSettings["label"] = label;
                receiverSettings["updateinterval"] = 1000;
                receiverSettings["repeat"] = true;

                knownDevices[fileUrl] = receiverSettings;
                receiverAdded(fileUrl);
            }

            lastUsedDeviceName = fileUrl;

            return label;
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

    function fileUrlToLabel(fileUrl) {
        return AppFramework.fileInfo(fileUrl).displayName;
    }

    //--------------------------------------------------------------------------

    function fileUrlToDisplayPath(fileUrl) {
        var path = fileUrlToPath(fileUrl);

        if (Qt.platform.os === "android") {
            path = path.replace(/%3A/g, ":").replace(/%2F/g, "/").replace(/%20/g, ":");
            var prefix = path.substring(0, path.lastIndexOf(":") + 1);
            prefix = prefix.substring(prefix.lastIndexOf("/") + 1);
            path = path.substring(path.lastIndexOf(":") + 1)
            path = prefix + path.substring(path.lastIndexOf(":") + 1, path.lastIndexOf("/") + 1);
            path = path + fileUrlToLabel(fileUrl);
        }

        return path;
    }

    //--------------------------------------------------------------------------

    function fileUrlToPath(fileUrl) {
        var fileInfo = AppFramework.fileInfo(fileUrl);
        var path = Qt.platform.os === "ios" ? fileInfo.filePath.replace(AppFramework.userHomePath + "/", "") : fileInfo.filePath;

        return path;
    }

    //--------------------------------------------------------------------------
}
