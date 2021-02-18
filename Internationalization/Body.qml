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

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0


import "controls" as Controls

Rectangle {

    property int selection: -1

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.preferredWidth: parent.width * 0.9
            Layout.preferredHeight: 30 * scaleFactor
            Layout.margins: 10 * scaleFactor

            Text {
                id: title
                anchors.left: parent.left
                width: parent.width
                anchors.verticalCenter: parent.verticalCenters
                text: qsTr("Select a locale from the purple menu:")
                font.bold: true
                font.pixelSize: 14 * scaleFactor
                wrapMode: Label.Wrap
            }
        }

        Rectangle {
            id: chooser
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: view.contentHeight

            ListView {
                id: view
                currentIndex: -1
                clip: true
                focus: true
                anchors.fill: parent
                model: [
                    "en_US",
                    "fi_FI",
                    "de_DE",
                    "zh_CN",
                    "fr_FR",
                ]

                delegate: Rectangle {
                    property string locale: modelData
                    color: "#40300030"
                    height: 25 * scaleFactor


                    width: view.width

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            AppFramework.defaultLocale = Qt.locale(modelData).name

                            AppFramework.loadTranslator(app.info.json.translations, app.folder.path);

                            // reload body component when changing language
                            reload ()

                            console.log(Qt.locale(modelData).name , app.folder.path , AppFramework.defaultLocale)
                        }
                    }

                    Text {
                        id: langText
                        leftPadding: 10
                        width: parent.width - 50
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                        color: selection === index ? "#8f499c" : "black"
                        font.bold: selection === index ? true : false
                        font.pixelSize: 12 * scaleFactor
                        text: Qt.locale(modelData).name + " ("+ Qt.locale(modelData).nativeCountryName + "/" + Qt.locale(modelData).nativeLanguageName + ")"
                    }

                    Image {
                        id: checkIcon
                        visible: false
                        anchors.right: parent.right
                        source: selection === index ? "./assets/check.png" : ""
                        width: 20 * scaleFactor
                        height: 20 * scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 15 * scaleFactor
                        mipmap: true
                    }

                    ColorOverlay {
                        source: checkIcon
                        anchors.fill: checkIcon
                        color: "#8f499c"
                    }

                    Component.onCompleted: {
                        if (Qt.locale(modelData).name === AppFramework.defaultLocale) {
                            selection = index;
                        }
                    }
                }
            }
        }

        Text {
            id: returnDescription
            Layout.preferredWidth: parent.width * 0.9
            text: qsTr("The following syntax is determined by the system locale that corresponds to the locale you chose in the purple menu above:")
            wrapMode: Text.Wrap
            font.bold: true
            font.pixelSize: 14 * scaleFactor
            Layout.margins: 10
        }

        Text {
            property var date: new Date()
            text: "Date: " + date.toLocaleDateString(Qt.locale(app.locale))
            Layout.leftMargin: 10 * scaleFactor
            font.pixelSize: 12 * scaleFactor
        }

        Text {
            property var date: new Date()
            text: "Time: " + date.toLocaleTimeString(Qt.locale(app.locale))
            Layout.leftMargin: 10 * scaleFactor
            font.pixelSize: 12 * scaleFactor
        }

        Text {
            property var dow: Qt.locale(app.locale).firstDayOfWeek
            text: "First day of week: " + Qt.locale(app.locale).standaloneDayName(dow)
            Layout.leftMargin: 10 * scaleFactor
            font.pixelSize: 12 * scaleFactor
        }

        Text {
            property var num: 10023823
            text: "Number: " + num.toLocaleString(Qt.locale(app.locale))
            Layout.leftMargin: 10 * scaleFactor
            font.pixelSize: 12 * scaleFactor
        }

        Text {
            property var num: 10023823
            text: "Currency: " + num.toLocaleCurrencyString(Qt.locale(app.locale))
            Layout.leftMargin: 10 * scaleFactor
            font.pixelSize: 12 * scaleFactor
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
        }
    }
}


