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
import "./BluetoothManager"
import "./BluetoothSettingsPages"

Item {
    id: bluetoothSettingsPages

    //--------------------------------------------------------------------------
    // Public properties

    // Reference to BluetoothManager (required)
    property BluetoothManager bluetoothManager

    // Custom StackView (optional)
    property StackView stackView

    //--------------------------------------------------------------------------
    // UI settings

    property string title: qsTr("Printers")

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
    property color backgroundColor: "#efefef"
    property color helpTextColor: textColor
    property color listBackgroundColor: "#ffffff"

    property color selectedTextColor: headerBarBackgroundColor
    property color selectedForegroundColor: selectedTextColor
    property color selectedBackgroundColor: listBackgroundColor
    property color hoverBackgroundColor: Qt.lighter(Qt.lighter(selectedForegroundColor))

    property real listDelegateHeight: 60 * AppFramework.displayScaleFactor
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

    // Show info icons in the device setting tabs
    property bool showInfoIcons: true

    // Device setting tabs to show
    property bool showAboutDevice: true

    //--------------------------------------------------------------------------
    // Internal properties

    readonly property AppDialog gnssDialog: bluetoothManager.gnssDialog

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
            stackView = settingsTabStackView.createObject(bluetoothSettingsPages)
        }

        if (!settingsTabLocation) {
            settingsTabContainer = settingsTabContainerComponent.createObject(bluetoothSettingsPages);
            settingsTabLocation = settingsTabLocationComponent.createObject(bluetoothSettingsPages, {
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
            title: bluetoothSettingsPages.title

            showAboutDevice: bluetoothSettingsPages.showAboutDevice

            anchors.fill: parent

            onRemoved: {
                bluetoothSettingsPages.settingsTabLocation.destroy();
                bluetoothSettingsPages.settingsTabLocation = null;

                bluetoothSettingsPages.settingsTabContainer.destroy();
                bluetoothSettingsPages.settingsTabContainer = null;

                showing = false;
            }
        }
    }

    //-------------------------------------------------------------------------

    Component {
        id: settingsTabContainerComponent

        SettingsTabContainer {
            settingsUI: bluetoothSettingsPages
            stackView: bluetoothSettingsPages.stackView
            bluetoothManager: bluetoothSettingsPages.bluetoothManager
            gnssDialog: bluetoothSettingsPages.gnssDialog

            headerBarHeight: bluetoothSettingsPages.headerBarHeight
            headerBarTextSize: bluetoothSettingsPages.headerBarTextSize
            headerBarTextBold: bluetoothSettingsPages.headerBarTextBold

            headerBarTextColor: bluetoothSettingsPages.headerBarTextColor
            headerBarBackgroundColor: bluetoothSettingsPages.headerBarBackgroundColor

            backIconColor: bluetoothSettingsPages.backIconColor
            backIconSize: bluetoothSettingsPages.backIconSize
            backIcon: bluetoothSettingsPages.backIcon

            settingsIconColor: bluetoothSettingsPages.settingsIconColor
            settingsIconSize: bluetoothSettingsPages.settingsIconSize
            settingsIcon: bluetoothSettingsPages.settingsIcon

            contentMargins: bluetoothSettingsPages.contentMargins

            textColor: bluetoothSettingsPages.textColor
            backgroundColor: bluetoothSettingsPages.backgroundColor
            helpTextColor: bluetoothSettingsPages.helpTextColor
            listBackgroundColor: bluetoothSettingsPages.listBackgroundColor

            selectedTextColor: bluetoothSettingsPages.selectedTextColor
            selectedForegroundColor: bluetoothSettingsPages.selectedForegroundColor
            selectedBackgroundColor: bluetoothSettingsPages.selectedBackgroundColor
            hoverBackgroundColor: bluetoothSettingsPages.hoverBackgroundColor

            listDelegateHeight: bluetoothSettingsPages.listDelegateHeight
            listSpacing: bluetoothSettingsPages.listSpacing

            addProviderButtonTextColor: bluetoothSettingsPages.addProviderButtonTextColor
            forgetProviderButtonTextColor: bluetoothSettingsPages.forgetProviderButtonTextColor

            deviceSettingsIconColor: bluetoothSettingsPages.deviceSettingsIconColor
            deviceSettingsIconSize: bluetoothSettingsPages.deviceSettingsIconSize
            deviceSettingsIcon: bluetoothSettingsPages.deviceSettingsIcon

            nextIconColor: bluetoothSettingsPages.nextIconColor
            nextIconSize: bluetoothSettingsPages.nextIconSize
            nextIcon: bluetoothSettingsPages.nextIcon

            infoIconColor: bluetoothSettingsPages.infoIconColor
            infoIconSize: bluetoothSettingsPages.infoIconSize

            fontFamily: bluetoothSettingsPages.fontFamily
            letterSpacing: bluetoothSettingsPages.letterSpacing
            helpTextLetterSpacing: bluetoothSettingsPages.helpTextLetterSpacing
            locale: bluetoothSettingsPages.locale
            isRightToLeft: bluetoothSettingsPages.isRightToLeft

            showInfoIcons: bluetoothSettingsPages.showInfoIcons
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
