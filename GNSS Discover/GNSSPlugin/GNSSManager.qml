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
import QtQuick.Layouts 1.15

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Positioning 1.0

import "./controls"
import "./GNSSManager"

Item {
    id: gnssManager

    //-------------------------------------------------------------------------
    // Public properties

    // Reference to GNSSSettingsPages component (required)
    property var gnssSettingsPages

    // Reference to AppSettings component (optional)
    property alias appSettings: gnssSettings.settings

    //-------------------------------------------------------------------------
    // GNSSManager configuration

    // Show on-screen message on error, set to false if errors are handled elsewhere
    property bool showErrors: true

    // Alert user if receiver has connected/disconnected/no location updates received
    property bool showAlerts: true

    // Alert user by popup/text to speech/vibration if using internal location provider
    property alias alertsVisualInternal: gnssSettings.defaultLocationAlertsVisualInternal
    property alias alertsSpeechInternal: gnssSettings.defaultLocationAlertsSpeechInternal
    property alias alertsVibrateInternal: gnssSettings.defaultLocationAlertsVibrateInternal

    // Alert user by popup/text to speech/vibration if using external location provider
    property alias alertsVisualExternal: gnssSettings.defaultLocationAlertsVisualExternal
    property alias alertsSpeechExternal: gnssSettings.defaultLocationAlertsSpeechExternal
    property alias alertsVibrateExternal: gnssSettings.defaultLocationAlertsVibrateExternal

    // Alert if no Nmea data received
    property alias monitorNmeaData: gnssSettings.defaultLocationAlertsMonitorNmeaData

    // Use Google Play Location API on Android if true
    property alias useGooglePlayLocationAPI: positionSourceManager.useGooglePlayLocationAPI

    // Attempt to reconnect to external GNSS provider automatically if true
    property alias stayConnected: positionSourceManager.stayConnected

    // Number of valid position updates needed before broadcasting positionChanged() signal
    property alias warmupCount: positionSourceManager.warmupCount

    //-------------------------------------------------------------------------
    // Public signals

    // Start/stop position source & connect to external GNSS providers
    signal start()
    signal stop()

    // New position has been received
    signal newPosition(var position)

    // TCP connection error
    signal tcpError(string errorString)

    // Bluetooth/serial port connection error
    signal deviceError(string errorString)

    // NMEA log file error
    signal nmeaLogFileError(string errorString)

    // Internal position source error
    signal positionSourceError(string errorString)

    // Device discovery error
    signal discoveryAgentError(string errorString)

    //-------------------------------------------------------------------------
    // Internal state properties

    // Provide direct access to internal components
    readonly property PositionSourceManager positionSourceManager: positionSourceManager
    readonly property PositionSourceMonitor positionSourceMonitor: positionSourceMonitor
    readonly property GNSSSettings gnssSettings: gnssSettings
    readonly property GNSSAlerts gnssAlerts: gnssAlerts

    // Location provider status
    readonly property alias active: positionSourceManager.active
    readonly property bool isActive: positionSourceManager.active
    readonly property bool isConnecting: positionSourceManager.isConnecting
    readonly property bool isConnected: positionSourceManager.isConnected
    readonly property bool isCurrent: positionSourceManager.isReady && positionSourceMonitor.positionIsCurrent

    // Location provider type
    readonly property bool isFile: positionSourceManager.isFile
    readonly property bool isGNSS: positionSourceManager.isGNSS
    readonly property bool isInternal: positionSourceManager.isInternal
    readonly property bool isBluetooth: positionSourceManager.isBluetooth
    readonly property bool isBluetoothLE: positionSourceManager.isBluetoothLE
    readonly property bool isSerialPort: positionSourceManager.isSerialPort
    readonly property bool isNetwork: positionSourceManager.isNetwork

    // Location provider name
    readonly property string name: positionSourceManager.name

    // Current position
    readonly property var position: positionSourceMonitor.currentPosition

    //-------------------------------------------------------------------------
    // Internal error messages

    readonly property string kUnableToConnect: qsTr("Unable to connect")
    readonly property string kDiscoveryFailed: qsTr("Device discovery failed")
    readonly property string kProviderUnavailable: qsTr("Location provider inaccessible")
    readonly property string kDiscoveryAgentError: qsTr("Please ensure:\n1. Bluetooth is turned on.\n2. The app has permission to access Bluetooth.")
    readonly property string kTcpConnectionError: qsTr("Please ensure:\n1. Your device is online.\n2. %1 is a valid network address.")
    readonly property string kSerialportConnectionError: qsTr("Please ensure:\n1. %1 is turned on.\n2. %1 is connected to your device.")
    readonly property string kBluetoothConnectionError: qsTr("Please ensure:\n1. Bluetooth is turned on.\n2. %1 is turned on.\n3. %1 is paired with your device.")
    readonly property string kNmeaLogFileError: qsTr("Please ensure:\n%1 exists and contains valid NMEA log data.")
    readonly property string kInternalLocationProviderError: qsTr("Please ensure:\n1. Location services are turned on.\n2. The app has permission to access your location.")

    //-------------------------------------------------------------------------
    // Internal signals

    signal receiverListUpdated()
    signal alert(var alertType)

    //-------------------------------------------------------------------------

    // needed for AppDialog to appear in the correct location
    anchors.fill: parent

    // make sure alerts are on top
    z: 99999

    //-------------------------------------------------------------------------

    onStart: {
        positionSourceManager.startPositionSource();
    }

    //-------------------------------------------------------------------------

    onStop: {
        positionSourceManager.stopPositionSource();
    }

    //-------------------------------------------------------------------------

    PositionSourceManager {
        id: positionSourceManager

        connectionType: gnssSettings.locationSensorConnectionType
        storedDeviceName: gnssSettings.lastUsedDeviceName
        storedDeviceJSON: gnssSettings.lastUsedDeviceJSON
        hostname: gnssSettings.hostname
        port: Number(gnssSettings.port)

        nmeaLogFile: gnssSettings.nmeaLogFile
        updateInterval: gnssSettings.updateInterval
        repeat: gnssSettings.repeat

        name: gnssSettings.lastUsedDeviceLabel > "" ? gnssSettings.lastUsedDeviceLabel : gnssSettings.lastUsedDeviceName;

        altitudeType: gnssSettings.locationAltitudeType
        confidenceLevelType: gnssSettings.locationConfidenceLevelType
        customGeoidSeparation: gnssSettings.locationGeoidSeparation
        antennaHeight: gnssSettings.locationAntennaHeight

        onTcpError: {
            gnssManager.tcpError(errorString);

            show(kUnableToConnect, kTcpConnectionError.arg(name), startPositionSource);
        }

        onDeviceError: {
            gnssManager.deviceError(errorString);

            if (isSerialPort) {
                show(kUnableToConnect, kSerialportConnectionError.arg(name), startPositionSource);
            } else {
                show(kUnableToConnect, kBluetoothConnectionError.arg(name), startPositionSource);
            }
        }

        onNmeaLogFileError: {
            gnssManager.nmeaLogFileError(errorString);

            show(kUnableToConnect, kNmeaLogFileError.arg(name), startPositionSource);
        }

        onPositionSourceError: {
            gnssManager.positionSourceError(errorString);

            show(kProviderUnavailable, kInternalLocationProviderError, startPositionSource);
        }

        onDiscoveryAgentError: {
            gnssManager.discoveryAgentError(errorString);

            show(kDiscoveryFailed, kDiscoveryAgentError, controller.startDiscoveryAgent);
        }

        function show(title, errorString, callback) {
            if (showErrors) {
                gnssDialog.parent = gnssSettingsPages && gnssSettingsPages.stackView && gnssSettingsPages.stackView.currentItem
                        ? gnssSettingsPages.stackView.currentItem
                        : gnssManager;

                gnssDialog.openDialogWithTitle(
                            title,
                            errorString, qsTr("TRY AGAIN"), qsTr("OK"),
                            callback, function() {});
            }
        }
    }

    //-------------------------------------------------------------------------

    PositionSourceMonitor {
        id: positionSourceMonitor

        positionSourceManager: positionSourceManager

        monitorNmeaData: gnssSettings.locationAlertsMonitorNmeaData
        maximumDataAge: gnssSettings.locationMaximumDataAge
        maximumPositionAge: gnssSettings.locationMaximumPositionAge

        onNewPosition: {
            gnssManager.newPosition(position);
        }

        onAlert: {
            gnssManager.alert(alertType);

            if (showAlerts) {
                gnssAlerts.positionSourceAlert(alertType);
            }
        }
    }

    //-------------------------------------------------------------------------

    GNSSAlerts {
        id: gnssAlerts

        gnssSettings: gnssSettings
        fontFamily: gnssSettingsPages.fontFamily
    }

    //-------------------------------------------------------------------------

    GNSSSettings {
        id: gnssSettings

        settings: Settings {
        }

        onReceiverAdded: {
            gnssManager.receiverListUpdated();
        }

        onReceiverRemoved: {
            gnssManager.receiverListUpdated();
        }
    }

    //-------------------------------------------------------------------------

    AppDialog {
        id: gnssDialog

        backgroundColor: gnssSettingsPages.listBackgroundColor
        buttonColor: gnssSettingsPages.selectedTextColor
        titleColor: gnssSettingsPages.textColor
        textColor: gnssSettingsPages.textColor
        fontFamily: gnssSettingsPages.fontFamily
    }

    //-------------------------------------------------------------------------

    Connections {
        target: Qt.application

        function onStateChanged() {
            switch (Qt.application.state) {
            case Qt.ApplicationActive:
                if (isActive && isGNSS && !isConnecting) {
                    reconnectTimer.start();
                }
                break;

            case Qt.ApplicationInactive:
            case Qt.ApplicationSuspended:
                if (reconnectTimer.running) {
                    reconnectTimer.stop();
                }
                break;
            }
        }
    }

    //-------------------------------------------------------------------------

    Timer {
        id: reconnectTimer

        property double startTime

        interval: gnssSettings.locationMaximumDataAge

        onRunningChanged: {
            if (running) {
                startTime = (new Date()).valueOf();
            }
        }

        onTriggered: {
            if (isActive && isGNSS && !isConnecting) {
                var now = new Date().valueOf();
                var dataAge = now - positionSourceMonitor.dataReceivedTime;

                if (dataAge > gnssSettings.locationMaximumDataAge) {
                    positionSourceManager.controller.fullDisconnect();
                    positionSourceManager.controller.reconnectNow();
                }
            }
        }
    }

    //-------------------------------------------------------------------------
}
