/* Copyright 2020 Esri
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
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.InterAppCommunication 1.0
import Esri.ArcGISRuntime 100.2
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
    property var internalStorage: AppFramework.standardPaths.standardLocations(StandardPaths.AppDataLocation);
    property string internalPath

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

            EmailComposer {
                id: emailComposer
                to: "example@example.com"
                cc: ["example2@example.com", "example3@example.com"]
                bcc: "example4@example.com"
                subject: "Feedback for " + app.info.title

                // Known limitation: html property becomes false if an attachment property is defined on Windows.

                body: AppFramework.osName !== "Windows" ? "<br> <br>" + " Device OS:" + Qt.platform.os + AppFramework.osVersion +
                                                          "<br>"  + " Device Locale:" + Qt.locale().name +
                                                          "<br>" + " App Version:" + app.info.version +
                                                          "<br>" + " AppStudio Version:" + AppFramework.version :

                                                          "\n\n" + "Device OS:" + Qt.platform.os + AppFramework.osVersion +  "\n" +
                                                          "Device Locale:" + Qt.locale().name + "\n" +
                                                          "App Version:" + app.info.version +  "\n" +
                                                          "AppStudio Version:" + AppFramework.version
                html: true

                onErrorChanged: {
                    var reason = error.errorCode
                    switch (reason) {
                    case EmailComposerError.ErrorInvalidRequest:
                        message.text = qsTr("Invalid Request");
                        break;
                    case EmailComposerError.ErrorServiceMissing:
                        message.text = qsTr("Mail service not configured.")
                        break;
                    case EmailComposerError.ErrorFileRead:
                        message.text = qsTr("Invalid attachment.")
                        break;
                    case EmailComposerError.ErrorPermission:
                        message.text = qsTr("Permission Error")
                        break;
                    case EmailComposerError.ErrorNotSupportedFeature:
                        message.text = qsTr("Platform not supported.")
                        break;
                    default:
                        message.text = qsTr("Unknown error.")
                    }

                    messageDialog.open();
                }
            }

            Component.onCompleted: {
                internalPath = internalStorage[internalStorage.length-1]
            }

            MapView {
                anchors.fill: parent
                //   color: Material.color(Material.Teal)

                Map {
                    BasemapLightGrayCanvasVector{}
                    initialViewpoint: ViewpointCenter {
                        center: Point {
                            x: -11e6
                            y: 6e6
                            spatialReference: SpatialReference {wkid: 102100}
                        }
                        targetScale: 9e7
                    }
                }

                Button {
                    anchors.centerIn: parent
                    text: qsTr( "Take a Screenshot and Generate Email" )
                    Material.background: "#D2A7D9"


                    onClicked: {
                        console.log("all paths", internalStorage)
                        console.log("current storage", internalStorage[internalStorage.length-1] + "/images/test.png")

                        if (AppFramework.osName === "Android") {
                            fileFolder.path = internalPath;
                            console.log("capture screenshot", AppFramework.grabWindowToFile(fileFolder.path + "/image.png"))
                            emailComposer.attachments = fileFolder.path + "/image.png"
                        } else if (AppFramework.osName === "iOS") {
                            fileFolder.path = "~/ArcGIS/Screenshots"
                            fileFolder.makeFolder()
                            console.log("capture screenshot", AppFramework.grabWindowToFile(fileFolder.path + "/image.jpg"))
                            emailComposer.attachments = fileFolder.path + "/image.jpg";
                        } else {
                            fileFolder.path = internalStorage[internalStorage.length-1] + "/images"
                            fileFolder.makeFolder()
                            fileFolder.path = internalStorage[internalStorage.length-1] + "/images/test.png"
                            console.log("captured screenshot", AppFramework.grabWindowToFile(fileFolder.path))
                            emailComposer.attachments =  fileFolder.path
                        }
                        emailComposer.show()
                    }
                }
            }

            FileFolder {
                id: fileFolder
            }

            Dialog {
                id: messageDialog
                Material.accent: "#8f499c"
                x: (parent.width - width)/2
                y: (parent.height - height)/2
                title: qsTr("Error")
                width: Math.min(0.9 * parent.width, 400*AppFramework.displayScaleFactor)
                closePolicy: Popup.NoAutoClose
                modal: true

                Label {
                    id: message
                    opacity: 0.9
                    wrapMode: Label.Wrap
                    width: parent.width
                    height: implicitHeight
                }
                standardButtons: Dialog.Ok
            }



        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

