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
    property color pressedTextColor: textColor
    property color hoveredTextColor: textColor
    property color backgroundColor: "#fefefe"
    property color hoveredBackgroundColor: "#e1f0fb"
    property color pressedBackgroundColor: hoveredBackgroundColor

    property color nextIconColor: "#c0c0c0"
    property real nextIconSize: 30 * AppFramework.displayScaleFactor
    property url nextIcon: "../images/next.png"
    property bool showInfoIcon: false

    property color infoIconColor: "#c0c0c0"
    property real infoIconSize: 30 * AppFramework.displayScaleFactor
    property url infoIcon: "../images/sharp_add_white_24dp.png"
    property bool showNextIcon: false

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 16 * AppFramework.displayScaleFactor
    property real letterSpacing: 0
    property bool bold: true
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    property int horizontalAlignment: Text.AlignHCenter
    property int verticalAlignment: Text.AlignVCenter

    //--------------------------------------------------------------------------

    contentItem: RowLayout {
        anchors.fill: parent

        spacing: 0

        Item {
            Layout.preferredWidth: 16 * AppFramework.displayScaleFactor
            Layout.fillHeight: true
        }

        Item {
            Layout.preferredWidth: infoIconSize
            Layout.fillHeight: true

            visible: showInfoIcon
            enabled: visible

            Accessible.role: Accessible.Pane

            StyledImage {
                anchors.centerIn: parent

                width: infoIconSize
                height: width

                source: button.infoIcon
                color: button.pressed
                       ? pressedTextColor
                       : button.hovered
                         ? hoveredTextColor
                         : infoIconColor
            }
        }

        Item {
            Layout.preferredWidth: showInfoIcon ? 12 * AppFramework.displayScaleFactor : 4 * AppFramework.displayScaleFactor
            Layout.fillHeight: true
        }

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

            LayoutMirroring.enabled: false

            verticalAlignment: button.verticalAlignment
            horizontalAlignment: button.horizontalAlignment
            minimumPixelSize: 8 * AppFramework.displayScaleFactor
            pixelSize: button.pixelSize
            fontFamily: button.fontFamily
            letterSpacing: button.letterSpacing
            bold: button.bold
            fontSizeMode: Text.Fit
            elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight
            wrapMode: button.wrapMode
        }

        Item {
            Layout.preferredWidth: 12 * AppFramework.displayScaleFactor
            Layout.fillHeight: true
        }

        Item {
            Layout.preferredWidth: nextIconSize
            Layout.fillHeight: true

            visible: showNextIcon
            enabled: visible

            Accessible.role: Accessible.Pane

            StyledImage {
                anchors.centerIn: parent

                width: nextIconSize
                height: width

                rotation: isRightToLeft ? 180 : 0

                source: button.nextIcon
                color: button.pressed
                       ? pressedTextColor
                       : button.hovered
                         ? hoveredTextColor
                         : nextIconColor
            }
        }

        Item {
            Layout.preferredWidth: 16 * AppFramework.displayScaleFactor
            Layout.fillHeight: true
        }
    }

    background: Rectangle {
        anchors.fill: parent

        color: button.pressed
               ? pressedBackgroundColor
               : button.hovered
                 ? hoveredBackgroundColor
                 : backgroundColor
    }

    //--------------------------------------------------------------------------
}
