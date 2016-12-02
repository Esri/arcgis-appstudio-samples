import QtQuick 2.2

Item {
    property alias gradient: horizontalGradient.gradient
    property int gradientDirection: Qt.LeftToRight

    Rectangle {
        id: horizontalGradient

        anchors.centerIn: parent

        width: parent.height
        height: parent.width

        rotation: gradientDirection == Qt.LeftToRight ? 270 : 90
    }
}
