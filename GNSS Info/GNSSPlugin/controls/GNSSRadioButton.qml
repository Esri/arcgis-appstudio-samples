import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

Rectangle {
    property alias radioButton: control
    property alias checked: control.checked
    property alias text: textItem.text

    property color foregroundColor: "black"
    property color secondaryForegroundColor: "green"
    property color backgroundColor: "#FAFAFA"
    property color secondaryBackgroundColor: "#F0F0F0"

    readonly property double scaleFactor: AppFramework.displayScaleFactor

    Layout.preferredHeight: 50 * scaleFactor
    Layout.preferredWidth: control.width
    Layout.fillWidth: true
    color: backgroundColor

    RadioButton {
        id: control

        y: parent.height / 2 - height / 2
        Layout.fillHeight: true
        Layout.fillWidth: true

        indicator: Rectangle {
            implicitWidth: 20 * scaleFactor
            implicitHeight: 20 * scaleFactor
            x: parent.x
            y: parent.height / 2 - height / 2
            radius: 10 * scaleFactor
            border.width: 2 * scaleFactor
            border.color: control.checked ? secondaryForegroundColor : foregroundColor
            color: backgroundColor
            opacity: enabled ? 1.0 : 0.3

            Rectangle {
                visible: control.checked
                anchors.fill: parent
                anchors.margins: 5 * scaleFactor
                radius: 5 * scaleFactor
                color: secondaryForegroundColor
            }
        }

        contentItem: Text {
            id: textItem

            opacity: enabled ? 1.0 : 0.3
            color: foregroundColor

            text: qsTr("RadioButton")
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            leftPadding: control.indicator.width + control.spacing
        }
    }
}
