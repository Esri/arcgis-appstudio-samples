import QtQuick 2.9
import QtQuick.Layouts 1.1

Rectangle {
    property alias headerText: headerText.text

    anchors.fill: parent
    clip: true
    color: primaryColor

    Text {
        id: headerText

        anchors.fill: parent

        font.pixelSize: app.baseFontSize * 1.1
        font.bold: true
        maximumLineCount: 2
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        id: infoImageRect

        width: 50 * scaleFactor
        height: parent.height
        anchors.right: parent.right
        color: primaryColor

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
