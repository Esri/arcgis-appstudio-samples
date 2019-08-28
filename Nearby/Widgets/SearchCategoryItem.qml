import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import ArcGIS.AppFramework 1.0

import Esri.ArcGISRuntime 100.5

Item {
    id: root

    property string iconUrl: ""
    property string title: ""
    property color iconColor: app.secondaryColor
    property color backgroundColor: app.primaryColor
    property bool isSelected: false

    Rectangle {
        id: iconContainer

        width: parent.width
        height: width
        radius: width * 0.5
        color: backgroundColor

        Image{
            id: icon

            width: parent.width*0.5
            height: parent.height*0.5
            anchors.centerIn: parent
            source: iconUrl
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }

        ColorOverlay{
            id: colorOverlay

            anchors.fill: icon
            source: icon
            color: iconColor
        }
    }

    Rectangle {
        width: iconContainer.width
        height: iconContainer.height
        radius: width * 0.5
        color: "#B3000000"
        Material.elevation: 1
        visible: isSelected

    }

    Label{
        anchors.top: iconContainer.bottom
        anchors.topMargin: 4 * app.scaleFactor
        width: parent.width
        horizontalAlignment: Label.AlignHCenter
        wrapMode: Label.WrapAnywhere
        clip: true
        font.pixelSize: 12 * app.scaleFactor
        text: title
        opacity: 0.9
    }
}
