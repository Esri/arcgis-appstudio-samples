import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0


RowLayout {
    anchors.fill: parent
    spacing:0
    clip:true

    Rectangle {
        Layout.preferredWidth: 50 * app.scaleFactor
    }


    Text {
        text:app.info.title
        font.family: "Tahoma"
        color:"white"
        font.pixelSize: app.baseFontSize
        font.bold: true
        maximumLineCount:2
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        Layout.alignment: Qt.AlignHCenter
    }

    Rectangle {
        id: infoIcon
        Layout.preferredWidth: 50 * app.scaleFactor
        Layout.alignment: Qt.AlignRight

        ToolButton {
            id:infoImage
            indicator: Image{
                width: 30 * app.scaleFactor
                height: 30 * app.scaleFactor
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
                stackView.push(descriptionPage)
//                descPage.visible = 1
            }
        }
    }
}





