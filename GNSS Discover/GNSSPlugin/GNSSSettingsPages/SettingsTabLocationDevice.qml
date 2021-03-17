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

import ArcGIS.AppFramework 1.0

import "../controls"
import "../lib/CoordinateConversions.js" as CC

SettingsTab {
    id: deviceTab

    property string deviceType: ""
    property string deviceName: ""
    property string deviceLabel: ""

    //--------------------------------------------------------------------------

    property var deviceProperties: null

    property bool showAboutDevice: true
    property bool showAlerts: true
    property bool showAntennaHeight: true
    property bool showAltitude: true
    property bool showAccuracy: true

    property bool showAlertsVisual: true
    property bool showAlertsSpeech: true
    property bool showAlertsVibrate: true
    property bool showAlertsTimeout: false

    property bool showProviderAlias: true

    signal selectInternal()
    signal updateViewAndDelegate()

    //--------------------------------------------------------------------------

    onUpdateViewAndDelegate: {
        var deviceLabel = gnssSettings.knownDevices[deviceName].label > "" ? gnssSettings.knownDevices[deviceName].label : deviceName;
        if (stackView.currentItem.settingsItem.objectName === deviceTab.deviceName) {
            stackView.currentItem.title = deviceLabel;
        }
        deviceTab.deviceLabel = deviceLabel;
    }

    //--------------------------------------------------------------------------

    Item {
        id: _item

        Accessible.role: Accessible.Pane

        Component.onCompleted: {
            controller.onDetailedSettingsPage = controller.useInternalGPS ? gnssSettings.kInternalPositionSourceName !== deviceName : controller.currentName !== deviceName;
            objectName = deviceName;
            updateDescriptions();
        }

        Component.onDestruction: {
            controller.onDetailedSettingsPage = false;
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Accessible.role: Accessible.Pane

            ListTabView {
                id: settingsTabView

                Layout.fillWidth: true
                Layout.preferredHeight: settingsTabView.listTabView.contentHeight
                Layout.maximumHeight: _item.height * 3 / 4

                backgroundColor: deviceTab.backgroundColor
                listSpacing: deviceTab.listSpacing

                delegate: settingsDelegate

                SettingsTabLocationAboutDevice {
                    id: sensorAbout

                    visible: showAboutDevice
                    enabled: visible

                    settingsTabContainer: deviceTab.settingsTabContainer
                    settingsTabContainerComponent: deviceTab.settingsTabContainerComponent

                    deviceType: deviceTab.deviceType
                    deviceName: deviceTab.deviceName
                    deviceLabel: deviceTab.deviceLabel

                    showProviderAlias: deviceTab.showProviderAlias

                    onChanged: {
                        updateViewAndDelegate();
                        _item.updateDescriptions();
                    }
                }

                SettingsTabLocationAlerts {
                    id: sensorAlerts

                    visible: showAlerts
                    enabled: visible

                    settingsTabContainer: deviceTab.settingsTabContainer
                    settingsTabContainerComponent: deviceTab.settingsTabContainerComponent

                    deviceType: deviceTab.deviceType
                    deviceName: deviceTab.deviceName
                    deviceLabel: deviceTab.deviceLabel

                    showAlertsVisual: deviceTab.showAlertsVisual
                    showAlertsSpeech: deviceTab.showAlertsSpeech
                    showAlertsVibrate: deviceTab.showAlertsVibrate
                    showAlertsTimeout: deviceTab.showAlertsTimeout

                    onChanged: {
                        _item.updateDescriptions();
                    }
                }

                SettingsTabLocationAntennaHeight {
                    id: sensorAntennaHeight

                    visible: showAntennaHeight
                    enabled: visible

                    settingsTabContainer: deviceTab.settingsTabContainer
                    settingsTabContainerComponent: deviceTab.settingsTabContainerComponent

                    deviceType: deviceTab.deviceType
                    deviceName: deviceTab.deviceName
                    deviceLabel: deviceTab.deviceLabel

                    onChanged: {
                        _item.updateDescriptions();
                    }
                }

                SettingsTabLocationAltitude {
                    id: sensorAltitude

                    visible: showAltitude
                    enabled: visible

                    settingsTabContainer: deviceTab.settingsTabContainer
                    settingsTabContainerComponent: deviceTab.settingsTabContainerComponent

                    deviceType: deviceTab.deviceType
                    deviceName: deviceTab.deviceName
                    deviceLabel: deviceTab.deviceLabel

                    onChanged: {
                        _item.updateDescriptions();
                    }
                }

                SettingsTabLocationAccuracy {
                    id: sensorAccuracy

                    visible: showAccuracy
                    enabled: visible

                    settingsTabContainer: deviceTab.settingsTabContainer
                    settingsTabContainerComponent: deviceTab.settingsTabContainerComponent

                    deviceType: deviceTab.deviceType
                    deviceName: deviceTab.deviceName
                    deviceLabel: deviceTab.deviceLabel

                    onChanged: {
                        _item.updateDescriptions();
                    }
                }

                onSelected: pushItem(item)
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20 * AppFramework.displayScaleFactor
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: deviceTab.listDelegateHeightSingleLine
                visible: deviceType !== kDeviceTypeInternal

                Accessible.role: Accessible.Pane

                PlainButton {
                    id: removeDeviceButton

                    anchors.fill: parent

                    enabled: deviceType !== kDeviceTypeInternal

                    text: qsTr("Remove this provider")

                    horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft

                    textColor: deviceTab.forgetProviderButtonTextColor
                    pressedTextColor: deviceTab.textColor
                    hoveredTextColor: deviceTab.textColor
                    backgroundColor: deviceTab.listBackgroundColor
                    pressedBackgroundColor: deviceTab.hoverBackgroundColor
                    hoveredBackgroundColor: deviceTab.hoverBackgroundColor

                    nextIconColor: deviceTab.nextIconColor
                    nextIconSize: deviceTab.nextIconSize
                    nextIcon: deviceTab.nextIcon
                    showNextIcon: false

                    infoIconColor: deviceTab.infoIconColor
                    infoIconSize: deviceTab.infoIconSize
                    showInfoIcon: false

                    fontFamily: deviceTab.fontFamily
                    letterSpacing: deviceTab.letterSpacing
                    isRightToLeft: deviceTab.isRightToLeft

                    onClicked: {
                        gnssDialog.parent = stackView.currentItem;
                        gnssDialog.openDialog(
                                    qsTr("Remove %1?").arg(deviceLabel),
                                    qsTr("CANCEL"), qsTr("REMOVE"),
                                    function() {},
                                    function() {
                                        // If this is the currently connected device, select the internal
                                        if (controller.currentName === deviceTab.deviceName) {
                                            selectInternal();
                                        }

                                        gnssSettings.deleteKnownDevice(deviceTab.deviceName);
                                        stackView.pop();
                                    });
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        //--------------------------------------------------------------------------

        Component {
            id: settingsDelegate

            SettingsTabDelegate {
                listTabView: settingsTabView

                listDelegateHeightTextBox: deviceTab.listDelegateHeightTextBox
                listDelegateHeightMultiLine: deviceTab.listDelegateHeightMultiLine
                listDelegateHeightSingleLine: deviceTab.listDelegateHeightSingleLine
                textColor: deviceTab.textColor
                helpTextColor: deviceTab.helpTextColor
                backgroundColor: deviceTab.backgroundColor
                listBackgroundColor: deviceTab.listBackgroundColor
                hoverBackgroundColor: deviceTab.hoverBackgroundColor

                nextIconColor: deviceTab.nextIconColor
                nextIconSize: deviceTab.nextIconSize
                nextIcon: deviceTab.nextIcon

                infoIconColor: deviceTab.infoIconColor
                infoIconSize: deviceTab.infoIconSize

                fontFamily: deviceTab.fontFamily
                letterSpacing: deviceTab.letterSpacing
                helpTextLetterSpacing: deviceTab.helpTextLetterSpacing
                locale: deviceTab.locale
                isRightToLeft: deviceTab.isRightToLeft

                showInfoIcons: deviceTab.showInfoIcons
            }
        }

        //-------------------------------------------------------------------------

        AppDialog {
            id: gnssDialog

            backgroundColor: deviceTab.listBackgroundColor
            buttonColor: deviceTab.selectedTextColor
            titleColor: deviceTab.textColor
            textColor: deviceTab.textColor
            fontFamily: deviceTab.fontFamily
        }

        //--------------------------------------------------------------------------

        function updateDescriptions(){

            var props = gnssSettings.knownDevices[deviceName] || null;

            if (props === null) {
                return;
            }

            // about
            var aboutDescString = deviceTab.resolveDeviceName(deviceType, deviceName, false);

            if (props.receiver && props.receiver.deviceType !== undefined && props.receiver.deviceType === kDeviceTypeSerialPort) {
                aboutDescString += qsTr(", %1 Bd").arg(props.receiver.address.deviceBaudRate)
            }

            sensorAbout.description = aboutDescString;

            // alert styles
            var alertStylesDescString = "";

            if (props.locationAlertsVisual !== undefined && props.locationAlertsVisual) {
                alertStylesDescString += "%1".arg(sensorAlerts.kBanner);
            }

            if (props.locationAlertsSpeech !== undefined && props.locationAlertsSpeech) {
                alertStylesDescString += alertStylesDescString > "" ? ", %1".arg(sensorAlerts.kVoice) : "%1".arg(sensorAlerts.kVoice);
            }

            if (props.locationAlertsVibrate !== undefined && props.locationAlertsVibrate) {
                alertStylesDescString += alertStylesDescString > "" ? ", %1".arg(sensorAlerts.kVibrate) : "%1".arg(sensorAlerts.kVibrate);
            }

            if (alertStylesDescString === "") {
                alertStylesDescString = "%1".arg(sensorAlerts.kNone);
            }

            sensorAlerts.description = alertStylesDescString;

            // altitude type
            if (props.altitudeType !== undefined) {
                sensorAltitude.description = props.altitudeType === gnssSettings.kAltitudeTypeMSL
                        ? sensorAltitude.altitudeTypeMSLLabel
                        : props.altitudeType === gnssSettings.kAltitudeTypeHAE
                          ? sensorAltitude.altitudeTypeHAELabel
                          : "";
            }

            // antenna height
            if (props.antennaHeight !== undefined) {
                sensorAntennaHeight.description = isFinite(props.antennaHeight)
                        ? CC.toLocaleLengthString(props.antennaHeight, locale)
                        : CC.toLocaleLengthString(0, locale);
            }

            // accuracy type
            if (props.confidenceLevelType !== undefined) {
                sensorAccuracy.description = props.confidenceLevelType === gnssSettings.kConfidenceLevelType68
                        ? sensorAccuracy.confidenceLevelType68Label
                        : props.confidenceLevelType === gnssSettings.kConfidenceLevelType95
                          ? sensorAccuracy.confidenceLevelType95Label
                          : "";
            }
        }
    }

    //--------------------------------------------------------------------------
}
