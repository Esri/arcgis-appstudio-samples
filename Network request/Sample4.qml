import QtQuick 2.0
import QtQuick.Controls 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Tab {
    title: "Download a file"

    property bool requestSuccess: false
    property bool filePresent: false
    property string fileToDownload: "http://video.esri.com/thumbs/2015/03/4228/4228-appstudio-for-arcgis_x.jpg"

    Item {
        FileFolder {
            id: fileFolder
            path: AppFramework.userHomePath + "/ArcGIS/AppStudio/Apps/a75d1ca36add40d4850488779c5c1b12"
        }

        FileInfo {
            id: fileInfo
            filePath: fileFolder.path + "/downloadedImage.jpg"
        }

        NetworkRequest{
            id: networkRequest
            url: fileToDownload
            responsePath: fileInfo.filePath

            onReadyStateChanged: {
                if (networkRequest.readyState === NetworkRequest.DONE){
                    requestSuccess = true;
                    filePresent = fileInfo.exists
                }
            }
        }

        Image {
            anchors {
                fill: parent
                margins: 10
            }

            source: filePresent ? fileInfo.url : "./no-image-thumb.png"
            fillMode: Image.PreserveAspectCrop

            Row {
                spacing: 5
                Button {
                    id: deleteButton
                    text: qsTr("Delete")
                    enabled: filePresent
                    onClicked: {
                        filePresent = !fileFolder.removeFile(fileInfo.filePath);
                    }
                }
                Button {
                    text: qsTr("Download")
                    enabled: !deleteButton.enabled
                    visible: requestSuccess //!filePresent
                    onClicked: {
                        requestSuccess = !requestSuccess
                        networkRequest.send()
                    }
                }
            }

            ProgressBar {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                visible: !requestSuccess
                minimumValue: 0
                maximumValue: 1
                value: networkRequest.progress
            }
        }

        Component.onCompleted:{
            if (filePresent){
                filePresent = !fileFolder.removeFile(fileInfo.filePath);
            }

            networkRequest.send();
        }
    }
}
