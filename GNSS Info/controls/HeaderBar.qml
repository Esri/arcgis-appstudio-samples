import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

RowLayout {
    property alias headerText: headerText.text

    anchors.fill: parent
    spacing: 0
    clip: true

    Text {
        id: headerText

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        font.pixelSize: app.baseFontSize * 1.1
        font.bold: true
        maximumLineCount: 2
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        color: "white"
    }

    Rectangle {
        id: infoImageRect

        Layout.alignment: Qt.AlignRight
        Layout.preferredWidth: 50 * scaleFactor

        Image {
            id: infoImage

            height: 30 * scaleFactor
            width: 30 * scaleFactor
            anchors.centerIn: parent

            source: "../assets/info.png"
            smooth: true
            mipmap: true

            MouseArea {
                anchors.fill: parent
                onClicked: descPage.visible = 1
            }
        }
    }
}
