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
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Positioning 1.0

Item {
    id: monitor

    //--------------------------------------------------------------------------

    property PositionSourceManager positionSourceManager
    property bool monitorNmeaData: false

    readonly property NmeaSource nmeaSource: positionSourceManager.nmeaSource
    readonly property DeviceDiscoveryAgent discoveryAgent: positionSourceManager.discoveryAgent
    readonly property PositioningSourcesController controller: positionSourceManager.controller

    readonly property bool active: positionSourceManager.active

    property bool positionIsCurrent: false
    property var currentPosition: ({})

    //--------------------------------------------------------------------------

    property int maximumDataAge: 5000
    property int maximumPositionAge: 5000

    //--------------------------------------------------------------------------

    property double dataReceivedTime
    property double positionReceivedTime

    //--------------------------------------------------------------------------

    signal newPosition(var position)
    signal alert(int alertType)

    //--------------------------------------------------------------------------

    onActiveChanged: {
        console.log("Position source monitoring active:", active);

        if (active) {
            initialize();
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        id: timer

        interval: 10000
        triggeredOnStart: false
        repeat: true
        running: active

        onTriggered: {
            monitorCheck();
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        id: nmeaSourceConnections

        target: nmeaSource
        enabled: active && positionSourceManager.isGNSS

        function onReceivedNmeaData() {
            dataReceivedTime = (new Date()).valueOf();
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        id: positionSourceManagerConnections

        target: positionSourceManager
        enabled: active

        function onNewPosition(position) {
            positionReceivedTime = positionSourceManager.positionTimestamp

            if (!positionSourceManager.isGNSS || position.fixTypeValid && position.fixType > 0) {
                currentPosition = position;
                positionIsCurrent = true;
            } else {
                positionIsCurrent = false;
            }

            newPosition(position);
        }

        function onIsConnectedChanged() {
            if (positionSourceManager.isGNSS) {
                if (positionSourceManager.isConnected) {
                    alert(GNSSAlerts.AlertType.Connected);
                } else {
                    positionIsCurrent = false;
                    alert(GNSSAlerts.AlertType.Disconnected);
                }
            }
        }

        function onTcpError(errorString) { positionIsCurrent = false; }
        function onDeviceError(errorString) { positionIsCurrent = false; }
        function onNmeaLogFileError(errorString) { positionIsCurrent = false; }
        function onDiscoveryAgentError(errorString) { positionIsCurrent = false; }
        function onPositionSourceError(errorString) { positionIsCurrent = false; }
    }

    //--------------------------------------------------------------------------

    function initialize() {
        dataReceivedTime = (new Date()).valueOf();
        positionReceivedTime = (new Date()).valueOf();
    }

    //--------------------------------------------------------------------------

    function monitorCheck() {
        var now = new Date().valueOf();

        if (nmeaSourceConnections.enabled && monitorNmeaData && !positionSourceManager.onSettingsPage && !positionSourceManager.isConnecting && !discoveryAgent.running) {
            var dataAge = now - dataReceivedTime;

            if (dataAge > maximumDataAge) {
                positionIsCurrent = false;
                alert(GNSSAlerts.AlertType.NoData);
                return;
            }
        }

        if (positionSourceManagerConnections.enabled && !positionSourceManager.onSettingsPage && !positionSourceManager.isConnecting && !discoveryAgent.running) {
            var positionAge = now - positionReceivedTime;

            if (positionAge > maximumPositionAge || positionSourceManager.isGNSS && (!currentPosition.fixTypeValid || currentPosition.fixType === 0)) {
                positionIsCurrent = false;
                alert(GNSSAlerts.AlertType.NoPosition);
                return;
            }
        }
    }

    //--------------------------------------------------------------------------
}
