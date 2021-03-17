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
import QtQuick.Layouts 1.15

import ArcGIS.AppFramework 1.0

import "../controls"

Item {
    id: infoText

    property string label
    property var value

    property bool isValid: value !== null && value !== undefined && value !== ""
    property string invalidValue: qsTr("No data")
    property bool showInvalid: true

    property color labelColor: "grey"
    property color textColor: "black"
    property color invalidColor: AppFramework.alphaColor(textColor, 0.8)

    property real labelRatio: 0.5

    property string fontFamily: Qt.application.font.family
    property real letterSpacing: 0
    property var locale: Qt.locale()
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    //--------------------------------------------------------------------------

    signal labelClicked(var mouse)
    signal labelPressAndHold(var mouse)

    signal valueClicked(var mouse)
    signal valuePressAndHold(var mouse)

    //--------------------------------------------------------------------------

    implicitHeight: layout.height
    height: layout.height

    visible: isValid || showInvalid

    //--------------------------------------------------------------------------

    RowLayout {
        id: layout

        width: parent.width

        AppText {
            id: labelText

            Layout.preferredWidth: infoText.width * labelRatio
            Layout.fillHeight: true

            text: label
            color: labelColor

            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            fontFamily: infoText.fontFamily
            letterSpacing: infoText.letterSpacing
            pixelSize: 12 * AppFramework.displayScaleFactor
            bold: false

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    labelClicked(mouse);
                }

                onPressAndHold: {
                    labelPressAndHold(mouse);
                }
            }
        }

        AppText {
            id: valueText

            Layout.fillWidth: true
            Layout.fillHeight: true

            text: isValid ? value : invalidValue

            fontFamily: infoText.fontFamily
            letterSpacing: infoText.letterSpacing
            pixelSize: 14 * AppFramework.displayScaleFactor
            bold: isValid
            font.italic: !isValid

            color: isValid ? textColor : invalidColor

            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 1
            elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    copyToClipboard();
                    valueClicked(mouse);
                }

                onPressAndHold: {
                    valuePressAndHold(mouse);
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    function copyToClipboard() {
        if (!isValid) {
            return;
        }

        console.log("Copy to clipboard:", valueText.text);

        AppFramework.clipboard.copy(valueText.text);
    }

    //--------------------------------------------------------------------------
}
