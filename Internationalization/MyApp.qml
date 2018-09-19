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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0




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
    property string locale: view.currentItem.locale

    Page {
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle {
            anchors.top:header.bottom

            Text {
                id: title
                anchors.top: parent.top
                anchors.topMargin: 5 * scaleFactor
                width: parent.width-10
                text: qsTr("Select a locale from the purple menu:")
                font.bold: true
                font.pixelSize: 15 * scaleFactor
            }

            Rectangle {
                id: chooser
                anchors.top: title.bottom
                anchors.topMargin: 5 * scaleFactor
                width: parent.width
                height: parent.height/2 - 10

                ListView {
                    id: view
                    clip: true
                    focus: true
                    anchors.fill: parent
                    model: [
                        "en_US",
                        "en_GB",
                        "fi_FI",
                        "de_DE",
                        "ar_SA",
                        "hi_IN",
                        "zh_CN",
                        "th_TH",
                        "fr_FR",
                        "nb_NO",
                        "sv_SE"
                    ]

                    delegate: Rectangle {
                        property string locale: modelData
                        color: "#40300030"
                        height: 30 * scaleFactor

                        width: view.width

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                view.currentIndex = index;
                            }
                        }

                        Text {
                            id: langText
                            color: view.currentIndex === index ? "white" : "black"
                            font.bold: view.currentIndex === index ? true : false
                            anchors.left: parent.left
                            anchors.leftMargin: 5 * scaleFactor
                            anchors.verticalCenter: parent.verticalCenter
                            text: Qt.locale(modelData).name + " ("+ Qt.locale(modelData).nativeCountryName + "/" + Qt.locale(modelData).nativeLanguageName + ")"
                        }
                    }

                    highlight: Rectangle {
                        height: 30 * scaleFactor
                        color: "#8f499c"


                    }
                    highlightMoveDuration: 200
                }
            }

            Text {
                id: returnDescription
                anchors.top: chooser.bottom
                anchors.topMargin: 1 * scaleFactor
                anchors.left: parent.left
                anchors.leftMargin: 5 * scaleFactor
                width: parent.width-10
                text: qsTr("The following syntax is determined by the system locale that corresponds to the locale you chose in the purple menu above:")
                wrapMode: Text.WordWrap
                font.bold: true
            }

            Rectangle {
                color: "white"
                anchors.top: returnDescription.bottom
                anchors.topMargin: 5 * scaleFactor
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5 * scaleFactor
                x: 5;
                width: parent.width - 10

                Column {
                    //   anchors.fill: parent
                    spacing: 5
                    Text {
                        property var date: new Date()
                        text: "Date: " + date.toLocaleDateString(Qt.locale(app.locale))
                    }
                    Text {
                        property var date: new Date()
                        text: "Time: " + date.toLocaleTimeString(Qt.locale(app.locale))
                    }
                    Text {
                        property var dow: Qt.locale(app.locale).firstDayOfWeek
                        text: "First day of week: " + Qt.locale(app.locale).standaloneDayName(dow)
                    }
                    Text {
                        property var num: 10023823
                        text: "Number: " + num.toLocaleString(Qt.locale(app.locale))
                    }
                    Text {
                        property var num: 10023823
                        text: "Currency: " + num.toLocaleCurrencyString(Qt.locale(app.locale))
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

