import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

RowLayout{
    anchors.fill: parent
    spacing:0
    clip:true

    Rectangle{
        id: positionAccuracyImage
        Layout.preferredWidth: 50 * scaleFactor
        Layout.alignment: Qt.AlignLeft
        Item{
            anchors.fill: parent
            width: 30 * scaleFactor
            height: 30 * scaleFactor
            Image{
                id: satelliteImage
                width: 30 * scaleFactor
                height: 30 * scaleFactor
                anchors.centerIn: parent
                source: positionAccuracy < 5 ? "../assets/satellite-3.png" : positionAccuracy >= 5 && positionAccuracy < 10 ? "../assets/satellite-2.png" : positionAccuracy >= 10 && positionAccuracy < 15 ? "../assets/satellite-1.png" : "../assets/satellite-0.png"
                fillMode: Image.PreserveAspectFit
                mipmap: true
            }
            ColorOverlay {
                id: satelliteColorOverlay
                width: 30 * scaleFactor
                height: 30 * scaleFactor
                anchors.fill: satelliteImage
                anchors.centerIn: parent
                source: satelliteImage
                color: "white"
            }
        }
    }

    Text {
        text: sampleName
        color:"white"
        font.pixelSize: app.baseFontSize * 1.1
        font.bold: true
        maximumLineCount:2
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        Layout.alignment: Qt.AlignCenter
    }

    Rectangle{
        id:infoImageRect
        Layout.alignment: Qt.AlignRight
        Layout.preferredWidth: 50*scaleFactor

        ToolButton {
            id:infoImage
            indicator: Image{
                width: 30 * scaleFactor
                height: 30 * scaleFactor
                anchors.centerIn: parent
                source: "../assets/info.png"
                fillMode: Image.PreserveAspectFit
                mipmap: true
            }
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            onClicked: {
                descPage.visible = 1
            }
        }
    }
}
