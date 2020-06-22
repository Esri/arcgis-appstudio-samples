import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Pane {
    id: root

    property bool propagateComposedEvents: true
    property bool preventStealing: true
    property bool mouseAccepted: false
    property bool hoverAllowed: true
    property bool clickable: true
    property color defaultBackgroundColor: "#FFFFFF"
    property color backgroundColor: "#FFFFFF"
    property color borderColor: Qt.darker(backgroundColor)
    property color highlightColor: "#E0E0E0"
    property real footerHeight : root.units(40)
    property real headerHeight: root.units(50)

    property bool checked: false

    signal clicked()
    signal entered()
    signal exited()

    property Item content: Item {}
    property Item header: Item {}
    property Item footer: Item {}

    Material.elevation: 6
    Material.background: backgroundColor

    width: Math.min(parent.width, root.units(600))
    height: root.units(300)
    anchors.horizontalCenter: parent.horizontalCenter

    contentItem: Rectangle {
        id: cardContainer

        border {
            width: root.units(1)
            color: borderColor
        }
        anchors.fill: parent
        clip: true

        ColumnLayout {
            antialiasing: true
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                height: headerHeight
                color: Qt.lighter(backgroundColor)
                children: [header]
            }

            Rectangle {
                color: backgroundColor
                Layout.fillHeight: true
                Layout.fillWidth: true
                children: [content]
            }

            Rectangle {
                Layout.fillWidth: true
                height: footerHeight
                color: Qt.lighter(backgroundColor)
                children: [footer]
            }
        }
    }

    //property alias ink: ink
    Ink {
        id: ink

        visible: root.clickable
        propagateComposedEvents: root.propagateComposedEvents
        preventStealing: root.preventStealing
        anchors.centerIn: parent
        enabled: true
        centered: true
        circular: true
        hoverEnabled: root.hoverAllowed
        width: parent.width
        height: parent.height
        states: [
            State {
                name: "HOVERED"
                PropertyChanges {
                    target: root
                    backgroundColor: root.highlightColor
                }
            }
        ]

        transitions: Transition {
            ColorAnimation {
                duration: 200
            }
        }

        onClicked: {
            mouse.accepted = root.mouseAccepted
            root.state = "SELECTED"
            root.clicked()
            //console.log("CLICKED!")
        }

        onEntered: {
            ink.state = "HOVERED"
            root.entered()
            //console.log("ENTERED!")
        }

        onExited: {
            ink.state = ""
            root.exited()
        }
    }


    onCheckedChanged: {
        if (checked) {
            root.state = "SELECTED"
        } else {
            root.state = ""
        }
    }

    states: [
        State {
            name: "SELECTED"
            PropertyChanges {
                target: root
                backgroundColor: root.highlightColor

            }
        }
    ]

    transitions: Transition {
        ColorAnimation {
            duration: 200
        }
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}
