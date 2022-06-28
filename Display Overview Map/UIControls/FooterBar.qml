import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

ToolBar {
    width: parent.width
    height: footerContentColumnLayout.height
    Material.background: app.primaryColor
    clip: true

    property Item footerContent: null

    ColumnLayout {
        id: footerContentColumnLayout
        width: parent.width
        spacing: 0

        // Footer contentItem wrapper
        Item {
            id: footerContentItem

            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 20 * scaleFactor : 0
            visible: footerContent

            // Footer contentItem [Can be replaced with any footer contentItem that is passed in]
            children: footerContent
        }

        // iOS home indicator height offset
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: footerContentItem.visible ? deviceManager.bottomIndicatorHeightOffset : 0
        }
    }
}




