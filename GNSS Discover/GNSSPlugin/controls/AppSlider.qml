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
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0

Rectangle {
    id: control

    property alias to: slider.to
    property alias from: slider.from
    property alias stepSize: slider.stepSize
    property alias value: slider.value

    property string text: ""
    property string toolTipText: slider.value.toFixed(0)

    property color textColor: "#000000"
    property color checkedColor: "#007ac2"
    property color backgroundColor: "#FAFAFA"
    property color hoverBackgroundColor: "#e1f0fb"

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 16 * AppFramework.displayScaleFactor
    property real letterSpacing: 0
    property bool bold: true
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    property real leftPadding: 20 * AppFramework.displayScaleFactor
    property real rightPadding: 20 * AppFramework.displayScaleFactor

    property bool isHovered: false

    color: isHovered ? hoverBackgroundColor : backgroundColor

    //--------------------------------------------------------------------------

    RowLayout {
        anchors.fill: parent

        spacing: 10 * AppFramework.displayScaleFactor

        AppText {
            id: textControl

            Layout.fillHeight: true

            opacity: control.enabled ? 1.0 : 0.3
            color: textColor

            text: control.text

            font {
                family: control.fontFamily
                pixelSize: control.pixelSize
                letterSpacing: control.letterSpacing
                bold: control.bold
            }

            verticalAlignment: Text.AlignVCenter
            leftPadding: isRightToLeft ? 0 : control.leftPadding
            rightPadding: isRightToLeft ? control.leftPadding : 0
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            LayoutMirroring.enabled: false

            horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
        }

        //--------------------------------------------------------------------------

        Slider {
            id: slider

            Layout.fillHeight: true
            Layout.fillWidth: true

            leftPadding: isRightToLeft ? control.leftPadding : 0
            rightPadding: isRightToLeft ? 0 : control.leftPadding

            hoverEnabled: true

            Material.accent: checkedColor
            Material.foreground: textColor
            Material.elevation: 1

            //--------------------------------------------------------------------------

            onMoved: isHovered = true
            onPressedChanged: isHovered = pressed
            onHoveredChanged: isHovered = hovered

            //--------------------------------------------------------------------------

            ToolTip {
                parent: slider.handle
                visible: slider.pressed && toolTipText > ""
                text: control.toolTipText
            }

            //--------------------------------------------------------------------------
        }
    }
}
