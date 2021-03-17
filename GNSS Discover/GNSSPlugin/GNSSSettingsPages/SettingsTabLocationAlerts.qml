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
import ArcGIS.AppFramework.Notifications 1.0

import "../controls"

SettingsTab {
    id: alertsTab

    title: qsTr("Alerts")
    icon: "../images/sharp_warning_white_24dp.png"
    description: ""

    property string deviceType: ""
    property string deviceName: ""
    property string deviceLabel: ""

    property bool showAlertsVisual: true
    property bool showAlertsSpeech: true
    property bool showAlertsVibrate: true
    property bool showAlertsTimeout: false

    //--------------------------------------------------------------------------

    readonly property bool isTheActiveSensor: deviceName === gnssSettings.kInternalPositionSourceName || controller.currentName === deviceName

    readonly property string kBanner: qsTr("Display")
    readonly property string kVoice: qsTr("Text to speech")
    readonly property string kVibrate: qsTr("Vibrate")
    readonly property string kNone: qsTr("Off")

    property bool initialized

    signal changed()

    //--------------------------------------------------------------------------

    Item {
        id: _item

        Accessible.role: Accessible.Pane

        Component.onCompleted: {
            initialized = true;
        }

        Component.onDestruction: {
        }

        ColumnLayout {
            anchors.fill: parent

            spacing: 10 * AppFramework.displayScaleFactor

            ColumnLayout {
                Layout.fillWidth: true

                spacing: alertsTab.listSpacing

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: alertsTab.listDelegateHeightSingleLine
                    color: alertsTab.listBackgroundColor

                    visible: showAlertsVisual

                    AppSwitch {
                        id: visualSwitch

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        checked: gnssSettings.knownDevices[deviceName].locationAlertsVisual

                        text: kBanner

                        textColor: alertsTab.textColor
                        checkedColor: alertsTab.selectedForegroundColor
                        backgroundColor: alertsTab.listBackgroundColor
                        hoverBackgroundColor: alertsTab.hoverBackgroundColor
                        fontFamily: alertsTab.fontFamily

                        onCheckedChanged: {
                            if (initialized && !gnssSettings.updating) {
                                gnssSettings.knownDevices[deviceName].locationAlertsVisual = checked;
                                if (isTheActiveSensor) {
                                    gnssSettings.locationAlertsVisual = checked;
                                }
                            }

                            changed();
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: alertsTab.listDelegateHeightSingleLine
                    color: alertsTab.listBackgroundColor

                    visible: showAlertsSpeech

                    AppSwitch {
                        id: speechSwitch

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        checked: gnssSettings.knownDevices[deviceName].locationAlertsSpeech

                        text: kVoice

                        textColor: alertsTab.textColor
                        checkedColor: alertsTab.selectedForegroundColor
                        backgroundColor: alertsTab.listBackgroundColor
                        hoverBackgroundColor: alertsTab.hoverBackgroundColor
                        fontFamily: alertsTab.fontFamily

                        onCheckedChanged: {
                            if (initialized && !gnssSettings.updating) {
                                gnssSettings.knownDevices[deviceName].locationAlertsSpeech = checked;
                                if (isTheActiveSensor) {
                                    gnssSettings.locationAlertsSpeech = checked;
                                }
                            }

                            changed();
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: alertsTab.listDelegateHeightSingleLine
                    color: alertsTab.listBackgroundColor

                    visible: showAlertsVibrate

                    AppSwitch {
                        id: vibrateSwitch

                        enabled: Vibration.supported

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        checked: gnssSettings.knownDevices[deviceName].locationAlertsVibrate

                        text: kVibrate

                        textColor: alertsTab.textColor
                        checkedColor: alertsTab.selectedForegroundColor
                        backgroundColor: alertsTab.listBackgroundColor
                        hoverBackgroundColor: alertsTab.hoverBackgroundColor
                        fontFamily: alertsTab.fontFamily

                        onCheckedChanged: {
                            if (initialized && !gnssSettings.updating) {
                                gnssSettings.knownDevices[deviceName].locationAlertsVibrate = checked;
                                if (isTheActiveSensor) {
                                    gnssSettings.locationAlertsVibrate = checked;
                                }
                            }

                            changed();
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: alertsTab.listDelegateHeightSingleLine
                    color: alertsTab.listBackgroundColor

                    visible: showAlertsTimeout

                    AppSlider {
                        id: timeoutSlider

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        to: 120000
                        from: 5000
                        stepSize: 5000

                        value: gnssSettings.knownDevices[deviceName].locationMaximumPositionAge

                        text: qsTr("Timeout")
                        toolTipText: qsTr("%1 s".arg(value / 1000))

                        textColor: alertsTab.textColor
                        checkedColor: alertsTab.selectedForegroundColor
                        backgroundColor: alertsTab.listBackgroundColor
                        hoverBackgroundColor: alertsTab.hoverBackgroundColor
                        fontFamily: alertsTab.fontFamily
                        letterSpacing: alertsTab.letterSpacing
                        isRightToLeft: alertsTab.isRightToLeft

                        onValueChanged: {
                            if (initialized && !gnssSettings.updating) {
                                gnssSettings.knownDevices[deviceName].locationMaximumPositionAge = value;
                                gnssSettings.knownDevices[deviceName].locationMaximumDataAge = value;
                                if (isTheActiveSensor) {
                                    gnssSettings.locationMaximumPositionAge = value;
                                    gnssSettings.locationMaximumDataAge = value;
                                }
                            }

                            changed();
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 16 * AppFramework.displayScaleFactor
                Layout.rightMargin: 16 * AppFramework.displayScaleFactor

                spacing: 10 * AppFramework.displayScaleFactor

                StyledImage {
                    Layout.preferredWidth: 24 * AppFramework.displayScaleFactor
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignTop

                    source: "../images/round_info_white_24dp.png"
                    color: alertsTab.helpTextColor
                }

                AppText {
                    Layout.fillWidth: true

                    text: qsTr("Alerts are triggered when the status of your connection changes. This includes receiver disconnection or data not being received.")
                    color: alertsTab.helpTextColor

                    fontFamily: alertsTab.fontFamily
                    letterSpacing: alertsTab.helpTextLetterSpacing
                    pixelSize: 12 * AppFramework.displayScaleFactor
                    bold: false

                    LayoutMirroring.enabled: false

                    horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    //--------------------------------------------------------------------------
}
