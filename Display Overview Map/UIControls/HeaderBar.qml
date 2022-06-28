import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

ToolBar {
    width: parent.width
    height: headerContentColumnLayout.height
    Material.background: app.primaryColor
    clip:true

    property Item headerContent: null

    ColumnLayout {
        id: headerContentColumnLayout
        width: parent.width
        spacing: 0

        // iOS status bar height offset
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: headerContentItem.visible ? deviceManager.topNotchHeightOffset : 0
        }

        // Header contentItem wrapper
        Item {
            id: headerContentItem

            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 56 * scaleFactor : 0
            visible: headerContent

            // Header contentItem [Can be replaced with any header contentItem that is passed in]
            children: headerContent
        }
    }
}




