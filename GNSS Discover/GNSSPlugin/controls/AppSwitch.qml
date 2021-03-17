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
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0

SwitchDelegate {
    id: control

    property color textColor: "#000000"
    property color checkedColor: "#007ac2"
    property color backgroundColor: "#FAFAFA"
    property color hoverBackgroundColor: "#e1f0fb"

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 16 * AppFramework.displayScaleFactor
    property bool bold: true

    property bool isHovered: false

    hoverEnabled: true

    Material.accent: checkedColor
    Material.foreground: textColor

    spacing: 5 * AppFramework.displayScaleFactor

    //--------------------------------------------------------------------------

    onPressed: isHovered = true
    onReleased: isHovered = false
    onCanceled: isHovered = false
    onHoveredChanged: isHovered = hovered

    //--------------------------------------------------------------------------

    font {
        family: control.fontFamily
        pixelSize: control.pixelSize
        bold: control.bold
    }

    //--------------------------------------------------------------------------

    indicator: Switch {
        enabled: control.enabled

        anchors.right: parent.right
        anchors.rightMargin: control.rightPadding
        anchors.verticalCenter: parent.verticalCenter
        padding: 0

        Material.accent: control.checkedColor

        checked: control.checked

        onCheckedChanged: {
            if (checked !== control.checked)
                control.checked = checked;
        }
    }

    background: Rectangle {
        anchors.fill: parent

        color: isHovered ? hoverBackgroundColor : backgroundColor
    }

    //--------------------------------------------------------------------------
}
