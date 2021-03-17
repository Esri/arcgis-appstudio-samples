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

import QtQuick 2.15
import QtQuick.Controls 2.15

import ArcGIS.AppFramework 1.0

import "./controls"

Popup {
    id: popup

    parent: parent.overlay

    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: (Qt.platform.os === "ios" || Qt.platform.os === "android") ? 290 : 330
    height: 450

    onClosed: {
        fileFolder.removeFile(screenshotFilePath)
    }

    FileFolder {
        id: fileFolder
    }

    // added close button to close the popup
    StyledImageButton {
        id: button
        x: -5
        y: -5
        height: 20
        width: 20
        source: "./images/clear.png"
        visible: true
        color: "#8f499c"

        onClicked: {
           popup.close()
        }
    }

    Image {
        id: image
        anchors.centerIn: parent
        visible: false
        opacity: 0.2
        cache: false
    }

    Canvas {
        id: mycanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext('2d')

            for (var i = 0; i < printCommandList.length; i++) {
                if (printCommandList[i].type === "text") {
                    if (printCommandList[i].bold === "bold") {
                        ctx.font = "bold 10px sans-serif"
                    } else {
                        ctx.font = "10px sans-serif"
                    }

                    if (Qt.platform.os === "linux") {
                        ctx.clearRect(parent.width - ctx.measureText(printCommandList[i].content).width - 10, printCommandList[i].position.y - 10, ctx.measureText(printCommandList[i].content).width + 15, 15)
                    } else {
                        if (Qt.platform.os === "ios"){
                            ctx.clearRect(parent.width - ctx.measureText(printCommandList[i].content).width - 20, printCommandList[i].position.y - 15, ctx.measureText(printCommandList[i].content).width + 20, 20)
                        } else {
                            ctx.clearRect(parent.width - ctx.measureText(printCommandList[i].content).width - 15, printCommandList[i].position.y - 10, ctx.measureText(printCommandList[i].content).width + 15, 10)
                        }
                    }
                    ctx.fillText(printCommandList[i].content, parent.width - ctx.measureText(printCommandList[i].content).width, printCommandList[i].position.y)
                }

                if (printCommandList[i].type === "image") {
                    var imageHeight = image.height * ((parent.width)/image.width)
                    if (Qt.platform.os === "android" || Qt.platform.os === "ios") {
                        ctx.drawImage(printCommandList[i].content, (parent.width - image.width * 380/image.height) / 2 , printCommandList[i].position.y, image.width * 380/image.height, 380)
                    } else {
                        ctx.drawImage(printCommandList[i].content, printCommandList[i].position.x, printCommandList[i].position.y, parent.width, imageHeight)
                    }
                }
            }
        }

        onImageLoaded: {
            var ctx = getContext('2d');
            ctx.clearRect(0, 0, mycanvas.width, mycanvas.height)
            mycanvas.requestPaint()

            if (Qt.platform.os === "windows") {
                image.source = "file:///" + screenshotFilePath
            } else {
                image.source = screenshotFilePath
            }
        }
    }
}
