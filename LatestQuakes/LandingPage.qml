/* ******************************************
Copyright 2015 Esri

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.​
******************************************* */

import QtQuick 2.3
import QtGraphicalEffects 1.0
import QtMultimedia 5.0
import "components"
import ArcGIS.AppFramework 1.0

Item {
    id: self

    signal done()

    property int screenWidth : Math.min(400*AppFramework.displayScaleFactor, parent.width)
    property color backGroundColor: "white"
    property color textColor: "black"
    property color headerColor: "white"
    property color buttonColor: "#ECECEC"
    property string buttonText: "Get Started"
    property string titleText: "Cool App Intro"
    property int titleFontPointSize: 20

    anchors.fill: parent
    height: parent.height
    width: parent.width

    anchors.horizontalCenter: parent.horizontalCenter

    Rectangle {
        anchors.fill: parent
        color: "white"
    }

    ListModel {
        id: listModel

        ListElement {
            message: "Your Utlimate <br>EarthQuake App"
            imageUrl: "assets/1.jpg"
            videoUrl: ""
        }
        ListElement {
            message: "Current EarthQuakes Info At Your Finger Tips"
            imageUrl: "assets/3.jpg"
            videoUrl: ""
        }
        ListElement {
            message: "Easy-To-Use and Powerful"
            imageUrl: "assets/4.jpg"
            videoUrl: ""
        }
        ListElement {
            message: "Watch a video clip"
            imageUrl: "assets/2.jpg"
            videoUrl: "http://www.sample-videos.com/video/mp4/240/big_buck_bunny_240p_1mb.mp4"
        }
    }

    Rectangle {
        id: headerItem
        width: screenWidth
        anchors.top: parent.top
        height: 70 * app.scaleFactor
        color: headerColor
        Text {
            id: title
            anchors.margins: 10 * app.scaleFactor
            color: textColor
            text: self.titleText
            anchors.centerIn: parent
            font.pointSize: self.titleFontPointSize
        }
        z:1

    }

    Rectangle {
        id: dots
        anchors.bottom: footerItem.top
        anchors.top: headerItem.bottom
        width: screenWidth
        height: parent.height

        Rectangle {
            visible: listModel.count > 1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5 * app.scaleFactor
            //anchors.centerIn: parent
            anchors.horizontalCenter: headerItem.horizontalCenter
            color: "transparent"
            width: parent.width
            height: 10 * app.scaleFactor
            //opacity: 0.5
            z:1
            Row {
                spacing: 5 * app.scaleFactor
                //anchors.fill: parent
                anchors.centerIn: parent

                Repeater {
                    model: listModel
                    id: listSwatches
                    Rectangle {
                        border.color: (listView.currentIndex == index) ? self.buttonColor : "white"
                        color: (listView.currentIndex == index) ? "white" : self.buttonColor
                        scale: (listView.currentIndex == index) ? 1 : 0.8
                        width: 8 * app.scaleFactor
                        height: 8 * app.scaleFactor
                        radius: 5 * app.scaleFactor
                    }
                }
            }
        }



        Component.onCompleted: {
            console.log(width, height)
        }

        ListView {
            id: listView
            model: listModel
            anchors.fill: parent
            clip: true
            focus: true

            orientation: ListView.Horizontal

            height: parent.height

            currentIndex: 0
            snapMode: ListView.SnapOneItem
            highlightFollowsCurrentItem: true


            //footerPositioning: ListView.OverlayFooter

            onFlickEnded: {
                console.log(currentIndex)
                console.log("flick ended at ", contentX, contentY  , indexAt(contentX, contentY));

                currentIndex = indexAt(contentX, contentY);
            }


            delegate: Component {
                Rectangle {

                    Component.onCompleted: {
                        console.log(width,height)
                        //console.log(message, imageUrl, videoUrl)
                    }

                    //color: backGroundColor
                    //anchors.fill: parent
                    //width: parent.width

                    width: screenWidth
                    height: listView.height
                    Text {
                        id: snippet
                        color: textColor
                        text: message
                        visible: message && message.length > 1
                        font.pointSize: 16
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.StyledText
                        width: parent.width * 0.8
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Text.AlignHCenter
                        anchors.topMargin: 20 * app.scaleFactor
                    }

                    Image {
                        anchors.top: snippet.bottom
                        source: imageUrl && imageUrl.length > 1? imageUrl : ""
                        opacity: 0
                        anchors.topMargin: 20 * app.scaleFactor
                        visible: imageUrl && imageUrl.length > 1
                        //visible: false
                        asynchronous: true
                        cache: true
                        width: parent.width * 0.9
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectCrop

                        onStatusChanged: if (status === Image.Ready) animateImage.start()

                        NumberAnimation on opacity {
                            id: animateImage
                            from: 0
                            to: 1
                            duration: 500
                            easing.type: Easing.InSine
                        }

                    }

                    //                    Text {
                    //                        anchors.centerIn: parent
                    //                        color: "orange"
                    //                        text: videoUrl
                    //                        width: parent.width
                    //                        wrapMode: Text.WrapAnywhere
                    //                    }

                    Video {
                        id: video
                        anchors.top: snippet.bottom
                        source: videoUrl && videoUrl.length > 1 ? videoUrl : ""
                        anchors.topMargin: 20 * app.scaleFactor
                        width: parent.width * 0.9
                        z:1
                        anchors.horizontalCenter: parent.horizontalCenter
                        autoPlay: false
                        height: parent.height
                        visible: videoUrl && videoUrl.length > 1
                        autoLoad: false
                        fillMode: VideoOutput.PreserveAspectCrop
                        property bool isPlaying: false

                        Rectangle {
                            height: 2*app.scaleFactor
                            visible: video.duration > 0
                            width: parent.width*video.position/video.duration
                            anchors.top: parent.top
                            anchors.left: parent.left
                            color: "orange"
                            z:1
                        }

                        Image {
                            anchors.centerIn: parent
                            source: "assets/video.png"
                            width: 80*scaleFactor
                            height: 80*scaleFactor
                            visible: !video.isPlaying
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if(video.isPlaying) {
                                    video.isPlaying = false
                                    video.pause()
                                } else {
                                    video.isPlaying = true
                                    video.play()
                                }
                            }
                        }

                        onErrorChanged: {
                            console.log(error, errorString)
                        }

                        onStopped: {
                            video.isPlaying = false
                        }

                        onPlaying: {

                        }
                    }
                }
            }
        }
    }
    Rectangle {

        id: footerItem

        Component.onCompleted: {
            console.log(width, height)
        }

        anchors.bottom: parent.bottom

        width: screenWidth
        height: 60 * app.scaleFactor
        color: backGroundColor

        CustomButton {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            //anchors.bottom: parent.bottom
            //anchors.bottomMargin: 8
            buttonBorderRadius: 0
            buttonWidth: parent.width * 0.8
            buttonHeight: 50 * app.scaleFactor
            buttonColor: self.buttonColor
            buttonFill: true
            buttonText: self.buttonText

            onButtonClicked: {
                done()
            }
        }
    }

}
