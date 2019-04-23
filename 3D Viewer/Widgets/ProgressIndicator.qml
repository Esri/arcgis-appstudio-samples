import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    id: root

    property color color: colors.white

    property bool isMasked: true

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        visible: isMasked && root.visible
    }

    BusyIndicator {
        anchors.centerIn: parent
        Material.accent: color
        running: root.visible
    }
}
