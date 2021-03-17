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
    id: antennaHeightTab

    title: qsTr("Antenna height")
    icon: "../images/sharp_vertical_align_top_white_24dp.png"
    description: ""

    property string deviceType: ""
    property string deviceName: ""
    property string deviceLabel: ""

    //--------------------------------------------------------------------------

    readonly property bool isTheActiveSensor: deviceName === gnssSettings.kInternalPositionSourceName || controller.currentName === deviceName

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

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: antennaHeightTab.listDelegateHeightTextBox
                color: antennaHeightTab.listBackgroundColor

                AppNumberField {
                    id: antennaHeightField

                    anchors.fill: parent
                    anchors.topMargin: 2 * AppFramework.displayScaleFactor
                    anchors.bottomMargin: 2 * AppFramework.displayScaleFactor
                    anchors.leftMargin: 10 * AppFramework.displayScaleFactor
                    anchors.rightMargin: 10 * AppFramework.displayScaleFactor

                    value: CC.toLocaleLength(gnssSettings.knownDevices[deviceName].antennaHeight, locale, 10)

                    suffixText: CC.localeLengthSuffix(locale)
                    placeholderText: qsTr("Antenna height")

                    textColor: antennaHeightTab.textColor
                    borderColor: antennaHeightTab.textColor
                    selectedColor: antennaHeightTab.selectedForegroundColor
                    backgroundColor: antennaHeightTab.listBackgroundColor
                    fontFamily: antennaHeightTab.fontFamily
                    letterSpacing: antennaHeightTab.letterSpacing
                    locale: antennaHeightTab.locale
                    isRightToLeft: antennaHeightTab.isRightToLeft

                    onValueChanged: {
                        var val = CC.fromLocaleLength(value, locale, 10)
                        if (initialized && !gnssSettings.updating) {
                            gnssSettings.knownDevices[deviceName].antennaHeight = val;
                            if (isTheActiveSensor) {
                                gnssSettings.locationAntennaHeight = val;
                            }
                        }

                        changed();
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
                    color: antennaHeightTab.helpTextColor
                }

                AppText {
                    Layout.fillWidth: true

                    text: qsTr("This is the distance from the antenna to the ground. The antenna height is subtracted from altitude values.")
                    color: antennaHeightTab.helpTextColor

                    fontFamily: antennaHeightTab.fontFamily
                    letterSpacing: antennaHeightTab.helpTextLetterSpacing
                    pixelSize: 12 * AppFramework.displayScaleFactor
                    bold: false

                    LayoutMirroring.enabled: false

                    horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.leftMargin: 20 * AppFramework.displayScaleFactor
                Layout.rightMargin: 20 * AppFramework.displayScaleFactor

                color: "transparent"

                Image {
                    anchors.fill: parent

                    source: "../images/antenna_height_large.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
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
