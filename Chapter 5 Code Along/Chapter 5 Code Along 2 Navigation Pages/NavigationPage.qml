import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Page {
    signal next()
    signal back()

    header: ToolBar{
        contentHeight: 56 * scaleFactor
        Material.primary: Material.Indigo
        Material.elevation: 8

        RowLayout{
            anchors.fill: parent

            ToolButton {
                indicator: Image{
                    width: parent.width*0.5
                    height: parent.height*0.5
                    anchors.centerIn: parent
                    source: "./images/back.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
                onClicked: {
                    back();
                }
            }

            Label {
                Layout.fillWidth: true
                text: title
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
                font.pixelSize: app.baseFontSize
            }
        }
    }

    RoundButton{
        width: radius*2
        height:width
        radius: 32*app.scaleFactor
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin:20*app.scaleFactor
            bottomMargin: 20*app.scaleFactor
        }
        Material.elevation: 6
        Material.background: Material.Orange
        contentItem: Image {
            width: parent.radius
            height: width
            mipmap: true
            source: "./images/add.png"
        }
        onClicked: {
            next();
        }
    }
}
