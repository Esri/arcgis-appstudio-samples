/* Copyright 2017 Esri
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


import QtQuick 2.7
import QtQuick.Controls 2.1


Rectangle {
    id: app

    width: 400
    height: 640

    Rectangle {
        id: header

        height: 56
        width: parent.width
        color: "steelBlue"

        ToolButton {
            width: 32
            height: 32

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 8
            }

            indicator: Image {
                source: "images/menu.png"
                anchors.fill: parent
            }

            onClicked: {
                menu.open()
            }
        }
    }

    Drawer {
        id: menu

        height: parent.height
        width: Math.min(0.75 * parent.width, 300)

        Column {
            anchors.fill: parent

            Rectangle {
                height: 56
                width: parent.width
                color: Qt.darker(header.color)
            }

            Button {
                text: "About"
                height: 56
                width: parent.width
                font.pixelSize: 20

                onClicked: {
                    menu.close()
                    aboutPage.open()
                }
            }
        }
    }

    Popup {
        id: aboutPage

        height: parent.height
        width: parent.width
        padding: 0

        background: Rectangle {
            anchors.fill: parent
            color: "#E0E0E0"
        }

        enter: Transition {
            NumberAnimation {
                property: "y"
                duration: 200
                from: parent.height
                to: 0
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "y"
                duration: 200
                from: 0
                to: parent.height
            }
        }

        Rectangle {
            id: aboutPageHeader

            height: 56
            width: parent.width
            color: "steelBlue"

            ToolButton {
                width: 32
                height: 32

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    margins: 8
                }

                indicator: Image {
                    source: "images/close.png"
                    anchors.fill: parent
                }

                onClicked: {
                    aboutPage.close()
                }
            }
        }

        Text {
            width: parent.width
            text: "This is a demo app for the AppStudio workshop"
            font.pixelSize: 20
            wrapMode: Text.WordWrap
            anchors {
                left: parent.left
                top: aboutPageHeader.bottom
                margins: 8
            }
        }
    }
}

