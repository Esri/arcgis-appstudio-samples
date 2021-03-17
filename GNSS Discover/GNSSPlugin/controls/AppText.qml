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
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

import ArcGIS.AppFramework 1.0

Label {
    id: appText

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 12 * AppFramework.displayScaleFactor
    property real letterSpacing: 0
    property bool bold: false

    font {
        family: appText.fontFamily
        pixelSize: appText.pixelSize
        letterSpacing: appText.letterSpacing
        bold: appText.bold
    }

    textFormat: Text.AutoText

    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

    Accessible.role: Accessible.StaticText
    Accessible.name: text
    Accessible.description: text
}
