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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import QtPositioning 5.8
import QtLocation 5.9

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Positioning 1.0
import ArcGIS.AppFramework.Devices 1.0

// Import the plugin providing Bluetooth printer support
import "./BluetoothPlugin"
import "./BluetoothPlugin/BluetoothManager"
import "./BluetoothPlugin/controls"

//------------------------------------------------------------------------------

App {
    id: app

    width: 480
    height: 640

    property var currentPosition: bluetoothSourceManager.controller.positionSource
    property var imageData
    property var imageDataInGray: []
    property var imageDataOriginal: []
    property var printCommandList: []

    readonly property BluetoothSourceManager bluetoothSourceManager: bluetoothManager.bluetoothSourceManager
    readonly property BluetoothSources sources: bluetoothSourceManager.controller.sources
    property Device currentDevice: bluetoothSourceManager.controller.currentDevice
    property var screenshotFilePath: AppFramework.standardPaths.standardLocations(StandardPaths.PicturesLocation)[0].toString() + "/ScreenShotMapView.png"
    property bool printerBusy: false


    //--------------------------------------------------------------------------

    // Start/stop position source
    Component.onCompleted: bluetoothManager.start()
    Component.onDestruction: bluetoothManager.stop()

    //--------------------------------------------------------------------------

    // Manage connections to Bluetooth printer
    BluetoothManager {
        id: bluetoothManager

        bluetoothSettingsPages: bluetoothSettingsPages
    }

    // Bluetooth settings UI
    BluetoothSettingsPages {
        id: bluetoothSettingsPages

        bluetoothManager: bluetoothManager
    }

    // Printer Print
    PrinterPrint {
        id: imageObject
    }

    // Printer Preview
    PrinterPreview {
        id: popup
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

            // Click to print the map
            PrinterPrintButton {
                bluetoothSettingsPages: bluetoothSettingsPages
            }

            // Click to preview the map
            PrinterPreviewButton {
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

            // Click to open the Printer settings UI
            BluetoothSettingsButton {
                bluetoothSettingsPages: bluetoothSettingsPages
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
            center: currentPosition.position.coordinate
            radius: currentPosition.position.horizontalAccuracy
            border.color: "#8000B2FF"
            border.width: 1
            color: "#4000B2FF"
        }
    }

    //--------------------------------------------------------------------------

    // Busy Indicator
    BusyIndicator {
        anchors.centerIn: parent
        height: 48 * AppFramework.displayScaleFactor
        width: height
        running: true
        Material.accent:"#8f499c"
        visible: printerBusy
    }
}

//------------------------------------------------------------------------------
