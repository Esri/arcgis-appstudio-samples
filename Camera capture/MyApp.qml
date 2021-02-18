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

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2
import QtMultimedia 5.6

import ArcGIS.AppFramework 1.0


import "controls" as Controls

App {
    id: app
    width: 400
    height: 750
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    Page {
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle {
            anchors.top:header.bottom
            Camera {
                id: camera

                imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

                exposure {
                    manualAperture: -1.0
                    manualIso: -1
                    manualShutterSpeed: -1.0
                    meteringMode: Camera.MeteringMatrix
                    exposureMode: Camera.ExposureAuto
                }

                flash.mode: Camera.FlashRedEyeReduction

                focus{
                    focusMode: Camera.FocusContinuous
                    focusPointMode: Camera.FocusPointAuto
                }

                imageCapture {
                    onCapturedImagePathChanged: {
                        console.log("Image captured:", camera.imageCapture.capturedImagePath);
                    }

                    onImageCaptured: {
                        photoPreview.source = preview
                    }
                }
            }

            VideoOutput {
                source: camera
                anchors.fill: parent
                focus : visible
                autoOrientation: true
                fillMode: VideoOutput.PreserveAspectCrop
            }

            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    camera.imageCapture.captureToLocation(imagesFolder.filePath("captureTest.jpg"));
                }
            }

            Image {
                id: photoPreview
                height: parent.height * 0.2
                width: parent.width * 0.2
                anchors {
                    margins: 10
                    top: parent.top
                    left: parent.left
                }
                fillMode: Image.PreserveAspectFit

                Text {
                    anchors {
                        top: parent.bottom
                        topMargin: 5
                        left: parent.left
                    }

                    text: camera.imageCapture.capturedImagePath
                    style: Text.Outline
                    font {
                        bold: true
                        pointSize: 10
                    }
                    color: "beige"
                    width: 0.9 * parent.width
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }
            }


            FileFolder {
                id: imagesFolder
            }

        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

