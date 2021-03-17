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
import ArcGIS.AppFramework.Sql 1.0

import "../GNSSManager"

Item {
    id: nmeaLogger

    //--------------------------------------------------------------------------

    property PositionSourceManager positionSourceManager

    property string logFileLocation: AppFramework.userHomePath + "/ArcGIS/" + Qt.application.name + "/Logs/"

    property bool allowLogging: true
    property bool isRecording: false
    property bool isPaused: false

    //--------------------------------------------------------------------------
    // Internal properties

    readonly property NmeaSource nmeaSource: positionSourceManager.nmeaSource

    property var nmeaLogFile
    property bool updating

    signal receivedNmeaData(var receivedSentence)
    signal alert(int alertType)

    //--------------------------------------------------------------------------

    Component.onDestruction: {
        if (allowLogging && isRecording) {
            closeLog(nmeaLogFile);
        }
    }

    //--------------------------------------------------------------------------

    onAllowLoggingChanged: {
        if (!allowLogging && isRecording) {
            closeLog(nmeaLogFile);
        }
    }

    //--------------------------------------------------------------------------

    onIsRecordingChanged: {
        if (allowLogging && !updating) {
            updating = true;

            if (isRecording) {
                nmeaLogFile = openLog();

                if (nmeaLogFile) {
                    alert(GNSSAlerts.AlertType.RecordingStarted);
                } else {
                    isRecording = false;

                    alert(GNSSAlerts.AlertType.FileIOError);
                }
            } else {
                closeLog(nmeaLogFile);

                alert(GNSSAlerts.AlertType.RecordingStopped);
            }

            updating = false;
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: nmeaSource
        enabled: !positionSourceManager.isInternal

        function onReceivedNmeaData() {
            logSentence(nmeaSource.receivedSentence.trim())
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: positionSourceManager
        enabled: positionSourceManager.isInternal

        function onNewPosition(position) {
            logPosition(position);
        }
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: fileFolder

        path: logFileLocation

        onPathChanged: {
            if (allowLogging) {
                makeFolder();
            }
        }

        Component.onCompleted: {
            if (allowLogging) {
                makeFolder();
            }
        }
    }

    //--------------------------------------------------------------------------

    function openLog() {
        var file = AppFramework.file(fileFolder.path + "/" + "NMEALog.nmea");

        if (file) {
            var index = 1;

            while (file.exists) {
                file.path = fileFolder.path + "/" + "NMEALog%1.nmea".arg(index)
                index++;
            }

            if (file.open(File.OpenModeReadWrite | File.OpenModeTruncate | File.OpenModeText)) {
                console.log("Writing to file " + file.path);
            } else {
                console.log("Unable to open file " + file.path);
                file = undefined;
            }
        }

        return file;
    }

    //--------------------------------------------------------------------------

    function closeLog(file) {
        if (file && file.openMode !== File.NotOpen) {
            file.close();
        }

        isPaused = false;
    }

    //--------------------------------------------------------------------------

    function writeLog(file, text) {
        if (file && file.openMode !== File.NotOpen) {
            file.writeLine(text);
        }
    }

    //--------------------------------------------------------------------------

    function logSentence(sentence) {
        if (allowLogging && isRecording && !isPaused) {
            writeLog(nmeaLogFile, sentence);
        }

        receivedNmeaData(sentence);
    }

    //--------------------------------------------------------------------------

    function logPosition(position) {
        var timestamp = position.timestamp;
        var coordinate = position.coordinate;
        if (!coordinate.isValid) {
            return;
        }

        var utcTime = "%1%2%3.%4"
        .arg(timestamp.getUTCHours().toString().padStart(2, "0"))
        .arg(timestamp.getUTCMinutes().toString().padStart(2, "0"))
        .arg(timestamp.getUTCSeconds().toString().padStart(2, "0"))
        .arg(Math.round(timestamp.getUTCMilliseconds()/10).toString().padStart(2, "0"));

        var utcDate = "%1%2%3"
        .arg(timestamp.getUTCDate().toString().padStart(2, "0"))
        .arg((timestamp.getUTCMonth() + 1).toString().padStart(2, "0"))
        .arg(timestamp.getUTCFullYear().toString().slice(-2));

        var ddm = Coordinate.convert(coordinate, "ddm").ddm;

        var ddmLatitude = ("%1%2"
                           .arg(ddm.latitudeDegrees.toString().padStart(2, "0"))
                           .arg("0".repeat(ddm.latitudeMinutes < 10 ? 1 : 0) + ddm.latitudeMinutes.toString())).padEnd(9, "0");

        var ddmLongitude = ("%1%2"
                            .arg(ddm.longitudeDegrees.toString().padStart(3, "0"))
                            .arg("0".repeat(ddm.longitudeMinutes < 10 ? 1 : 0) + ddm.longitudeMinutes.toString())).padEnd(10, "0");

        var sog = position.speedValid
                ? (Math.round(position.speed * 19.4384) / 10).toString()
                : "";

        var cog = position.directionValid
                ? (Math.round(position.direction * 10) / 10).toString()
                : "";

        var hdop = position.horizontalAccuracyValid
                ? (Math.round(position.horizontalAccuracy / 0.47) / 10).toString()
                : ""

        var vdop = position.verticalAccuracyValid
                ? (Math.round(position.verticalAccuracy / 0.47) / 10).toString()
                : ""

        var pdop = position.horizontalAccuracyValid && position.verticalAccuracyValid
                ? (Math.round(Math.sqrt(position.horizontalAccuracy*position.horizontalAccuracy + position.verticalAccuracy*position.verticalAccuracy) / 0.47) / 10).toString()
                : ""

        var fixType = position.horizontalAccuracyValid && position.verticalAccuracyValid
                ? 3 // 3D fix
                : position.horizontalAccuracyValid
                  ? 2 // 2D fix
                  : 1 // no fix

        var gsa = "GPGSA,A,%1,,,,,,,,,,,,,%2,%3,%4"
        .arg(fixType)
        .arg(pdop)
        .arg(hdop)
        .arg(vdop);

        logSentence(addChecksum(gsa));

        var gga = "GPGGA,%1,%2,%3,%4,%5,1,00,%6,%7,%8,,,,"
        .arg(utcTime)
        .arg(ddmLatitude)
        .arg(ddm.latitudeHemisphere)
        .arg(ddmLongitude)
        .arg(ddm.longitudeHemisphere)
        .arg(hdop)
        .arg(position.altitudeValid ? coordinate.altitude : "")
        .arg(position.altitudeValid ? "M" : "");

        logSentence(addChecksum(gga));

        var rmc = "GPRMC,%1,A,%2,%3,%4,%5,%6,%7,%8,%9,%10"
        .arg(utcTime)
        .arg(ddmLatitude)
        .arg(ddm.latitudeHemisphere)
        .arg(ddmLongitude)
        .arg(ddm.longitudeHemisphere)
        .arg(sog)
        .arg(cog)
        .arg(utcDate)
        .arg(position.magneticVariationValid ? Math.abs(position.magneticVariation) : "")
        .arg(position.magneticVariationValid ? position.magneticVariation < 0 ? "W" : "E" : "");

        logSentence(addChecksum(rmc));
    }

    //--------------------------------------------------------------------------

    function addChecksum(data) {
        var checksum = 0;

        for (var i = 0; i < data.length; i++) {
            checksum = checksum ^ data.charCodeAt(i);
        }

        var hex = Number(checksum).toString(16).toUpperCase().padStart(2, "0");

        return "$%1*%2".arg(data).arg(hex);
    }

    //--------------------------------------------------------------------------
}
