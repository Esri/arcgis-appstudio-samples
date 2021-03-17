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
import ArcGIS.AppFramework.Speech 1.0
import ArcGIS.AppFramework.Notifications 1.0

import "../controls"

Item {
    id: alerts

    //--------------------------------------------------------------------------

    enum AlertType {
        Connected = 1,
        Disconnected = 2,
        NoData = 3,
        NoPosition = 4,
        RecordingStarted = 5,
        RecordingStopped = 6,
        FileIOError = 7
    }

    //--------------------------------------------------------------------------

    property GNSSSettings gnssSettings

    property color infoTextColor: "white"
    property color infoBackgroundColor: "blue"

    property color warningTextColor: "black"
    property color warningBackgroundColor: "#FFBF00"

    property color errorTextColor: "white"
    property color errorBackgroundColor: "#a80000"

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 20 * AppFramework.displayScaleFactor
    property real letterSpacing: 0
    property bool bold: false

    property var locale: Qt.locale()

    readonly property url kIconSatellite: "../images/satellite.png"

    //--------------------------------------------------------------------------

    anchors.fill: parent
    z: 99999

    //--------------------------------------------------------------------------

    readonly property var kPositionAlertInfos: [
        {
            type: GNSSAlerts.AlertType.Connected,
            icon: kIconSatellite,
            sayMessage: qsTr("The location sensor is connected"),
            displayMessage: qsTr("Location sensor connected"),
            textColor: infoTextColor,
            backgroundColor: infoBackgroundColor,
            priority: true,
        },

        {
            type: GNSSAlerts.AlertType.Disconnected,
            icon: kIconSatellite,
            sayMessage: qsTr("The location sensor is disconnected"),
            displayMessage: qsTr("Location sensor disconnected"),
            textColor: errorTextColor,
            backgroundColor: errorBackgroundColor,
            priority: true,
        },

        {
            type: GNSSAlerts.AlertType.NoData,
            icon: kIconSatellite,
            sayMessage: qsTr("No data is being received from the location sensor"),
            displayMessage: qsTr("No data received"),
            textColor: warningTextColor,
            backgroundColor: warningBackgroundColor,
            priority: false,
        },

        {
            type: GNSSAlerts.AlertType.NoPosition,
            icon: kIconSatellite,
            sayMessage: qsTr("No positions are being received from the location sensor"),
            displayMessage: qsTr("No position received"),
            textColor: warningTextColor,
            backgroundColor: warningBackgroundColor,
            priority: false,
        },

        {
            type: GNSSAlerts.AlertType.RecordingStarted,
            icon: kIconSatellite,
            sayMessage: qsTr("Recording started"),
            displayMessage: qsTr("Recording started"),
            textColor: infoTextColor,
            backgroundColor: infoBackgroundColor,
            priority: true,
        },

        {
            type: GNSSAlerts.AlertType.RecordingStopped,
            icon: kIconSatellite,
            sayMessage: qsTr("Recording stopped"),
            displayMessage: qsTr("Recording stopped"),
            textColor: infoTextColor,
            backgroundColor: infoBackgroundColor,
            priority: true,
        },

        {
            type: GNSSAlerts.AlertType.FileIOError,
            icon: kIconSatellite,
            sayMessage: qsTr("Log file could not be opened"),
            displayMessage: qsTr("Unable to open log file"),
            textColor: errorTextColor,
            backgroundColor: errorBackgroundColor,
            priority: true,
        },
    ]

    //--------------------------------------------------------------------------

    function positionSourceAlert(alertType) {
        console.log("positionSourceAlert:", alertType);

        var alertInfo;

        for (var i = 0; i < kPositionAlertInfos.length; i++) {
            if (kPositionAlertInfos[i].type === alertType) {
                alertInfo = kPositionAlertInfos[i];
                break;
            }
        }

        var sayMessage;
        var icon;
        var displayMessage;
        var textColor;
        var backgroundColor;
        var priority;

        if (alertInfo) {
            icon = alertInfo.icon;
            sayMessage = alertInfo.sayMessage;
            displayMessage = alertInfo.displayMessage;
            textColor = alertInfo.textColor;
            backgroundColor = alertInfo.backgroundColor;
            priority = alertInfo.priority;
        } else {
            icon = kIconSatellite;
            sayMessage = qsTr("Position source alert %1").arg(alertType);
            displayMessage = qsTr("Position source alert %1").arg(alertType);
            textColor = warningTextColor;
            backgroundColor = warningBackgroundColor;
            priority = false;
        }

        if (gnssSettings.locationAlertsVibrate) {
            Vibration.vibrate();
        }

        if (gnssSettings.locationAlertsSpeech) {
            say(sayMessage, priority);
        }

        if (gnssSettings.locationAlertsVisual) {
            show(displayMessage, icon, textColor, backgroundColor, undefined, priority);
        }
    }

    //--------------------------------------------------------------------------

    function say(message, priority) {
        if (tts.state !== TextToSpeech.Ready && !priority) {
            return;
        }

        if (tts.state === TextToSpeech.Speaking) {
            tts.stop();
        }

        tts.say(message);
    }

    //--------------------------------------------------------------------------

    function show(message, icon, textColor, backgroundColor, duration, priority) {
        if (faderMessage.visible && !priority) {
            return;
        }

        if (textColor === undefined) {
            textColor = infoTextColor;
        }

        if (backgroundColor === undefined) {
            backgroundColor = infoBackgroundColor;
        }

        faderMessage.show(message, icon, textColor, backgroundColor, duration);
    }

    //--------------------------------------------------------------------------

    TextToSpeech {
        id: tts
    }

    onLocaleChanged: {
        // textToSpeech.availableLocales can take a long time to access on some platforms,
        // so we take a local copy once and use this to do the checks below
        var supportedLocales = JSON.parse(JSON.stringify(tts.availableLocales));

        // e.g. system locale en_AU -> T2S supported locale en_AU
        var found = supportedLocales.indexOf(locale.name)

        if (found < 0) {
            var languageCode = AppFramework.localeInfo(locale.name).languageCode

            // e.g. system locale de_CH -> Qt default locale de_DE -> T2S supported locale de_DE
            found = supportedLocales.indexOf(locale.name)

            if (found < 0) {
                var codes = [];

                for (var indx in supportedLocales) {
                    codes.push(supportedLocales[indx].split("_")[0]);
                }

                // e.g. system locale ar_QA -> Qt default locale ar_EG -> language "ar" -> T2S supported locale ar_SA
                found = codes.indexOf(languageCode);
            }
        }

        // Known exceptions could be added here, e.g. locale "gsw_CH" (Swiss German dialect)
        // could be mapped to "de_De".

        if (found >= 0) {
            tts.locale = supportedLocales[found];
        }
    }

    //--------------------------------------------------------------------------

    FaderMessage {
        id: faderMessage

        fontFamily: alerts.fontFamily
        pixelSize: alerts.pixelSize
        letterSpacing: alerts.letterSpacing
        bold: alerts.bold
    }

    MouseArea {
        anchors.fill: parent

        enabled: faderMessage.visible

        onClicked: {
            faderMessage.hide();

            if (tts.state === TextToSpeech.Speaking) {
                tts.stop();
            }
        }
    }

    //--------------------------------------------------------------------------
}
