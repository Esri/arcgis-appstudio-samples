import QtQuick 2.9
import QtQuick.Controls 2.2

import ArcGIS.AppFramework 1.0

Item {
    id: root

    property real maximumScreenWidth: app.width > 1000 * app.scaleFactor ? 800 * app.scaleFactor : 568 * app.scaleFactor

    property bool isiPhoneX: false
    property bool isiOS: false
    property bool ismacOS: false
    property bool isWindows: false
    property bool isLinux: false
    property bool isRTL: false
    property bool isSmall: app.width <= AppFramework.displayScaleFactor * 496//AppFramework.systemInformation.family === "phone"
    property bool isLarge: !isSmall
    property real maximumCardWidth: isSmall? app.width - 48 * app.scaleFactor: 392 * app.scaleFactor
    property real maximumSmallLayoutWidth: 496 * app.scaleFactor

    signal onIsSmallChanged

    function initialize() {
        // check device
        isiPhoneX = AppFramework.systemInformation.model.indexOf("iPhone X") > -1;
        isiOS = Qt.platform.os === "ios";
        ismacOS = Qt.platform.os === "osx";
        isWindows = Qt.platform.os === "windows";
        isLinux = Qt.platform.os === "linux"
        isRTL = AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he";
    }
}
