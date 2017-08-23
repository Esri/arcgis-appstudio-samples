import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

ColumnLayout {
    property string name
    property alias value: slider.value
    property alias minimumValue: slider.from
    property alias maximumValue: slider.to

    Text {
        id: label
        Layout.fillWidth: true
        text: "%1 %2".arg(name).arg(value)
    }

    Slider {
        id: slider
        Layout.fillWidth: true
        Layout.leftMargin: 10 * AppFramework.displayScaleFactor
        Layout.rightMargin: Layout.leftMargin
        from: 0
        to: 100
        stepSize: 1
        Material.accent: "#8f499c"

    }
}
