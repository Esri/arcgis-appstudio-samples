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
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0

Button {
    id: button

    property int wrapMode: Text.NoWrap

    property color textColor: "black"
    property color pressedTextColor: "black"
    property color hoveredTextColor: "black"
    property color backgroundColor: "#fefefe"
    property color hoveredBackgroundColor: "#e1f0fb"
    property color pressedBackgroundColor: hoveredBackgroundColor

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 16 * AppFramework.displayScaleFactor
    property real letterSpacing: 0
    property bool bold: false

    property int horizontalAlignment: Text.AlignHCenter
    property int verticalAlignment: Text.AlignVCenter

    //--------------------------------------------------------------------------

    contentItem: RowLayout {
        anchors.fill: parent

        spacing: 0

        AppText {
            id: buttonText

            Layout.fillWidth: true
            Layout.fillHeight: true

            text: button.text
            color: button.pressed
                   ? pressedTextColor
                   : button.hovered
                     ? hoveredTextColor
                     : textColor

            verticalAlignment: button.verticalAlignment
            horizontalAlignment: button.horizontalAlignment
            minimumPixelSize: 8 * AppFramework.displayScaleFactor
            pixelSize: button.pixelSize
            fontFamily: button.fontFamily
            letterSpacing: button.letterSpacing
            bold: button.bold
            fontSizeMode: Text.Fit
            elide: Text.ElideRight
            wrapMode: button.wrapMode
        }
    }

    background: Rectangle {
        anchors.fill: parent

        radius: 6 * AppFramework.displayScaleFactor

        color: button.pressed
               ? pressedBackgroundColor
               : button.hovered
                 ? hoveredBackgroundColor
                 : backgroundColor
    }

    //--------------------------------------------------------------------------
}
