/* Copyright 2017 Esri
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
import QtPositioning 5.8

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Notifications.Local 1.0
import ArcGIS.AppFramework.Notifications 1.0
import ArcGIS.AppFramework.Speech 1.0

App{
    id: app
    width: 421
    height: 750

    readonly property color primaryColor: "#3F51B5"
    readonly property color accentColor: Qt.lighter(primaryColor,1.2)
    readonly property color headerTextColor: "#ffffff"
    readonly property color buttonBackgroundColor: accentColor
    readonly property color buttonTextColor: "#ffffff"

    property real scaleFactor: AppFramework.displayScaleFactor
    readonly property real baseFontSize: app.width < 450*app.scaleFactor? 21 * scaleFactor:23 * scaleFactor
    readonly property real titleFontSize: app.baseFontSize
    readonly property real subtitleFontSize: 1.1 * app.baseFontSize

    // App Page
    Page{
        anchors.fill: parent

        // Adding App Page Header Section
        header: ToolBar{
            id:header            
            contentHeight: 56 * scaleFactor
            Material.primary: app.primaryColor

            RowLayout{
                anchors.fill: parent
                spacing:0                
                Item{
                    Layout.preferredWidth: 16*app.scaleFactor
                    Layout.fillHeight: true
                }
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Workshop plugins demo")
                    elide: Label.ElideRight
                    horizontalAlignment: Qt.AlignLeft
                    verticalAlignment: Qt.AlignVCenter
                    font.pixelSize: app.titleFontSize
                    color: app.headerTextColor
                }
            }
        }
        // Header Section ends

        // TODO:-Add Code here

        ColumnLayout {
            anchors.centerIn: parent

            TextField {
                id: titleText
                placeholderText: "Enter title"
            }

            TextField {
                id: messageText
                placeholderText: "Enter message"
            }

            TextField {
                id: timeText
                placeholderText: "Enter time"
            }
// Uncomment to enable or disable background location by clicking on the button
//            Button {
//                text: positionSource.active ? "STOP" : "START"
//                onClicked: {
//                    positionSource.active = !positionSource.active;
//                }
//            }

        }

        // App Body ends here

        // Button to perform action
        RoundButton{
            width: radius*2
            height:width
            radius: 32*app.scaleFactor
            anchors {
                right: parent.right
                bottom: parent.bottom
                rightMargin:16*app.scaleFactor
                bottomMargin: 48*app.scaleFactor
            }
            Material.elevation: 6
            Material.background: app.buttonBackgroundColor
            contentItem: Image {
                width: parent.radius
                height: width
                mipmap: true
                rotation: messageDialog.visible ? 45:0
                source: "./assets/add.png"
                Behavior on rotation{
                    NumberAnimation{duration: 200}
                }
            }

            onClicked:{
                var notificationID = notification.schedule(titleText.text, messageText.text, timeText.text)
//                messageDialog.open();
            }
        }
    }


    // Show Dialog on the button click
    Dialog {
        id: messageDialog
        Material.accent: app.primaryColor
        x: (parent.width - width)/2
        y: (parent.height - height)/2
        title: qsTr("Title")
        width: Math.min(0.8 * parent.width, 400*AppFramework.displayScaleFactor)
        closePolicy: Popup.NoAutoClose

        modal: true
        Label {
            id: message
            text: qsTr("Welcome to AppStudio!")
            opacity: 0.9
            wrapMode: Label.Wrap
            width: parent.width
            height: implicitHeight
        }
        standardButtons: Dialog.Ok
    }

    LocalNotification {
        id: notification

        onTriggered: {
            tts.say("You have a notification");
            console.log("notification triggered at " + new Date() + " for id: "+ id)
//            Vibration.vibrate()
        }
    }
// Uncomment to enable background location
//    PositionSource {
//        id: positionSource
//         active: true

//        onPositionChanged: {
//            var coord = positionSource.position.coordinate;
//            console.log("Coorindate", coord.longitude, coord.latitude);
//            var data = "Coorindate" + coord.longitude + coord.latitude;
//            notification.schedule("My Location", data, 1);
//        }
//    }

    TextToSpeech {
        id: tts
    }
}






