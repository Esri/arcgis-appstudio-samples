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


// You can run your app in Qt Creator by pressing Alt+Shift+R.
// Alternatively, you can run apps through UI using Tools > External > AppStudio > Run.
// AppStudio users frequently use the Ctrl+A and Ctrl+I commands to
// automatically indent the entirety of the .qml file.


//------------------------------------------------------------------------------
//
//  For more information on supporting external GNSS providers see ./GNSSPlugin/README.txt
//
//------------------------------------------------------------------------------


import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtPositioning 5.12
import QtLocation 5.12

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Positioning 1.0

// Import the plugin providing GNSS support
import "./GNSSPlugin"

//------------------------------------------------------------------------------

App {
    id: app

    width: 414
    height: 736

    property var currentPosition

    //--------------------------------------------------------------------------

    // Start/stop position source
    Component.onCompleted: gnssManager.start()
    Component.onDestruction: gnssManager.stop()

    // Process position updates
    Connections {
        target: gnssManager

        onNewPosition: {
            currentPosition = position;
        }
    }

    //--------------------------------------------------------------------------

    // Manage connections to GNSS providers
    GNSSManager {
        id: gnssManager

        gnssSettingsPages: gnssSettingsPages
    }

    // GNSS settings UI
    GNSSSettingsPages {
        id: gnssSettingsPages

        gnssManager: gnssManager
    }

    // GNSS status UI
    GNSSStatusPages {
        id: gnssStatusPages

        gnssManager: gnssManager
        gnssSettingsPages: gnssSettingsPages
    }

    //--------------------------------------------------------------------------

    // Title bar
    Rectangle {
        id: titleRect

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: 50 * AppFramework.displayScaleFactor
        color: "#8f499c"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15 * AppFramework.displayScaleFactor
            anchors.rightMargin: 15 * AppFramework.displayScaleFactor

            // Click to open the GNSS status UI
            GNSSStatusButton {
                gnssStatusPages: gnssStatusPages
            }

            Text {
                Layout.fillWidth: true
                text: app.info.title
                color: "#ffffff"
                font.pixelSize: 20 * AppFramework.displayScaleFactor
                font.bold: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
            }

            // Click to open the GNSS settings UI
            GNSSSettingsButton {
                gnssSettingsPages: gnssSettingsPages
            }
        }
    }

    //--------------------------------------------------------------------------

    // Map display
    Map {
        id: map

        anchors {
            top: titleRect.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        plugin: Plugin {
            preferred: ["AppStudio"]
        }

        center: positionCircle.center
        zoomLevel: 16

        MapCircle {
            id: positionCircle

            center: currentPosition ? currentPosition.coordinate : QtPositioning.coordinate()
            radius: currentPosition && currentPosition.horizontalAccuracy ? currentPosition.horizontalAccuracy : 20

            border.color: "#8000B2FF"
            border.width: 2
            color: currentPosition && currentPosition.horizontalAccuracy ? "#4000B2FF" : "transparent"
        }
    }

    //--------------------------------------------------------------------------
}

//------------------------------------------------------------------------------
