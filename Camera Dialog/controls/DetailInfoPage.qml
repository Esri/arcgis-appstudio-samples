import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2
import QtMultimedia 5.6

import ArcGIS.AppFramework 1.0

Rectangle{
    id:detailInfoPage

    anchors.fill: parent
    property bool vidRotation: false
    property bool imgOrVid: true //true for showing img
    property url imgSource:""
    property url vidSource:""
    property string vidSizeText:""
    property string imgTimeText:""
    property string vidTimeText:""
    property string vidPathText:""
    property string imgPathText:""
    property string imgLocationText:""
    property string imgMakeText:""
    property string imgFileInfoText:""
    property string imgExifInfoText:""
    signal infoPageClosed()
    property bool vidPlay: false

    color: "#353535"

    ToolButton {
        id:infoCloseButton

        width: 25 * scaleFactor
        height: 25 * scaleFactor
        indicator: Image{
            anchors.fill:parent
            horizontalAlignment: Qt.AlignRight
            verticalAlignment: Qt.AlignVCenter
            source: "../assets/clear.png"
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }
        anchors {
            top: parent.top
            topMargin: defaultMargin/2
            right: parent.right
            rightMargin: defaultMargin
        }
        onClicked: {
            detailInfoPage.visible=false;
            infoPageClosed();
        }
    }

    Rectangle{
        id:previewBox

        width: parent.width - 2 * defaultMargin
        anchors.top: parent.top
        anchors.topMargin: 4*defaultMargin
        anchors.bottom: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#353535"
        border.color:"#9F9F9F"
        border.width: 2 * scaleFactor
        visible: true

        Image {
            id:  img

            anchors.fill: parent
            anchors.margins: 3*scaleFactor
            autoTransform: true
            fillMode: Image.PreserveAspectFit
            source: imgSource
            visible: imgOrVid?true:false
        }

        Video {
            id: vid

            anchors.fill: parent
            anchors.margins: 3*scaleFactor
            visible: imgOrVid?false:true
            orientation: vidRotation?-90:0
            fillMode: VideoOutput.PreserveAspectFit
            source: vidSource

            ToolButton {
                id: playBtn

                width: 50*AppFramework.displayScaleFactor
                height: width
                anchors.centerIn: parent
                padding: 0
                scale: 1.2
                visible: vid.playbackState !== MediaPlayer.PlayingState
                enabled: visible

                indicator: Item {
                    anchors.fill: parent

                    Rectangle {
                        width: parent.width
                        height: width
                        radius: width/2
                        color: "grey"
                        anchors.centerIn: parent
                    }

                    Image{
                        id: playIcon
                        width: parent.width*0.6
                        height: width
                        anchors.centerIn: parent
                        source: vid.playbackState === MediaPlayer.PlayingState ? "": vid.playbackState === MediaPlayer.PausedState? "../assets/ic_pause_white_48dp.png" : "../assets/ic_play_arrow_white_48dp.png"
                    }
                }

                onClicked: {
                    vid.play();
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: !playBtn.visible
                onClicked: {
                    vid.pause();
                }
            }

            Component.onCompleted: {
                vid.play();
            }
        }

    }

    Rectangle{
        id:imgMetaDataRect

        width: parent.width * 0.9
        anchors.top: previewBox.bottom
        anchors.bottom:parent.bottom
        anchors.topMargin: 2*defaultMargin
        anchors.leftMargin: defaultMargin
        anchors.left:parent.left
        color: "#353535"
        visible: imgOrVid

        Label {
            id: imgTime
            wrapMode: Text.Wrap
            font.pixelSize: baseFontSize*0.7
            font.bold: true
            width: parent.width
            anchors.topMargin: 2*scaleFactor
            text: imgTimeText

            color: "#BFBFBF"
        }

        Label {
            id: fileInfoDeatilTitle
            wrapMode: Text.Wrap
            font.pixelSize: baseFontSize*0.7
            width: parent.width
            anchors.top:imgTime.bottom
            anchors.topMargin: 2*defaultMargin
            font.bold: true
            text:qsTr("FILE INFO")
            color: "#BFBFBF"
        }

        Rectangle{
            id:fileInfoDeatil

            height:65*scaleFactor
            width: parent.width
            anchors.top:fileInfoDeatilTitle.bottom
            anchors.topMargin: defaultMargin
            color: "#353535"
            Image{
                id: fileInfoDeatilImg
                height:25 * scaleFactor
                width:height
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:parent.left
                anchors.leftMargin: defaultMargin
                source:"../assets/image.svg"
                mipmap:true
            }
            Label{
                id:imgPath

                wrapMode: Text.Wrap
                font.pixelSize: baseFontSize*0.7
                font.bold: true
                width: parent.width - fileInfoDeatilImg.width - defaultMargin * 3
                anchors.top:parent.top
                anchors.left:fileInfoDeatilImg.right
                anchors.leftMargin: defaultMargin*2
                color: "#FFFFFF"
                text:imgPathText
            }
            Label{
                id:imgFileInfoDetail

                wrapMode: Text.Wrap
                font.pixelSize: baseFontSize*0.7
                font.bold:true
                width: parent.width - fileInfoDeatilImg - defaultMargin * 3
                anchors.top:imgPath.bottom
                anchors.left:fileInfoDeatilImg.right
                anchors.leftMargin:  defaultMargin*2
                color: "#BFBFBF"
                text: imgFileInfoText
            }
        }


        Label {
            id: imgExifInfoTitle
            wrapMode: Text.Wrap
            font.pixelSize: baseFontSize*0.7
            width: parent.width
            anchors.top:fileInfoDeatil.bottom
            anchors.topMargin: defaultMargin
            font.bold: true
            text:qsTr("EXIF")
            color: "#BFBFBF"
        }

        Rectangle{
            id:imgExifInfo

            height:35*scaleFactor
            width: parent.width
            anchors.top:imgExifInfoTitle.bottom
            anchors.topMargin:  defaultMargin
            color: "#353535"
            Image{
                id: imgExifInfoImg
                height:25 * scaleFactor
                width:height
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:parent.left
                anchors.leftMargin:  defaultMargin
                source:"../assets/label.svg"
                mipmap:true
            }
            Label{
                id:imgMake

                wrapMode: Text.Wrap
                font.pixelSize: baseFontSize*0.75
                font.bold: true
                width: parent.width - imgExifInfoImg.width - 3* defaultMargin
                anchors.top:parent.top
                anchors.left:imgExifInfoImg.right
                anchors.leftMargin:  defaultMargin*2
                color: "#FFFFFF"
                text:imgMakeText
            }
            Label{
                id:imgExifInfoDetail

                wrapMode: Text.Wrap
                font.pixelSize: baseFontSize*0.7
                font.bold:true
                width: parent.width - imgExifInfoImg.width - 3* defaultMargin
                anchors.top:imgMake.bottom
                anchors.left:imgExifInfoImg.right
                anchors.leftMargin:  defaultMargin*2
                color: "#BFBFBF"
                text:imgExifInfoText
            }
        }

        Rectangle{
            id:imgLocation

            height:35*scaleFactor
            width: parent.width
            anchors.top:imgExifInfo.bottom
            anchors.topMargin:  defaultMargin
            color: "#353535"
            Image{
                id: imgLocationimg
                height:25 * scaleFactor
                width:height
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:parent.left
                anchors.leftMargin:  defaultMargin
                source:"../assets/pin.svg"
                mipmap:true
            }
            Label{
                id:imgLocationLabel

                wrapMode: Text.Wrap
                font.pixelSize: baseFontSize*0.75
                font.bold: true
                width: parent.width - imgLocationimg.width - defaultMargin * 3
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:imgLocationimg.right
                anchors.leftMargin:  defaultMargin*2
                color: "#FFFFFF"
                text:imgLocationText
            }
        }

    }

    Rectangle{
        id:vidMetaDataRect

        width: parent.width * 0.9
        anchors.top: previewBox.bottom
        anchors.bottom:parent.bottom
        anchors.topMargin: 2*defaultMargin
        anchors.leftMargin: defaultMargin
        anchors.left:parent.left
        color: "#353535"
        visible: !imgOrVid


        Label {
            id: vidTime
            wrapMode: Text.Wrap
            font.pixelSize: baseFontSize*0.7
            font.bold: true
            width: parent.width
            anchors.topMargin:2*defaultMargin
            text: vidTimeText

            color: "#BFBFBF"
        }

        Label {
            id: vidFileInfoTitle
            wrapMode: Text.Wrap
            font.pixelSize: baseFontSize*0.7
            width: parent.width
            anchors.top:vidTime.bottom
            anchors.topMargin: 2*defaultMargin
            font.bold: true
            text:qsTr("FILE INFO")
            color: "#BFBFBF"
        }

        Rectangle{
            id:vidFileInfo

            height:50*scaleFactor
            width: parent.width
            anchors.top:vidFileInfoTitle.bottom
            anchors.topMargin: 2*defaultMargin
            color: "#353535"
            Image{
                id: vidFileInfoImg
                height:25 * scaleFactor
                width:height
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:parent.left
                anchors.leftMargin:  defaultMargin*2
                source:"../assets/image.svg"
                mipmap:true
            }
            Label{
                id:vidPath

                wrapMode: Text.Wrap
                font.pixelSize: baseFontSize*0.7
                font.bold: true
                width: parent.width - vidFileInfoImg.width - defaultMargin*4
                anchors.top:parent.top
                anchors.left:vidFileInfoImg.right
                anchors.leftMargin:  defaultMargin*2
                color: "#FFFFFF"
                text: vidPathText
            }
            Label{
                id:vidSize

                wrapMode: Text.Wrap
                font.pixelSize: baseFontSize*0.7
                font.bold:true
                width: parent.width - vidFileInfoImg.width - defaultMargin*4
                anchors.top:vidPath.bottom
                anchors.left:vidFileInfoImg.right
                anchors.leftMargin:  defaultMargin*2
                color: "#BFBFBF"
                text:vidSizeText
            }
        }
    }
}
