/* Copyright 2019 Esri
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
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2

import QtPositioning 5.3
import QtSensors 5.3

import "./Controls"
import "./Views"
import "./Assets"

App {
    id: app
    width: 421
    height: 750

    property double scaleFactor: AppFramework.displayScaleFactor
    readonly property color primaryColor: "#8f499c"
    readonly property color secondaryColor: "#FFFFFF"
    readonly property color headerTextColor: "#808080"
    readonly property color btnColor: "#808080"
    property alias sources: sources
    property alias strings: strings

    MapArea {
        id: mapArea

        anchors.fill: parent
    }

    Strings {
        id: strings
    }

    Sources {
        id: sources
    }

    DeviceManager {
        id: deviceManager
    }

    StatusBarControls {
        id: statusBarControls
    }
}

