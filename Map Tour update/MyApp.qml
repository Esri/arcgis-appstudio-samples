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
import QtQuick.Controls 1.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

App {
    id: app
    width: 600
    height: 600

    FileFolder {
        id: fileFolder
    }

    ListView {
        id: listView
        anchors {
            fill: parent
            margins: 5
        }
        model: ListModel {
            id: listModel
            ListElement {
                textDesc: qsTr("Unused module reference, has been removed. This change will be invisible to users who create new map tours. Users who have map tours created with beta versions of AppStudio, may see a white screen when they attempt to view their app. This tool will update older versions of Map tour on your PC.\r\n")
                fontBold: false
                fontColor: "black"
                fontSize: 10
            }
        }
        delegate: Text {
            text: textDesc
            wrapMode: Text.WordWrap
            font.bold: fontBold
            font.pointSize: fontSize
            color: fontColor
            anchors {
                left: parent.left
                right: parent.right
            }
            MouseArea {
                anchors.fill: parent
                enabled: fontBold
                onClicked: {
                    var str = "file:///" + fileFolder.path.toString() + "/" + textDesc.substring(3, textDesc.length);
                    Qt.openUrlExternally(str)
                }
            }
        }
    }

    Button {
        text: qsTr("Update Map tours")
        anchors.centerIn: parent

        onClicked: {
            visible = !visible;
            updateTours();
        }
    }

    function updateTours(){
        fileFolder.path =  app.folder.path;
        fileFolder.cdUp();
        listModel.append({"textDesc": fileFolder.path, "fontBold": false, "fontColor": "black", "fontSize":10})

        var folderList = fileFolder.folderNames();

        for (var f in folderList) {
            listModel.append({"textDesc": " + " + folderList[f], "fontBold": true, "fontColor": "black", "fontSize":12})

            fileFolder.cd(folderList[f]);
            var subFolders = fileFolder.folderNames();

            for (var s in subFolders){
                if (subFolders[s] === "MapTour"){
                    listModel.append({"textDesc": "  - " + subFolders[s], "fontBold": false, "fontColor": "black", "fontSize":10})

                    fileFolder.cd("MapTour");

                    if (fileFolder.fileNames("MapTourApp.qml", true)){
                        listModel.append({"textDesc": "   >> " + fileFolder.fileNames("MapTourApp.qml", true), "fontBold": false, "fontColor": "black", "fontSize":10})

                        var newFile = fileFolder.path + "/MapTourAppNew.qml";
                        fileFolder.copyFile("MapTourApp.qml", newFile);

                        var readfile = fileFolder.readTextFile(newFile);

                        var newArray = [];
                        var txtArray = [];
                        txtArray = readfile.split("\r\n");

                        var findString = "import ArcGIS.AppFramework.Runtime.Dialogs 1.0"

                        if ( txtArray.indexOf(findString) > -1 ) {
                            txtArray.splice( txtArray.indexOf(findString), 1 );
                            for (var i in txtArray)
                                newArray.push(txtArray[i] + "\r\n")
                        }

                        fileFolder.writeTextFile(newFile, newArray.join(""));
                        fileFolder.renameFile(fileFolder.path + "/MapTourApp.qml", fileFolder.path + "/MapTourApp_Original.qml");
                        fileFolder.renameFile(fileFolder.path + "/MapTourAppNew.qml", fileFolder.path + "/MapTourApp.qml");
                        listModel.append({"textDesc": qsTr("   >> Successfully updated the file.") , "fontBold": false, "fontColor": "green", "fontSize":10})
                    }

                    fileFolder.copyFile(app.folder.path + "/PortalSignInDialog.qml", fileFolder.path + "/PortalSignInDialog.qml");
                    listModel.append({"textDesc": qsTr("   >> Successfully copied PortalSignIndDialog.qml"),  "fontBold": false, "fontColor": "green", "fontSize":10})

                    fileFolder.cdUp();
                    break;
                }
                else {
                    listModel.append({"textDesc": qsTr("   !! No MapTour folder present in this folder."),  "fontBold": false, "fontColor": "orange", "fontSize":10})
                }
            }
            fileFolder.cdUp();
        }
    }
}

