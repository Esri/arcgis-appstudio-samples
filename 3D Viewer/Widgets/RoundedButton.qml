import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

TouchGestureArea {
    id: root

    radius: this.width / 2

    property alias source: icon.source
    property alias iconColor: icon.color
    property alias iconRotation: icon.rotation

    property real iconSize: 24 * constants.scaleFactor

    IconImage {
        id: icon

        width: iconSize
        height: this.width
        anchors.centerIn: parent
        opacity: root.isEnabled ? 1 : 0.38
    }
}
