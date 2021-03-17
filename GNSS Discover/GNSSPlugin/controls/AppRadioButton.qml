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

RadioButton {
    id: control

    property color textColor: "#000000"
    property color checkedColor: "#007ac2"
    property color backgroundColor: "#FAFAFA"
    property color hoverBackgroundColor: "#e1f0fb"

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 16 * AppFramework.displayScaleFactor
    property real letterSpacing: 0
    property bool bold: true
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    property bool isHovered: false

    hoverEnabled: true

    spacing: 5 * AppFramework.displayScaleFactor

    //--------------------------------------------------------------------------

    onPressed: isHovered = true
    onReleased: isHovered = false
    onHoveredChanged: isHovered = hovered

    //--------------------------------------------------------------------------

    font {
        family: control.fontFamily
        pixelSize: control.pixelSize
        letterSpacing: control.letterSpacing
        bold: control.bold
    }

    //--------------------------------------------------------------------------

    contentItem: AppText {
        id: textControl

        opacity: control.enabled ? 1.0 : 0.3
        color: textColor

        text: control.text
        font: control.font

        verticalAlignment: Text.AlignVCenter
        rightPadding: isRightToLeft ? 0 : control.indicator.width + control.spacing
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        LayoutMirroring.enabled: false

        horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
    }

    //--------------------------------------------------------------------------

    indicator: Rectangle {
        implicitWidth: 30 * AppFramework.displayScaleFactor
        implicitHeight: 30 * AppFramework.displayScaleFactor

        x: isRightToLeft ? control.rightPadding : control.width - width - control.rightPadding
        y: parent.height / 2 - height / 2

        color: isHovered ? hoverBackgroundColor : backgroundColor

        Image {
            id: image

            anchors.fill: parent

            visible: false

            source: "../images/round_done_white_24dp.png"
            fillMode: Image.PreserveAspectFit
        }

        ColorOverlay {
            visible: control.checked
            anchors.fill: image
            source: image
            color: checkedColor
        }
    }

    //--------------------------------------------------------------------------

    background: Rectangle {
        anchors.fill: parent

        color: isHovered ? hoverBackgroundColor : backgroundColor
    }

    //--------------------------------------------------------------------------
}
