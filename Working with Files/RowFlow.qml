import QtQuick 2.13
import QtQuick.Layouts 1.12

Flow {
    id: flow
    Layout.fillWidth: true

    property alias leftItem: leftItem.sourceComponent
    property alias rightItem: rightItem.sourceComponent

    Loader {
        id: leftItem
    }

    Item {
        width: flow.width - leftItem.width - rightItem.width
        height: Math.max(leftItem.height, rightItem.height)
        visible: width >= 0
    }

    Loader {
        id: rightItem
    }
}
