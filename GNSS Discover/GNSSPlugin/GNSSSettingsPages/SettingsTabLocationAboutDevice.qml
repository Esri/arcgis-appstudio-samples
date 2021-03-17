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
    id: aboutDeviceTab

    title: qsTr("About")
    icon: "../images/round_info_white_24dp.png"
    description: ""

    property string deviceType: ""
    property string deviceName: ""
    property string deviceLabel: ""

    property bool showProviderAlias

    //--------------------------------------------------------------------------

    readonly property bool isTheActiveSensor: deviceName === gnssSettings.kInternalPositionSourceName || controller.currentName === deviceName

    property bool dirty: false
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
            if (dirty) {
                changed();
                dirty = false;
            }
        }

        ColumnLayout {
            anchors.fill: parent

            spacing: 10 * AppFramework.displayScaleFactor

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: aboutDeviceTab.listDelegateHeightTextBox
                color: aboutDeviceTab.listBackgroundColor

                visible: deviceType !== kDeviceTypeInternal && showProviderAlias

                AppTextField {
                    id: deviceLabel

                    anchors.fill: parent
                    anchors.topMargin: 2 * AppFramework.displayScaleFactor
                    anchors.bottomMargin: 2 * AppFramework.displayScaleFactor
                    anchors.leftMargin: 10 * AppFramework.displayScaleFactor
                    anchors.rightMargin: 10 * AppFramework.displayScaleFactor

                    text: gnssSettings.knownDevices[deviceName].label > "" ? gnssSettings.knownDevices[deviceName].label : deviceName
                    placeholderText: qsTr("Custom display name")

                    textColor: aboutDeviceTab.textColor
                    borderColor: aboutDeviceTab.textColor
                    selectedColor: aboutDeviceTab.selectedForegroundColor
                    backgroundColor: aboutDeviceTab.listBackgroundColor
                    fontFamily: aboutDeviceTab.fontFamily
                    letterSpacing: aboutDeviceTab.letterSpacing
                    locale: aboutDeviceTab.locale
                    isRightToLeft: aboutDeviceTab.isRightToLeft

                    onTextChanged: {
                        if (initialized && !gnssSettings.updating) {
                            var label = text;

                            if (deviceType === kDeviceTypeFile && !text) {
                                label = gnssSettings.fileUrlToLabel(gnssSettings.knownDevices[deviceName].filename);
                            }

                            gnssSettings.knownDevices[deviceName].label = label;
                            if (isTheActiveSensor) {
                                gnssSettings.lastUsedDeviceLabel = label;
                            }

                            dirty = true;
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: aboutDeviceTab.listSpacing

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: aboutDeviceTab.listDelegateHeightSingleLine
                    color: aboutDeviceTab.listBackgroundColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20 * AppFramework.displayScaleFactor
                        anchors.rightMargin: 20 * AppFramework.displayScaleFactor

                        spacing: 10 * AppFramework.displayScaleFactor

                        AppText {
                            text: qsTr("Provider:")
                            color: aboutDeviceTab.textColor

                            fontFamily: aboutDeviceTab.fontFamily
                            pixelSize: 14 * AppFramework.displayScaleFactor
                            letterSpacing: aboutDeviceTab.letterSpacing
                            bold: true

                            fontSizeMode: Text.HorizontalFit
                            minimumPixelSize: 12 * AppFramework.displayScaleFactor
                            elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight
                            wrapMode: Text.NoWrap

                            LayoutMirroring.enabled: false

                            horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                        }

                        AppText {
                            Layout.fillWidth: true

                            text: aboutDeviceTab.resolveDeviceName(deviceType, deviceName, true)
                            color: aboutDeviceTab.textColor

                            fontFamily: aboutDeviceTab.fontFamily
                            pixelSize: 14 * AppFramework.displayScaleFactor
                            letterSpacing: aboutDeviceTab.letterSpacing
                            bold: false

                            fontSizeMode: Text.HorizontalFit
                            minimumPixelSize: 12 * AppFramework.displayScaleFactor
                            elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight
                            maximumLineCount: 3

                            LayoutMirroring.enabled: false

                            horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: aboutDeviceTab.listDelegateHeightSingleLine
                    color: aboutDeviceTab.listBackgroundColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20 * AppFramework.displayScaleFactor
                        anchors.rightMargin: 20 * AppFramework.displayScaleFactor

                        spacing: 10 * AppFramework.displayScaleFactor

                        AppText {
                            text: qsTr("Type:")
                            color: aboutDeviceTab.textColor

                            fontFamily: aboutDeviceTab.fontFamily
                            pixelSize: 14 * AppFramework.displayScaleFactor
                            letterSpacing: aboutDeviceTab.letterSpacing
                            bold: true

                            fontSizeMode: Text.HorizontalFit
                            minimumPixelSize: 12 * AppFramework.displayScaleFactor
                            elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight
                            wrapMode: Text.NoWrap

                            LayoutMirroring.enabled: false

                            horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                        }

                        AppText {
                            Layout.fillWidth: true

                            text: deviceType
                            color: aboutDeviceTab.textColor

                            fontFamily: aboutDeviceTab.fontFamily
                            pixelSize: 14 * AppFramework.displayScaleFactor
                            letterSpacing: aboutDeviceTab.letterSpacing
                            bold: false

                            fontSizeMode: Text.HorizontalFit
                            minimumPixelSize: 12 * AppFramework.displayScaleFactor
                            elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight

                            LayoutMirroring.enabled: false

                            horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: aboutDeviceTab.listDelegateHeightSingleLine
                    color: aboutDeviceTab.listBackgroundColor

                    visible: deviceType === kDeviceTypeFile

                    AppSwitch {
                        id: visualSwitch

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        text: qsTr("Loop at end of file")

                        textColor: aboutDeviceTab.textColor
                        checkedColor: aboutDeviceTab.selectedForegroundColor
                        backgroundColor: aboutDeviceTab.listBackgroundColor
                        hoverBackgroundColor: aboutDeviceTab.hoverBackgroundColor

                        fontFamily: aboutDeviceTab.fontFamily
                        pixelSize: 14 * AppFramework.displayScaleFactor

                        checked: gnssSettings.knownDevices[deviceName].repeat
                                 ? gnssSettings.knownDevices[deviceName].repeat
                                 : false

                        onCheckedChanged: {
                            if (initialized && !gnssSettings.updating) {
                                gnssSettings.knownDevices[deviceName].repeat = checked;
                                if (isTheActiveSensor) {
                                    gnssSettings.repeat = checked;
                                }
                            }

                            dirty = true;
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: aboutDeviceTab.listDelegateHeightSingleLine
                    color: aboutDeviceTab.listBackgroundColor

                    visible: deviceType === kDeviceTypeFile

                    AppSlider {
                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        from: 1
                        to: 20
                        stepSize: 1

                        value: gnssSettings.knownDevices[deviceName].updateinterval
                               ? 1000 / gnssSettings.knownDevices[deviceName].updateinterval
                               : 1

                        text: qsTr("Position update rate")
                        toolTipText: qsTr("%1 Hz").arg(value)

                        textColor: aboutDeviceTab.textColor
                        checkedColor: aboutDeviceTab.selectedForegroundColor
                        backgroundColor: aboutDeviceTab.listBackgroundColor
                        hoverBackgroundColor: aboutDeviceTab.hoverBackgroundColor

                        fontFamily: aboutDeviceTab.fontFamily
                        pixelSize: 14 * AppFramework.displayScaleFactor
                        letterSpacing: aboutDeviceTab.letterSpacing
                        isRightToLeft: aboutDeviceTab.isRightToLeft

                        onValueChanged: {
                            if (initialized && !gnssSettings.updating) {
                                gnssSettings.knownDevices[deviceName].updateinterval = 1000 / value;
                                if (isTheActiveSensor) {
                                    gnssSettings.updateInterval = 1000 / value;
                                }
                            }

                            dirty = true;
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: aboutDeviceTab.listDelegateHeightSingleLine
                    color: aboutDeviceTab.listBackgroundColor

                    visible: deviceType === kDeviceTypeSerialPort

                    AppSlider {
                        readonly property var kBaudRate: [300, 600, 1200, 2400, 4800, 9600, 14400, 19200, 38400, 57600, 115200]
                        readonly property var receiver: gnssSettings.knownDevices[deviceName].receiver

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        from: 0
                        to: kBaudRate.length-1
                        stepSize: 1

                        value: receiver && receiver.address ? kBaudRate.indexOf(receiver.address.deviceBaudRate) : 0

                        text: qsTr("Baud rate")
                        toolTipText: qsTr("%1 Bd").arg(kBaudRate[value])

                        textColor: aboutDeviceTab.textColor
                        checkedColor: aboutDeviceTab.selectedForegroundColor
                        backgroundColor: aboutDeviceTab.listBackgroundColor
                        hoverBackgroundColor: aboutDeviceTab.hoverBackgroundColor

                        fontFamily: aboutDeviceTab.fontFamily
                        pixelSize: 14 * AppFramework.displayScaleFactor
                        letterSpacing: aboutDeviceTab.letterSpacing
                        isRightToLeft: aboutDeviceTab.isRightToLeft

                        onValueChanged: {
                            if (initialized && !gnssSettings.updating) {
                                gnssSettings.knownDevices[deviceName].receiver.address.deviceBaudRate = kBaudRate[value];
                                if (isTheActiveSensor) {
                                    controller.currentDevice.baudRate = kBaudRate[value]
                                }
                            }

                            dirty = true;
                        }
                    }
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
