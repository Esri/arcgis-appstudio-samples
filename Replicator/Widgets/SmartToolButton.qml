import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

import QtGraphicalEffects 1.0

ToolButton {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    // Image source
    property url imageSource: ""
    property bool isMirrored: false

    // Image color
    property alias imageColor: tabButtonColorOverlay.color
    property alias imageRotation: tabButtonImage.rotation

    indicator: Image {
        id: tabButtonImage
        width: parent.width / 2
        height: parent.height / 2
        anchors.centerIn: parent
        source: imageSource
        fillMode: Image.PreserveAspectFit
        mirror: isMirrored
        mipmap: true
    }

    ColorOverlay {
        id: tabButtonColorOverlay
        anchors.fill: tabButtonImage
        source: tabButtonImage
        rotation: tabButtonImage.rotation
    }
}
