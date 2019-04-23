import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import QtGraphicalEffects 1.0

Rectangle {
    id: root

    width: content.width
    height: content.height

    state: "Hide"

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 48 * constants.scaleFactor

    radius: 4 * constants.scaleFactor
    color: colors.black
    opacity: 0

    visible: opacity > 0

    Behavior on opacity {
        enabled: root.state === "Hide"

        NumberAnimation { duration: animationDuration }
    }

    states: [
        State {
            name: "Show";
            PropertyChanges { target: root; opacity: 0.87 }
        },
        State {
            name: "Hide";
            PropertyChanges { target: root; opacity: 0 }
        }
    ]

    property int animationDuration: 1000

    Item {
        id: content

        width: Math.min(contentColumnLayout.width, appManager.maximumScreenWidth)
        height: contentColumnLayout.height
        visible: false

        ColumnLayout {
            id: contentColumnLayout

            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16 * constants.scaleFactor
            }

            Item {
                Layout.preferredWidth: contentRowLayout.width
                Layout.preferredHeight: contentRowLayout.height

                RowLayout {
                    id: contentRowLayout

                    spacing: 0

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.preferredWidth: message.width
                        Layout.preferredHeight: message.height

                        Label {
                            id: message

                            text: ""
                            color: colors.white

                            font.family: fonts.avenirNextRegular
                            font.pixelSize: 14 * constants.scaleFactor

                            wrapMode: Label.Wrap
                            maximumLineCount: 2
                            lineHeight: 20 * constants.scaleFactor
                            lineHeightMode: Text.FixedHeight
                            elide: Text.ElideRight
                            clip: true

                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16 * constants.scaleFactor
            }
        }
    }

    DropShadow {
        anchors.fill: content
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: content
    }

    Timer {
        id: timer

        interval: animationDuration
        running: false
        repeat: false

        onTriggered: {
            hide();
        }
    }

    function hide() {
        root.state = "Hide";
    }

    function show(text) {
        message.text = text;
        root.state = "Show";
        timer.restart();
    }
}
