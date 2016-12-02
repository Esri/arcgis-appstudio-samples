import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Rectangle {
    id: rectContainer
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor
    state: cameraWindow.isPortrait ? "" : app.isDesktop ? "" : "landscape"
    signal next(string message)
    signal previous(string message)

    property string fileLocation: "images/placeholder.png"
    property bool photoReady: false

    property real lat:0
    property real lon:0

    readonly property int halfScreenWidth: (width * 0.5) * app.scaleFactor

    ExifInfo {
        id: page2_exifInfo
    }

    ImagePicker {
        id: imagePicker
        title: "Select Photo"

        onSelect: {
            photoReady = true
            fileLocation = fileName
            app.selectedImageFilePath_ORIG = fileName.replace("file:///","");
            app.selectedImageFilePath = fileName

            page2_exifInfo.url = app.selectedImageFilePath

            console.log("Exif FileInfo: ", page2_exifInfo.filePath, page2_exifInfo.exists, page2_exifInfo.size);

            debugText.text += " | " + page2_exifInfo.filePath + " | " + page2_exifInfo.size;

            theNewPoint = ArcGISRuntime.createObject("Point");
            theNewPoint.spatialReference = ArcGISRuntime.createObject("SpatialReference", {"json":{"wkid":4326}});

            if(page2_exifInfo.gpsLongitude && page2_exifInfo.gpsLatitude) {
                geoLocationText.visible = true
                geoLocationText.text = "Lat: " + (page2_exifInfo.gpsLatitude).toFixed(4) + " Long: " + (page2_exifInfo.gpsLongitude).toFixed(4)
                lat = page2_exifInfo.gpsLatitude
                lon = page2_exifInfo.gpsLongitude
                app.selectedImageHasGeolocation = true
                theNewPoint.x = lon;
                theNewPoint.y = lat;
            } else {
                app.selectedImageHasGeolocation = false;
                theNewPoint.x = 0;
                theNewPoint.y = 0;
            }

            console.log("AddPhotoPage: NewPoint: ", JSON.stringify(theNewPoint.json), JSON.stringify(theNewPoint.spatialReference.json));
        }
    }


    CameraWindow {
        id: cameraWindow
        title: "Camera"

        onSelect: {
            fileLocation = "file:///" + fileName
            app.selectedImageFilePath_ORIG = fileName
            app.selectedImageFilePath = "file:///" + fileName

            appFolder.writeTextFile("Camera_"+new Date().toDateString(), fileName)

            photoReady = true

            page2_exifInfo.url = app.selectedImageFilePath;
            console.log("Camera Exif FileInfo: ", page2_exifInfo.filePath, page2_exifInfo.exists, page2_exifInfo.size);

            debugText.text += "<br>" + page2_exifInfo.filePath + "<br>Exists: " + page2_exifInfo.exists + " | Size: " + page2_exifInfo.size;

            theNewPoint = ArcGISRuntime.createObject("Point");
            theNewPoint.spatialReference = ArcGISRuntime.createObject("SpatialReference", {"json":{"wkid":4326}});

            if(page2_exifInfo.gpsLongitude && page2_exifInfo.gpsLatitude) {
                app.selectedImageHasGeolocation = true
                geoLocationText.text = "Lat: " + (page2_exifInfo.gpsLatitude).toFixed(4) + " Long: " + (page2_exifInfo.gpsLongitude).toFixed(4)
                lat = page2_exifInfo.gpsLatitude
                lon = page2_exifInfo.gpsLongitude

                theNewPoint.x = lon;
                theNewPoint.y = lat;
            } else {
                app.selectedImageHasGeolocation = false;
                theNewPoint.x = 0;
                theNewPoint.y = 0;
            }

            console.log("AddPhotoPage: New Point: ", JSON.stringify(theNewPoint.json));

        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: createPage_headerBar
            Layout.alignment: Qt.AlignTop
            //Layout.fillHeight: true
            color: app.headerBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            ImageButton {
                source: "images/back-left.png"
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    console.log("Back button from create page clicked")
                    previous("")
                }
            }

            Text {
                id: createPage_titleText
                text: qsTr("Add Photo")
                textFormat: Text.StyledText
                anchors.centerIn: parent
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: "transparent"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - createPage_headerBar.height

            Flickable {
                id: flickableContent
                width: parent.width
                height: parent.height
                contentHeight:  parent.height + 30

                interactive: cameraWindow.isPortrait

                clip: true

                Item {
                    anchors.fill: parent

                    Image {
                        id: previewImage
                        fillMode: Image.PreserveAspectFit
                        source: fileLocation
                        width: 300*app.scaleFactor
                        height: width*0.6

                        anchors {
                            margins: 20*app.scaleFactor
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }

                        Rectangle {
                            anchors.fill: parent
                            border.color: "#ccc"
                            border.width: 1
                            color: "transparent"
                        }

                        Rectangle {
                            width: parent.width
                            height: 30*app.scaleFactor
                            anchors.left: parent.left
                            anchors.top: parent.top
                            visible: app.selectedImageHasGeolocation
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#77000000";}
                                GradientStop { position: 1.0; color: "#22000000";}
                            }

                            Image {
                                id:geoLocationPin
                                anchors.left: parent.left
                                anchors.bottom: parent.botom
                                anchors.margins: 5*app.scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                visible: app.selectedImageHasGeolocation
                                source: "images/esri_pin_red.png"
                                width: 10*app.scaleFactor
                                height: 20*app.scaleFactor
                            }

                            Text {
                                id: geoLocationText
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                                anchors.left: geoLocationPin.right
                                anchors.bottom: parent.botom
                                anchors.margins: 5*app.scaleFactor
                                anchors.verticalCenter: parent.verticalCenter
                                textFormat: Text.StyledText
                                font {
                                    pointSize: app.baseFontSize * 0.6
                                }
                                color: "white"
                                visible: app.selectedImageHasGeolocation
                            }
                        }

                        Text {
                            id: debugText
                            text: fileLocation.toString()
                            textFormat: Text.StyledText
                            width: parent.width
                            height: parent.height
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            style: Text.Raised
                            styleColor: "#99000000"

                            visible: false
                            font {
                                pointSize: app.baseFontSize * 0.6
                            }
                            maximumLineCount: 8
                            color: "cyan"
                            wrapMode: Text.Wrap

                        }
                    }

                    Column {
                        id: buttonsColumn
                        spacing: 5
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: previewImage.bottom
                            //topMargin: 20*app.scaleFactor
                            margins: 20 * app.scaleFactor
                        }
                        CustomButton{
                            id:page2_button1
                            buttonText: photoReady ? qsTr("RE-TAKE PHOTO") : qsTr("TAKE A PHOTO ")
                            opacity: photoReady? 0.8: 1
                            buttonColor: app.buttonColor
                            buttonWidth: 300 * app.scaleFactor
                            buttonHeight: buttonWidth/6
                            buttonFill: photoReady? false : true

                            anchors.horizontalCenter: parent.horizontalCenter

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Camera clicked");
                                    cameraWindow.visible = true
                                }
                            }
                        }

                        CustomButton{
                            id:page2_button2

                            enabled: deviceOS != "ios"
                            visible: enabled

                            buttonText: photoReady? qsTr("RE-SELECT PHOTO") : qsTr("SELECT PHOTO")
                            buttonColor: app.buttonColor
                            buttonWidth: 300 * app.scaleFactor
                            opacity: photoReady? 0.8: 1
                            buttonHeight: buttonWidth/6
                            buttonFill: photoReady? false : true
                            anchors.horizontalCenter: parent.horizontalCenter

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Select photo clicked");
                                    imagePicker.visible = true
                                }
                            }
                        }

                        CustomButton{
                            id: skipButton
                            buttonText: qsTr("SKIP")
                            buttonColor: app.buttonColor
                            buttonFill: false
                            buttonWidth: 300 * app.scaleFactor
                            buttonHeight: buttonWidth/6
                            visible: app.allowPhotoToSkip
                            anchors.horizontalCenter: parent.horizontalCenter

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Skip button clicked");
                                    app.hasAttachment = false;
                                    skipPressed = true;
                                    next("refinelocation")
                                }
                            }
                        }
                        Rectangle {
                            height: 5
                            width: page2_button3.buttonWidth
                            visible: photoReady
                            color: "transparent"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Rectangle {
                            id: page2_seperator
                            visible: photoReady
                            height: 2*app.scaleFactor
                            width: page2_button3.buttonWidth
//                            y: 5 * app.scaleFactor
                            color: app.buttonColor
                            opacity: 0.5
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Rectangle {
                            height: 5
                            width: page2_button3.buttonWidth
                            visible: photoReady
                            color: "transparent"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        CustomButton{
                            id:page2_button3
                            buttonText: "Next: " + (app.selectedImageHasGeolocation ? "REFINE" : "ADD") + " LOCATION"
                            visible: photoReady
                            buttonColor: app.buttonColor
                            buttonWidth: 300 * app.scaleFactor
                            buttonHeight: buttonWidth/5
                            anchors.horizontalCenter: parent.horizontalCenter

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    next("refinelocation");
                                    console.log("skipped?", skipPressed)
                                }
                            }
                        }

                    }
                }
            }
        }
    }

    states:[
        State {
            name: "landscape"

            PropertyChanges {
                target: rectContainer
            }

            PropertyChanges {
                target: flickableContent
                contentHeight: parent.height
            }

            PropertyChanges {
                target: buttonsColumn
                anchors.margins: 20 * app.scaleFactor
            }
            AnchorChanges {
                target: buttonsColumn
                anchors {
                    top: undefined
                    verticalCenter: parent.verticalCenter
                    left: parent.horizontalCenter
                }
            }

            AnchorChanges {
                target: previewImage
                anchors {
                    top: undefined
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: undefined
                    right: parent.horizontalCenter
                    //left: parent.left
                }
            }

//            PropertyChanges {
//                target: previewImage
//                width: halfScreenWidth * 0.9
//                height: 180 / (300 * app.scaleFactor) * width
//            }

            PropertyChanges {
                target: page2_button1
                buttonWidth: buttonWidth > halfScreenWidth ? halfScreenWidth * 0.9 : buttonWidth
            }

            PropertyChanges {
                target: page2_button2
                buttonWidth: buttonWidth > halfScreenWidth ? halfScreenWidth * 0.9 : buttonWidth
            }
            PropertyChanges {
                target: skipButton
                buttonWidth: buttonWidth > halfScreenWidth ? halfScreenWidth * 0.9 : buttonWidth
            }

            PropertyChanges {
                target: page2_button3
                buttonWidth: buttonWidth > halfScreenWidth ? halfScreenWidth * 0.9 : buttonWidth
            }
        }
    ]

    Component.onCompleted: console.log(previewImage.width, previewImage.height)

}
