import QtQuick 2.0
import QtQuick.Window 2.2

import ArcGIS.AppFramework 1.0

QtObject {
    property bool isPortrait : Screen.width < Screen.height
    property bool isIOS : Qt.platform.os === "ios"
    property int padding : isIOS ? isPortrait ? getHeightPortrait() : getHeightLandscape() : 0
    property int safeAreaMargins: Screen.orientation === 2 ? isNotchAvailable() ? 40 : 0 : 0

    function getHeightLandscape() {
        return isNotchAvailable() ? 0 : 20
    }

    function getHeightPortrait() {
        return isNotchAvailable() ? 40 : 20;
    }

    function isNotchAvailable() {
        let unixName = AppFramework.systemInformation.unixMachine;
        if (unixName.match(/iPhone(10|\d\d)/)) {
            switch(unixName) {
            case "iPhone10,1":
            case "iPhone10,4":
            case "iPhone10,2":
            case "iPhone10,5":
                return false;
            default:
                return true;
            }
        }
        return false;
    }
}
