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

    readonly property bool isTheActiveSensor: deviceName === bluetoothSettings.kInternalPositionSourceName || controller.currentName === deviceName

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

                    text: bluetoothSettings.knownDevices[deviceName].label > "" ? bluetoothSettings.knownDevices[deviceName].label : deviceName
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
                        if (initialized && !bluetoothSettings.updating) {
                            bluetoothSettings.knownDevices[deviceName].label = text;
                            if (isTheActiveSensor) {
                                bluetoothSettings.lastUsedDeviceLabel = text;
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
                    Layout.preferredHeight: Math.max(label1.height, label2.height, aboutDeviceTab.listDelegateHeight)
                    color: aboutDeviceTab.listBackgroundColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20 * AppFramework.displayScaleFactor
                        anchors.rightMargin: 20 * AppFramework.displayScaleFactor

                        spacing: 10 * AppFramework.displayScaleFactor

                        AppText {
                            id: label1

                            text: qsTr("Printer:")
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
                            id: label2

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
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    //--------------------------------------------------------------------------
}
