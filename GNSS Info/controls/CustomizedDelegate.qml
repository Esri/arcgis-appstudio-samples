import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    width: parent.width
    height: 35 * scaleFactor

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            anchors.top: parent.top
            height: 1 * scaleFactor
            color: "lightgrey"
        }

        Row {
            anchors.fill: parent
            anchors.topMargin: 1 * scaleFactor
            Layout.fillWidth: true

            Rectangle {
                width: parent.width * 0.5
                height: parent.height
                color: "white"

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: label
                    font.pixelSize: baseFontSize * 0.9
                    color: "grey"
                }
            }

            Rectangle {
                width: parent.width * 0.5
                height: parent.height
                color: "white"

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: qualityPage[attr] || qsTr("No Data")
                    font.pixelSize: baseFontSize * 0.9
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            anchors.bottom: parent.bottom
            height: 1 * scaleFactor
            color: "lightgrey"
        }
    }
}
