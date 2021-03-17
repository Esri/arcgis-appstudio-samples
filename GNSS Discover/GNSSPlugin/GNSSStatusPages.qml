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
import "./GNSSStatusPages"

Item {
    id: gnssStatusPages

    //--------------------------------------------------------------------------
    // Public properties

    // Reference to GNSSManager (required)
    property GNSSManager gnssManager

    // Reference to GNSSSettingsPages (required)
    property GNSSSettingsPages gnssSettingsPages

    // Custom StackView (optional)
    property StackView stackView

    // Allow access to settings UI
    property bool allowSettingsAccess: false

    // Data tabs to show
    property bool showData: true
    property bool showMap: true
    property bool showSkyPlot: true
    property bool showDebug: true

    //--------------------------------------------------------------------------
    // UI settings

    // Header bar styling
    property real headerBarHeight: gnssSettingsPages.headerBarHeight
    property real headerBarTextSize: gnssSettingsPages.headerBarTextSize
    property bool headerBarTextBold: gnssSettingsPages.headerBarTextBold

    property color headerBarTextColor: gnssSettingsPages.headerBarTextColor
    property color headerBarBackgroundColor: gnssSettingsPages.headerBarBackgroundColor

    property color backIconColor: gnssSettingsPages.backIconColor
    property real backIconSize: gnssSettingsPages.backIconSize
    property url backIcon: gnssSettingsPages.backIcon

    property color settingsIconColor: gnssSettingsPages.settingsIconColor
    property real settingsIconSize: gnssSettingsPages.settingsIconSize
    property url settingsIcon: gnssSettingsPages.settingsIcon

    // Page styling
    property real contentMargins: gnssSettingsPages.contentMargins

    property color textColor: gnssSettingsPages.textColor
    property color labelColor: gnssSettingsPages.helpTextColor
    property color backgroundColor: gnssSettingsPages.pageBackgroundColor
    property color listBackgroundColor: gnssSettingsPages.listBackgroundColor

    property color buttonBarBorderColor: gnssSettingsPages.pageBackgroundColor
    property color buttonBarButtonColor: gnssSettingsPages.headerBarBackgroundColor
    property color buttonBarRecordingColor: "mediumvioletred"
    property color buttonBarBackgroundColor: gnssSettingsPages.listBackgroundColor

    property color tabBarBackgroundColor: gnssSettingsPages.headerBarBackgroundColor
    property color tabBarTabBorderColor: "transparent"
    property color tabBarTabForegroundColor: gnssSettingsPages.headerBarTextColor
    property color tabBarTabBackgroundColor: "transparent"
    property color tabBarSelectedTabForegroundColor: Qt.darker(tabBarTabForegroundColor, 1.25)
    property color tabBarSelectedTabBackgroundColor: "transparent"
    property color tabBarDisabledTabColor: "grey"

    // Font styling
    property string fontFamily: gnssSettingsPages.fontFamily
    property real letterSpacing: gnssSettingsPages.letterSpacing
    property var locale: gnssSettingsPages.locale
    property bool isRightToLeft: gnssSettingsPages.isRightToLeft

    //--------------------------------------------------------------------------
    // Internal properties

    property alias nmeaLogger: nmeaLogger

    readonly property bool allowNmeaLogging: gnssSettingsPages.showAddFileProvider
    readonly property string logFileLocation: gnssSettingsPages.logFileLocation

    property bool showing

    //--------------------------------------------------------------------------

    LayoutMirroring.enabled: isRightToLeft
    LayoutMirroring.childrenInherit: isRightToLeft

    anchors.fill: parent
    z: 9999

    //--------------------------------------------------------------------------

    function showGNSSStatus(gnssStackView) {
        if (showing) {
            return;
        }

        forceActiveFocus();
        Qt.inputMethod.hide();

        if (gnssStackView) {
            stackView = gnssStackView;
        } else if (!stackView) {
            stackView = gnssStatusStackView.createObject(gnssStatusPages)
        }

        stackView.push(gnssManager.isGNSS
                       ? gnssInfoPage
                       : locationInfoPage);

        showing = true;
    }

    //--------------------------------------------------------------------------

    Component {
        id: locationInfoPage

        LocationInfoPageInternal {
            settingsUI: gnssStatusPages.gnssSettingsPages
            stackView: gnssStatusPages.stackView
            gnssManager: gnssStatusPages.gnssManager
            nmeaLogger: gnssStatusPages.nmeaLogger

            headerBarHeight: gnssStatusPages.headerBarHeight
            headerBarTextSize: gnssStatusPages.headerBarTextSize
            headerBarTextBold: gnssStatusPages.headerBarTextBold

            headerBarTextColor: gnssStatusPages.headerBarTextColor
            headerBarBackgroundColor: gnssStatusPages.headerBarBackgroundColor

            backIconColor: gnssStatusPages.backIconColor
            backIconSize: gnssStatusPages.backIconSize
            backIcon: gnssStatusPages.backIcon

            settingsIconColor: gnssStatusPages.settingsIconColor
            settingsIconSize: gnssStatusPages.settingsIconSize
            settingsIcon: gnssStatusPages.settingsIcon

            contentMargins: gnssStatusPages.contentMargins

            textColor: gnssStatusPages.textColor
            labelColor: gnssStatusPages.labelColor
            backgroundColor: gnssStatusPages.backgroundColor
            listBackgroundColor: gnssStatusPages.listBackgroundColor

            buttonBarBorderColor: gnssStatusPages.buttonBarBorderColor
            buttonBarButtonColor: gnssStatusPages.buttonBarButtonColor
            buttonBarRecordingColor: gnssStatusPages.buttonBarRecordingColor
            buttonBarBackgroundColor: gnssStatusPages.buttonBarBackgroundColor

            tabBarBackgroundColor: gnssStatusPages.tabBarBackgroundColor
            tabBarTabBorderColor: gnssStatusPages.tabBarTabBorderColor
            tabBarTabForegroundColor: gnssStatusPages.tabBarTabForegroundColor
            tabBarTabBackgroundColor: gnssStatusPages.tabBarTabBackgroundColor
            tabBarSelectedTabForegroundColor: gnssStatusPages.tabBarSelectedTabForegroundColor
            tabBarSelectedTabBackgroundColor: gnssStatusPages.tabBarSelectedTabBackgroundColor
            tabBarDisabledTabColor: gnssStatusPages.tabBarDisabledTabColor

            fontFamily: gnssStatusPages.fontFamily
            letterSpacing: gnssStatusPages.letterSpacing
            locale: gnssStatusPages.locale
            isRightToLeft: gnssStatusPages.isRightToLeft

            allowSettingsAccess: gnssStatusPages.allowSettingsAccess

            showData: gnssStatusPages.showData
            showMap: gnssStatusPages.showMap
            showSkyPlot: gnssStatusPages.showSkyPlot
            showDebug: gnssStatusPages.showDebug

            onRemoved: {
                showing = false;
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: gnssInfoPage

        LocationInfoPageGNSS {
            settingsUI: gnssStatusPages.gnssSettingsPages
            stackView: gnssStatusPages.stackView
            gnssManager: gnssStatusPages.gnssManager
            nmeaLogger: gnssStatusPages.nmeaLogger

            headerBarHeight: gnssStatusPages.headerBarHeight
            headerBarTextSize: gnssStatusPages.headerBarTextSize
            headerBarTextBold: gnssStatusPages.headerBarTextBold

            headerBarTextColor: gnssStatusPages.headerBarTextColor
            headerBarBackgroundColor: gnssStatusPages.headerBarBackgroundColor

            backIconColor: gnssStatusPages.backIconColor
            backIconSize: gnssStatusPages.backIconSize
            backIcon: gnssStatusPages.backIcon

            settingsIconColor: gnssStatusPages.settingsIconColor
            settingsIconSize: gnssStatusPages.settingsIconSize
            settingsIcon: gnssStatusPages.settingsIcon

            contentMargins: gnssStatusPages.contentMargins

            textColor: gnssStatusPages.textColor
            labelColor: gnssStatusPages.labelColor
            backgroundColor: gnssStatusPages.backgroundColor
            listBackgroundColor: gnssStatusPages.listBackgroundColor

            buttonBarBackgroundColor: gnssStatusPages.buttonBarBackgroundColor
            buttonBarBorderColor: gnssStatusPages.buttonBarBorderColor
            buttonBarButtonColor: gnssStatusPages.buttonBarButtonColor
            buttonBarRecordingColor: gnssStatusPages.buttonBarRecordingColor

            tabBarBackgroundColor: gnssStatusPages.tabBarBackgroundColor
            tabBarTabBorderColor: gnssStatusPages.tabBarTabBorderColor
            tabBarTabForegroundColor: gnssStatusPages.tabBarTabForegroundColor
            tabBarTabBackgroundColor: gnssStatusPages.tabBarTabBackgroundColor
            tabBarSelectedTabForegroundColor: gnssStatusPages.tabBarSelectedTabForegroundColor
            tabBarSelectedTabBackgroundColor: gnssStatusPages.tabBarSelectedTabBackgroundColor
            tabBarDisabledTabColor: gnssStatusPages.tabBarDisabledTabColor

            fontFamily: gnssStatusPages.fontFamily
            letterSpacing: gnssStatusPages.letterSpacing
            locale: gnssStatusPages.locale
            isRightToLeft: gnssStatusPages.isRightToLeft

            allowSettingsAccess: gnssStatusPages.allowSettingsAccess

            showData: gnssStatusPages.showData
            showMap: gnssStatusPages.showMap
            showSkyPlot: gnssStatusPages.showSkyPlot
            showDebug: gnssStatusPages.showDebug

            onRemoved: {
                showing = false;
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: gnssStatusStackView

        StackView {
            anchors.fill: parent
        }
    }

    //--------------------------------------------------------------------------

    NmeaLogger {
        id: nmeaLogger

        positionSourceManager: gnssManager.positionSourceManager
        allowLogging: gnssStatusPages.allowNmeaLogging
        logFileLocation: gnssStatusPages.logFileLocation

        onAlert: {
            gnssManager.alert(alertType);

            if (gnssManager.showAlerts) {
                gnssManager.gnssAlerts.positionSourceAlert(alertType);
            }
        }
    }

    //--------------------------------------------------------------------------
}
