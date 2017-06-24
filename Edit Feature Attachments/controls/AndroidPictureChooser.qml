import QtQuick 2.7
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Rectangle {
    id: androidPictureChooserComponent
    property string title
    property alias outputFolder: outputFolder
    property var pictureUrl
    property var imageModel
    property var imageUrl
    property bool copyToOutputFolder: true
    property string androidImageGalleryLoc: "file:///storage/emulated/0/DCIM/Camera/"

    signal accepted()
    signal rejected()

    property string path

    onVisibleChanged: {
        console.log("Visible changed", androidPictureChooserComponent.visible)
    }

    onRejected: {
        close()
    }

    onAccepted: {
        var pictureUrlInfo = AppFramework.urlInfo(pictureUrl);
        var picturePath = pictureUrlInfo.localFile;
        var assetInfo = AppFramework.urlInfo(picturePath);
        var outputFileName;

        outputFileName = AppFramework.createUuidString(2) + "." + AppFramework.fileInfo(picturePath).suffix;
        console.log("outputFileName", outputFileName);

        photoReady = true;

        if (copyToOutputFolder) {
            var outputFileInfo = outputFolder.fileInfo(outputFileName);
            outputFolder.removeFile(outputFileName);
            outputFolder.copyFile(picturePath, outputFileInfo.filePath);
            picturePath = outputFolder.filePath(outputFileName);
        }

        app.selectedImageFilePath = picturePath;
        close();
    }

    anchors.fill: parent
    visible: false
    color: "black"

    FileFolder {
        id: fileFolder
    }

    FileFolder {
        id: outputFolder
    }

    ListModel {
        id: picturesModel
    }

    ColumnLayout{
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: header
            Layout.alignment: Qt.AlignTop
            color: "#323232"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }
        }

        Rectangle{
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.maximumWidth: 600*app.scaleFactor
            color: "#4c4c4c"
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: emptyImage
                source: "../images/no_photo_graphic.png"
                visible: picturesModel.count==0
                width: 256*app.scaleFactor
                height: 256*app.scaleFactor
                fillMode: Image.PreserveAspectFit
                smooth: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 16*app.scaleFactor
                anchors.top: parent.top
                anchors.topMargin: (parent.height - height)/3
            }

            Text {
                text: qsTr("Sorry, no photos!")
                wrapMode: Text.Wrap
                maximumLineCount: 2
                width: emptyImage.width
                font.pixelSize: app.textFontSize
                font.family: app.customTextFont.name
                color: "#cccccc"
                font.weight: Font.Bold
                visible: picturesModel.count==0
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: emptyImage.bottom
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            GridView {
                id: gridView
                anchors.fill: parent
                model: picturesModel
                focus: true

                cellWidth: gridView.width/3
                cellHeight: gridView.width/3

                delegate: Rectangle{
                    color: "transparent"
                    width: gridView.cellWidth
                    height: gridView.cellHeight
                    Image {
                        anchors.fill: parent
                        anchors.margins: 5*app.scaleFactor
                        source: url
                        asynchronous: true
                        autoTransform: true
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: 200
                        sourceSize.height: 200
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pictureUrl = url;
                                androidPictureChooserComponent.accepted();
                            }
                        }
                    }
                }

            }
        }
    }

    DropShadow {
        source: header
        //anchors.fill: source
        width: source.width
        height: source.height
        cached: false
        radius: 5.0
        samples: 16
        color: "#80000000"
        smooth: true
        visible: source.visible
    }

    function getPaths() {
        picturesModel.clear();
        // Android Path
        var allAndroidCameraPath = ["file:///storage/emulated/0/DCIM/Camera",
                                    "file:///storage/emulated/0/DCIM/Pictures",
                                    "file:///storage/sdcard/0/Pictures",
                                    "file:///storage/emulated/0/Pictures",
                                    "file:///sdcard/DCIM"]
        for(var i in allAndroidCameraPath){
            fileFolder.url = allAndroidCameraPath[i];
            var sourceFilesCurrent = fileFolder.fileNames()
            console.log("allAndroidCameraPath",i, allAndroidCameraPath[i])
            if (sourceFilesCurrent) {
                var index
                for (index in sourceFilesCurrent) {
                    var file = sourceFilesCurrent[index]
                    if(file.indexOf(".jpeg")>-1 ||file.indexOf(".jpg")>-1 || file.indexOf(".gif")>-1 || file.indexOf(".png")>-1 || file.indexOf(".bmp")>-1){
                        path = allAndroidCameraPath[i] + "/" + file
                        picturesModel.insert(0,{"url": path, "name": file});
                    }
                }
            }
        }
    }

    function open() {
        androidPictureChooserComponent.visible = true
        busy.running = true
        getPaths()
        busy.running = false
        androidPictureChooserComponent.enabled = true
    }

    function close() {
        androidPictureChooserComponent.visible = false
        androidPictureChooserComponent.enabled = false
    }

    BusyIndicator{
        id: busy
        anchors.centerIn: parent
        visible: running
    }
}
