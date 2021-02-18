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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtPositioning 5.8
import QtLocation 5.9

import Esri.ArcGISRuntime 100.6
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Positioning 1.0

import "./BluetoothManager"
import "./controls"
import "./lib/PixelProcess.js" as PP

Item {
    id: item

    // Button styling
    property color color: "#ffffff"

    width: 30 * AppFramework.displayScaleFactor
    height: width

    //--------------------------------------------------------------------------
    // Internal properties
    property bool blinkTrigger: false
    property bool blinkState: false

    signal clicked(var mouse)
    signal pressAndHold(var mouse)

    FileFolder {
        id: fileFolder
    }

    //------------------------------------------------------------------------------

    StyledImageButton {
        id: button

        anchors.fill: parent
        source: "./images/print-preview-32.svg"
        visible: true
        enabled: visible
        color: item.color

        onClicked: {
            printCommandList = []
            PP.initilizePrintCommandList(printCommandList)

            var coordinateText = ""
            if (currentPosition.position.coordinate.isValid === true) {
                coordinateText += currentPosition.position.coordinate.latitude.toFixed(6) + ", " + currentPosition.position.coordinate.longitude.toFixed(6)
            } else {
                // add London's lat/long if current position is not available
                coordinateText += "51.507614, -0.127782" // London
            }

            if (Qt.platform.os === "linux" || Qt.platform.os === "android" || Qt.platform.os === "ios") {
                PP.printTextWithParameter(0, 2, popup.width/2 - 30, 10, "Map center location is -5555.555555, -5555.555555", printCommandList)
            } else {
                PP.printTextWithParameter(0, 2, popup.width/2 - 30, 10, "Map center location is -90.555555, -180.555555", printCommandList)
            }

            PP.printTextWithParameter(0, 2, (popup.width * 3) / 4 - 30 , 10, coordinateText, printCommandList, "bold")

            screenshotFilePath = fileFolder.filePath("ScreenShotMapView" + Math.floor(Math.random() * Math.floor(1000)) + ".png")

            var imageFileUrl = "file://" + screenshotFilePath

            if (Qt.platform.os === "windows") {
                imageFileUrl = "file:///" + screenshotFilePath
            }

            if (Qt.platform.os === "android") {
                PP.printImageWithParameter(imageFileUrl, 30, 20, printCommandList)
            } else {
                PP.printImageWithParameter(imageFileUrl, 0, 20, printCommandList)
            }

            var currentTimeAndDateString = Qt.formatDateTime(new Date(), "h:mmap on dd MMMM yyyy")

            if (Qt.platform.os === "android") {
                PP.printTextWithParameter(0, 2, popup.width/2 - 10, popup.height - 30, "Printed at " + currentTimeAndDateString, printCommandList)
            } else {
                PP.printTextWithParameter(0, 2, popup.width/2 - 10, popup.height - 30, "Printed at " + currentTimeAndDateString, printCommandList)
            }

            map.grabToImage(function(result) {
                var saved = result.saveToFile(screenshotFilePath);
                console.log("save to file result = " + saved)

                var imageFileUrl = "file://" + screenshotFilePath

                if (Qt.platform.os === "windows") {
                    imageFileUrl = "file:///" + screenshotFilePath
                }
                popup.open()
                mycanvas.loadImage(imageFileUrl)
            })

            item.clicked(mouse)
        }

        onPressAndHold: {
            item.pressAndHold(mouse);
        }
    }

    //--------------------------------------------------------------------------
}
