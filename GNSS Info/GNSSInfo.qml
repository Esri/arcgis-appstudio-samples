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
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Speech 1.0

import "controls" as Controls
import "views"

App {
    id: app

    width: 400 * scaleFactor
    height: 750 * scaleFactor

    property alias positionSource: sources.positionSource
    property alias satelliteInfoSource: sources.satelliteInfoSource
    property alias nmeaSource: sources.nmeaSource
    property alias tcpSocket: sources.tcpSocket
    property alias discoveryAgent: sources.discoveryAgent

    property Device currentDevice: sources.currentDevice
    property bool isConnecting: sources.isConnecting
    property bool isConnected: sources.isConnected

    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize: 14 * scaleFactor

    property color primaryColor: "#8f499c"
    property color darkPrimaryColor: "#662472"
    property color backgroundColor: "#EEEEEE"
    property color navBarColor: "#FFFFFF"
    property color greyTextColor: "#555555"

    readonly property string disconnectedText: qsTr("Device disconnected")
    readonly property string connectedText: qsTr("Device connected")

    signal showLocationPage()

    //--------------------------------------------------------------------------

    onIsConnectedChanged: {
        if (isConnected) {
            textToSpeech.say(connectedText);
            showLocationPage();
        } else {
            textToSpeech.say(disconnectedText);
        }
    }

    //--------------------------------------------------------------------------

    onShowLocationPage: {
        locationPage.clear();
        skyplotPage.clear();
        debugPage.clear();

        if (footer.currentIndex === 0) {
            footer.currentIndex = 1;
        }
    }

    //--------------------------------------------------------------------------

    Page {
        anchors.fill: parent

        header: ToolBar {
            id: header

            width: parent.width
            height: 50 * scaleFactor
            Material.background: primaryColor

            Controls.HeaderBar {
                headerText: app.info.title
            }
        }

        //--------------------------------------------------------------------------

        contentItem: Rectangle {
            anchors.top: header.bottom
            color: backgroundColor

            DevicePage {
                id: devicePage

                anchors.fill: parent
                visible: footer.currentIndex === 0

                discoveryAgent: app.discoveryAgent
                currentDevice: app.currentDevice
                isConnecting: app.isConnecting
                isConnected: app.isConnected
            }

            LocationPage {
                id: locationPage

                anchors.fill: parent
                visible: footer.currentIndex === 1

                positionSource: app.positionSource
                isConnected: app.isConnected
            }

            SkyPlotPage {
                id: skyplotPage

                anchors.fill: parent
                visible: footer.currentIndex === 2

                positionSource: app.positionSource
                satelliteInfoSource: app.satelliteInfoSource
            }

            QualityPage {
                id: qualityPage

                anchors.fill: parent
                visible: footer.currentIndex === 3

                positionSource: app.positionSource
            }

            DebugPage {
                id: debugPage

                anchors.fill: parent
                visible: footer.currentIndex === 4

                nmeaSource: app.nmeaSource
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
            height: 52 * scaleFactor
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
                id: skyplotIcon

                height: footer.height
                imageSource: "assets/skyplot.png"
                imageColor: checked ? primaryColor : "grey"
                imageText: qsTr("SkyPlot")
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

    //--------------------------------------------------------------------------

    DescriptionPage {
        id: descPage

        visible: false
    }

    //--------------------------------------------------------------------------

    PositioningSources {
        id: sources
    }

    //--------------------------------------------------------------------------

    Connections {
        target: tcpSocket

        onErrorChanged: {
            console.log("Connection error:", tcpSocket.error, tcpSocket.errorString)

            errorDialog.text = tcpSocket.errorString;
            errorDialog.open();
        }
    }

    // -------------------------------------------------------------------------

    Connections {
        target: currentDevice

        onErrorChanged: {
            if (currentDevice) {
                console.log("Connection error:", currentDevice.error)

                errorDialog.text = currentDevice.error;
                errorDialog.open();
            }
        }
    }

    // -------------------------------------------------------------------------

    Dialog {
        id: errorDialog

        property alias text: label.text

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true

        standardButtons: Dialog.Ok
        title: qsTr("Unable to connect");
        text: ""

        Label {
            id: label

            Layout.fillWidth: true
            font.pixelSize: baseFontSize
            Material.accent: primaryColor
        }
    }

    //--------------------------------------------------------------------------

    TextToSpeech {
        id: textToSpeech
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
