/* Copyright 2018 Esri
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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

PageIndicator {

    property SwipeView swipeView

    property bool showImages: true
    property bool showText: true
    property color tabsBorder: "red"
    property color tabsSelectedBackgroundColor: "transparent"
    property color tabsBackgroundColor: "transparent"
    property color tabsBorderColor: "transparent"
    property color tabsSelectedTextColor: "#00b2ff"
    property color tabsTextColor: Qt.darker(tabsSelectedTextColor, 1.25)//"#b0b0b0"
    property color disabledColor: "grey"
    property real tabsPadding: 0//1 * AppFramework.displayScaleFactor
    property real imageSize: 25 * AppFramework.displayScaleFactor
    property string fontFamily: Qt.application.font.family
    property real textSize: showImages ? 9 * AppFramework.displayScaleFactor : 13 * AppFramework.displayScaleFactor
    property bool resize: true

    //--------------------------------------------------------------------------

    visible: interactive

    // height: 50 * AppFramework.displayScaleFactor

    count: swipeView.count
    currentIndex: swipeView.currentIndex
    interactive: swipeView.interactive

    onCurrentIndexChanged: {
        swipeView.currentIndex = currentIndex;
    }

    Connections {
        target: swipeView

        onCurrentIndexChanged: {
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
                margins: tabsPadding
            }

            color: currentIndex == index ? tabsSelectedBackgroundColor : tabsBackgroundColor

            border {
                color:  tabsBorderColor
                width: 1
            }
            radius: showImages ? 5 * AppFramework.displayScaleFactor : height / 2

            ColumnLayout {
                anchors {
                    fill: parent
                    leftMargin: tabsPadding
                    rightMargin: tabsPadding
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
                    color: swipeView.itemAt(index).enabled ? (currentIndex == index) ? tabsSelectedTextColor : tabsTextColor : disabledColor
                    font {
                        bold: false//true//styleData.selected
                        pixelSize: textSize
                        family: fontFamily
                    }
                }
            }

            Rectangle {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.bottom
                    //bottomMargin: -tabsPadding - 1 * AppFramework.displayScaleFactor
                }

                visible: showImages && currentIndex == index
                height: (showText ? 2 : 3) * AppFramework.displayScaleFactor
                width: tabText.paintedWidth
                color: tabsSelectedTextColor
                radius: height / 2
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
