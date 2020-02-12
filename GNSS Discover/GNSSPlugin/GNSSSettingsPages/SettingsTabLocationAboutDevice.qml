/* Copyright 2019 Esri
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
import QtQuick.Layouts 1.3

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

    //--------------------------------------------------------------------------

    property bool initialized
    property bool dirty: false

    readonly property bool isTheActiveSensor: deviceName === gnssSettings.kInternalPositionSourceName || controller.currentName === deviceName

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
                Layout.preferredHeight: aboutDeviceTab.listDelegateHeight
                color: aboutDeviceTab.listBackgroundColor

                visible: deviceType !== kDeviceTypeInternal

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
                            gnssSettings.knownDevices[deviceName].label = text;
                            if (isTheActiveSensor) {
                                gnssSettings.lastUsedDeviceLabel = text;
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
                    Layout.preferredHeight: aboutDeviceTab.listDelegateHeight
                    color: aboutDeviceTab.listBackgroundColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20 * AppFramework.displayScaleFactor
                        anchors.rightMargin: 20 * AppFramework.displayScaleFactor

                        spacing: 10 * AppFramework.displayScaleFactor

                        AppText {
                            text: qsTr("Provider:")
                            color: aboutDeviceTab.textColor
                            wrapMode: Text.NoWrap

                            fontFamily: aboutDeviceTab.fontFamily
                            pixelSize: 14 * AppFramework.displayScaleFactor
                            letterSpacing: aboutDeviceTab.letterSpacing
                            bold: true

                            fontSizeMode: Text.HorizontalFit
                            minimumPixelSize: 8 * AppFramework.displayScaleFactor
                            elide: Text.ElideRight

                            LayoutMirroring.enabled: false

                            horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                        }

                        AppText {
                            Layout.fillWidth: parent

                            color: aboutDeviceTab.textColor
                            text: deviceType !== kDeviceTypeInternal ? deviceName : controller.integratedProviderName

                            fontFamily: aboutDeviceTab.fontFamily
                            pixelSize: 14 * AppFramework.displayScaleFactor
                            letterSpacing: aboutDeviceTab.letterSpacing
                            bold: false

                            fontSizeMode: Text.HorizontalFit
                            minimumPixelSize: 8 * AppFramework.displayScaleFactor
                            elide: Text.ElideRight

                            LayoutMirroring.enabled: false

                            horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: aboutDeviceTab.listDelegateHeight
                    color: aboutDeviceTab.listBackgroundColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20 * AppFramework.displayScaleFactor
                        anchors.rightMargin: 20 * AppFramework.displayScaleFactor

                        spacing: 10 * AppFramework.displayScaleFactor

                        AppText {
                            text: qsTr("Type:")
                            color: aboutDeviceTab.textColor
                            wrapMode: Text.NoWrap

                            fontFamily: aboutDeviceTab.fontFamily
                            pixelSize: 14 * AppFramework.displayScaleFactor
                            letterSpacing: aboutDeviceTab.letterSpacing
                            bold: true

                            fontSizeMode: Text.HorizontalFit
                            minimumPixelSize: 8 * AppFramework.displayScaleFactor
                            elide: Text.ElideRight

                            LayoutMirroring.enabled: false

                            horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                        }

                        AppText {
                            Layout.fillWidth: parent

                            color: aboutDeviceTab.textColor
                            text: deviceType

                            fontFamily: aboutDeviceTab.fontFamily
                            pixelSize: 14 * AppFramework.displayScaleFactor
                            letterSpacing: aboutDeviceTab.letterSpacing
                            bold: false

                            fontSizeMode: Text.HorizontalFit
                            minimumPixelSize: 8 * AppFramework.displayScaleFactor
                            elide: Text.ElideRight

                            LayoutMirroring.enabled: false

                            horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: aboutDeviceTab.listDelegateHeight
                    color: aboutDeviceTab.listBackgroundColor

                    visible: deviceType === kDeviceTypeFile

                    AppSwitch {
                        id: visualSwitch

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        checked: gnssSettings.knownDevices[deviceName].repeat
                                 ? gnssSettings.knownDevices[deviceName].repeat
                                 : false

                        text: qsTr("Loop at end of file")

                        textColor: aboutDeviceTab.textColor
                        checkedColor: aboutDeviceTab.selectedForegroundColor
                        backgroundColor: aboutDeviceTab.listBackgroundColor
                        hoverBackgroundColor: aboutDeviceTab.hoverBackgroundColor
                        fontFamily: aboutDeviceTab.fontFamily

                        onCheckedChanged: {
                            if (initialized && !gnssSettings.updating) {
                                gnssSettings.knownDevices[deviceName].repeat = checked;
                                if (isTheActiveSensor) {
                                    gnssSettings.repeat = checked;
                                }
                            }
                            changed();
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: aboutDeviceTab.listDelegateHeight
                    color: aboutDeviceTab.listBackgroundColor

                    visible: deviceType === kDeviceTypeFile

                    AppSlider {
                        id: updateSpinner

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        from: 1
                        to: 20
                        stepSize: 1

                        value: gnssSettings.knownDevices[deviceName].updateinterval
                               ? 1000 / gnssSettings.knownDevices[deviceName].updateinterval
                               : 1

                        text: qsTr("Update rate")
                        toolTipText: qsTr("%1 Hz").arg(value)

                        textColor: aboutDeviceTab.textColor
                        checkedColor: aboutDeviceTab.selectedForegroundColor
                        backgroundColor: aboutDeviceTab.listBackgroundColor
                        hoverBackgroundColor: aboutDeviceTab.hoverBackgroundColor
                        fontFamily: aboutDeviceTab.fontFamily
                        letterSpacing: aboutDeviceTab.letterSpacing
                        isRightToLeft: aboutDeviceTab.isRightToLeft

                        onValueChanged: {
                            if (initialized && !gnssSettings.updating) {
                                gnssSettings.knownDevices[deviceName].updateinterval = 1000 / value;
                                if (isTheActiveSensor) {
                                    gnssSettings.updateInterval = 1000 / value;
                                }
                            }
                            changed();
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
