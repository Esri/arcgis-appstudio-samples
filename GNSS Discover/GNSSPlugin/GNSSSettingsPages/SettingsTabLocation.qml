/* Copyright 2020 Esri
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

import QtQml 2.2
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Platform 1.0

import "../controls"

SettingsTab {
    id: settingsTabLocation

    title: qsTr("Location providers")

    //--------------------------------------------------------------------------
    // Settings configuration

    // Show various "Add Provider" buttons (if supported by the platform)
    property bool showAddUSBProvider: true
    property bool showAddNetworkProvider: true
    property bool showAddFileProvider: true

    // Settings tabs to show in the detailed device configuration settings
    property bool showAboutDevice: true
    property bool showAlerts: true
    property bool showAntennaHeight: true
    property bool showAltitude: true
    property bool showAccuracy: true

    // Alert types to show in the alerts settings
    property bool showAlertsVisual: true
    property bool showAlertsSpeech: true
    property bool showAlertsVibrate: true
    property bool showAlertsTimeout: false

    // Show provider alias if available
    property bool showProviderAlias: true

    //--------------------------------------------------------------------------
    // Internal properties

    readonly property Device currentDevice: controller.currentDevice
    readonly property string currentNmeaLogFile: controller.nmeaLogFile
    readonly property string currentNetworkAddress: controller.currentNetworkAddress

    readonly property bool isConnecting: controller.isConnecting
    readonly property bool isConnected: controller.isConnected

    readonly property bool showDetailedSettingsCog: showAboutDevice || showAlerts || showAntennaHeight || showAltitude || showAccuracy
    readonly property bool showAddUSB: !(Qt.platform.os === "ios" || Qt.platform.os === "android") && showAddUSBProvider

    property string logFileLocation: AppFramework.userHomePath + "/ArcGIS/" + Qt.application.name

    property var _addDeviceTab
    property var _addNetworkTab
    property var _addNMEALogTab
    property bool _dirty: true

    signal selectInternal()

    //--------------------------------------------------------------------------

    Item {
        id: _item

        anchors.fill: parent
        Accessible.role: Accessible.Pane

        //----------------------------------------------------------------------

        Component.onCompleted: {
            controller.onSettingsPage = true;

            if (Qt.platform.os === "ios") {
                // On iOS this brings up a dialog notifying the user that Bluetooth
                // needs to be enabled to connect to external accessories
                Permission.serviceStatus(Permission.BluetoothService)
            }
        }

        //----------------------------------------------------------------------

        Component.onDestruction: {
            controller.onSettingsPage = false;
        }

        //----------------------------------------------------------------------

        Connections {
            target: settingsTabLocation

            onActivated: {
                if (_dirty) {
                    _item.createListTabView(gnssSettings.knownDevices);
                    _dirty = false;
                }
            }
        }

        //----------------------------------------------------------------------

        Connections {
            target: gnssSettings

            onReceiverAdded: {
                _item.addDeviceListTab(name, gnssSettings.knownDevices)
                sortedListTabView.sort();
                _dirty = true;
            }

            onReceiverRemoved: {
                _dirty = true;
            }
        }

        //----------------------------------------------------------------------

        ListModel {
            id: cachedReceiversListModel
        }

        //----------------------------------------------------------------------

        ScrollView {
            anchors.fill: parent
            clip: true

            ScrollBar.vertical.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                anchors.fill: parent

                spacing: settingsTabLocation.listSpacing

                Accessible.role: Accessible.Pane

                // -----------------------------------------------------------------

                SortedListTabView {
                    id: sortedListTabView

                    Layout.fillWidth: true
                    Layout.preferredHeight: listTabView.contentHeight
                    Layout.maximumHeight: _item.height / 2

                    backgroundColor: settingsTabLocation.backgroundColor
                    listSpacing: settingsTabLocation.listSpacing

                    delegate: deviceListDelegate

                    onSelected: pushItem(item)

                    lessThan: function(left, right) {
                        switch (left.deviceType) {
                        case kDeviceTypeInternal:
                            return true;
                        case kDeviceTypeBluetooth:
                        case kDeviceTypeBluetoothLE:
                        case kDeviceTypeNetwork:
                        case kDeviceTypeSerialPort:
                        case kDeviceTypeFile:
                        case kDeviceTypeUnknown:
                        default:
                            if (right.deviceType === kDeviceTypeInternal) {
                                return false;
                            }

                            return left.deviceLabel.localeCompare(right.deviceLabel) < 0 ? true : false;
                        }
                    }
                }

                // -----------------------------------------------------------------

                Item {
                    visible: !settingsTabLocation.showAddUSB && !settingsTabLocation.showAddNetworkProvider && !settingsTabLocation.showAddFileProvider

                    Layout.fillWidth: true
                    Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
                }

                // -----------------------------------------------------------------

                // only support classic Bluetooth receivers on iOS and Android
                PlainButton {
                    visible: !settingsTabLocation.showAddUSB && !settingsTabLocation.showAddNetworkProvider && !settingsTabLocation.showAddFileProvider

                    Layout.preferredWidth: settingsTabLocation.width
                    Layout.preferredHeight: settingsTabLocation.listDelegateHeight

                    text: qsTr("Add provider")

                    horizontalAlignment: isRightToLeft ? Label.AlignRight : Label.AlignLeft

                    textColor: settingsTabLocation.addProviderButtonTextColor
                    pressedTextColor: settingsTabLocation.textColor
                    hoveredTextColor: settingsTabLocation.textColor
                    backgroundColor: settingsTabLocation.listBackgroundColor
                    pressedBackgroundColor: settingsTabLocation.hoverBackgroundColor
                    hoveredBackgroundColor: settingsTabLocation.hoverBackgroundColor

                    nextIconColor: settingsTabLocation.nextIconColor
                    nextIconSize: settingsTabLocation.nextIconSize
                    nextIcon: settingsTabLocation.nextIcon
                    showNextIcon: true

                    infoIconColor: settingsTabLocation.nextIconColor
                    infoIconSize: settingsTabLocation.infoIconSize
                    showInfoIcon: settingsTabLocation.showInfoIcons

                    fontFamily: settingsTabLocation.fontFamily
                    letterSpacing: settingsTabLocation.letterSpacing
                    isRightToLeft: settingsTabLocation.isRightToLeft

                    onClicked: {
                        positionSourceManager.discoverBluetooth = true;
                        positionSourceManager.discoverBluetoothLE = false;
                        positionSourceManager.discoverSerialPort = false;

                        if (!_addDeviceTab) {
                            _addDeviceTab = addDeviceTab.createObject(_item);
                        }

                        pushItem(_addDeviceTab);
                    }
                }

                // -----------------------------------------------------------------

                // section title on OSX and Windows
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32 * AppFramework.displayScaleFactor
                    Layout.topMargin: 24 * AppFramework.displayScaleFactor

                    spacing: 0

                    visible: settingsTabLocation.showAddUSB || settingsTabLocation.showAddNetworkProvider || settingsTabLocation.showAddFileProvider

                    Item {
                        Layout.preferredWidth: 16 * AppFramework.displayScaleFactor
                        Layout.preferredHeight: 32 * AppFramework.displayScaleFactor
                    }

                    AppText {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32 * AppFramework.displayScaleFactor
                        Layout.alignment: Qt.AlignBottom

                        text: qsTr("ADD PROVIDER")
                        color: settingsTabLocation.textColor

                        fontFamily: settingsTabLocation.fontFamily
                        letterSpacing: settingsTabLocation.letterSpacing
                        pixelSize: 10 * AppFramework.displayScaleFactor
                        bold: true

                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                    }

                    Item {
                        Layout.preferredWidth: 16 * AppFramework.displayScaleFactor
                        Layout.preferredHeight: 32 * AppFramework.displayScaleFactor
                    }
                }

                // -----------------------------------------------------------------

                // classic Bluetooth receivers on OSX and Windows
                PlainButton {
                    visible: settingsTabLocation.showAddUSB || settingsTabLocation.showAddNetworkProvider || settingsTabLocation.showAddFileProvider

                    Layout.preferredWidth: settingsTabLocation.width
                    Layout.preferredHeight: settingsTabLocation.listDelegateHeight

                    text: qsTr("Via Bluetooth")

                    horizontalAlignment: isRightToLeft ? Label.AlignRight : Label.AlignLeft

                    textColor: settingsTabLocation.addProviderButtonTextColor
                    pressedTextColor: settingsTabLocation.textColor
                    hoveredTextColor: settingsTabLocation.textColor
                    backgroundColor: settingsTabLocation.listBackgroundColor
                    pressedBackgroundColor: settingsTabLocation.hoverBackgroundColor
                    hoveredBackgroundColor: settingsTabLocation.hoverBackgroundColor

                    nextIconColor: settingsTabLocation.nextIconColor
                    nextIconSize: settingsTabLocation.nextIconSize
                    nextIcon: settingsTabLocation.nextIcon
                    showNextIcon: true

                    infoIconColor: settingsTabLocation.nextIconColor
                    infoIconSize: settingsTabLocation.infoIconSize
                    showInfoIcon: settingsTabLocation.showInfoIcons

                    fontFamily: settingsTabLocation.fontFamily
                    letterSpacing: settingsTabLocation.letterSpacing
                    isRightToLeft: settingsTabLocation.isRightToLeft

                    onClicked: {
                        positionSourceManager.discoverBluetooth = true;
                        positionSourceManager.discoverBluetoothLE = false;
                        positionSourceManager.discoverSerialPort = false;

                        if (!_addDeviceTab) {
                            _addDeviceTab = addDeviceTab.createObject(_item);
                        }

                        pushItem(_addDeviceTab);
                    }
                }

                // -----------------------------------------------------------------

                // classic USB/COM Port receivers on OSX and Windows
                PlainButton {
                    visible: settingsTabLocation.showAddUSB

                    Layout.preferredWidth: settingsTabLocation.width
                    Layout.preferredHeight: settingsTabLocation.listDelegateHeight

                    text: qsTr("Via USB")

                    horizontalAlignment: isRightToLeft ? Label.AlignRight : Label.AlignLeft

                    textColor: settingsTabLocation.addProviderButtonTextColor
                    pressedTextColor: settingsTabLocation.textColor
                    hoveredTextColor: settingsTabLocation.textColor
                    backgroundColor: settingsTabLocation.listBackgroundColor
                    pressedBackgroundColor: settingsTabLocation.hoverBackgroundColor
                    hoveredBackgroundColor: settingsTabLocation.hoverBackgroundColor

                    nextIconColor: settingsTabLocation.nextIconColor
                    nextIconSize: settingsTabLocation.nextIconSize
                    nextIcon: settingsTabLocation.nextIcon
                    showNextIcon: true

                    infoIconColor: settingsTabLocation.nextIconColor
                    infoIconSize: settingsTabLocation.infoIconSize
                    showInfoIcon: settingsTabLocation.showInfoIcons

                    fontFamily: settingsTabLocation.fontFamily
                    letterSpacing: settingsTabLocation.letterSpacing
                    isRightToLeft: settingsTabLocation.isRightToLeft

                    onClicked: {
                        positionSourceManager.discoverBluetooth = false;
                        positionSourceManager.discoverBluetoothLE = false;
                        positionSourceManager.discoverSerialPort = true;

                        if (!_addDeviceTab) {
                            _addDeviceTab = addDeviceTab.createObject(_item);
                        }

                        pushItem(_addDeviceTab);
                    }
                }

                // -----------------------------------------------------------------

                // network receivers on OSX and Windows
                PlainButton {
                    visible: settingsTabLocation.showAddNetworkProvider

                    Layout.preferredWidth: settingsTabLocation.width
                    Layout.preferredHeight: settingsTabLocation.listDelegateHeight

                    text: qsTr("Via Network")

                    horizontalAlignment: isRightToLeft ? Label.AlignRight : Label.AlignLeft

                    textColor: settingsTabLocation.addProviderButtonTextColor
                    pressedTextColor: settingsTabLocation.textColor
                    hoveredTextColor: settingsTabLocation.textColor
                    backgroundColor: settingsTabLocation.listBackgroundColor
                    pressedBackgroundColor: settingsTabLocation.hoverBackgroundColor
                    hoveredBackgroundColor: settingsTabLocation.hoverBackgroundColor

                    nextIconColor: settingsTabLocation.nextIconColor
                    nextIconSize: settingsTabLocation.nextIconSize
                    nextIcon: settingsTabLocation.nextIcon
                    showNextIcon: true

                    infoIconColor: settingsTabLocation.nextIconColor
                    infoIconSize: settingsTabLocation.infoIconSize
                    showInfoIcon: settingsTabLocation.showInfoIcons

                    fontFamily: settingsTabLocation.fontFamily
                    letterSpacing: settingsTabLocation.letterSpacing
                    isRightToLeft: settingsTabLocation.isRightToLeft

                    onClicked: {
                        if (!_addNetworkTab) {
                            _addNetworkTab = addNetworkTab.createObject(_item);
                        }

                        pushItem(_addNetworkTab);
                    }
                }

                // -----------------------------------------------------------------

                // NMEA data from file
                PlainButton {
                    visible: settingsTabLocation.showAddFileProvider

                    Layout.preferredWidth: settingsTabLocation.width
                    Layout.preferredHeight: settingsTabLocation.listDelegateHeight

                    text: qsTr("Via File")

                    horizontalAlignment: isRightToLeft ? Label.AlignRight : Label.AlignLeft

                    textColor: settingsTabLocation.addProviderButtonTextColor
                    pressedTextColor: settingsTabLocation.textColor
                    hoveredTextColor: settingsTabLocation.textColor
                    backgroundColor: settingsTabLocation.listBackgroundColor
                    pressedBackgroundColor: settingsTabLocation.hoverBackgroundColor
                    hoveredBackgroundColor: settingsTabLocation.hoverBackgroundColor

                    nextIconColor: settingsTabLocation.nextIconColor
                    nextIconSize: settingsTabLocation.nextIconSize
                    nextIcon: settingsTabLocation.nextIcon
                    showNextIcon: true

                    infoIconColor: settingsTabLocation.nextIconColor
                    infoIconSize: settingsTabLocation.infoIconSize
                    showInfoIcon: settingsTabLocation.showInfoIcons

                    fontFamily: settingsTabLocation.fontFamily
                    letterSpacing: settingsTabLocation.letterSpacing
                    isRightToLeft: settingsTabLocation.isRightToLeft

                    onClicked: {
                        if (!_addNMEALogTab) {
                            _addNMEALogTab = addNMEALogTab.createObject(_item);
                        }

                        pushItem(_addNMEALogTab);
                    }
                }

                // -----------------------------------------------------------------

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }

        //----------------------------------------------------------------------

        Component {
            id: deviceTab

            SettingsTabLocationDevice {
                settingsTabContainer: settingsTabLocation.settingsTabContainer
                settingsTabContainerComponent: settingsTabLocation.settingsTabContainerComponent

                showAboutDevice: settingsTabLocation.showAboutDevice
                showAlerts: settingsTabLocation.showAlerts
                showAntennaHeight: settingsTabLocation.showAntennaHeight
                showAltitude: settingsTabLocation.showAltitude
                showAccuracy: settingsTabLocation.showAccuracy

                showAlertsVisual: settingsTabLocation.showAlertsVisual
                showAlertsSpeech: settingsTabLocation.showAlertsSpeech
                showAlertsVibrate: settingsTabLocation.showAlertsVibrate
                showAlertsTimeout: settingsTabLocation.showAlertsTimeout
            }
        }

        //----------------------------------------------------------------------

        Component {
            id: addDeviceTab

            SettingsTabLocationAddDevice {
                settingsTabContainer: settingsTabLocation.settingsTabContainer
                settingsTabContainerComponent: settingsTabLocation.settingsTabContainerComponent

                receiverListModel: cachedReceiversListModel

                onShowReceiverSettingsPage: {
                    _item.showReceiverSettingsPage(deviceName)
                }
            }
        }

        //----------------------------------------------------------------------

        Component {
            id: addNetworkTab

            SettingsTabLocationAddNetwork {
                settingsTabContainer: settingsTabLocation.settingsTabContainer
                settingsTabContainerComponent: settingsTabLocation.settingsTabContainerComponent

                onShowReceiverSettingsPage: {
                    _item.showReceiverSettingsPage(deviceName)
                }
            }
        }

        //----------------------------------------------------------------------

        Component {
            id: addNMEALogTab

            SettingsTabLocationAddNmeaLog {
                settingsTabContainer: settingsTabLocation.settingsTabContainer
                settingsTabContainerComponent: settingsTabLocation.settingsTabContainerComponent

                logFileLocation: settingsTabLocation.logFileLocation

                onShowReceiverSettingsPage: {
                    _item.showReceiverSettingsPage(deviceName)
                }
            }
        }

        //----------------------------------------------------------------------

        Component {
            id: deviceListDelegate

            Rectangle {
                id: delegate

                property string delegateDeviceType: deviceType !== undefined ? deviceType : kDeviceTypeUnknown
                property string delegateDeviceName: deviceName !== undefined ? deviceName : ""
                property string delegateHostname: deviceProperties && deviceProperties.hostname !== undefined
                                                  ? deviceProperties.hostname
                                                  : ""
                property string delegatePort: deviceProperties && deviceProperties.port !== undefined
                                              ? deviceProperties.port
                                              : ""
                property string delegateFileName: deviceProperties && deviceProperties.filename !== undefined
                                                  ? deviceProperties.filename
                                                  : ""

                readonly property string label: deviceProperties.label

                property bool isInternal: delegateDeviceType === kDeviceTypeInternal
                property bool isNetwork: delegateDeviceType === kDeviceTypeNetwork
                property bool isFile: delegateDeviceType === kDeviceTypeFile
                property bool isDevice: !isInternal && !isNetwork && !isFile

                property bool isSelected: isDevice && controller.useExternalGPS
                                          ? currentDevice && currentDevice.name === delegateDeviceName
                                          : isNetwork && controller.useTCPConnection
                                            ? controller.currentNetworkAddress === delegateHostname + ":" + delegatePort
                                            : isFile && controller.useFile
                                              ? controller.nmeaLogFile === delegateFileName
                                              : isInternal && controller.useInternalGPS

                readonly property bool hovered: tabAction.containsMouse || deviceSettingsMouseArea.containsMouse
                readonly property bool pressed: tabAction.containsPress || deviceSettingsMouseArea.containsPress

                Accessible.role: Accessible.Pane

                width: parent.parent.width
                height: settingsTabLocation.listDelegateHeight

                color: delegate.pressed
                       ? settingsTabLocation.hoverBackgroundColor
                       : delegate.hovered
                         ? settingsTabLocation.hoverBackgroundColor
                         : delegate.isSelected
                           ? settingsTabLocation.selectedBackgroundColor
                           : settingsTabLocation.listBackgroundColor

                //----------------------------------------------------------------------

                onIsSelectedChanged: {
                    if (isSelected) {
                        Qt.callLater(ListView.view.positionViewAtIndex, DelegateModel.itemsIndex, ListView.Contain)
                    }
                }

                //----------------------------------------------------------------------

                RowLayout {
                    anchors.fill: parent

                    spacing: 0

                    Accessible.role: Accessible.Pane

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        RowLayout {
                            anchors.fill: parent

                            spacing: 0

                            Accessible.role: Accessible.Pane

                            Item {
                                Layout.preferredWidth: 16 * AppFramework.displayScaleFactor
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.preferredWidth: settingsTabLocation.infoIconSize
                                Layout.fillHeight: true

                                visible: settingsTabLocation.showInfoIcons
                                enabled: visible

                                Accessible.role: Accessible.Pane

                                StyledImage {
                                    anchors.centerIn: parent

                                    width: settingsTabLocation.infoIconSize
                                    height: width

                                    source: delegate.delegateDeviceType > ""
                                            ? "../images/deviceType-%1.png".arg(delegate.delegateDeviceType)
                                            : ""

                                    color: delegate.pressed
                                           ? settingsTabLocation.textColor
                                           : delegate.hovered
                                             ? settingsTabLocation.textColor
                                             : delegate.isSelected
                                               ? settingsTabLocation.selectedForegroundColor
                                               : settingsTabLocation.infoIconColor
                                }
                            }

                            Item {
                                Layout.preferredWidth: settingsTabLocation.showInfoIcons ? 12 * AppFramework.displayScaleFactor : 4 * AppFramework.displayScaleFactor
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Accessible.role: Accessible.Pane

                                ColumnLayout {
                                    id: textColumn

                                    anchors.fill: parent

                                    spacing: 0

                                    readonly property bool hasAlias: modelData.title !== delegate.delegateDeviceName && !delegate.isInternal

                                    AppText {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        verticalAlignment: Qt.AlignVCenter

                                        text: modelData.title

                                        color: delegate.pressed
                                               ? settingsTabLocation.textColor
                                               : delegate.hovered
                                                 ? settingsTabLocation.textColor
                                                 : delegate.isSelected
                                                   ? settingsTabLocation.selectedTextColor
                                                   : settingsTabLocation.textColor

                                        fontFamily: settingsTabLocation.fontFamily
                                        letterSpacing: settingsTabLocation.letterSpacing
                                        pixelSize: 16 * AppFramework.displayScaleFactor
                                        bold: true

                                        LayoutMirroring.enabled: false

                                        horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft

                                        wrapMode: Text.NoWrap
                                        elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight
                                        clip: true
                                    }

                                    AppText {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        verticalAlignment: Qt.AlignVCenter

                                        visible: settingsTabLocation.showProviderAlias && textColumn.hasAlias

                                        text: "<span style='font-size:%1pt'>%2</span>".arg(font.pixelSize*0.8).arg(delegate.delegateDeviceName)

                                        color: delegate.pressed
                                               ? settingsTabLocation.helpTextColor
                                               : delegate.hovered
                                                 ? settingsTabLocation.helpTextColor
                                                 : delegate.isSelected
                                                   ? settingsTabLocation.selectedTextColor
                                                   : settingsTabLocation.helpTextColor

                                        fontFamily: settingsTabLocation.fontFamily
                                        letterSpacing: settingsTabLocation.letterSpacing
                                        pixelSize: 16 * AppFramework.displayScaleFactor
                                        bold: false

                                        LayoutMirroring.enabled: false

                                        horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft

                                        wrapMode: Text.NoWrap
                                        elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight
                                        clip: true
                                    }
                                }
                            }

                            Item {
                                visible: delegate.isSelected

                                Layout.preferredWidth: 16 * AppFramework.displayScaleFactor
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.preferredWidth: settingsTabLocation.settingsIconSize
                                Layout.fillHeight: true

                                visible: delegate.isSelected

                                Accessible.role: Accessible.Pane

                                StyledImage {
                                    anchors.centerIn: parent

                                    width: settingsTabLocation.settingsIconSize
                                    height: width

                                    visible: delegate.isSelected && !isConnecting
                                    source: isConnected ? "../images/round_done_white_24dp.png" : "../images/round_error_white_24dp.png"

                                    color: delegate.pressed
                                           ? settingsTabLocation.textColor
                                           : delegate.hovered
                                             ? settingsTabLocation.textColor
                                             : delegate.isSelected
                                               ? settingsTabLocation.selectedForegroundColor
                                               : settingsTabLocation.settingsIconColor
                                }

                                AppBusyIndicator {
                                    anchors.centerIn: parent

                                    visible: delegate.isSelected && isConnecting

                                    implicitSize: 14 * AppFramework.displayScaleFactor
                                    backgroundColor: settingsTabLocation.selectedForegroundColor

                                    running: visible
                                }
                            }

                            Item {
                                visible: showDetailedSettingsCog

                                Layout.preferredWidth: 16 * AppFramework.displayScaleFactor
                                Layout.fillHeight: true
                            }

                            Rectangle {
                                visible: showDetailedSettingsCog
                                enabled: visible

                                Layout.fillHeight: true
                                Layout.topMargin: 8 * AppFramework.displayScaleFactor
                                Layout.bottomMargin: 8 * AppFramework.displayScaleFactor
                                Layout.preferredWidth: 1 * AppFramework.displayScaleFactor

                                color: delegate.pressed
                                       ? settingsTabLocation.textColor
                                       : delegate.hovered
                                         ? settingsTabLocation.textColor
                                         : delegate.isSelected
                                           ? settingsTabLocation.selectedForegroundColor
                                           : settingsTabLocation.settingsIconColor

                                Accessible.role: Accessible.Separator
                                Accessible.ignored: true
                            }
                        }

                        MouseArea {
                            id: tabAction

                            anchors.fill: parent
                            hoverEnabled: true

                            Accessible.role: Accessible.Button

                            onClicked: {
                                _item.connectProvider(delegate);
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 16 * AppFramework.displayScaleFactor
                        Layout.fillHeight: true
                        visible: showDetailedSettingsCog
                    }

                    Item {
                        Layout.preferredWidth: settingsTabLocation.settingsIconSize
                        Layout.fillHeight: true

                        visible: showDetailedSettingsCog
                        enabled: visible

                        Accessible.role: Accessible.Pane

                        StyledImage {
                            anchors.centerIn: parent

                            width: parent.width
                            height: width

                            source: settingsTabLocation.settingsIcon

                            color: delegate.pressed
                                   ? settingsTabLocation.textColor
                                   : delegate.hovered
                                     ? settingsTabLocation.textColor
                                     : delegate.isSelected
                                       ? settingsTabLocation.selectedForegroundColor
                                       : settingsTabLocation.settingsIconColor
                        }

                        MouseArea {
                            id: deviceSettingsMouseArea

                            anchors.fill: parent
                            hoverEnabled: true

                            Accessible.role: Accessible.Button

                            onClicked: {
                                sortedListTabView.selected(modelData);
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 16 * AppFramework.displayScaleFactor
                        Layout.fillHeight: true
                    }
                }

                //----------------------------------------------------------------------

                Connections {
                    target: settingsTabLocation

                    onSelectInternal: {
                        if (delegate.delegateDeviceType === kDeviceTypeInternal) {
                            _item.connectProvider(delegate);
                        }
                    }
                }
            }
        }

        //----------------------------------------------------------------------

        function createListTabView(devicesList) {
            for (var i = 0; i < sortedListTabView.contentData.length; i++) {
                var tab = sortedListTabView.contentData[i]
                tab.destroy();
            }

            sortedListTabView.contentData = null;
            cachedReceiversListModel.clear();

            for (var deviceName in devicesList) {
                _item.addDeviceListTab(deviceName, devicesList)
            }

            // make sure the list is sorted
            sortedListTabView.sort();

            // highlight the currently selected item
            for (i = 0; i < sortedListTabView.model.count; i++) {
                var item = sortedListTabView.model.get(i).model;

                if (item.deviceName === controller.currentName) {
                    sortedListTabView.listTabView.positionViewAtIndex(i, ListView.Contain);
                    break;
                }
            }
        }

        //----------------------------------------------------------------------

        function addDeviceListTab(deviceName, devicesList) {
            if (deviceName === "") {
                return;
            }

            var receiverSettings = devicesList[deviceName];
            var deviceType = "";

            if (receiverSettings.receiver) {
                deviceType = receiverSettings.receiver.deviceType;
                cachedReceiversListModel.append({name: deviceName, deviceType: receiverSettings.receiver.deviceType});
            } else if (receiverSettings.hostname > "" && receiverSettings.port) {
                deviceType = kDeviceTypeNetwork;
                cachedReceiversListModel.append({name: deviceName, deviceType: kDeviceTypeNetwork});
            } else if (receiverSettings.filename > "") {
                deviceType = kDeviceTypeFile;
                cachedReceiversListModel.append({name: deviceName, deviceType: kDeviceTypeFile});
            } else if (deviceName === gnssSettings.kInternalPositionSourceName) {
                deviceType = kDeviceTypeInternal;
                cachedReceiversListModel.append({name: deviceName, deviceType: kDeviceTypeInternal});
            } else {
                return;
            }

            var _deviceTab = deviceTab.createObject(sortedListTabView.tabViewContainer, {
                                                        "title": receiverSettings.label && receiverSettings.label > "" ? receiverSettings.label : deviceName,
                                                        "deviceType": deviceType,
                                                        "deviceName": deviceName,
                                                        "deviceLabel": receiverSettings.label && receiverSettings.label > "" ? receiverSettings.label : deviceName,
                                                        "deviceProperties": receiverSettings
                                                    });

            _deviceTab.selectInternal.connect(function() {
                selectInternal();
            });

            _deviceTab.updateViewAndDelegate.connect(function() {
                _dirty = true;
            });
        }

        //----------------------------------------------------------------------

        function connectProvider(delegate) {
            if (delegate.isDevice) {
                if ( (!isConnecting && !isConnected) || !controller.useExternalGPS || (currentDevice && currentDevice.name !== delegate.delegateDeviceName) ) {
                    var device = gnssSettings.knownDevices[delegate.delegateDeviceName].receiver;
                    gnssSettings.createExternalReceiverSettings(delegate.delegateDeviceName, device);

                    controller.deviceSelected(Device.fromJson(JSON.stringify(device), controller));
                } else {
                    controller.deviceDeselected();
                }
            } else if (delegate.isNetwork) {
                if ( (!isConnecting && !isConnected) || !controller.useTCPConnection || (currentNetworkAddress > "" && currentNetworkAddress !== delegate.delegateDeviceName) ) {
                    var address = delegate.delegateDeviceName.split(":");
                    gnssSettings.createNetworkSettings(address[0], address[1]);

                    controller.networkHostSelected(address[0], address[1]);
                } else {
                    controller.deviceDeselected();
                }
            } else if (delegate.isFile) {
                if ( (!isConnecting && !isConnected) || !controller.useFile || (currentNmeaLogFile > "" && currentNmeaLogFile !== delegate.delegateDeviceName) ) {
                    gnssSettings.createNmeaLogFileSettings(delegate.delegateFileName);

                    controller.nmeaLogFileSelected(delegate.delegateFileName);
                } else {
                    controller.deviceDeselected();
                }
            } else if (delegate.isInternal) {
                controller.deviceDeselected();
                gnssSettings.createInternalSettings();
            } else {
                controller.deviceDeselected();
            }

            return;
        }

        //----------------------------------------------------------------------

        function showReceiverSettingsPage(name) {
            var listModel = sortedListTabView.contentData;

            var item = null;
            for (var i=0; i<listModel.length; i++) {
                if (listModel[i].title === name) {
                    item = listModel[i];
                    break;
                }
            }

            replaceItem(item);
        }

        //----------------------------------------------------------------------
    }

    //--------------------------------------------------------------------------
}
