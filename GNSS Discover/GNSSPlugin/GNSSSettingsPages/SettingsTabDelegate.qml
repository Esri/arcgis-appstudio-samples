/* Copyright 2019 Esri
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
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0

import "../controls"

Rectangle {
    id: delegate

    property var listTabView

    property real listDelegateHeight: 60 * AppFramework.displayScaleFactor

    property color textColor: "#000000"
    property color helpTextColor: "#000000"
    property color backgroundColor: "#e1f0fb"
    property color listBackgroundColor: "#e1f0fb"
    property color hoverBackgroundColor: "#e1f0fb"

    property color nextIconColor: "#c0c0c0"
    property real nextIconSize: 30 * AppFramework.displayScaleFactor
    property url nextIcon: "../images/next.png"

    property color infoIconColor: "#c0c0c0"
    property real infoIconSize: 30 * AppFramework.displayScaleFactor

    property string fontFamily: Qt.application.font.family
    property real letterSpacing: 0
    property real helpTextLetterSpacing: 0
    property var locale: Qt.locale()
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    property bool showInfoIcons: true

    width: ListView.view.width
    height: listDelegateHeight

    color: mouseArea.containsMouse ? hoverBackgroundColor : listBackgroundColor
    visible: modelData.enabled
    opacity: modelData.enabled ? 1 : 0.5

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: height

            visible: showInfoIcons
            enabled: visible

            StyledImage {
                anchors.centerIn: parent

                width: infoIconSize
                height: width

                source: modelData.icon
                color: infoIconColor
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.leftMargin: !isRightToLeft && !showInfoIcons ? 20 * AppFramework.displayScaleFactor : 0
            Layout.rightMargin: isRightToLeft && !showInfoIcons ? 20 * AppFramework.displayScaleFactor : 0

            ColumnLayout {
                anchors.fill: parent

                spacing: 0

                AppText {
                    Layout.fillWidth: true

                    text: modelData.title
                    color: textColor

                    fontFamily: delegate.fontFamily
                    letterSpacing: delegate.letterSpacing
                    pixelSize: 16 * AppFramework.displayScaleFactor
                    bold: true

                    LayoutMirroring.enabled: false

                    horizontalAlignment: isRightToLeft ? Label.AlignRight : Label.AlignLeft
                }

                AppText {
                    Layout.fillWidth: true
                    visible: text > ""

                    text: modelData.description
                    color: delegate.helpTextColor

                    LayoutMirroring.enabled: false

                    horizontalAlignment: isRightToLeft ? Label.AlignRight : Label.AlignLeft
                    verticalAlignment: Text.AlignVCenter

                    fontFamily: delegate.fontFamily
                    letterSpacing: delegate.helpTextLetterSpacing
                    pixelSize: 12 * AppFramework.displayScaleFactor
                    bold: false
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: height

            StyledImage {
                anchors.centerIn: parent

                width: nextIconSize
                height: width

                source: nextIcon
                color: nextIconColor

                rotation: isRightToLeft ? 180 : 0
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            listTabView.selected(modelData);
        }
    }
}
