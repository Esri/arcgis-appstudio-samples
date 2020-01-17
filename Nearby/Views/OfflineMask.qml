import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Authentication 1.0

import QtGraphicalEffects 1.0

Page {
    id: root

    background: Rectangle { color: colors.secondaryColor}

    ColumnLayout {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        Image {
            id: image

            Layout.preferredWidth: 80 * app.scaleFactor
            Layout.preferredHeight: 80 * app.scaleFactor
            Layout.alignment: Qt.AlignHCenter
            source: sources.cloudOffBlackIcon
            mipmap: true
            fillMode: Image.PreserveAspectFit
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8 * app.scaleFactor
        }

        Label {
            Layout.alignment: Qt.AlignHCenter

            text: strings.offline

            font.pixelSize: 13 * app.scaleFactor
            color: colors.subTextColor

            horizontalAlignment: Label.AlignHCenter
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8 * app.scaleFactor
        }
    }
}
