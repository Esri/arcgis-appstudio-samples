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
import "../lib/CoordinateConversions.js" as CC

ColumnLayout {
    id: numberField

    property alias text: textField.text
    property alias suffixText: textField.suffixText
    property alias placeholderText: textField.placeholderText

    property color textColor: "#000000"
    property color borderColor: "#c0c0c0"
    property color selectedColor: "#c0c0c0"
    property color backgroundColor: "transparent"

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 14 * AppFramework.displayScaleFactor
    property real letterSpacing: 0
    property bool bold: false
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    property var locale: Qt.locale()

    property real value: Number.NaN
    property bool updating

    //--------------------------------------------------------------------------

    AppTextField {
        id: textField

        Layout.fillWidth: true
        Layout.preferredHeight: parent.height

        text: isFinite(value) ? CC.numberToLocaleString(locale, value) : ""

        textColor: numberField.textColor
        borderColor: numberField.borderColor
        selectedColor: numberField.selectedColor
        backgroundColor: numberField.backgroundColor
        fontFamily: numberField.fontFamily
        pixelSize: numberField.pixelSize
        letterSpacing: numberField.letterSpacing
        bold: numberField.bold
        locale: numberField.locale
        isRightToLeft: numberField.isRightToLeft

        Component.onCompleted: {
            if (Qt.platform.os === "ios") {
                inputMethodHints = Qt.ImhPreferNumbers;
            } else {
                inputMethodHints = Qt.ImhFormattedNumbersOnly;
            }
        }

        onTextChanged: {
            updateValue();
        }

        function updateValue() {
            if (!updating) {
                updating = true;

                if (textField.length && textField.acceptableInput) {
                    value = CC.numberFromLocaleString(locale, text);
                } else {
                    value = Number.NaN;
                }

                updating = false;
            }
        }
    }

    //--------------------------------------------------------------------------
}
