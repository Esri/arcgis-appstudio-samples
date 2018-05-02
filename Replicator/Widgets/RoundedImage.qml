import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import QtGraphicalEffects 1.0

Item {
    property real radius
    property alias imageSource: roundedButtonImage.source
    property alias fillMode: roundedButtonImage.fillMode
    property alias mipmap: roundedButtonImage.mipmap
    property alias enableBusyIndicator: busyIndicator.visible
    property alias status: roundedButtonImage.status
    property color backgroundColor: colors.transparent
    property bool isShowBusyIndicator: true
    property bool isShowBorder: false
    property bool isBorderOpacity: false

    Image{
        id: roundedButtonImage
        anchors.fill: parent
        visible: false
        mipmap: true

        Rectangle {
            anchors.fill: parent
            color: backgroundColor
            border.width: isShowBorder ? 1 : 0
            border.color: colors.default_content_color
            radius: roundedButtonMask.radius
            opacity: isBorderOpacity? 0.6 : 1.0
            smooth: true
        }
    }

    Rectangle {
        id: roundedButtonMask
        anchors.centerIn: parent
        radius: parent.radius
        width: roundedButtonImage.width
        height: roundedButtonImage.height
        visible: false
    }

    OpacityMask {
        anchors.fill: roundedButtonImage
        source: roundedButtonImage
        maskSource: roundedButtonMask
    }

    BusyIndicator{
        id: busyIndicator
        width: parent.width * 0.8
        height: parent.height * 0.8
        opacity: 0.6
        visible: isShowBusyIndicator
        Material.accent: colors.primary_color
        anchors.centerIn: parent
        running: status === Image.Loading
    }
}
