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
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0

import "../"
import "../controls"
import "../GNSSManager"

SwipeTab {
    id: tab

    title: qsTr("NMEA Log")
    icon: "../images/list-black-24dp.svg"

    //--------------------------------------------------------------------------

    property GNSSManager gnssManager
    property NmeaLogger nmeaLogger

    readonly property PositionSourceManager positionSourceManager: gnssManager.positionSourceManager

    //--------------------------------------------------------------------------

    property bool isPaused: nmeaLogger ? nmeaLogger.isPaused : false
    property bool isRecording: nmeaLogger ? nmeaLogger.isRecording : false

    property color textColor: "#000000"
    property color dividerColor: "#80808080"
    property color backgroundColor: "white"

    property color buttonBarBorderColor: "#efefef"
    property color buttonBarButtonColor: "#8f499c"
    property color buttonBarRecordingColor: "mediumvioletred"
    property color buttonBarBackgroundColor: "#f8f8f8"

    //--------------------------------------------------------------------------

    signal clear()

    //--------------------------------------------------------------------------

    onClear: {
        dataModel.clear();
    }

    //--------------------------------------------------------------------------

    Connections {
        target: nmeaLogger

        function onReceivedNmeaData(receivedSentence) {
            if (!isPaused) {
                var nmea = receivedSentence.trim();

                dataModel.append({
                                     dataText: nmea,
                                     isValid: true
                                 });
            }

            if (dataModel.count > 100) {
                dataModel.remove(0);
            }
        }
    }

    //--------------------------------------------------------------------------

    Rectangle {
        anchors.fill: parent
        color: backgroundColor

        ListView {
            id: listView

            anchors.fill: parent
            anchors.margins: 5 * AppFramework.displayScaleFactor

            spacing: 3 * AppFramework.displayScaleFactor
            clip: true

            model: dataModel
            delegate: dataDelegate
        }
    }

    //--------------------------------------------------------------------------

    ListModel {
        id: dataModel

        onCountChanged: {
            if (count > 0) {
                listView.positionViewAtEnd();
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: dataDelegate

        AppText {
            width: ListView.view.width

            text: dataText
            color: textColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignLeft

            fontFamily: tab.fontFamily
            letterSpacing: tab.letterSpacing
            pixelSize: 12 * AppFramework.displayScaleFactor

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.bottom
                }

                height: 1
                color: dividerColor
            }
        }
    }

    //--------------------------------------------------------------------------

    ButtonBarLayout {
        id: buttonBar

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: 15 * AppFramework.displayScaleFactor
        }

        color: buttonBarBackgroundColor
        border.color: buttonBarBorderColor

        StyledImageButton {
            id: pauseButton

            Layout.preferredWidth: 32 * AppFramework.displayScaleFactor
            Layout.preferredHeight: Layout.preferredWidth

            source: "../images/pause-32-f.svg"
            color: buttonBarButtonColor

            onClicked: {
                if (nmeaLogger) {
                    nmeaLogger.isPaused = !nmeaLogger.isPaused;
                } else {
                    isPaused = !isPaused;
                }

                buttonBar.fader.start();
            }

            PulseAnimation {
                target: pauseButton
                running: isPaused
            }
        }

        StyledImageButton {
            id: recordingButton

            Layout.preferredWidth: 32 * AppFramework.displayScaleFactor
            Layout.preferredHeight: Layout.preferredWidth

            source: isRecording ? "../images/square-32-f.svg" : "../images/recording-start.png"
            visible: nmeaLogger ? nmeaLogger.allowLogging : false
            color: buttonBarRecordingColor

            onClicked: {
                if (nmeaLogger) {
                    nmeaLogger.isRecording = !nmeaLogger.isRecording;
                } else {
                    isRecording = !isRecording;
                }

                buttonBar.fader.start();
            }

            PulseAnimation {
                target: recordingButton
                running: isRecording && !isPaused
            }
        }

        StyledImageButton {
            Layout.preferredWidth: 32 * AppFramework.displayScaleFactor
            Layout.preferredHeight: Layout.preferredWidth

            source: "../images/x-circle-32-f.svg"
            color: buttonBarButtonColor

            onClicked: {
                clear();

                buttonBar.fader.start();
            }
        }
    }

    //--------------------------------------------------------------------------
}

