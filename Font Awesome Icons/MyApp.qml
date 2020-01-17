/* Copyright 2020 Esri
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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.SecureStorage 1.0

import "controls" as Controls

App {
    id: app
    width: 400
    height: 750

    function units(value) {
        return AppFramework.displayScaleFactor * value
    }

    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)
    property color iconColor: "#4C4C4C"

    QtObject {
        id: fa
        readonly property string  settings: "\uf013"
        readonly property string  home: "\uf015"
        readonly property string  email: "\uf0e0"
        readonly property string  gps: "\uf124"
        readonly property string  inbox: "\uf01c"
    }

    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle{
            anchors.top:header.bottom

            FontLoader {
                id: fontAwesome
                source: "assets/fontawesome-webfont.ttf"
            }

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight:app. height/3 * scaleFactor
                    spacing: 40 *scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter

                    //Add a Font Awesome Twitter icon by creating a Text element
                    Text {
                        font.family: fontAwesome.name
                        text: "\uf099"
                        font.pixelSize: 35 *scaleFactor
                        color: "#1DA1F2"
                    }

                    //Add a Font Awesome Github icon by creating a Text element
                    Text {
                        font.family: fontAwesome.name
                        text: "\uf092"
                        font.pixelSize: 35 *scaleFactor
                        color: "black"
                    }

                    //Add a Font Awesome Facebook icon by creating a Text element
                    Text {
                        font.family: fontAwesome.name
                        text: "\uf230"
                        font.pixelSize: 35 *scaleFactor
                        color: "#3B5998"
                    }

                    //Add a Font Awesome Google icon by creating a Text element
                    Text {
                        font.family: fontAwesome.name
                        text: "\uf2b3"
                        font.pixelSize: 35 *scaleFactor
                        color: "#DC4E40"
                    }
                }

                RowLayout {

                    Layout.preferredHeight:app. height/3 * scaleFactor
                    spacing: 15 * scaleFactor

                    Text {
                        id: homeIcon
                        font.family: fontAwesome.name
                        text: fa.home
                        font.pixelSize: 35 * scaleFactor
                        color: iconColor
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left:homeIcon.right
                        anchors.leftMargin: 8 *scaleFactor
                        text:qsTr("Home")
                        font.pixelSize: 15 * scaleFactor
                        color:iconColor
                    }

                    Text {
                        id: settingsIcon
                        font.family: fontAwesome.name
                        text: fa.settings
                        font.pixelSize: 35 * scaleFactor
                        color: iconColor
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: settingsIcon.right
                        anchors.leftMargin: 8 *scaleFactor
                        text: qsTr("Settings")
                        font.pixelSize: 15 * sTcaleFactor
                        color: iconColor
                    }

                    Text {
                        id: inboxIcon
                        font.family: fontAwesome.name
                        text: qsTr("")
                        font.pixelSize: 35 * scaleFactor
                        color:iconColor
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: inboxIcon.right
                        anchors.leftMargin: 8 *scaleFactor
                        text: qsTr("Inbox")
                        font.pixelSize: 15 * scaleFactor
                        color: iconColor
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight:app. height/3 * scaleFactor
                    spacing: 10 *scaleFactor

                    Button {
                        Layout.preferredWidth: 100 * scaleFactor
                        Layout.preferredHeight: 50 * scaleFactor
                        Layout.alignment: Qt.AlignHCenter

                        Text{
                            id: emailIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 15 * scaleFactor
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: fontAwesome.name
                            text: fa.email
                            font.pixelSize: 20 *scaleFactor
                            color: "green"
                        }

                        Text {
                            anchors.left: emailIcon.right
                            anchors.leftMargin: 13 * scaleFactor
                            anchors.verticalCenter: parent.verticalCenter
                            text:qsTr("Email")
                            font.pixelSize: 15 * scaleFactor
                            color:"#888"
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 100 * scaleFactor
                        Layout.preferredHeight: 50 * scaleFactor
                        radius: width/2
                        color: "#ccc"
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            anchors.centerIn: parent
                            font.family: fontAwesome.name
                            text: fa.gps
                            font.pixelSize: 20 *scaleFactor
                            color: "blue"
                        }
                    }
                }
            }
        }
    }


    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

