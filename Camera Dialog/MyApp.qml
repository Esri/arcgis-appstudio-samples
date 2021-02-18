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
import ArcGIS.AppFramework.Multimedia 1.0
import ArcGIS.AppFramework.InterAppCommunication 1.0


import "controls" as Controls

App {
    id: app
    width: 400
    height: 750
    Material.background: "#353535"
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)
    property var defaultMargin: 10 *scaleFactor
    property url clipBoardUrl: ""


    Page {
        anchors.fill: parent
        Material.background: "#353535"
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8F499C"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem:Rectangle {
            width: parent.width
            color: "#353535"
            anchors.top: header.bottom
            anchors.bottom:parent.bottom
            anchors.topMargin: defaultMargin

            Rectangle{
                id:initialButtonGroup

                anchors.fill: parent
                color: "#353535"

                Button {
                    id: openCameraButton

                    width: Math.min(parent.width/2,200)
                    anchors.bottom: parent.verticalCenter
                    anchors.bottomMargin: 5*defaultMargin
                    anchors.horizontalCenter: parent.horizontalCenter
                    Material.background: "#4A4A4A"
                    Material.foreground: "#FFFFFF"
                    text: qsTr("Capture Image")
                    onClicked: {
                        cameraDialog.captureMode = CameraDialog.CameraCaptureModeStillImage;
                        cameraDialog.open();
                    }
                }

                Button {
                    id: openVideoButton

                    width: Math.min(parent.width/2,200)
                    anchors.top: openCameraButton.bottom
                    anchors.topMargin: 2*defaultMargin
                    anchors.horizontalCenter: parent.horizontalCenter
                    Material.background: "#4A4A4A"
                    Material.foreground: "#FFFFFF"
                    text: qsTr("Record Video")
                    onClicked: {
                        cameraDialog.captureMode = CameraDialog.CameraCaptureModeVideo;
                        cameraDialog.open();
                    }
                }
            }

            Controls.DetailInfoPage{
                id:detailPage

                visible:false

                onInfoPageClosed:{
                    initialButtonGroup.visible = true;
                }
            }

            Button {
                id: emailButton

                width: parent.width/3
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2*defaultMargin
                anchors.horizontalCenter: parent.horizontalCenter
                Material.background: "#4A4A4A"
                Material.foreground: "#FFFFFF"
                visible: detailPage.visible
                text: qsTr("Share Via Email")
                onClicked: {
                    emailComposer.show();
                }
            }

        }

    }

    FileInfo{
        id: fileInfo
    }

    CameraDialog {
        id: cameraDialog

        onAccepted: {
            initialButtonGroup.visible = false;
            detailPage.visible = true;
            detailPage.vidRotation = false;

            if (captureMode === CameraDialog.CameraCaptureModeStillImage) {
                detailPage.imgOrVid = true;
                detailPage.imgSource = fileUrl.toString().toString();
                emailComposer.attachments = AppFramework.urlInfo(fileUrl).localFile;
                imageObject.load(fileUrl.toString().replace(Qt.platform.os == "windows"? "file:///": "file://",""));
                var imgFileInfo = AppFramework.fileInfo(fileUrl.toString().replace(Qt.platform.os == "windows"? "file:///": "file://",""));
                setImgMetaData(imgFileInfo,imageObject);
                clipBoardUrl = fileUrl;
            } else {
                if(app.width<app.height &&  Qt.platform.os === "ios") detailPage.vidRotation = true;
                detailPage.imgOrVid = false;
                detailPage.vidSource = fileUrl;
                emailComposer.attachments = AppFramework.urlInfo(fileUrl).localFile;
                var vidFileInfo = AppFramework.fileInfo(fileUrl.toString().replace(Qt.platform.os == "windows"? "file:///": "file://",""));
                setVidMetaData(vidFileInfo);
                clipBoardUrl = fileUrl;
            }

        }

        onRejected: {
            console.log("rejected ", error)

            switch(error)
            {
            case CameraDialog.CameraErrorNo:
                console.log("**No Error")
                break;
            case cameraDialog.CameraErrorCameraPermissionNotGranted:
                console.log("**Camera Permission Not Granted")
                break;
            case CameraDialog.CameraErrorMicrophonePermissionNotGranted:
                console.log("**Microphone Permission Not Granted")
                break;
            case CameraDialog.CameraErrorStoragePermissionNotGranted:
                console.log("**Storage Permission Not Granted")
                break;
            }
        }
    }

    function setVidMetaData(vidFileInfo){
        var sizeVid = vidFileInfo.size;
        detailPage.vidSizeText = sizeVid>1000000?("Size: %1 MB".arg((sizeVid/1000000).toFixed(1))):("Size: %1 KB".arg((sizeVid/1000).toFixed(1)));
        var date = new Date();
        detailPage.vidTimeText = vidFileInfo.created.toLocaleString()>""?vidFileInfo.created.toLocaleString():date.toLocaleString();
        detailPage.vidPathText = "%1 \n%2".arg(vidFileInfo.url.toString().substring(0,vidFileInfo.url.toString().length-vidFileInfo.fileName.length).replace("file://","")).arg(vidFileInfo.fileName);
    }

    function setImgMetaData(imgFileInfo, imageObject){
        var size = imageObject.exifInfo.size;
        var date = new Date();
        detailPage.imgTimeText = imgFileInfo.created.toLocaleString()>""?imgFileInfo.created.toLocaleString():date.toLocaleString();
        detailPage.imgPathText ="%1 \n%2".arg(imgFileInfo.url.toString().substring(0,imgFileInfo.url.toString().length-imgFileInfo.fileName.length).replace("file://","")).arg(imgFileInfo.fileName);
        detailPage.imgLocationText = imageObject.exifInfo.gpsLatitude? ("(%1, %2)".arg(imageObject.exifInfo.gpsLatitude.toFixed(2)).arg(imageObject.exifInfo.gpsLongitude.toFixed(2))) : qsTr("NOT SET");
        detailPage.imgFileInfoText = size>1000000?("%1 X %2  %3 MB".arg(imageObject.width).arg(imageObject.height).arg((size/1000000).toFixed(1))):("%1 X %2  %3 KB".arg(imageObject.width).arg(imageObject.height).arg((size/1000).toFixed(1)));
        var apertureValue = typeof imageObject.exifInfo.values.ExtendedApertureValue!=="undefined"?("f/%1  ".arg(imageObject.exifInfo.values.ExtendedApertureValue)):"";
        var exposureTime = typeof imageObject.exifInfo.values.ExtendedExposureTime!=="undefined"?("1/%1  ".arg((1/imageObject.exifInfo.values.ExtendedExposureTime).toFixed(0))):"";
        var focalLength = typeof imageObject.exifInfo.values.ExtendedFocalLength!=="undefined"?("%1 mm".arg(imageObject.exifInfo.values.ExtendedFocalLength)):"";
        var detail2temp = "%1%2%3".arg(apertureValue).arg(exposureTime).arg(focalLength);
        detailPage.imgExifInfoText = detail2temp>""?detail2temp:"NO DETAIL INFO";
        var imgMake = typeof imageObject.exifInfo.values.ImageMake!=="undefined"?imageObject.exifInfo.values.ImageMake:"";
        var imgModel = typeof imageObject.exifInfo.values.ImageModel!=="undefined"?imageObject.exifInfo.values.ImageModel:"";
        var imgMakeModelTemp = "%1 %2".arg(imgMake).arg(imgModel);
        detailPage.imgMakeText = imgMakeModelTemp>" "?imgMakeModelTemp:"NO IMAGE MAKE INFO";
    }

    EmailComposer {
        id: emailComposer
        subject: "Camera Dialog Photo/Video"
    }

    ImageObject{
        id: imageObject
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

