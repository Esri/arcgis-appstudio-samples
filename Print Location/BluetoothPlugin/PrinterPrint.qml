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

import ArcGIS.AppFramework 1.0
import "./lib/PixelProcess.js" as PP

ImageObject {
    id: imageObject

    onImageContentChanged: {

        var height = imageObject.heightim
        var width = imageObject.width

        if (width === 0 || height === 0) {
            return
        }

        // scale the image to 360 in width if the image is too big or too small
        // note: the scaled width has to be 4 integer times
        if (width !== 360) {
            imageObject.scaleToWidth(360)
            return
        }

        imageData = PP.generateBitmapHexString(imageObject, imageData, imageDataInGray)

        // starting print

        var fontHeights = [
                    [9, 9, 18, 18, 18, 36, 36,  ],
                    [48, , , , , , ,  ],
                    [12, 24, , , , , , ],
                    [, , , , , , , ],
                    [47, 94, 45, 90, 180,, 270, 360, 450],
                    [24, 48, 46, 92, , , , ],
                    [27, , , , , , , ],
                    [24, 48, , , , , , ]
                ];

        for (var i = 0; i < printCommandList.length; i++) {
            if (printCommandList[i].type === "text") {
                var cpclPrintingSentence = ""
                // print text in bold
                if (printCommandList[i].bold === "bold") {
                    cpclPrintingSentence += "! U1 SETLP " + printCommandList[i].font + " " + printCommandList[i].fontSize + " " + fontHeights[printCommandList[i].font][printCommandList[i].fontSize] + "\r\n"
                    cpclPrintingSentence += " ! U1 SETBOLD 2 " + printCommandList[i].content + " ! U1 SETBOLD 0" + "\r\n"

                    currentDevice.writeData = cpclPrintingSentence
                } else {
                    // add left margin before print
                    if (printCommandList[i].leftMargin > 0) {
                       cpclPrintingSentence += "! U1 X " + printCommandList[i].leftMargin + "\r\n"
                    }

                    cpclPrintingSentence += "! U1 SETLP " + printCommandList[i].font + " " + printCommandList[i].fontSize + " " + fontHeights[printCommandList[i].font][printCommandList[i].fontSize] + "\r\n"
                    cpclPrintingSentence += printCommandList[i].content

                    currentDevice.writeData = cpclPrintingSentence
                }
            }

            if (printCommandList[i].type === "image") {
                height = imageObject.height
                width = imageObject.width
                var imageString = "! 0 200 200 " + height.toString() +  " 1\r\n"
                imageString += "CENTER\r\n"
                imageString += "EG " + (Math.floor(width/8)).toString() + " " + height.toString() + " 1 1\r\n"
                imageString += imageData
                imageString += "\r\n"
                imageString += "PRINT\r\n"

                currentDevice.writeData = imageString

                // clear the imageData
                imageData = ""
                imageDataInGray.length = 0
            }
        }
    }
}
