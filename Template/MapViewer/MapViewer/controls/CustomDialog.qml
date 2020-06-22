import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

Dialog {
    id: root

    property Item content

    property bool flickable: true
    property real pageHeaderHeight: units(56)
    property real defaultMargin: units(24)

    x: 0.5 * (parent.width - width)
    y: 0.5 * (parent.height - height - pageHeaderHeight)

    topPadding: 0
    bottomPadding: 0
    topMargin: 0
    bottomMargin: 0
    closePolicy: Popup.NoAutoClose
    width: Math.min(parent.width - 2 * defaultMargin, units(400))
    height: Math.min(parent.width - 2 * defaultMargin, units(400))

    contentItem: ColumnLayout {
        antialiasing: true
        spacing: 0

        Flickable {
            interactive: flickable
            Layout.preferredHeight: parent.height
            Layout.fillWidth: true
            clip: true
            contentHeight: flickableContent.height
            ColumnLayout {
                id: flickableContent

                spacing: 0
                width: parent.width
                children: [content]
            }
        }
    }

    Component.onCompleted: {
        content.Layout.preferredWidth = Qt.binding(function () {
            return flickableContent.width
        })
    }
    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}
