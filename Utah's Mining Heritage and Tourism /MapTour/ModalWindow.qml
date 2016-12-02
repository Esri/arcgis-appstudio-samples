/* Copyright 2015 Esri
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

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework.Controls 1.0

Item {

    id: modalWindow

    width: parent.width
    height: parent.height

    z:100

    property string title: "Title"
    property string description: "Description goes here"
    //property string buttonText: "OK"

    visible: false

    focus: visible

    //android back button
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            console.log("Back button captured!")
            event.accepted = true
            visible = false;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerBar
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: app.headerBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Text {
                id: titleText
                text: title
                textFormat: Text.StyledText
                font.family: app.customTitleFont.name
                //anchors.centerIn: parent
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.textColor
                maximumLineCount: 1
                elide: Text.ElideRight
                anchors.leftMargin: 8*app.scaleFactor
            }

            ImageButton {
                source: "images/close.png"
                //rotation: -90
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10*app.scaleFactor
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    modalWindow.visible = false
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: "#EE000000"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - headerBar.height

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Flickable {
                //anchors.fill: parent
                width: parent.width
                height: parent.height
                contentHeight: descriptionText.contentHeight + 50
                clip: true

                maximumFlickVelocity: 2000;
                //flickDeceleration: 200;

                Component.onCompleted: {
                    console.log("Vertical velocity: ", verticalVelocity);
                    console.log("Flick decelration: ", flickDeceleration);
                    console.log("Max flick velocity: ", maximumFlickVelocity);
                }



                Item {
                    anchors.fill: parent

                    Text {
                        id: descriptionText
                        font.family: app.customTextFont.name
                        text: description
                        textFormat: Text.StyledText
                        anchors.fill: parent
                        anchors.margins: {
                            left: 5*app.scaleFactor
                            right: 5*app.scaleFactor
                            top: 10*app.scaleFactor
                            bottom: 10*app.scaleFactor
                        }
                        font {
                            pointSize: app.baseFontSize * 0.8
                        }
                        color: app.textColor
                        wrapMode: Text.Wrap
                        linkColor: "#e5e6e7"
                        onLinkActivated: {
                            Qt.openUrlExternally(unescape(link));
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        visible: false
        radius: 5
        color: "#EBEBEB"
        width: parent.width * 0.9
        height: parent.height * 0.9
        anchors.centerIn: parent





    }
}
