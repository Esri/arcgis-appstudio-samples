import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

Rectangle {
    property alias control: control
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

    Switch {
        id: control

        y: parent.height / 2 - height / 2
        Layout.fillHeight: true
        Layout.fillWidth: true

        indicator: Rectangle {
            implicitWidth: 40 * scaleFactor
            implicitHeight: 16 * scaleFactor
            x: parent.x
            y: parent.height / 2 - height / 2
            radius: 8 * scaleFactor
            border.width: 2 * scaleFactor
            border.color: control.checked ? secondaryForegroundColor : foregroundColor
            color: backgroundColor
            opacity: enabled ? 1.0 : 0.3

            Rectangle {
                implicitWidth: 24 * scaleFactor
                implicitHeight: 24 * scaleFactor
                x: control.checked ? parent.width - width : 0
                y: parent.height / 2 - height / 2
                radius: 12 * scaleFactor
                border.width: 2 * scaleFactor
                border.color: control.checked ? secondaryForegroundColor : foregroundColor
                color: control.checked ? secondaryForegroundColor : secondaryBackgroundColor
            }
        }

        contentItem: Text {
            id: textItem

            opacity: enabled ? 1.0 : 0.3
            color: foregroundColor

            text: qsTr("Switch")
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            leftPadding: control.indicator.width + control.spacing
        }
    }
}
