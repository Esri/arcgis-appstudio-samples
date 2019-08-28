import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Platform 1.0

Item {
    id: deviceManager

    // Device name
    property bool isiPhoneX: false
    property bool isiPhoneXS: false
    property bool isiPhoneXMax: false
    property bool isiPhoneXR: false
    property bool isiPhoneXSeries: isiPhoneX || isiPhoneXS || isiPhoneXMax || isiPhoneXR
    property bool isDesktop: false
    property bool isiPhone: false
    property bool isiPad: false
    property bool isSmall: AppFramework.systemInformation.family === "phone"
    property bool isLarge: !isSmall

    function initialize() {
        isiPhone = AppFramework.systemInformation.model.includes("iPhone");
        isiPad = AppFramework.systemInformation.model.includes("iPad");
        isiPhoneX = AppFramework.systemInformation.model.indexOf("iPhone X") > -1;
        isiPhoneXS = AppFramework.systemInformation.model.indexOf("iPhone XS") > -1;
        isiPhoneXMax = AppFramework.systemInformation.model.indexOf("iPhone XS Max") > -1;
        isiPhoneXR = AppFramework.systemInformation.model.indexOf("iPhone XR") > -1;
    }

}
