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
import QtPositioning 5.15

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Positioning 1.0

Item {
    id: positionSourceManager

    //--------------------------------------------------------------------------

    property alias controller: controller
    property alias positionSource: controller.positionSource
    property alias satelliteInfoSource: controller.satelliteInfoSource
    property alias discoveryAgent: controller.discoveryAgent
    property alias nmeaSource: controller.nmeaSource

    property alias discoverBluetooth: sources.discoverBluetooth
    property alias discoverBluetoothLE: sources.discoverBluetoothLE
    property alias discoverSerialPort: sources.discoverSerialPort

    property alias stayConnected: controller.stayConnected
    property alias onSettingsPage: controller.onSettingsPage
    property alias onDetailedSettingsPage: controller.onDetailedSettingsPage

    property alias connectionType: controller.connectionType
    property alias storedDeviceName: controller.storedDeviceName
    property alias storedDeviceJSON: controller.storedDeviceJSON
    property alias hostname: controller.hostname
    property alias port: controller.port

    property alias nmeaLogFile: controller.nmeaLogFile
    property alias updateInterval: controller.updateInterval
    property alias repeat: controller.repeat

    property alias name: controller.currentLabel

    //--------------------------------------------------------------------------

    property bool useGooglePlayLocationAPI: true

    property int altitudeType: 0 // 0=MSL, 1=HAE
    property int confidenceLevelType: 0 // 0=68% CL, 1=95% CL
    property real customGeoidSeparation: Number.NaN
    property real antennaHeight: Number.NaN

    property int warmupCount: controller.connectionType > controller.eConnectionType.internal ? 3 : 1

    //--------------------------------------------------------------------------
    // Status flags

    readonly property bool valid: positionSource.valid
    readonly property bool active: positionSource.active

    readonly property bool isFile: controller.useFile
    readonly property bool isGNSS: !controller.useInternalGPS
    readonly property bool isInternal: controller.useInternalGPS
    readonly property bool isBluetooth: controller.useExternalGPS && controller.currentDevice && controller.currentDevice.deviceType === Device.DeviceTypeBluetooth
    readonly property bool isBluetoothLE: controller.useExternalGPS && controller.currentDevice && controller.currentDevice.deviceType === Device.DeviceTypeBluetoothLE
    readonly property bool isSerialPort: controller.useExternalGPS && controller.currentDevice && controller.currentDevice.deviceType === Device.DeviceTypeSerialPort
    readonly property bool isNetwork: controller.useTCPConnection

    readonly property bool isConnecting: controller.isConnecting || controller.errorWhileConnecting
    readonly property bool isConnected: controller.isConnected
    readonly property bool isWarmingUp: isConnected && positionCount <= warmupCount
    readonly property bool isReady: status === kStatusInUse

    readonly property int status: !active
                                  ? kStatusNull
                                  : isConnecting
                                    ? kStatusConnecting
                                    : isWarmingUp
                                      ? kStatusWarmingUp
                                      : isConnected
                                        ? kStatusInUse
                                        : kStatusNull // connection to external device lost

    readonly property int kStatusNull: 0            // Not active
    readonly property int kStatusConnecting: 1      // Connecting to position source
    readonly property int kStatusWarmingUp: 2       // Connected, warming up
    readonly property int kStatusInUse: 3           // Connected, warmed up, and in use

    //--------------------------------------------------------------------------
    // Internal

    property date activatedTimestamp    // Time when activated
    property double positionTimestamp   // Time when current position was received

    property int positionCount: 0

    //--------------------------------------------------------------------------

    readonly property var systemInfo: {
        "pluginName": controller.integratedProviderName,

        "antennaHeight": antennaHeight,
        "altitudeType": altitudeType,
        "confidenceLevelType": confidenceLevelType,
        "geoidSeparationCustom": altitudeType == 0 ? customGeoidSeparation : Number.NaN,
    }

    readonly property var deviceInfo: {
        "deviceType": controller.currentDevice ? controller.currentDevice.deviceType : Device.DeviceTypeUnknown,
        "deviceName": controller.currentDevice ? controller.currentDevice.name : "",
        "deviceAddress": controller.currentDevice ? controller.currentDevice.address : "",

        "antennaHeight": antennaHeight,
        "altitudeType": altitudeType,
        "confidenceLevelType": confidenceLevelType,
        "geoidSeparationCustom": altitudeType == 0 ? customGeoidSeparation : Number.NaN,
    }

    readonly property var networkInfo: {
        "networkAddress": controller.tcpSocket ? controller.tcpSocket.remoteAddress.address : "",
        "networkPort": controller.tcpSocket ? controller.tcpSocket.remotePort : "",
        "networkName": controller.tcpSocket ? controller.tcpSocket.remoteName : "",

        "antennaHeight": antennaHeight,
        "altitudeType": altitudeType,
        "confidenceLevelType": confidenceLevelType,
        "geoidSeparationCustom": altitudeType == 0 ? customGeoidSeparation : Number.NaN,
    }

    readonly property var fileInfo: {
        "fileName": controller.nmeaLogFile ? controller.nmeaLogFile : "",
        "updateInterval": controller.updateInterval,
        "repeat": controller.repeat,

        "antennaHeight": antennaHeight,
        "altitudeType": altitudeType,
        "confidenceLevelType": confidenceLevelType,
        "geoidSeparationCustom": altitudeType == 0 ? customGeoidSeparation : Number.NaN,
    }

    //--------------------------------------------------------------------------

    property bool debug: false

    //--------------------------------------------------------------------------

    // As of Qt 5.12.3, enums take a long time to resolve. This can have an impact
    // on app performance. See https://bugreports.qt.io/browse/QTBUG-77237

    //    enum PositionSourceType {
    //        Unknown = 0,
    //        User = 1,
    //        System = 2,
    //        External = 3,
    //        Network = 4,
    //        File = 5
    //    }

    //--------------------------------------------------------------------------

    signal startPositionSource()
    signal stopPositionSource()
    signal newPosition(var position)

    signal tcpError(string errorString)
    signal deviceError(string errorString)
    signal nmeaLogFileError(string errorString)
    signal discoveryAgentError(string errorString)
    signal positionSourceError(string errorString)

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        AppFramework.environment.setValue("APPSTUDIO_POSITION_DESIRED_ACCURACY", "HIGHEST");
        AppFramework.environment.setValue("APPSTUDIO_POSITION_ACTIVITY_MODE", "OTHERNAVIGATION");
        AppFramework.environment.setValue("APPSTUDIO_POSITION_UPDATE_MODE", "ALL")
        AppFramework.environment.setValue("APPSTUDIO_POSITION_POWER_MODE", "HIGHEST")
        AppFramework.environment.setValue("APPSTUDIO_POSITION_GPS_WAIT_TIME", 5000)
        AppFramework.environment.setValue("APPSTUDIO_POSITION_PRIORITY_MODE", "HIGH_ACCURACY")
        AppFramework.environment.setValue("APPSTUDIO_POSITION_FUSED_PROVIDER", useGooglePlayLocationAPI ? "ON" : "OFF")
        AppFramework.environment.setValue("APPSTUDIO_POSITION_FUSED_PROVIDER_FILTER", "MOCKONLY")

        if (isInternal && active) {
            stopPositionSource();
            startPositionSource();
        }
    }

    //-------------------------------------------------------------------------

    onUseGooglePlayLocationAPIChanged: {
        if (Qt.platform.os === "android") {
            AppFramework.environment.setValue("APPSTUDIO_POSITION_FUSED_PROVIDER", useGooglePlayLocationAPI ? "ON" : "OFF");

            if (isInternal && active) {
                stopPositionSource();
                startPositionSource();
            }
        }
    }

    //-------------------------------------------------------------------------

    onStartPositionSource: {
        controller.startPositionSource();
    }

    //-------------------------------------------------------------------------

    onStopPositionSource: {
        controller.stopPositionSource();
    }

    //-------------------------------------------------------------------------

    onStatusChanged: {
        console.log("Position source manager status:", status);
    }

    //--------------------------------------------------------------------------

    PositioningSources {
        id: sources

        connectionType: controller.connectionType
        updateInterval: controller.updateInterval
        repeat: controller.repeat
    }

    //--------------------------------------------------------------------------

    PositioningSourcesController {
        id: controller

        sources: sources

        onIsConnectedChanged: {
            if (initialized && isGNSS) {
                // require warm-up after disconnect
                if (!isConnected) {
                    positionCount = 0;
                }
            }
        }

        onTcpError: {
            positionSourceManager.tcpError(errorString);
        }

        onDeviceError: {
            positionSourceManager.deviceError(errorString);
        }

        onNmeaLogFileError: {
            positionSourceManager.nmeaLogFileError(errorString);
        }

        onDiscoveryAgentError: {
            positionSourceManager.discoveryAgentError(errorString);
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: positionSource

        function onActiveChanged() {
            console.log("positionSource.active:", positionSource.active);

            // require warm-up after activation
            if (positionSource.active) {
                positionCount = 0;
                activatedTimestamp = new Date();
            }
        }

        function onPositionChanged() {
            var newposition = positionSource.position;

            // replace position time-stamp with current time if we're parsing a log file
            if (isFile) {
                newposition.timestamp = new Date();
            }

            positionTimestamp = (new Date()).valueOf();

            // TODO - comparison with activatedTimestamp will delay position updates if the system clock is running fast
            if (newposition.latitudeValid && newposition.longitudeValid /*&& newposition.timestamp >= activatedTimestamp*/) {
                positionCount++;

                addPositionSource(newposition);

                updateAltitude(newposition);

                updateAccuracy(newposition);

                if (isWarmingUp) {
                    console.log("Cold position source - count:", positionCount, "of", warmupCount, "coordinate:", newposition.coordinate, "timestamp:", newposition.timestamp, "connectionType:", controller.connectionType);
                } else if (isConnected) {
                    if (debug) {
                        console.log("New position - count:", positionCount, "coordinate:", newposition.coordinate, "timestamp:", newposition.timestamp, "connectionType:", controller.connectionType);
                    }

                    newPosition(newposition);
                }
            }
        }

        function onSourceErrorChanged() {
            console.error("Positioning Source Error:", positionSource.sourceError);

            var errorString = "";

            switch (positionSource.sourceError) {
            case PositionSource.AccessError :
                errorString = qsTr("Position source access error");
                break;

            case PositionSource.ClosedError :
                errorString = qsTr("Position source closed error");
                break;

            case PositionSource.SocketError :
                errorString = qsTr("Position source socket error");
                break;

            case PositionSource.NoError :
                errorString = "";
                break;

            default:
                errorString = qsTr("Unknown position source error %1").arg(positionSource.sourceError);
                break;
            }

            positionSourceError(errorString);
        }
    }

    //--------------------------------------------------------------------------

    function addPositionSource(info) {

        switch (controller.connectionType) {
        case controller.eConnectionType.internal:
            info.positionSourceType = 2 //PositionSourceManager.PositionSourceType.System;
            info.positionSourceInfo = systemInfo;
            break;

        case controller.eConnectionType.external:
            info.positionSourceType = 3 //PositionSourceManager.PositionSourceType.External;
            info.positionSourceInfo = deviceInfo;
            break;

        case controller.eConnectionType.network:
            info.positionSourceType = 4 //PositionSourceManager.PositionSourceType.Network;
            info.positionSourceInfo = networkInfo;
            break;

        case controller.eConnectionType.file:
            info.positionSourceType = 5 //PositionSourceManager.PositionSourceType.File;
            info.positionSourceInfo = fileInfo;
            break;

        default:
            console.error("Unknown connectionType:", controller.connectionType);

            info.positionSourceType = 0 //PositionSourceManager.PositionSourceType.Unknown;
            info.positionSourceInfo = undefined;
            break;
        }

        info.positionSourceTypeValid = true;
        info.positionSourceInfoValid = typeof info.positionSourceInfo === "object";
    }

    //--------------------------------------------------------------------------

    /*
      The height above the ellipsoid (HAE) of a point is determined by its altitude above
      mean sea-level (MSL) and the geoid separation (N) at this location:

          HAE = MSL + N

      where N > 0 if the geoid lies above the ellipsoid, and N < 0 if the geoid lies below.

      The geoid separation can be reported by the device (Ngps) or it can be user defined (Nuser).

      If Ngps is defined then the altitude reported by the device is altitude above mean sea-level
      (GPS_MSL), otherwise it is height above ellipsoid (GPS_HAE).

      If Ngps or Nuser are undefined, they will be set to 0. If Nuser is defined it takes precedence
      over Ngps on the assumption that the user is working with a more accurate geoid separation
      model. In this case, mean sea level altitudes have to be corrected for the geoid separation
      reported by the device.

      -----------------+----------------------------------+--------------------------------
                       |          Ngps undefined          |          Ngps defined
      -----------------+----------------------------------+--------------------------------
                       |  MSL = GPS_HAE (+ Ngps) - Nuser  |  MSL = GPS_MSL + Ngps - Nuser
      Nuser defined    |                                  |
                       |  HAE = GPS_HAE (+ Npgs)          |  HAE = GPS_MSL + Ngps
      -----------------+----------------------------------+--------------------------------
                       |  MSL ~ GPS_HAE                   |  MSL = GPS_MSL
      Nuser undefined  |                                  |
                       |  HAE = GPS_HAE (+ Ngps)          |  HAE = GPS_MSL + Ngps
      -----------------+----------------------------------+--------------------------------
    */

    function updateAltitude(position) {
        if (!position.altitudeValid) {
            return
        }

        var Ngps = position.geoidSeparationValid ? position.geoidSeparation : 0.0;
        var Nuser = isFinite(customGeoidSeparation) ? customGeoidSeparation : 0.0;
        var altitude = position.coordinate.altitude;

        switch (altitudeType) {
        case 0: // MSL
        default:
            if (isFinite(customGeoidSeparation)) {
                altitude += Ngps - Nuser;
            }
            break;

        case 1: // HAE;
            altitude += Ngps;
            break;
        }

        // Subtract antenna height
        if (isFinite(antennaHeight)) {
            position.antennaHeight = antennaHeight;
            position.antennaHeightValid = true;

            altitude -= antennaHeight;
        }

        position.coordinate.altitude = altitude;
    }

    //--------------------------------------------------------------------------

    // Report horizontal, vertical, and position accuracy with 68% or 95% confidence level,
    // assuming that the errors in all directions are approximately equal, see
    // https://www.fgdc.gov/standards/projects/accuracy/part3/chapter3 (p3-10 and p3-11) and
    // http://earth-info.nga.mil/GandG/publications/tr96.pdf (pA-4)
    function updateAccuracy(position) {
        switch (confidenceLevelType) {
        case 0: // 68% CL
        default:
            break;

        case 1: // 95% CL
            if (position.positionAccuracyValid) {
                // this is 2.7955/sqrt(3)
                position.positionAccuracy *= 1.6140;
            }

            if (position.horizontalAccuracyValid) {
                // this is 2.4477/sqrt(2)
                position.horizontalAccuracy *= 1.7308;
            }

            if (position.verticalAccuracyValid) {
                position.verticalAccuracy *= 1.96;
            }
        }
    }

    //--------------------------------------------------------------------------
}
