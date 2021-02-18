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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

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
    onHoveredChanged: isHovered = hovered

    //--------------------------------------------------------------------------

    font {
        family: control.fontFamily
        pixelSize: control.pixelSize
        bold: control.bold
    }

    //--------------------------------------------------------------------------

    indicator: Item {
        id: indicator
        implicitWidth: 38 * AppFramework.displayScaleFactor
        implicitHeight: 32 * AppFramework.displayScaleFactor

        anchors.right: parent.right
        anchors.rightMargin: control.rightPadding
        anchors.verticalCenter: parent.verticalCenter

        property Item control
        property alias handle: handle

        Material.elevation: 1

        Rectangle {
            width: parent.width
            height: 14 * AppFramework.displayScaleFactor
            radius: height / 2
            y: parent.height / 2 - height / 2
            color: control.enabled ? (control.checked ? control.Material.switchCheckedTrackColor : control.Material.switchUncheckedTrackColor)
                                   : control.Material.switchDisabledTrackColor
        }

        Rectangle {
            id: handle
            x: Math.max(0, Math.min(parent.width - width, control.visualPosition * parent.width - (width / 2)))
            y: (parent.height - height) / 2
            width: 20 * AppFramework.displayScaleFactor
            height: 20 * AppFramework.displayScaleFactor
            radius: width / 2
            color: control.enabled ? (control.checked ? control.Material.switchCheckedHandleColor : control.Material.switchUncheckedHandleColor)
                                   : control.Material.switchDisabledHandleColor

            Behavior on x {
                enabled: !control.pressed
                SmoothedAnimation {
                    duration: 300
                }
            }
            layer.enabled: indicator.Material.elevation > 0
            layer.effect: DropShadow {
                radius: 8
                samples: 17
                color: control.checked ? handle.color : Qt.darker(handle.color)
            }
        }
    }

    background: Rectangle {
        anchors.fill: parent

        color: isHovered ? hoverBackgroundColor : backgroundColor
    }

    //--------------------------------------------------------------------------
}
