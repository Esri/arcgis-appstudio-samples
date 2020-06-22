import QtQuick 2.7

import ArcGIS.AppFramework.Networking 1.0

Item {
    id: networkConfig

    property var config: toArray(Networking.configurations)

    property bool isOnline: isLAN || isWIFI || isMobileData

    property bool isLAN: config.some(isConfigActiveLAN)
    property bool isWIFI: config.some(isConfigActiveWIFI)
    property bool isMobileData: config.some(isConfigActiveMobileData)

    property bool isMobileDataOnly: isMobileData && !isWIFI && !isLAN

    function toArray(o) {
        return Object.keys(o).map(function (e) { return o[e]; } );
    }

    function isConfigActive(c) {
        return (c.state & NetworkConfiguration.StateActive) === NetworkConfiguration.StateActive;
    }

    function isConfigLAN(c) {
        if (c.bearerType === NetworkConfiguration.BearerEthernet) {
            return true;
        }

        if (Qt.platform.os === "osx") {
            return c.name === "en0";
        }

        return false;
    }

    function isConfigWIFI(c) {
        if (c.bearerType === NetworkConfiguration.BearerWLAN) {
            return true;
        }

        if (Qt.platform.os === "ios") {
            return c.name === "en0";
        }

        if (Qt.platform.os === "osx") {
            return c.name === "awdl0";
        }

        return false;
    }

    function isConfigMobileData(c) {
        switch (c.bearerType) {
        case NetworkConfiguration.Bearer2G:
        case NetworkConfiguration.BearerCDMA2000:
        case NetworkConfiguration.BearerWCDMA:
        case NetworkConfiguration.BearerHSPA:
        case NetworkConfiguration.BearerWiMAX:
        case NetworkConfiguration.BearerEVDO:
        case NetworkConfiguration.BearerLTE:
        case NetworkConfiguration.Bearer3G:
        case NetworkConfiguration.Bearer4G:
            return true;
        }

        if (Qt.platform.os === "ios") {
            return c.name === "pdp_ip0";
        }

        return false;
    }

    function isConfigActiveLAN(c) {
        return isConfigActive(c) && isConfigLAN(c);
    }

    function isConfigActiveWIFI(c) {
        return isConfigActive(c) && isConfigWIFI(c);
    }

    function isConfigActiveMobileData(c) {
        return isConfigActive(c) && isConfigMobileData(c);
    }

    function update() {
        Networking.updateConfigurations();
    }
}
