/* Copyright 2015 Esri
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

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtMultimedia 5.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Barcodes 1.0

App {
    id: app
    width: 800
    height: 532

    property string imageFileName: "barcode.jpg"
    property string capturedBarcodeType: ""
    property string capturedBarcodeValue : ""
    property int displayScaleFactor: AppFramework.displayScaleFactor

    Rectangle {
        anchors.fill: parent
        color: "lightgrey"

        Column {
            id: infoColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 10
            }

            spacing: 10

            Row {
                spacing: 10

                ExclusiveGroup {
                    id: captureExGroup
                }

                RadioButton {
                    id: rdbFile
                    exclusiveGroup: captureExGroup
                    text: qsTr("Choose barcode image")

                    onClicked: {
                        fileDialog.open();
                    }
                }
                RadioButton {
                    id: rdbCamera
                    exclusiveGroup: captureExGroup
                    text: qsTr("Take a picture")
                    checked: true

                    onCheckedChanged: {
                        if (checked){
                            timer.running = true;
                            videoOutput.visible = true;
                        }
                        else {
                            timer.running = false;
                        }
                    }
                }
            }

            Button {
                iconSource: "./switchCamera.jpg"
                //text: camera.displayName
                width: 64 * displayScaleFactor
                height: width
                enabled: QtMultimedia.availableCameras
                onClicked: {
                    cameraIndex = (cameraIndex + 1) % cameraArray.length
                    camera.deviceId = cameraArray[cameraIndex]
                }

            }

            Text {
                width: parent.width
                text: barcodeImage.source
            }

            Text {
                text: "Barcode type: " + capturedBarcodeType
            }

            Text {
                text: "<a href=\"" + barcodeDecoder.barcode + "\">" + capturedBarcodeValue + "</a>"
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: infoColumn.bottom
                bottom: parent.bottom
                margins: 10
            }

            color: "darkgrey"
            border {
                width: 1
                color: "black"
            }

            VideoOutput {
                id: videoOutput
                anchors.fill: parent
                visible: rdbCamera.checked
                source: camera
                autoOrientation: true
            }

            Image {
                id: barcodeImage
                anchors.fill: parent
                width: parent.width * 0.5
                visible: rdbFile.checked && barcodeDecoder.status === BarcodeDecoder.Ready
                fillMode: Image.PreserveAspectFit
            }

            Rectangle {
                width : 75 * AppFramework.displayScaleFactor
                height: width
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5 * AppFramework.displayScaleFactor
                anchors.horizontalCenter: parent.horizontalCenter
                radius: width * 0.5
                color: mouseArea.pressed ? "purple" : "white"
                border.color: "black"
                border.width: 1.5
                Image {
                    anchors.fill: parent
                    anchors.margins: width * .25
                    source: "./camera.png"
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: {
                        camera.imageCapture.captureToLocation(barcodesFolder.filePath(imageFileName));
                    }
                }
            }
        }


    }

    BarcodeDecoder {
        id: barcodeDecoder

        onStatusChanged: {
            switch (status){
            case 0:
                console.log("barcodeReader status ready");
                if (barcodeDecoder.barcode > "") {
                    capturedBarcodeValue = barcodeDecoder.barcode;
                    capturedBarcodeType = barcodeDecoder.barcodeTypeString;
                }
                break;
            case 1:
                console.log("barcodeReader status decoding");
                break;
            case 2:
                console.log("barcodeReader status error");
                if (barcodesFolder.fileExists(imageFileName)){
                    barcodesFolder.removeFile(imageFileName);
                    barcodeImage.source = "";
                }
                break;
            }
        }

        onPointsChanged: {
            console.log("points", points);
        }
    }

    FileFolder {
        id: barcodesFolder
    }


    Camera {
        id: camera

        cameraState: Camera.LoadedState

        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

        exposure {
            exposureCompensation: -1.0
            exposureMode: Camera.ExposurePortrait
        }

        flash.mode: Camera.FlashRedEyeReduction

        imageCapture {
            onCapturedImagePathChanged: {
                barcodeDecoder.clear();
                //barcodeDecoder.source = AppFramework.resolvedPathUrl(camera.imageCapture.capturedImagePath);
                barcodeDecoder.decode(AppFramework.resolvedPathUrl(camera.imageCapture.capturedImagePath));
            }
        }
    }

    Timer {
        id: timer
        running: false //true
        interval: 3000
        repeat: true
        onTriggered: {
            camera.imageCapture.captureToLocation(barcodesFolder.filePath(imageFileName));
        }
    }

    FileDialog {
        id: fileDialog

        onAccepted: {
            barcodeImage.source = fileUrl;
            barcodeDecoder.clear();
            //barcodeDecoder.source = fileUrl;
            barcodeDecoder.decode(fileUrl);
            videoOutput.visible = false;
        }
    }

    property int cameraIndex: 0
    property var cameraArray: []
    Component.onCompleted: {
        camera.start();
        for (var i in QtMultimedia.availableCameras){
            cameraArray.push(QtMultimedia.availableCameras[i].deviceId);
        }
    }
}
