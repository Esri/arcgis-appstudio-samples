import QtQuick 2.9

Rectangle {
    anchors.fill: parent
    color: colors.transparent

    border.width: debugWidth
    border.color: debugColor

    property real debugWidth: 2
    property color debugColor: "green"
}
