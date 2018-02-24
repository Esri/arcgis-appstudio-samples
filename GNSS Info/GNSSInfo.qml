/* Copyright 2018 Esri
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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQml 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import ArcGIS.AppFramework.Positioning 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Networking 1.0

import "controls" as Controls
import "views"

App {
    id: app

    width: 400 * scaleFactor
    height: 750 * scaleFactor

    property alias positionSource: positionSource
    property alias position: positionSource.position

    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize: !isSmallScreen ? 18 * scaleFactor : 14 * scaleFactor

    property color primaryColor: "#8f499c"
    property color lightPrimaryColor: "#8f499c"
    property color backgroundColor: "#EEEEEE"
    property color navBarColor: "#FFFFFF"
    property color greyTextColor: "#555555"

    property bool isSmallScreen: (width || height) < 410 * scaleFactor
    property bool debug: false

    //--------------------------------------------------------------------------

    Page {
        anchors.fill: parent

        header: ToolBar {
            id: header

            width: parent.width
            height: isSmallScreen ? 50 * scaleFactor : 56 * scaleFactor
            Material.background: primaryColor

            Controls.HeaderBar {
                headerText: app.info.title
            }
        }

        // sample starts here ------------------------------------------------------

        contentItem: Rectangle {
            anchors.top: header.bottom
            color: backgroundColor

            DevicePage {
                id: devicePage

                anchors.fill: parent
                visible: footer.currentIndex === 0
            }

            LocationPage {
                id: locationPage

                anchors.fill: parent
                visible: footer.currentIndex === 1
            }

            QualityPage {
                id: qualityPage

                anchors.fill: parent
                visible: footer.currentIndex === 2
            }

            DebugPage {
                id: debugPage

                nmeaSource: nmeaSource

                anchors.fill: parent
                visible: footer.currentIndex === 3
            }
        }

        Rectangle {
            id: lineAboveFooter

            anchors.bottom: parent.bottom
            width: parent.width
            height: 1.3 * scaleFactor
            color: "lightgrey"
        }

        footer: TabBar {
            id: footer

            width: parent.width
            height: isSmallScreen ? 50 * scaleFactor : 56 * scaleFactor
            Material.accent: "#00000000"

            currentIndex: 0

            background: Rectangle {
                anchors.fill: parent
                color: navBarColor
            }

            Controls.CustomizedTabButton {
                id: deviceIcon

                height: footer.height
                imageSource: "assets/device.png"
                imageColor: checked ? primaryColor : "grey"
                imageText: qsTr("Device")
            }

            Controls.CustomizedTabButton {
                id: locationIcon

                height: footer.height
                imageSource: "assets/location.png"
                imageColor: checked ? primaryColor : "grey"
                imageText: qsTr("Location")
            }

            Controls.CustomizedTabButton {
                id: qualityIcon

                height: footer.height
                imageSource: "assets/quality.png"
                imageColor: checked ? primaryColor : "grey"
                imageText: qsTr("Quality")
            }

            Controls.CustomizedTabButton {
                id: debugIcon

                height: footer.height
                imageSource: "assets/debug.png"
                imageColor: checked ? primaryColor : "grey"
                imageText: qsTr("Log")
            }
        }
    }

    // sample ends here --------------------------------------------------------

    Controls.DescriptionPage {
        id: descPage

        visible: false
    }

    //--------------------------------------------------------------------------

    PositionSource {
        id: positionSource

        active: true
        nmeaSource: nmeaSource

        onPositionChanged: {
            if (debug) {
                console.log("Position change:", JSON.stringify(position));
            }
        }
    }

    //--------------------------------------------------------------------------

    NmeaSource {
        id: nmeaSource

        onSourceChanged: {
            console.log("SOURCE CHANGED", JSON.stringify(source));
            positionSource.update();
        }

        onReceivedNmeaData: {
            // sconsole.log("RECEIVED NMEA DATA", receivedSentence.trim());
        }
    }

    //--------------------------------------------------------------------------

    TcpSocket {
        id: tcpSocket
    }

    //--------------------------------------------------------------------------

    function convertValueToLengthString(value) {
        switch (Qt.locale().measurementSystem) {
        case Locale.MetricSystem:
            return qsTr("%1 m").arg(round(value, 3));
        case Locale.ImperialUKSystem:
        case Locale.ImperialUSSystem:
        case Locale.ImperialSystem:
            return qsTr("%1 ft").arg(round(value / 0.3048, 3));
        }
    }

    function convertValueToSpeedString(value) {
        switch (Qt.locale().measurementSystem) {
        case Locale.MetricSystem:
            return qsTr("%1 km/h").arg(round(value * 3.6, 2));
        case Locale.ImperialUKSystem:
        case Locale.ImperialUSSystem:
        case Locale.ImperialSystem:
            return qsTr("%1 mph").arg(round(value * 2.23694, 2));
        }
    }

    function round(value, numberOfDigits) {
        var pow = Math.pow(10, numberOfDigits);
        return (Math.round(value * pow) / pow).toFixed(numberOfDigits);
    }

    //--------------------------------------------------------------------------
}
