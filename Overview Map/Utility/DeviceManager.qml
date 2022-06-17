/*
* File that provides all device specific functionalities based on OS, screen size, display type.
* Provides contants for UI elements such as margins, sizing and padding that can be uniformly used across the app.
*/
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.Window 2.12

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Platform 1.0

Item {
    id: deviceManager

    // OS-specific, device-specific constants
    readonly property bool isiPhoneXSeries: isiOS && checkIfNotchAvailable()
    readonly property bool isDesktop: false
    readonly property bool isTablet: ( Math.max(app.width, app.height) > 1000 *deviceManager.scaleFactor ) || ( AppFramework.systemInformation.family === "tablet" )
    readonly property bool isAndroid: Qt.platform.os === "android"
    readonly property bool isiOS: Qt.platform.os === "ios"
    readonly property bool isOnline: Networking.isOnline
    readonly property bool isPortrait: app.width < app.height || Screen.orientation === Qt.PortraitOrientation || Screen.orientation === Qt.InvertedPortraitOrientation
    readonly property bool isHomeIndicatorAvailable: isiPhoneXSeries || checkIfHomeIndicatorAvailable()
    readonly property bool isCompact: app.width <= compactThreshold || app.height <= compactThreshold
    readonly property bool isMidsized: (app.width > compactThreshold) && (app.width <= 800)
    readonly property bool isLarge: !isCompact && !isMidsized
    readonly property bool isLandscape: app.width > app.height
    readonly property bool isMobile: ( Qt.platform.os === "ios") || ( Qt.platform.os === "android")
    readonly property bool isSmallScreen: (width || height) < 400 *deviceManager.scaleFactor

    // Sizing constants - margins, padding, offsets
    readonly property real scaleFactor: AppFramework.displayScaleFactor
    readonly property int  baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isCompact ? 0 : 3)
    readonly property real baseUnit: 8 *deviceManager.scaleFactor
    readonly property real defaultMargin: 2 * baseUnit
    readonly property real maximumScreenWidth: app.width > 1000 *deviceManager.scaleFactor ? 800 *deviceManager.scaleFactor : 568 *deviceManager.scaleFactor
    readonly property real compactThreshold: 496 *deviceManager.scaleFactor
    readonly property int headerHeight: 56 *deviceManager.scaleFactor
    readonly property int footerHeight: 20 *deviceManager.scaleFactor
    readonly property real topNotchHeightOffset: isiOS ? (isPortrait ? getHeightPortrait() : getHeightLandscape()) : 0
    readonly property real bottomIndicatorHeightOffset: checkIfHomeIndicatorAvailable() ? 16 *deviceManager.scaleFactor : 0

    readonly property string primaryColor: "#8f499c"

    /*
    * @desc => Return the height offset for device in landscape mode based on whether notch is present or not
    */
    function getHeightLandscape() {
        return checkIfNotchAvailable() ? 0 : 20 *deviceManager.scaleFactor
    }

    /*
    * @desc => Return the height offset for device in portrait mode based on whether notch is present or not
    */
    function getHeightPortrait() {
        return checkIfNotchAvailable() ? 40 *deviceManager.scaleFactor : 20 *deviceManager.scaleFactor
    }

    /*
    * @desc => Check if the current device is a desktop
    */
    function checkIfDesktop() {
        isDesktop = Qt.platform.os === "windows" || Qt.platform.os === "osx";
    }

    /*
    * @desc => Check if the top notch is present in the current device (iPad or iOSX)
    */
    function checkIfNotchAvailable() {
        let unixName;

        if ( AppFramework.systemInformation.hasOwnProperty("unixMachine") )
            unixName = AppFramework.systemInformation.unixMachine;

        if ( typeof unixName === "undefined" )
            return false

        if ( unixName.match(/iPhone(10|\d\d)/) ) {
            switch(unixName) {
            case "iPhone10,1":
            case "iPhone10,4":
            case "iPhone10,2":
            case "iPhone10,5":
                return false;

            default: //iPhone10,3 and iPhone10, 6 refer to iPhone X
                return true;
            }
        }

        //iPhone XS, XS Max, XR
        if ( unixName.match(/iPhone(11|\d\d)/) ) {
            return true;
        }

        if ( unixName.match(/iPhone(12|\d\d)/) || unixName.match(/iPhone(13|\d\d)/)) {
            switch(unixName) {
                //iPhone SE 2nd Gen
            case "iPhone12,8":
                return false;

                //iPhone 12, iPhone 12 Pro, iPhone 12 Pro Max, iPhone 13
            default:
                return true;
            }
        }

        return false;
    }

    /*
    * @desc => Check if the bottom home indicator is present in the current device (iPad or iOSX)
    */
    function checkIfHomeIndicatorAvailable(){
        let unixName;

        if ( AppFramework.systemInformation.hasOwnProperty("unixMachine") ){
            unixName = AppFramework.systemInformation.unixMachine;
        }

        // ipad pro 11 inch, ipad pro 12.9 inch
        if ( unixName.match(/iPad(8|\d\d)/) ){
            return true;
        }

        if ( unixName.match(/iPad(13|\d\d)/) ){
            switch(unixName) {
                //iPad air 4th gen
            case "iPad13,1":
            case "iPad13,2":
                return true;

            default:
                return false;
            }
        }

        if ( Qt.platform.os === "ios" ) {
            switch(unixName){
                //iPhone X
            case "iPhone10,3":
            case "iPhone10,6":
                //iPhone XS, XR
            case "iPhone11,2":
            case "iPhone11,4":
            case "iPhone11,6":
            case "iPhone11,8":
                //iPhone 11
            case "iPhone12,1":
            case "iPhone12,3":
            case "iPhone12,5":
                //iPhone 12
            case "iPhone13,1":
            case "iPhone13,2":
            case "iPhone13,3":
            case "iPhone13,4":
                return true;
            }
        }

        return false;
    }

    /*
    * @desc => Sets the appropriate theme for Status bar in iOS devices
    */
    function setStatusBar() {
        if ( StatusBar.supported ) {
            StatusBar.visible = true;
            if ( isiOS )
                StatusBar.color = "transparent";

            if ( isAndroid )
                StatusBar.color = primaryColor;
        }
    }
}
