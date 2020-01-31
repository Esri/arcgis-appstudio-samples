import QtQuick 2.12
import QtQuick.Controls 2.12
import ArcGIS.AppFramework 1.0
import "App"

App {
    id: app

    width: 640 * AppFramework.displayScaleFactor
    height: 480 * AppFramework.displayScaleFactor

    DocumentDialogSample {
        anchors.fill: parent
    }
}
