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

import QtQml 2.12
import QtQuick 2.12

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0

import "../"
import "../controls"
import "../GNSSManager"

Item {
    id: nmeaLogger

    //--------------------------------------------------------------------------

    property GNSSManager gnssManager

    property string logFileLocation: AppFramework.userHomePath + "/ArcGIS/" + Qt.application.name

    property bool allowLogging: true
    property bool isRecording: false
    property bool isPaused: false
    property bool updating: false

    property color infoTextColor: "white"
    property color infoBackgroundColor: "blue"

    property color errorTextColor: "white"
    property color errorBackgroundColor: "#a80000"

    readonly property url kIconSatellite: "../images/satellite.png"

    property string fontFamily: Qt.application.font.family
    property real letterSpacing: 0
    property var locale: Qt.locale()
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    //--------------------------------------------------------------------------
    // Internal properties

    readonly property PositionSourceManager positionSourceManager: gnssManager.positionSourceManager
    readonly property NmeaSource nmeaSource: positionSourceManager.nmeaSource

    property var nmeaLogFile

    //--------------------------------------------------------------------------

    anchors.fill: parent
    z: 99999

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
            var message = "";

            if (isRecording) {
                nmeaLogFile = openLog();

                if (nmeaLogFile) {
                    message = qsTr("Recording started.");
                    faderMessage.show(message, kIconSatellite, infoTextColor, infoBackgroundColor)
                } else {
                    message = qsTr("Unable to open NMEA log file.");
                    faderMessage.show(message, kIconSatellite, errorTextColor, errorBackgroundColor)
                    isRecording = false;
                }
            } else {
                closeLog(nmeaLogFile);

                message = qsTr("Recording finished.");
                faderMessage.show(message, kIconSatellite, infoTextColor, infoBackgroundColor)
            }
            updating = false;
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: nmeaSource

        onReceivedNmeaData: {
            if (allowLogging && isRecording && !isPaused) {
                writeLog(nmeaLogFile, nmeaSource.receivedSentence.trim());
            }
        }
    }

    //--------------------------------------------------------------------------

    FaderMessage {
        id: faderMessage

        z: 9999

        fontFamily: nmeaLogger.fontFamily
        letterSpacing: nmeaLogger.letterSpacing
        pixelSize: 20 * AppFramework.displayScaleFactor
        bold: false
    }

    //--------------------------------------------------------------------------

    MouseArea {
        anchors.fill: parent

        enabled: faderMessage.visible

        onClicked: {
            faderMessage.hide();
        }
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: fileFolder

        path: nmeaLogger.logFileLocation

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
                console.log("Writing to file" + file.path);
            } else {
                console.log("Unable to open file" + file.path);
                file = undefined;
            }
        }

        return file;
    }

    function closeLog(file) {
        if (file && file.openMode !== File.NotOpen) {
            file.close();
        }
    }

    function writeLog(file, text) {
        if (file && file.openMode !== File.NotOpen) {
            file.writeLine(text);
        }
    }

    //--------------------------------------------------------------------------
}
