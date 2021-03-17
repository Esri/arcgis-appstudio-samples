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
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0

PageIndicator {
    property SwipeView swipeView

    property bool showImages: true
    property bool showText: true

    property color tabBarTabBorderColor: "transparent"
    property color tabBarTabForegroundColor: "#8f499c"
    property color tabBarTabBackgroundColor: "transparent"
    property color tabBarSelectedTabForegroundColor: Qt.lighter(tabBarTabForegroundColor, 1.25)
    property color tabBarSelectedTabBackgroundColor: "transparent"
    property color tabBarDisabledTabColor: "grey"

    property real tabBarPadding: 1 * AppFramework.displayScaleFactor
    property real imageSize: 25 * AppFramework.displayScaleFactor
    property real textSize: showImages ? 9 * AppFramework.displayScaleFactor : 13 * AppFramework.displayScaleFactor

    property string fontFamily: Qt.application.font.family

    property bool resize: true

    //--------------------------------------------------------------------------

    count: swipeView.count
    currentIndex: swipeView.currentIndex

    onCurrentIndexChanged: {
        swipeView.currentIndex = currentIndex;
    }

    Connections {
        target: swipeView

        function onCurrentIndexChanged() {
            currentIndex = swipeView.currentIndex;
        }
    }

    //--------------------------------------------------------------------------

    delegate: Item {
        implicitWidth: resize
                       ? swipeView.width / (count + 1)
                       : 40 * AppFramework.displayScaleFactor
        implicitHeight: 42 * AppFramework.displayScaleFactor

        visible: swipeView.itemAt(index).visible

        Rectangle {
            anchors {
                fill: parent
                margins: tabBarPadding
            }

            color: currentIndex == index ? tabBarSelectedTabBackgroundColor : tabBarTabBackgroundColor

            border {
                color: tabBarTabBorderColor
                width: 1 * AppFramework.displayScaleFactor
            }
            radius: showImages ? 5 * AppFramework.displayScaleFactor : height / 2

            ColumnLayout {
                anchors {
                    fill: parent
                    margins: tabBarPadding
                }

                spacing: 0

                Item {
                    Layout.preferredWidth: imageSize
                    Layout.preferredHeight: imageSize
                    Layout.alignment: Qt.AlignCenter

                    visible: showImages

                    Image {
                        id: tabImage

                        anchors.fill: parent
                        source: swipeView.itemAt(index).icon
                        fillMode: Image.PreserveAspectFit
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: tabImage
                        source: tabImage
                        color: tabText.color
                    }
                }

                Text {
                    id: tabText

                    Layout.fillWidth: true

                    visible: showText
                    text: swipeView.itemAt(index).title
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: swipeView.itemAt(index).enabled ? (currentIndex == index) ? tabBarSelectedTabForegroundColor : tabBarTabForegroundColor : tabBarDisabledTabColor
                    font {
                        bold: index == currentIndex
                        pixelSize: textSize
                        family: fontFamily
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter

                    visible: showImages && currentIndex == index

                    height: (showText ? 2 : 3) * AppFramework.displayScaleFactor
                    width: tabText.paintedWidth

                    color: tabBarSelectedTabForegroundColor
                    radius: height / 2
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                currentIndex = index;
            }
        }
    }
}
