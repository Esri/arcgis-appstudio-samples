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
import QtQuick.Controls.Material 2.1

import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

App {
    id: app
    width: 400
    height: 640

    property real scaleFactor: AppFramework.displayScaleFactor
    readonly property real baseFontSize: app.width < 450*app.scaleFactor? 21 * scaleFactor:23 * scaleFactor

    Page {
        anchors.fill: parent

        header: ToolBar{
            contentHeight: 56 * scaleFactor
            Material.primary: Material.Indigo
            Material.elevation: 8

            RowLayout{
                anchors.fill: parent

                ToolButton {
                    indicator: Image{
                        width: parent.width*0.5
                        height: parent.height*0.5
                        anchors.centerIn: parent
                        source: "./images/back.png"
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Title")
                    elide: Label.ElideRight
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                    font.pixelSize: app.baseFontSize
                }
            }
        }

        RoundButton{
            width: radius*2
            height:width
            radius: 32*app.scaleFactor
            anchors {
                right: parent.right
                bottom: parent.bottom
                rightMargin:20*app.scaleFactor
                bottomMargin: 20*app.scaleFactor
            }
            Material.elevation: 6
            Material.background: Material.Orange
            contentItem: Image {
                width: parent.radius
                height: width
                mipmap: true
                source: "./images/add.png"
            }
        }
    }
}

