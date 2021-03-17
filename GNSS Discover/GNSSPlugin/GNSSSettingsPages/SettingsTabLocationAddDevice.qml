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
import QtQuick.Layouts 1.15

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Platform 1.0

import "../controls"

SettingsTab {
    id: addDeviceTab

    title: qsTr("Select provider")

    property var receiverListModel

    signal showReceiverSettingsPage(var deviceName)

    //--------------------------------------------------------------------------

    Item {
        id: _item

        Accessible.role: Accessible.Pane

        // Internal properties -------------------------------------------------

        readonly property DeviceDiscoveryAgent discoveryAgent: controller.discoveryAgent

        readonly property string kDescriptionBluetooth: qsTr("All GNSS receivers that are paired to the device will be displayed in this list. If your receiver is missing please check that Bluetooth is enabled and that the receiver is paired.")
        readonly property string kDescriptionSerialPort: qsTr("All GNSS receivers that are physically connected to the device will be displayed in this list. If your receiver is missing please check the connection.")

        readonly property bool scanSerialPort: positionSourceManager.discoverSerialPort
        readonly property bool iOS: Qt.platform.os === "ios"

        property bool initialized

        // ---------------------------------------------------------------------

        Component.onCompleted: {
            _item.initialized = true;

            controller.onDetailedSettingsPage = true;

            // disable Bluetooth scanning if not needed
            discoveryAgent.setPropertyValue("isScanBluetoothDevices" , scanSerialPort ? false : true);
            discoveryAgent.setPropertyValue("isScanSerialPortDevices" , scanSerialPort ? true : false);

            // omit previously stored device from discovered devices list
            discoveryAgent.deviceFilter = function(device) {
                for (var i = 0; i < receiverListModel.count; i++) {
                    var cachedReceiver = receiverListModel.get(i);
                    if (device && cachedReceiver && device.name === cachedReceiver.name) {
                        return false;
                    }
                }
                return discoveryAgent.filter(device);
            }
        }

        // ---------------------------------------------------------------------

        Component.onDestruction: {
            controller.onDetailedSettingsPage = false;

            // Clear the model so old devices are not visible if view is re-loaded.
            discoveryAgent.devices.clear();

            // reset standard filter
            discoveryAgent.deviceFilter = function(device) { return discoveryAgent.filter(device); }

            // stop the discoveryAgent
            discoveryAgent.stop();
        }

        // ---------------------------------------------------------------------

        Connections {
            target: addDeviceTab

            function onActivated() {
                // Activating this here ensures that any error message is displayed
                // on this page (not it's ancestor)
                discoverySwitch.checked = true;
            }
        }

        //--------------------------------------------------------------------------

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Accessible.role: Accessible.Pane

            // -----------------------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: addDeviceTab.listDelegateHeightSingleLine
                color: addDeviceTab.listBackgroundColor

                AppSwitch {
                    id: discoverySwitch

                    property bool updating

                    anchors.fill: parent
                    leftPadding: 16 * AppFramework.displayScaleFactor
                    rightPadding: 16 * AppFramework.displayScaleFactor

                    text: qsTr("Discover")

                    textColor: addDeviceTab.textColor
                    checkedColor: addDeviceTab.selectedForegroundColor
                    backgroundColor: addDeviceTab.listBackgroundColor
                    hoverBackgroundColor: addDeviceTab.hoverBackgroundColor
                    fontFamily: addDeviceTab.fontFamily

                    onCheckedChanged: {
                        if (_item.initialized && !updating) {
                            if (checked) {
                                if (!iOS || _item.scanSerialPort || Permission.serviceStatus(Permission.BluetoothService) === Permission.ServiceStatusPoweredOn) {
                                    devicesListView.model.clear()
                                    controller.startDiscoveryAgent();
                                } else {
                                    positionSourceManager.discoveryAgentError("")
                                    checked = false;
                                }
                            } else {
                                controller.stopDiscoveryAgent();
                            }
                        }
                    }

                    Connections {
                        target: _item.discoveryAgent

                        function onRunningChanged() {
                            discoverySwitch.updating = true;
                            discoverySwitch.checked = _item.discoveryAgent.running;
                            discoverySwitch.updating = false;
                        }
                    }
                }
            }

            // -----------------------------------------------------------------

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 32 * AppFramework.displayScaleFactor
                Layout.topMargin: 24 * AppFramework.displayScaleFactor
                Layout.leftMargin: 16 * AppFramework.displayScaleFactor
                Layout.rightMargin: 16 * AppFramework.displayScaleFactor

                AppText {
                    Layout.fillWidth: true

                    text: qsTr("CHOOSE A PROVIDER")
                    color: addDeviceTab.textColor

                    fontFamily: addDeviceTab.fontFamily
                    letterSpacing: addDeviceTab.letterSpacing
                    pixelSize: 10 * AppFramework.displayScaleFactor
                    bold: true

                    LayoutMirroring.enabled: false

                    horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                }

                AppBusyIndicator {
                    Layout.alignment: Qt.AlignVCenter

                    implicitSize: 8 * AppFramework.displayScaleFactor
                    backgroundColor: addDeviceTab.selectedForegroundColor

                    running: discoverySwitch.checked
                }
            }

            // -----------------------------------------------------------------

            ListView {
                id: devicesListView

                Layout.fillWidth: true
                Layout.preferredHeight: count * (addDeviceTab.listDelegateHeightSingleLine + spacing)
                Layout.maximumHeight: _item.height / 2

                visible: count > 0

                spacing: addDeviceTab.listSpacing

                clip: true

                model: _item.discoveryAgent.devices
                delegate: deviceDelegate
            }

            // -----------------------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: addDeviceTab.listDelegateHeightSingleLine

                visible: !devicesListView.visible

                color: addDeviceTab.listBackgroundColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16 * AppFramework.displayScaleFactor
                    anchors.rightMargin: 16 * AppFramework.displayScaleFactor

                    AppText {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        text: discoverySwitch.checked ? qsTr("Searching...") : qsTr("Press <b>Discover</b> to search.")
                        color: addDeviceTab.textColor
                        opacity: 0.5

                        LayoutMirroring.enabled: false

                        horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter

                        fontFamily: addDeviceTab.fontFamily
                        letterSpacing: addDeviceTab.letterSpacing
                        pixelSize: 16 * AppFramework.displayScaleFactor
                        bold: false
                    }
                }
            }

            // -----------------------------------------------------------------

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 16 * AppFramework.displayScaleFactor
                Layout.leftMargin: 16 * AppFramework.displayScaleFactor
                Layout.rightMargin: 16 * AppFramework.displayScaleFactor

                spacing: 10 * AppFramework.displayScaleFactor

                StyledImage {
                    Layout.preferredWidth: 24 * AppFramework.displayScaleFactor
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignTop

                    source: "../images/round_info_white_24dp.png"
                    color: addDeviceTab.helpTextColor
                }

                AppText {
                    Layout.fillWidth: true

                    text: _item.scanSerialPort ? _item.kDescriptionSerialPort : _item.kDescriptionBluetooth
                    color: addDeviceTab.helpTextColor

                    fontFamily: addDeviceTab.fontFamily
                    letterSpacing: addDeviceTab.helpTextLetterSpacing
                    pixelSize: 12 * AppFramework.displayScaleFactor
                    bold: false

                    LayoutMirroring.enabled: false

                    horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                }
            }

            // -----------------------------------------------------------------

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        // ---------------------------------------------------------------------

        Component {
            id: deviceDelegate

            Rectangle {
                id: delegate

                width: ListView.view.width
                height: addDeviceTab.listDelegateHeightSingleLine

                color: mouseArea.containsMouse ? hoverBackgroundColor : listBackgroundColor
                opacity: ListView.view.enabled ? 1 : 0.5

                RowLayout {
                    anchors.fill: parent

                    spacing: 0

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height

                        visible: showInfoIcons
                        enabled: visible

                        StyledImage {
                            anchors.centerIn: parent

                            width: infoIconSize
                            height: width

                            source: "../images/deviceType-%1.png".arg(deviceType)
                            color: infoIconColor
                        }
                    }

                    AppText {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: !showInfoIcons ? 20 * AppFramework.displayScaleFactor : 0

                        text: name
                        color: addDeviceTab.textColor

                        fontFamily: addDeviceTab.fontFamily
                        letterSpacing: addDeviceTab.letterSpacing
                        pixelSize: 16 * AppFramework.displayScaleFactor
                        bold: false

                        LayoutMirroring.enabled: false

                        horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height

                        visible: showInfoIcons
                        enabled: visible

                        StyledImage {
                            anchors.centerIn: parent

                            width: nextIconSize
                            height: width

                            source: nextIcon
                            color: nextIconColor

                            rotation: isRightToLeft ? 180 : 0
                        }
                    }
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        var device = _item.discoveryAgent.devices.get(index);
                        var deviceName = gnssSettings.createExternalReceiverSettings(name, device.toJson());
                        controller.deviceSelected(device);
                        showReceiverSettingsPage(deviceName);
                    }
                }
            }
        }

        // ---------------------------------------------------------------------
    }
}
