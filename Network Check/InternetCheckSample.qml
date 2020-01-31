import QtQuick 2.7
import QtQuick.Controls 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Networking 1.0

Item {
    GridView {
        anchors.fill: parent
        anchors.margins: 10 * AppFramework.displayScaleFactor

        model: [ "Online", "LAN", "WIFI", "MobileData", "MobileDataOnly" ]

        cellWidth: 160 * AppFramework.displayScaleFactor
        cellHeight: 160 * AppFramework.displayScaleFactor

        delegate: Rectangle {
            property bool active: internetStatus["is%1".arg(modelData)]

            width: 144 * AppFramework.displayScaleFactor
            height: 144 * AppFramework.displayScaleFactor

            color: active ? "green" : "grey"

            Text {
                anchors.centerIn: parent

                text: modelData

                color: parent.active ? "yellow": "white"
            }
        }
    }

    InternetStatus {
        id: internetStatus
    }

    Component.onCompleted: Networking.updateConfigurations()
}
