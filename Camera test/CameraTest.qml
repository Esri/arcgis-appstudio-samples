//------------------------------------------------------------------------------

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtMultimedia 5.0

import ArcGIS.AppFramework 1.0

Rectangle {
    id: project
    width: 800
    height: 600

    Camera {
        id: camera

        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

        exposure {
            exposureCompensation: -1.0
            exposureMode: Camera.ExposurePortrait
        }

        flash.mode: Camera.FlashRedEyeReduction

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
    }

    CameraDeviceSelector {
        id: cameraDeviceSelector

        camera: camera
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
                pointSize: 12
            }
            color: "beige"
        }
    }

    Column {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }

        spacing: 5

        ComboBox {
            width: parent.width
            model: cameraDeviceSelector.deviceDescriptions
            currentIndex: cameraDeviceSelector.selectedDevice

            onActivated: {
                cameraDeviceSelector.selectedDevice = index;
                camera.start();
            }
        }

        Text {
            text: cameraDeviceSelector.selectedDevice.toString() + " Name=" + cameraDeviceSelector.selectedDeviceName + " Description=" + cameraDeviceSelector.selectedDeviceDescription
        }
    }

    FileFolder {
        id: imagesFolder
    }
}

