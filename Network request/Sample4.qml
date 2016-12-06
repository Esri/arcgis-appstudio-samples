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
            path: app.folder.path
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
