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
    readonly property real baseFontSize: app.width<450*app.scaleFactor? 21 * scaleFactor:23 * scaleFactor

    Page {
        id:page
        anchors.fill: parent

        Loader{
            id: loader
            anchors.fill: parent
        }

        footer:TabBar {
            Material.accent: Material.Indigo
            padding: 0
            Repeater {
                model: tabViewModel
                TabButton {
                    text: name
                }
            }
            onCurrentIndexChanged: {
                switch(currentIndex){
                case 0:
                    loader.sourceComponent = page1;
                    break;
                case 1:
                    loader.sourceComponent = page2;
                    break;
                case 2:
                    loader.sourceComponent = page3;
                    break;
                default:
                    break;
                }
            }
        }
    }

    ListModel{
        id: tabViewModel
        ListElement { name: qsTr("Page 1"); }
        ListElement { name: qsTr("Page 2"); }
        ListElement { name: qsTr("Page 3"); }
    }

    Component{
        id: page1
        NavigationPage{
            title: qsTr("Page 1")
        }
    }

    Component{
        id: page2
        NavigationPage{
            title: qsTr("Page 2")
        }
    }

    Component{
        id: page3
        NavigationPage{
            title: qsTr("Page 3")
        }
    }
}

