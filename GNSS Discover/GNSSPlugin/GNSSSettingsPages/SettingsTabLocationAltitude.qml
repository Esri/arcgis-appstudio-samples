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
    id: altitudeTab

    title: qsTr("Altitude type")
    icon: "../images/sharp_terrain_white_24dp.png"
    description: ""

    property string deviceType: ""
    property string deviceName: ""
    property string deviceLabel: ""

    //--------------------------------------------------------------------------

    readonly property bool isTheActiveSensor: deviceName === gnssSettings.kInternalPositionSourceName || controller.currentName === deviceName

    readonly property string altitudeTypeMSLLabel: qsTr("Altitude above mean sea level")
    readonly property string altitudeTypeHAELabel: qsTr("Height above ellipsoid")

    property bool initialized

    signal changed()

    //--------------------------------------------------------------------------

    Item {
        id: _item

        Accessible.role: Accessible.Pane

        Component.onCompleted: {
            var altitudeType = gnssSettings.knownDevices[deviceName].altitudeType;

            if (altitudeType === gnssSettings.kAltitudeTypeMSL) {
                mslButton.checked = true;
            }

            if (altitudeType === gnssSettings.kAltitudeTypeHAE) {
                haeButton.checked = true;
            }

            updateDescriptions();
            initialized = true;
        }

        Component.onDestruction: {
        }

        ColumnLayout {
            anchors.fill: parent

            spacing: 10 * AppFramework.displayScaleFactor

            ColumnLayout {
                Layout.fillWidth: true

                spacing: altitudeTab.listSpacing

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: altitudeTab.listDelegateHeightSingleLine
                    color: altitudeTab.listBackgroundColor

                    AppRadioButton {
                        id: mslButton

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        text: altitudeTypeMSLLabel

                        textColor: altitudeTab.textColor
                        checkedColor: altitudeTab.selectedForegroundColor
                        backgroundColor: altitudeTab.listBackgroundColor
                        hoverBackgroundColor: altitudeTab.hoverBackgroundColor
                        fontFamily: altitudeTab.fontFamily
                        letterSpacing: altitudeTab.letterSpacing
                        isRightToLeft: altitudeTab.isRightToLeft

                        onCheckedChanged: {
                            if (initialized && !gnssSettings.updating && checked) {
                                haeButton.checked = false;
                                gnssSettings.knownDevices[deviceName].altitudeType = gnssSettings.kAltitudeTypeMSL;
                                if (isTheActiveSensor) {
                                    gnssSettings.locationAltitudeType = gnssSettings.kAltitudeTypeMSL;
                                }
                            }
                            changed();
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: altitudeTab.listDelegateHeightSingleLine
                    color: altitudeTab.listBackgroundColor

                    AppRadioButton {
                        id: haeButton

                        anchors.fill: parent
                        leftPadding: 20 * AppFramework.displayScaleFactor
                        rightPadding: 20 * AppFramework.displayScaleFactor

                        text: altitudeTypeHAELabel

                        textColor: altitudeTab.textColor
                        checkedColor: altitudeTab.selectedForegroundColor
                        backgroundColor: altitudeTab.listBackgroundColor
                        hoverBackgroundColor: altitudeTab.hoverBackgroundColor
                        fontFamily: altitudeTab.fontFamily
                        letterSpacing: altitudeTab.letterSpacing
                        isRightToLeft: altitudeTab.isRightToLeft

                        onCheckedChanged: {
                            if (initialized && !gnssSettings.updating && checked) {
                                mslButton.checked = false;
                                gnssSettings.knownDevices[deviceName].altitudeType = gnssSettings.kAltitudeTypeHAE;
                                if (isTheActiveSensor) {
                                    gnssSettings.locationAltitudeType = gnssSettings.kAltitudeTypeHAE;
                                }
                            }
                            changed();
                        }
                    }
                }
            }

            Item {
                visible: mslButton.checked

                Layout.fillWidth: true
                Layout.preferredHeight: geoidTabView.listTabView.contentHeight

                Accessible.role: Accessible.Pane

                ListTabView {
                    id: geoidTabView

                    anchors.fill: parent

                    backgroundColor: altitudeTab.backgroundColor
                    listSpacing: altitudeTab.listSpacing

                    delegate: settingsDelegate

                    SettingsTabLocationGeoid {
                        id: sensorGeoidSeparation

                        visible: mslButton.checked
                        enabled: visible

                        settingsTabContainer: altitudeTab.settingsTabContainer
                        settingsTabContainerComponent: altitudeTab.settingsTabContainerComponent

                        deviceType: altitudeTab.deviceType
                        deviceName: altitudeTab.deviceName
                        deviceLabel: altitudeTab.deviceLabel

                        onChanged: {
                            _item.updateDescriptions();
                        }
                    }

                    onSelected: pushItem(item)
                }
            }

            RowLayout {
                visible: mslButton.checked

                Layout.fillWidth: true
                Layout.leftMargin: 20 * AppFramework.displayScaleFactor
                Layout.rightMargin: 20 * AppFramework.displayScaleFactor

                spacing: 10 * AppFramework.displayScaleFactor

                StyledImage {
                    Layout.preferredWidth: 24 * AppFramework.displayScaleFactor
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignTop

                    source: "../images/round_info_white_24dp.png"
                    color: altitudeTab.helpTextColor
                }

                AppText {
                    Layout.fillWidth: true

                    text: qsTr('The geoid separation is the distance between mean sea level and the ellipsoid at your location. Set this if your location provider does not report this value.')
                    color: altitudeTab.helpTextColor

                    fontFamily: altitudeTab.fontFamily
                    letterSpacing: altitudeTab.helpTextLetterSpacing
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

        //--------------------------------------------------------------------------

        Component {
            id: settingsDelegate

            SettingsTabDelegate {
                listTabView: geoidTabView

                listDelegateHeightTextBox: altitudeTab.listDelegateHeightTextBox
                listDelegateHeightMultiLine: altitudeTab.listDelegateHeightMultiLine
                listDelegateHeightSingleLine: altitudeTab.listDelegateHeightSingleLine
                textColor: altitudeTab.textColor
                helpTextColor: altitudeTab.helpTextColor
                backgroundColor: altitudeTab.backgroundColor
                listBackgroundColor: altitudeTab.listBackgroundColor
                hoverBackgroundColor: altitudeTab.hoverBackgroundColor

                nextIconColor: altitudeTab.nextIconColor
                nextIconSize: altitudeTab.nextIconSize
                nextIcon: altitudeTab.nextIcon

                infoIconColor: altitudeTab.infoIconColor
                infoIconSize: altitudeTab.infoIconSize

                fontFamily: altitudeTab.fontFamily
                letterSpacing: altitudeTab.letterSpacing
                helpTextLetterSpacing: altitudeTab.helpTextLetterSpacing
                locale: altitudeTab.locale
                isRightToLeft: altitudeTab.isRightToLeft

                showInfoIcons: false
            }
        }

        //--------------------------------------------------------------------------

        function updateDescriptions(){

            var props = gnssSettings.knownDevices[deviceName] || null;

            if (props === null) {
                return;
            }

            if (props.geoidSeparation !== undefined) {
                sensorGeoidSeparation.description = isFinite(props.geoidSeparation)
                        ? CC.toLocaleLengthString(props.geoidSeparation, locale)
                        : CC.toLocaleLengthString(0, locale);
            }
        }
    }

    //--------------------------------------------------------------------------
}
