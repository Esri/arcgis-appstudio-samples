import QtQuick 2.9
import QtQuick.Controls 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Rectangle {
    id: root

    property color shadowColor: colors.white

    property bool isPressed: this.state === "Pressed"
    property bool isEnabled: true

    property real normalOpacity: 0.0
    property real pressOpacity: 0.12

    property alias bottomLayer: bottomLayer

    signal clicked()

    Item {
        id: bottomLayer

        anchors.fill: parent
    }

    Rectangle {
        id: background

        anchors.fill: parent
        radius: root.radius
        color: shadowColor
        opacity: 0
    }

    states: [
        State {
            name: "Pressed"
            PropertyChanges {
                target: background
                opacity: pressOpacity
            }
        }
    ]

    transitions: [
        Transition {
            from: ""; to: "Pressed"
            OpacityAnimator {
                duration: constants.normalDuration
            }
        }
    ]

    MouseArea {
        anchors.fill: parent

        onPressed: {
            if (root.isEnabled)
                root.state = "Pressed";
        }

        onReleased: {
            if (root.isEnabled)
                root.state = "";
        }

        onClicked: {
            if (root.isEnabled)
                root.clicked();
        }

        onCanceled: {
            if (root.isEnabled)
                root.state = "";
        }
    }
}
