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
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import ArcGIS.AppFramework 1.0

import "../"

Rectangle {
    id: page

    property alias title: titleText.text

    default property alias content: content.data

    property GNSSManager gnssManager
    property StackView stackView

    // Header bar styling
    property real headerBarHeight: 50 * AppFramework.displayScaleFactor
    property real headerBarTextSize: 20 * AppFramework.displayScaleFactor
    property bool headerBarTextBold: true

    property color headerBarTextColor: "#ffffff"
    property color headerBarBackgroundColor: "#8f499c"

    property color backIconColor: headerBarTextColor
    property real backIconSize: 30 * AppFramework.displayScaleFactor
    property url backIcon: "../images/back.png"

    property color settingsIconColor: headerBarTextColor
    property real settingsIconSize: 30 * AppFramework.displayScaleFactor
    property url settingsIcon: "../images/round_settings_white_24dp.png"

    // Page styling
    property real contentMargins: 0
    property color textColor: "#303030"
    property color backgroundColor: "#f8f8f8"
    property color listBackgroundColor: "#ffffff"

    property alias topSpacingBackgroundColor: topSpacing.color
    property alias bottomSpacingBackgroundColor: bottomSpacing.color

    // Font styling
    property string fontFamily: Qt.application.font.family
    property real letterSpacing: 0
    property real helpTextLetterSpacing: 0
    property var locale: Qt.locale()
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    // set these to provide access to settings
    property bool allowSettingsAccess
    property var settingsUI

    //--------------------------------------------------------------------------

    readonly property var settingsTabContainer: settingsUI ? settingsUI.settingsTabContainer : null
    readonly property var settingsTabLocation: settingsUI ? settingsUI.settingsTabLocation : null

    readonly property real coverStatusBar: statusBarEnabled()
    readonly property bool isPortrait: width < height

    readonly property real notchHeightTop: !coverStatusBar || !isPortrait
                                           ? 0 * AppFramework.displayScaleFactor
                                           : isNotchAvailable()
                                             ? 40 * AppFramework.displayScaleFactor
                                             : 20 * AppFramework.displayScaleFactor

    readonly property real notchHeightBottom: !coverStatusBar
                                              ? 0 * AppFramework.displayScaleFactor
                                              : isNotchAvailable()
                                                ? 20 * AppFramework.displayScaleFactor
                                                : 0 * AppFramework.displayScaleFactor

    //--------------------------------------------------------------------------

    signal titlePressAndHold()
    signal backButtonPressed()
    signal settingsCogPressed()
    signal activated()
    signal deactivated()
    signal removed()

    //--------------------------------------------------------------------------

    color: backgroundColor

    //-----------------------------------------------------------------------------------
    // backbutton handling

    onActivated: {
        forceActiveFocus();
    }

    Keys.onReleased: {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
            event.accepted = true
            backButtonPressed();
        }
    }

    //--------------------------------------------------------------------------

    // prevent mouse events from filtering through to the underlying components
    MouseArea {
        anchors.fill: parent
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: topSpacing

        visible: Qt.platform.os === "ios"

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: Qt.platform.os === "ios" ? notchHeightTop : 0
        color: headerBarBackgroundColor
    }

    Rectangle {
        id: headerBar

        anchors {
            left: parent.left
            right: parent.right
            top: topSpacing.bottom
        }

        height: headerBarHeight
        color: headerBarBackgroundColor

        RowLayout {
            anchors.fill: parent

            spacing: 0

            Item {
                Layout.preferredWidth: 15 * AppFramework.displayScaleFactor
                Layout.fillHeight: true
            }

            StyledImageButton {
                id: backButton

                Layout.fillHeight: true
                Layout.preferredWidth: backIconSize
                Layout.preferredHeight: backIconSize
                Layout.alignment: Qt.AlignVCenter

                source: backIcon
                color: backIconColor
                rotation: isRightToLeft ? 180 : 0

                onClicked: {
                    backButtonPressed();
                }
            }

            AppText {
                id: titleText

                Layout.fillWidth: true
                Layout.fillHeight: true

                color: headerBarTextColor

                fontFamily: page.fontFamily
                pixelSize: page.headerBarTextSize
                minimumPixelSize: pixelSize
                letterSpacing: page.letterSpacing
                bold: page.headerBarTextBold

                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 1
                elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight

                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                MouseArea {
                    anchors.fill: parent

                    onPressAndHold: {
                        titlePressAndHold();
                    }
                }
            }

            Item {
                visible: !configButton.visible

                Layout.fillHeight: true
                Layout.preferredWidth: backIconSize
                Layout.preferredHeight: backIconSize
            }

            StyledImageButton {
                id: configButton

                visible: allowSettingsAccess && settingsUI
                enabled: visible

                Layout.fillHeight: true
                Layout.preferredHeight: settingsIconSize
                Layout.preferredWidth: settingsIconSize
                Layout.alignment: Qt.AlignVCenter

                source: settingsIcon
                color: settingsIconColor

                onClicked: {
                    settingsCogPressed();
                }
            }

            Item {
                Layout.preferredWidth: 15 * AppFramework.displayScaleFactor
                Layout.fillHeight: true
            }
        }
    }

    Item {
        id: content

        anchors {
            left: page.left
            right: page.right
            top: headerBar.bottom
            bottom: bottomSpacing.top
            margins: contentMargins
        }
    }

    Rectangle {
        id: bottomSpacing

        visible: Qt.platform.os === "ios"

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: Qt.platform.os === "ios" ? notchHeightBottom : 0
        color: backgroundColor
    }

    //--------------------------------------------------------------------------

    onBackButtonPressed: {
        if (stackView) {
            if (stackView.depth > 1) {
                stackView.pop()
            } else {
                stackView.clear()
            }
        } else {
            console.log("Error: stackView has not been set")
        }
    }

    //--------------------------------------------------------------------------

    onSettingsCogPressed: {
        if (stackView && settingsUI) {
            settingsUI.showLocationSettings(stackView, true)
        } else {
            console.log("Error: stackView and/or settingsUI have not been set")
        }
    }

    //--------------------------------------------------------------------------

    StackView.onActivated: {
        activated();
    }

    //--------------------------------------------------------------------------

    StackView.onDeactivated: {
        deactivated();
    }

    //--------------------------------------------------------------------------

    StackView.onRemoved: {
        removed();
    }

    //--------------------------------------------------------------------------

    function isNotchAvailable() {
        var unixName = AppFramework.systemInformation.unixMachine
        if (typeof unixName !== "undefined" && unixName.match(/iPhone(10|\d\d)/)) {
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

    //--------------------------------------------------------------------------

    function statusBarEnabled() {
        var app;
        var statusBar = false;

        var current = this;
        while (current.parent) {
            current = current.parent;

            if (current instanceof App) {
                app = current;
                break;
            }
        }

        if (app) {
            var appInfo = app.info.json;

            if (appInfo.hasOwnProperty("display") && appInfo.display.hasOwnProperty("statusBar")) {
                statusBar = app.info.json.display.statusBar;
            }
        }

        return statusBar;
    }

    //--------------------------------------------------------------------------
}
