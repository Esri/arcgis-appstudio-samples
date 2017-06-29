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

import QtQuick 2.0
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

Rectangle {
    id: root
    width: 320
    height: 480
    color: "lightgray"
    property string locale: view.currentItem.locale

    Text {
        id: description
        anchors.topMargin: 10
        width: parent.width-10
        text: qsTr("This sample demonstrates internationalization of a qml app. All instructional text is retrieved from translations files.")
        wrapMode: Text.WordWrap
    }

    Text {
        id: title
        anchors.top: description.bottom
        anchors.topMargin: 10
        width: parent.width-10
        text: qsTr("Select a locale from the purple menu:")
    }

    Rectangle {
        id: chooser
        anchors.top: title.bottom
        anchors.topMargin: 5
        width: parent.width-10
        x: 5
        height: parent.height/2 - 10
        color: "#40300030"
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
            delegate: Text {
                property string locale: modelData
                height: 30
                width: view.width
                text: Qt.locale(modelData).name + " ("+ Qt.locale(modelData).nativeCountryName + "/" + Qt.locale(modelData).nativeLanguageName + ")"
                MouseArea {
                    anchors.fill: parent
                    onClicked: view.currentIndex = index
                }
            }
            highlight: Rectangle {
                height: 30
                color: "#60300030"
            }
        }
    }

    Text {
        id: returnDescription
        anchors.top: chooser.bottom
        anchors.topMargin: 10
        width: parent.width-10
        text: qsTr("The following syntax is determined by the system locale that corresponds to the locale you chose in the purple menu above:")
        wrapMode: Text.WordWrap
    }

    Rectangle {
        color: "white"
        anchors.top: returnDescription.bottom
        anchors.topMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        x: 5; width: parent.width - 10
        Column {
            anchors.fill: parent
            spacing: 5
            Text {
                property var date: new Date()
                text: "Date: " + date.toLocaleDateString(Qt.locale(root.locale))
            }
            Text {
                property var date: new Date()
                text: "Time: " + date.toLocaleTimeString(Qt.locale(root.locale))
            }
            Text {
                property var dow: Qt.locale(root.locale).firstDayOfWeek
                text: "First day of week: " + Qt.locale(root.locale).standaloneDayName(dow)
            }
            Text {
                property var num: 10023823
                text: "Number: " + num.toLocaleString(Qt.locale(root.locale))
            }
            Text {
                property var num: 10023823
                text: "Currency: " + num.toLocaleCurrencyString(Qt.locale(root.locale))
            }
        }
    }
}
