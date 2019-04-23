import QtQuick 2.9
import QtQuick.Controls 2.2

import QtGraphicalEffects 1.0

Item {
    id: root

    property real velocity: 30 * constants.scaleFactor

    onWidthChanged: {
        loader.sourceComponent = undefined;
        loader.sourceComponent = barComponent;
    }

    Loader {
        id: loader

        anchors.fill: parent
    }

    Component {
        id: barComponent

        Item {
            anchors.fill: parent

            Item {
                id: leftPart

                width: parent.width
                height: parent.height
                x: -parent.width
                y: 0

                LinearGradient {
                    anchors.fill: parent

                    start: Qt.point(0, 0)
                    end: Qt.point(parent.width, 0)

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: colors.gradient_start }
                        GradientStop { position: 1.0; color: colors.gradient_end }
                    }
                }
            }

            Item {
                id: rightPart

                width: parent.width
                height: parent.height
                x: 0
                y: 0

                LinearGradient {
                    anchors.fill: parent

                    start: Qt.point(0, 0)
                    end: Qt.point(parent.width, 0)

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: colors.gradient_end }
                        GradientStop { position: 1.0; color: colors.gradient_start }
                    }
                }
            }

            Timer {
                id: timer

                interval: 1000 / 30
                running: true
                repeat: true

                onTriggered: {
                    translatePlatform();
                }

                function translatePlatform() {
                    leftPart.x += velocity;
                    rightPart.x += velocity;

                    if (leftPart.x > parent.width)
                        leftPart.x -= 2 * parent.width;

                    if (rightPart.x > parent.width)
                        rightPart.x -= 2 * parent.width;
                }
            }
        }
    }
}
