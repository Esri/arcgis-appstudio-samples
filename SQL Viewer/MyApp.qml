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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

import "controls" as Controls
import "SQLViewer"

App {
    id: app

    width: 480 * AppFramework.displayScaleFactor
    height: 800 * AppFramework.displayScaleFactor

    Material.accent: "#8f499c"

    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * AppFramework.displayScaleFactor) + (isSmallScreen ? 0 : 3)
    property real smallScreenSize: 400 * AppFramework.displayScaleFactor
    property bool isSmallScreen: (width < smallScreenSize) || (height < smallScreenSize)


    Page {
        anchors.fill: parent
        header: ToolBar {
            id:header
            width: parent.width
            height: 50 * AppFramework.displayScaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar {
            }
        }

        // Find SQLViewer code from the SQLViewer folder. Click on MyApp folder on top left, click on SQLViewer folder
        SQLViewer {
            anchors.fill: parent
        }
    }

    Controls.DescriptionPage {
        id: descPage
        visible: false
    }
}

