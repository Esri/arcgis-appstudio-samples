import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0


RowLayout {
    anchors.fill: parent
    spacing:0
    clip:true

    Item {
        Layout.preferredWidth: 50 * app.scaleFactor
    }

    Item {
        Layout.fillWidth: true
    }

    Text {
        text:app.info.title
        color:"white"
        font.pixelSize: app.baseFontSize
        font.bold: true
        maximumLineCount:2
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        Layout.alignment: Qt.AlignHCenter
    }

    Item {
        Layout.fillWidth: true
    }

    Item {
        id: infoIcon
        Layout.preferredWidth: 50 * app.scaleFactor

        Rectangle {
            id:infoImageRect
            anchors.fill: parent

            ImageButton {
                id:infoImage
                source: "../assets/info.png"
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors {
                    centerIn: parent
                }
                onClicked: {
                    stackView.push(descriptionPage)
//                    descPage.visible = 1
                }
            }
        }
    }
}





