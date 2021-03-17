/* Copyright 2021 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.15
import QtQuick.Controls 2.15

import ArcGIS.AppFramework 1.0

import "./controls"
import "./GNSSManager"
import "./GNSSSettingsPages"

Item {
    id: gnssSettingsPages

    //--------------------------------------------------------------------------
    // Public properties

    // Reference to GNSSManager (required)
    property GNSSManager gnssManager

    // Custom StackView (optional)
    property StackView stackView

    //--------------------------------------------------------------------------
    // UI settings

    property string title: qsTr("Location Providers")

    // Header bar styling
    property real headerBarHeight: 50 * AppFramework.displayScaleFactor
    property real headerBarTextSize: 20 * AppFramework.displayScaleFactor
    property bool headerBarTextBold: true

    property color headerBarTextColor: "#ffffff"
    property color headerBarBackgroundColor: "#8f499c"

    property color backIconColor: headerBarTextColor
    property real backIconSize: 30 * AppFramework.displayScaleFactor
    property url backIcon: "./images/back.png"

    property color settingsIconColor: headerBarTextColor
    property real settingsIconSize: 30 * AppFramework.displayScaleFactor
    property url settingsIcon: "./images/round_settings_white_24dp.png"

    // Page styling
    property real contentMargins: 0

    property color textColor: "#303030"
    property color helpTextColor: textColor
    property color pageBackgroundColor: "#efefef"
    property color listBackgroundColor: "#ffffff"

    property color selectedTextColor: headerBarBackgroundColor
    property color selectedForegroundColor: selectedTextColor
    property color selectedBackgroundColor: listBackgroundColor
    property color hoverBackgroundColor: Qt.lighter(Qt.lighter(selectedForegroundColor))

    property real listDelegateHeightTextBox: 60 * AppFramework.displayScaleFactor
    property real listDelegateHeightMultiLine: 60 * AppFramework.displayScaleFactor
    property real listDelegateHeightSingleLine: 60 * AppFramework.displayScaleFactor
    property real listSpacing: 2 * AppFramework.displayScaleFactor

    // Button styling
    property color addProviderButtonTextColor: selectedTextColor
    property color forgetProviderButtonTextColor: selectedTextColor

    // Icon styling
    property color deviceSettingsIconColor: Qt.lighter(textColor)
    property real deviceSettingsIconSize: 30 * AppFramework.displayScaleFactor
    property url deviceSettingsIcon: "./images/round_settings_white_24dp.png"

    property color nextIconColor: selectedForegroundColor
    property real nextIconSize: 30 * AppFramework.displayScaleFactor
    property url nextIcon: "./images/next.png"

    property color infoIconColor: Qt.lighter(textColor)
    property real infoIconSize: 30 * AppFramework.displayScaleFactor

    // Font styling
    property string fontFamily: Qt.application.font.family
    property real letterSpacing: 0
    property real helpTextLetterSpacing: 0
    property var locale: Qt.locale()
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    // Show various "Add Provider" buttons (if supported by the platform)
    property bool showAddUSBProvider: true
    property bool showAddNetworkProvider: true
    property bool showAddFileProvider: true

    // Show info icons in the device setting tabs
    property bool showInfoIcons: true

    // Device setting tabs to show
    property bool showAboutDevice: true
    property bool showAlerts: true
    property bool showAntennaHeight: true
    property bool showAltitude: true
    property bool showAccuracy: true

    // Alert style settings to show
    property bool showAlertsVisual: true
    property bool showAlertsSpeech: true
    property bool showAlertsVibrate: true
    property bool showAlertsTimeout: false

    // Show provider alias if available
    property bool showProviderAlias: true

    //--------------------------------------------------------------------------
    // Internal properties

    property string logFileLocation: AppFramework.userHomePath + "/ArcGIS/" + Qt.application.name + "/Logs/"

    property var settingsTabLocation
    property var settingsTabContainer

    property bool showing

    //--------------------------------------------------------------------------

    LayoutMirroring.enabled: isRightToLeft
    LayoutMirroring.childrenInherit: isRightToLeft

    anchors.fill: parent
    z: 9999

    //-------------------------------------------------------------------------

    function showLocationSettings(settingsStackView, replace) {
        if (showing) {
            return;
        }

        forceActiveFocus();
        Qt.inputMethod.hide();

        if (settingsStackView) {
            stackView = settingsStackView;
        } else if (!stackView) {
            stackView = settingsTabStackView.createObject(gnssSettingsPages)
        }

        if (!settingsTabLocation) {
            settingsTabContainer = settingsTabContainerComponent.createObject(stackView);
            settingsTabLocation = settingsTabLocationComponent.createObject(stackView, {
                                           settingsTabContainer: settingsTabContainer,
                                           settingsTabContainerComponent: settingsTabContainerComponent
                                         });
        }

        if (replace) {
            stackView.replace(settingsTabContainer, {
                               settingsTab: settingsTabLocation,
                               title: settingsTabLocation.title,
                               settingsComponent: settingsTabLocation.contentComponent
                           });
        } else {
            stackView.push(settingsTabContainer, {
                               settingsTab: settingsTabLocation,
                               title: settingsTabLocation.title,
                               settingsComponent: settingsTabLocation.contentComponent
                           });
        }

        showing = true;
    }

    //--------------------------------------------------------------------------

    Component {
        id: settingsTabLocationComponent

        SettingsTabLocation {
            title: gnssSettingsPages.title

            showAddUSBProvider: gnssSettingsPages.showAddUSBProvider
            showAddNetworkProvider: gnssSettingsPages.showAddNetworkProvider
            showAddFileProvider: gnssSettingsPages.showAddFileProvider

            showAboutDevice: gnssSettingsPages.showAboutDevice
            showAlerts: gnssSettingsPages.showAlerts
            showAntennaHeight: gnssSettingsPages.showAntennaHeight
            showAltitude: gnssSettingsPages.showAltitude
            showAccuracy: gnssSettingsPages.showAccuracy

            showAlertsVisual: gnssSettingsPages.showAlertsVisual
            showAlertsSpeech: gnssSettingsPages.showAlertsSpeech
            showAlertsVibrate: gnssSettingsPages.showAlertsVibrate
            showAlertsTimeout: gnssSettingsPages.showAlertsTimeout

            showProviderAlias: gnssSettingsPages.showProviderAlias

            logFileLocation: gnssSettingsPages.logFileLocation

            anchors.fill: parent

            onRemoved: {
                gnssSettingsPages.settingsTabLocation.destroy();
                gnssSettingsPages.settingsTabLocation = null;

                gnssSettingsPages.settingsTabContainer.destroy();
                gnssSettingsPages.settingsTabContainer = null;

                showing = false;
            }
        }
    }

    //-------------------------------------------------------------------------

    Component {
        id: settingsTabContainerComponent

        SettingsTabContainer {
            settingsUI: gnssSettingsPages
            stackView: gnssSettingsPages.stackView
            gnssManager: gnssSettingsPages.gnssManager

            headerBarHeight: gnssSettingsPages.headerBarHeight
            headerBarTextSize: gnssSettingsPages.headerBarTextSize
            headerBarTextBold: gnssSettingsPages.headerBarTextBold

            headerBarTextColor: gnssSettingsPages.headerBarTextColor
            headerBarBackgroundColor: gnssSettingsPages.headerBarBackgroundColor

            backIconColor: gnssSettingsPages.backIconColor
            backIconSize: gnssSettingsPages.backIconSize
            backIcon: gnssSettingsPages.backIcon

            settingsIconColor: gnssSettingsPages.settingsIconColor
            settingsIconSize: gnssSettingsPages.settingsIconSize
            settingsIcon: gnssSettingsPages.settingsIcon

            contentMargins: gnssSettingsPages.contentMargins

            textColor: gnssSettingsPages.textColor
            backgroundColor: gnssSettingsPages.pageBackgroundColor
            helpTextColor: gnssSettingsPages.helpTextColor
            listBackgroundColor: gnssSettingsPages.listBackgroundColor

            selectedTextColor: gnssSettingsPages.selectedTextColor
            selectedForegroundColor: gnssSettingsPages.selectedForegroundColor
            selectedBackgroundColor: gnssSettingsPages.selectedBackgroundColor
            hoverBackgroundColor: gnssSettingsPages.hoverBackgroundColor

            listDelegateHeightTextBox: gnssSettingsPages.listDelegateHeightTextBox
            listDelegateHeightMultiLine: gnssSettingsPages.listDelegateHeightMultiLine
            listDelegateHeightSingleLine: gnssSettingsPages.listDelegateHeightSingleLine
            listSpacing: gnssSettingsPages.listSpacing

            addProviderButtonTextColor: gnssSettingsPages.addProviderButtonTextColor
            forgetProviderButtonTextColor: gnssSettingsPages.forgetProviderButtonTextColor

            deviceSettingsIconColor: gnssSettingsPages.deviceSettingsIconColor
            deviceSettingsIconSize: gnssSettingsPages.deviceSettingsIconSize
            deviceSettingsIcon: gnssSettingsPages.deviceSettingsIcon

            nextIconColor: gnssSettingsPages.nextIconColor
            nextIconSize: gnssSettingsPages.nextIconSize
            nextIcon: gnssSettingsPages.nextIcon

            infoIconColor: gnssSettingsPages.infoIconColor
            infoIconSize: gnssSettingsPages.infoIconSize

            fontFamily: gnssSettingsPages.fontFamily
            letterSpacing: gnssSettingsPages.letterSpacing
            helpTextLetterSpacing: gnssSettingsPages.helpTextLetterSpacing
            locale: gnssSettingsPages.locale
            isRightToLeft: gnssSettingsPages.isRightToLeft

            showInfoIcons: gnssSettingsPages.showInfoIcons
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: settingsTabStackView

        StackView {
            anchors.fill: parent
        }
    }

    //--------------------------------------------------------------------------
}
