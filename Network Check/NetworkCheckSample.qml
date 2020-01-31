import QtQuick 2.7
import QtQuick.Controls 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Networking 1.0

Item {
    GridView {
//        anchors.fill: parent

        anchors {
            topMargin: 10 * AppFramework.displayScaleFactor
            leftMargin: (parent.width - Math.floor (parent.width / cellWidth) * cellWidth) / 2.0  //Make gridview appear in center of the screen
            top: parent.top
            bottom: parent.bottom;
            left: parent.left;
            right: parent.right

        }

        model: [ "Online", "LAN", "WIFI", "MobileData", "MobileDataOnly" ]

        cellWidth: 160 * AppFramework.displayScaleFactor
        cellHeight: 160 * AppFramework.displayScaleFactor

        delegate: Rectangle {
            property bool active: networkStatus["is%1".arg(modelData)]

            width: 160 * AppFramework.displayScaleFactor
            height: 160 * AppFramework.displayScaleFactor

            border {
                width: 5;
                color: "white"
            }

            color: active ? "green" : "grey"

            Text {
                anchors.centerIn: parent

                text: modelData

                color: parent.active ? "yellow": "white"
            }
        }
    }

    NetworkStatus {
        id: networkStatus
    }

    Component.onCompleted: Networking.updateConfigurations()
}
