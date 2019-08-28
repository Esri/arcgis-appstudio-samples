import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Authentication 1.0

import QtGraphicalEffects 1.0

import "../Widgets"
import "../Assets"

Page {
    id: root

    background: Rectangle { color: colors.secondaryColor}

    MouseArea {
        anchors.fill: parent
        preventStealing: true
    }

    ColumnLayout {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }

        Label {
            Layout.alignment: Qt.AlignHCenter

            text: strings.locationPermission

            font.pixelSize: 13 * app.scaleFactor
            color: colors.subTextColor

            horizontalAlignment: Label.AlignHCenter
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16 * app.scaleFactor
        }

        CustomRoundButton {
            Layout.preferredWidth: 72 * app.scaleFactor
            Layout.preferredHeight: 36 * app.scaleFactor
            Layout.alignment: Qt.AlignHCenter
            imageSource: sources.pinBlackIcon
            overlayColor: app.btnColor
            borderColor: app.btnColor
            isFilled: false
            title: strings.allow
            onClicked: {
                deviceManager.checkLocationAccess();
            }
        }

    }

}
