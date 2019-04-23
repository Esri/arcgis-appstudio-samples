import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import "../../Widgets" as Widgets

Rectangle {
    id: root

    width: app.width
    height: app.height
    x: 0
    y: 0
    color: colors.black
    opacity: 0.54
    visible: false

    property string title: ""

    property real maximumHeight: 0

    property color sheetColor: colors.white

    MouseArea {
        anchors.fill: parent

        onClicked: {
            close();
        }
    }

    Pane {
        id: pane

        width: Math.min(parent.width, appManager.maximumScreenWidth)
        height: Math.min(sheetColumn.height, maximumHeight)

        Material.elevation: this.state === "Idle" ? 0 : 16
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        state: "Idle"
        padding: 0

        background: Rectangle {
            anchors.fill: parent
            color: sheetColor
        }

        transitions: Transition {
            AnchorAnimation { easing.type: Easing.OutQuart; duration: constants.normalDuration }
        }

        states: [
            State {
                name: "Idle"
                AnchorChanges { target: pane; anchors { top: parent.bottom; bottom: undefined }}
            },
            State {
                name: "Show"
                AnchorChanges { target: pane; anchors { top: undefined; bottom: parent.bottom }}
            }
        ]

        Flickable {
            id: flickable

            anchors.fill: parent
            contentWidth: sheetColumn.width
            contentHeight: sheetColumn.height
            flickableDirection: Flickable.VerticalFlick
            interactive: sheetColumn.height > maximumHeight
            clip: true

            ColumnLayout {
                id: sheetColumn

                width: flickable.width
                spacing: 0

                Label {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56 * constants.scaleFactor

                    text: title
                    font.pixelSize: 16 * constants.scaleFactor
                    font.family: fonts.avenirNextDemi
                    color: colors.black
                    clip: true
                    elide: Text.ElideRight
                    visible: title > ""

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter

                    leftPadding: 16 * constants.scaleFactor
                    rightPadding: 16 * constants.scaleFactor
                }

                Repeater {
                    id: repeater

                    model: ListModel {}

                    delegate: Widgets.TouchGestureArea {
                        id: delegate

                        Layout.fillWidth: true
                        Layout.preferredHeight: 48 * constants.scaleFactor
                        color: colors.white

                        onClicked: {

                        }
                    }
                }
            }
        }
    }

    Timer {
        id: timer

        interval: constants.normalDuration
        running: false
        repeat: false

        onTriggered: root.visible = false;
    }

    function open() {
        root.visible = true;
    }

    function close() {
        timer.start();
    }
}
