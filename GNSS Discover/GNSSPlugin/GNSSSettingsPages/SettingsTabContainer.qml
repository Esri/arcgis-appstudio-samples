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

import "../controls"

Page {
    id: settingsTabContainer

    property var settingsTab

    property alias settingsComponent: loader.sourceComponent
    property alias settingsItem: loader.item

    property color helpTextColor: textColor
    property color listBackgroundColor: "#ffffff"

    property color selectedTextColor: "#007ac2"
    property color selectedForegroundColor: selectedTextColor
    property color selectedBackgroundColor: listBackgroundColor
    property color hoverBackgroundColor: Qt.lighter(selectedForegroundColor)

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
    property url deviceSettingsIcon: "../images/round_settings_white_24dp.png"

    property color nextIconColor: selectedForegroundColor
    property real nextIconSize: 30 * AppFramework.displayScaleFactor
    property url nextIcon: "../images/next.png"

    property color infoIconColor: Qt.lighter(textColor)
    property real infoIconSize: 30 * AppFramework.displayScaleFactor

    property bool showInfoIcons: true

    Loader {
        id: loader

        anchors.fill: parent
    }

    onTitlePressAndHold: {
        if (settingsTab) {
            settingsTab.titlePressAndHold();
        }
    }

    onActivated: {
        if (settingsTab) {
            settingsTab.activated()
        }
    }

    onDeactivated: {
        if (settingsTab) {
            settingsTab.deactivated()
        }
    }

    onRemoved: {
        if (settingsTab) {
            settingsTab.removed()
        }
    }
}
