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

import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework.Devices 1.0

Rectangle {
    id: debugRec

    property NmeaSource nmeaSource

    property bool isPaused

    signal clear();

    color: "black"

    //--------------------------------------------------------------------------

    onClear: dataModel.clear()

    //--------------------------------------------------------------------------

    Connections {
        target: nmeaSource

        onReceivedNmeaData: {
            if (!isPaused) {
                dataModel.append({
                                     dataText: nmeaSource.receivedSentence.trim(),
                                     isValid: true
                                 });
            }

            if (dataModel.count > 100) {
                dataModel.remove(0);
            }
        }
    }

    //--------------------------------------------------------------------------

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5 * scaleFactor

        ListView {
            id: listView

            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 3 * scaleFactor
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

        Text {
            width: ListView.view.width

            text: dataText
            color: isValid ? "#00ff00" : "#ff0000"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.bottom
                }

                height: 1
                color: "#80808080"
            }
        }
    }

    //--------------------------------------------------------------------------

    RoundButton {
        width: 56 * scaleFactor
        height: this.width

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80 * scaleFactor
        anchors.right: parent.right
        anchors.rightMargin: 15 * scaleFactor

        Material.elevation: 6
        Material.background: primaryColor
        contentItem: Image {
            id:pauseImage

            source: isPaused ? "../assets/play.png" : "../assets/pause.png"
            anchors.centerIn: parent
            mipmap: true
        }

        onClicked: isPaused = isPaused ? false : true;
    }

    //--------------------------------------------------------------------------

    RoundButton {
        width: 56 * scaleFactor
        height: this.width

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15 * scaleFactor
        anchors.right: parent.right
        anchors.rightMargin: 15 * scaleFactor

        Material.elevation: 6
        Material.background: primaryColor
        contentItem: Image {
            id:clearImage

            source: "../assets/clear.png"
            anchors.centerIn: parent
            mipmap: true
        }

        ColorOverlay {
            anchors.fill: clearImage
            source: clearImage
            color: "white"
        }

        onClicked: clear();
    }

    //--------------------------------------------------------------------------
}
