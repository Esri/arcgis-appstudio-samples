import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0


Item {
    signal start()

    ColumnLayout {
        width: parent.width - 72 * scaleFactor
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0
        clip: true

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 36 * scaleFactor
        }

        Label {
            Layout.fillWidth: true
            text: strings.homepage_welcome
            font {
                weight: Font.Normal
                pixelSize: 24 * scaleFactor
            }
            color: colors.black_87
        }

        Label {
            Layout.fillWidth: true
            text: app.info.title
            font {
                weight: Font.Medium
                pixelSize: 24 * scaleFactor
            }
            color: colors.primary_color
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8 * scaleFactor
        }

        Label {
            Layout.fillWidth: true
            text: strings.homepage_app_description
            font {
                weight: Font.Normal
                pixelSize: 14 * scaleFactor
            }
            color: colors.black_54
            wrapMode: Label.Wrap
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 60 * scaleFactor
        }

        Image {
            Layout.fillWidth: true
            Layout.fillHeight: true
            source: sources.homeImage
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 62 * scaleFactor
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            topPadding: 9 * scaleFactor
            bottomPadding: topPadding
            rightPadding: 24 * scaleFactor
            leftPadding: rightPadding
            text: strings.homepage_get_start
            Material.foreground: colors.white_100
            Material.background: colors.primary_color

            font {
                weight: Font.Medium
                pixelSize: 14 * scaleFactor
            }

            onClicked: {
                start();
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 51 * scaleFactor
        }
    }
}
