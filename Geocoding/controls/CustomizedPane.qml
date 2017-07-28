import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Pane {
    id: pane
    property real radius: 2*AppFramework.displayScaleFactor

    layer.effect: OpacityMask {
        maskSource: Item {
            width: pane.width
            height: pane.height
            Rectangle {
                anchors.centerIn: parent
                width: pane.width
                height: pane.height
                radius: radius
            }
        }
    }
}
