import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

//Add a rectangle item as header
Rectangle{
    id:header
    Layout.alignment: Qt.AlignTop
    color:"#8f499c"
    Layout.preferredWidth: parent.width
    Layout.preferredHeight: 50 * scaleFactor
    MouseArea {
        anchors.fill: parent
        onClicked: {
            mouse.accepted = false
        }
    }
    //Add Info icon
    ImageButton {
        source: "assets/info.png"
        height: 30 * scaleFactor
        width: 30 * scaleFactor
        checkedColor : "transparent"
        pressedColor : "transparent"
        hoverColor : "transparent"
        glowColor : "transparent"
        anchors {
            right: parent.right
            rightMargin:10*scaleFactor
            verticalCenter: parent.verticalCenter
        }
        onClicked: {
            descPage.visible = 1
        }
    }

    //Add Sample name
    Text {
        id: sampleTitle
        text:app.info.title
        color:"white"
        font.pointSize:14
        font.bold: true
        maximumLineCount: 1
        elide: Text.ElideRight
        anchors{
            centerIn: parent
            verticalCenter: parent.verticalCenter
        }
   }
}





