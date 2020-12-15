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
        Layout.preferredWidth: 50*scaleFactor
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





