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

SettingsTab {
    id: accuracyTab

    title: qsTr("Accuracy")
    icon: "../images/sharp_gps_fixed_white_24dp.png"
    description: ""

    property string deviceType: ""
    property string deviceName: ""
    property string deviceLabel: ""

    //--------------------------------------------------------------------------

    readonly property bool isTheActiveSensor: deviceName === gnssSettings.kInternalPositionSourceName || controller.currentName === deviceName

    readonly property string confidenceLevelType68Label: qsTr("68%")
    readonly property string confidenceLevelType95Label: qsTr("95%")

    property bool initialized

    signal changed()

    //--------------------------------------------------------------------------

    Item {
        id: _item

        Accessible.role: Accessible.Pane

        Component.onCompleted: {
            var confidenceLevelType = gnssSettings.knownDevices[deviceName].confidenceLevelType;

            if (confidenceLevelType === gnssSettings.kConfidenceLevelType68) {
                sixtyeightButton.checked = true;
            }

            if (confidenceLevelType === gnssSettings.kConfidenceLevelType95) {
                ninetyfiveButton.checked = true;
            }

            initialized = true;
        }

        Component.onDestruction: {
        }

        ColumnLayout {
            anchors.fill: parent

            spacing: 10 * AppFramework.displayScaleFactor

            ColumnLayout {
                Layout.fillWidth: true

                spacing: accuracyTab.listSpacing

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: accuracyTab.listDelegateHeightSingleLine
                    color: accuracyTab.listBackgroundColor

                    AppRadioButton {
                        id: sixtyeightButton

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        text: confidenceLevelType68Label

                        textColor: accuracyTab.textColor
                        checkedColor: accuracyTab.selectedForegroundColor
                        backgroundColor: accuracyTab.listBackgroundColor
                        hoverBackgroundColor: accuracyTab.hoverBackgroundColor
                        fontFamily: accuracyTab.fontFamily
                        letterSpacing: accuracyTab.letterSpacing
                        isRightToLeft: accuracyTab.isRightToLeft

                        onCheckedChanged: {
                            if (initialized && !gnssSettings.updating && checked) {
                                ninetyfiveButton.checked = false;
                                gnssSettings.knownDevices[deviceName].confidenceLevelType = gnssSettings.kConfidenceLevelType68;
                                if (isTheActiveSensor) {
                                    gnssSettings.locationConfidenceLevelType = gnssSettings.kConfidenceLevelType68;
                                }
                            }

                            changed();
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: accuracyTab.listDelegateHeightSingleLine
                    color: accuracyTab.listBackgroundColor

                    AppRadioButton {
                        id: ninetyfiveButton

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        text: confidenceLevelType95Label

                        textColor: accuracyTab.textColor
                        checkedColor: accuracyTab.selectedForegroundColor
                        backgroundColor: accuracyTab.listBackgroundColor
                        hoverBackgroundColor: accuracyTab.hoverBackgroundColor
                        fontFamily: accuracyTab.fontFamily
                        letterSpacing: accuracyTab.letterSpacing
                        isRightToLeft: accuracyTab.isRightToLeft

                        onCheckedChanged: {
                            if (initialized && !gnssSettings.updating && checked) {
                                sixtyeightButton.checked = false;
                                gnssSettings.knownDevices[deviceName].confidenceLevelType = gnssSettings.kConfidenceLevelType95;
                                if (isTheActiveSensor) {
                                    gnssSettings.locationConfidenceLevelType = gnssSettings.kConfidenceLevelType95;
                                }
                            }

                            changed();
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 20 * AppFramework.displayScaleFactor
                Layout.rightMargin: 20 * AppFramework.displayScaleFactor

                spacing: 10 * AppFramework.displayScaleFactor

                StyledImage {
                    Layout.preferredWidth: 24 * AppFramework.displayScaleFactor
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignTop

                    source: "../images/round_info_white_24dp.png"
                    color: accuracyTab.helpTextColor
                }

                AppText {
                    Layout.fillWidth: true

                    text: qsTr("By default location providers report horizontal and vertical accuracy with a 68% confidence level. Choose 95% to report accuracy at a higher confidence.")
                    color: accuracyTab.helpTextColor

                    fontFamily: accuracyTab.fontFamily
                    letterSpacing: accuracyTab.helpTextLetterSpacing
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
