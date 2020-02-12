/* Copyright 2018 Esri
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

import QtQuick 2.12
import QtQuick.Controls 2.12

import ArcGIS.AppFramework 1.0

import "../"
import "../controls"
import "../BluetoothManager"

Item {
    default property Component contentComponent

    property string title
    property string description
    property url icon

    property var settingsTabContainer
    property var settingsTabContainerComponent

    // Internal properties
    readonly property BluetoothManager bluetoothManager: settingsTabContainer.bluetoothManager
    readonly property AppDialog gnssDialog: settingsTabContainer.gnssDialog
    readonly property StackView stackView: settingsTabContainer.stackView

    readonly property color textColor: settingsTabContainer.textColor
    readonly property color backgroundColor: settingsTabContainer.backgroundColor
    readonly property color helpTextColor: settingsTabContainer.helpTextColor
    readonly property color listBackgroundColor: settingsTabContainer.listBackgroundColor

    readonly property color selectedTextColor: settingsTabContainer.selectedTextColor
    readonly property color selectedForegroundColor: settingsTabContainer.selectedForegroundColor
    readonly property color selectedBackgroundColor: settingsTabContainer.selectedBackgroundColor
    readonly property color hoverBackgroundColor: settingsTabContainer.hoverBackgroundColor

    readonly property real listDelegateHeight: settingsTabContainer.listDelegateHeight
    readonly property real listSpacing: settingsTabContainer.listSpacing

    readonly property color addProviderButtonTextColor: settingsTabContainer.addProviderButtonTextColor
    readonly property color forgetProviderButtonTextColor: settingsTabContainer.forgetProviderButtonTextColor

    readonly property color settingsIconColor: settingsTabContainer.deviceSettingsIconColor
    readonly property real settingsIconSize: settingsTabContainer.deviceSettingsIconSize
    readonly property url settingsIcon: settingsTabContainer.deviceSettingsIcon

    readonly property color nextIconColor: settingsTabContainer.nextIconColor
    readonly property real nextIconSize: settingsTabContainer.nextIconSize
    readonly property url nextIcon: settingsTabContainer.nextIcon

    readonly property color infoIconColor: settingsTabContainer.infoIconColor
    readonly property real infoIconSize: settingsTabContainer.infoIconSize

    readonly property string fontFamily: settingsTabContainer.fontFamily
    readonly property real letterSpacing: settingsTabContainer.letterSpacing
    readonly property real helpTextLetterSpacing: settingsTabContainer.helpTextLetterSpacing
    readonly property var locale: settingsTabContainer.locale
    readonly property bool isRightToLeft: settingsTabContainer.isRightToLeft

    readonly property bool showInfoIcons: settingsTabContainer.showInfoIcons

    //--------------------------------------------------------------------------

    readonly property BluetoothSettings bluetoothSettings: bluetoothManager.bluetoothSettings
    readonly property BluetoothSourceManager bluetoothSourceManager: bluetoothManager.bluetoothSourceManager
    readonly property BluetoothSourcesController controller: bluetoothSourceManager.controller

    readonly property string kDeviceTypeInternal: "Internal"
    readonly property string kDeviceTypeNetwork: "Network"
    readonly property string kDeviceTypeBluetooth: "Bluetooth"
    readonly property string kDeviceTypeBluetoothLE: "BluetoothLE"
    readonly property string kDeviceTypeSerialPort: "SerialPort"
    readonly property string kDeviceTypeUnknown: "Unknown"

    signal pushItem(var item)
    signal replaceItem(var item)
    signal titlePressAndHold()
    signal activated()
    signal deactivated()
    signal removed()

    //--------------------------------------------------------------------------

    onPushItem: {
        stackView.push(settingsTabContainerComponent, {
                           settingsTab: item,
                           title: item.title,
                           settingsComponent: item.contentComponent
                       });
    }

    //--------------------------------------------------------------------------

    onReplaceItem: {
        stackView.replace(settingsTabContainerComponent, {
                              settingsTab: item,
                              title: item.title,
                              settingsComponent: item.contentComponent
                          });
    }

    //--------------------------------------------------------------------------

    Component.onDestruction: {
        if (bluetoothSettings) {
            Qt.callLater(bluetoothSettings.write);
        }
    }

    //--------------------------------------------------------------------------
}
