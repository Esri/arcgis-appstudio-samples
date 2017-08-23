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


import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "controls" as Controls

App{
    id: app
    width: 421
    height: 750

    property bool lightTheme: true

    // App color properties

    readonly property color appBackgroundColor: lightTheme? "#FAFAFA":"#303030"
    readonly property color appDialogColor: lightTheme? "#FFFFFF":"424242"
    readonly property color appPrimaryTextColor: lightTheme? "#000000":"#FFFFFF"
    readonly property color appSecondaryTextColor: Qt.darker(appPrimaryTextColor)
    readonly property color primaryColor:"#8f499c"
    readonly property color accentColor: Qt.lighter(primaryColor,1.2)
    readonly property color headerTextColor:"#FFFFFF"
    readonly property color listViewDividerColor:"#19000000"

    // App size properties

    property real scaleFactor: AppFramework.displayScaleFactor
    readonly property real baseFontSize: app.width<450*app.scaleFactor? 21 * scaleFactor:23 * scaleFactor
    readonly property real titleFontSize: 1.1 * app.baseFontSize
    readonly property real captionFontSize: 0.6 * app.baseFontSize


    MainPage{
        anchors.fill: parent
    }

    ListModel{
        id: tabViewModel
        ListElement { name: qsTr("Map"); }
        ListElement { name: qsTr("Copy"); }
        ListElement { name: qsTr("Paste"); }
        ListElement { name: qsTr("Image"); }
    }
    Component{
        id: page1ViewPage
        Controls.MapActions{}

    }
    Component{
        id: page2ViewPage
        Controls.CopyActions{}
    }

    Component{
        id: page3ViewPage
        Controls.DataActions{}
    }
    Component{
        id: page4ViewPage
        Controls.ImageActions{}
    }

    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}






