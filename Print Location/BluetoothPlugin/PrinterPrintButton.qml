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

import QtQuick 2.12
import QtQuick.Controls 2.12

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0

import "./BluetoothManager"
import "./controls"
import "./lib/PixelProcess.js" as PP

Item {
    id: item

    //--------------------------------------------------------------------------
    // Public properties

    // Reference to BluetoothSettingsPages (required)
    property BluetoothSettingsPages bluetoothSettingsPages

    // Button styling
    property color color: "#ffffff"

    width: 30 * AppFramework.displayScaleFactor
    height: width

    //--------------------------------------------------------------------------
    // Internal properties
    readonly property BluetoothManager bluetoothManager: bluetoothSettingsPages.bluetoothManager
    readonly property BluetoothSourceManager bluetoothSourceManager: bluetoothManager.bluetoothSourceManager
    readonly property BluetoothSources sources: bluetoothSourceManager.controller.sources
    property Device currentDevice: bluetoothSourceManager.controller.currentDevice
    readonly property bool isConnecting: true

    signal clicked(var mouse)
    signal pressAndHold(var mouse)

    //--------------------------------------------------------------------------

    FileFolder {
        id: fileFolder
    }

    //--------------------------------------------------------------------------

    StyledImageButton {
        id: button
        anchors.fill: parent
        source: "./images/print-32.svg"
        visible: true
        enabled: currentDevice
        color: item.color

        onClicked: {
            printCommandList = []
            PP.initilizePrintCommandList(printCommandList)

            PP.printTextWithParameter(0, 2, 120, 10, "Map center location is ", printCommandList, "nobold", 0)

            var coordinateText = ""
            if (currentPosition.position.coordinate.isValid === true) {
                coordinateText += currentPosition.position.coordinate.latitude.toFixed(6) + ", " + currentPosition.position.coordinate.longitude.toFixed(6)
            } else {
                // add London's lat/long if current position is not available
                coordinateText += "51.507614, -0.127782" // London
            }

            PP.printTextWithParameter(0, 2, 230, 10, coordinateText, printCommandList, "bold", 0)

            var imageFileUrl = "file://" + screenshotFilePath
            PP.printImageWithParameter(imageFileUrl, 0, 20, printCommandList)

            var currentTimeAndDateString = Qt.formatDateTime(new Date(), "h:mmap on dd MMMM yyyy")

            PP.printTextWithParameter(0, 2, 170, 475, "Printed at " + currentTimeAndDateString, printCommandList, "nobold", 80)

            screenshotFilePath = fileFolder.filePath("ScreenShotMapView.png")
            console.log("the screenshotFilePath = " + screenshotFilePath)

            map.grabToImage(function(result) {
                result.saveToFile(screenshotFilePath);
                imageObject.load(screenshotFilePath)
            })

            printerBusy = true
            printTimer.start()
            item.clicked(mouse)
        }

        onPressAndHold: {
            item.pressAndHold(mouse);
        }
    }

    // timer for printer busy indicator
    // -------------------------------------------------------------------------

    Timer {
        id: printTimer

        interval: 5000
        running: false
        repeat: false

        onTriggered: {
            printerBusy = false
        }
    }

    //--------------------------------------------------------------------------
}
