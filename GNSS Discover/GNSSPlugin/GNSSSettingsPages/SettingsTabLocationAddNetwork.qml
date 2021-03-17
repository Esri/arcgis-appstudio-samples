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

import "../controls"

SettingsTab {
    id: addNetworkTab

    title: qsTr("Network information")

    signal showReceiverSettingsPage(var deviceName)

    //--------------------------------------------------------------------------

    Item {
        id: _item

        Accessible.role: Accessible.Pane

        // Internal properties -------------------------------------------------

        property alias hostname: hostnameTextField.text
        property alias port: portTextField.value

        property bool initialized

        // ---------------------------------------------------------------------

        Component.onCompleted: {
            _item.initialized = true;

            controller.onDetailedSettingsPage = true;
        }

        // ---------------------------------------------------------------------

        Component.onDestruction: {
            controller.onDetailedSettingsPage = false;
        }

        // ---------------------------------------------------------------------

        ColumnLayout {
            anchors.fill: parent

            spacing: 0

            Accessible.role: Accessible.Pane

            // -----------------------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: addNetworkTab.listDelegateHeightTextBox
                color: addNetworkTab.listBackgroundColor

                AppTextField {
                    id: hostnameTextField

                    anchors.fill: parent
                    anchors.topMargin: 2 * AppFramework.displayScaleFactor
                    anchors.bottomMargin: 2 * AppFramework.displayScaleFactor
                    anchors.leftMargin: 10 * AppFramework.displayScaleFactor
                    anchors.rightMargin: 10 * AppFramework.displayScaleFactor

                    placeholderText: qsTr("Hostname")

                    textColor: addNetworkTab.textColor
                    borderColor: addNetworkTab.textColor
                    selectedColor: addNetworkTab.selectedForegroundColor
                    backgroundColor: addNetworkTab.listBackgroundColor
                    fontFamily: addNetworkTab.fontFamily
                    letterSpacing: addNetworkTab.letterSpacing
                    locale: addNetworkTab.locale
                    isRightToLeft: addNetworkTab.isRightToLeft
                }
            }

            // -----------------------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: addNetworkTab.listDelegateHeightTextBox
                color: addNetworkTab.listBackgroundColor

                AppNumberField {
                    id: portTextField

                    anchors.fill: parent
                    anchors.topMargin: 2 * AppFramework.displayScaleFactor
                    anchors.bottomMargin: 2 * AppFramework.displayScaleFactor
                    anchors.leftMargin: 10 * AppFramework.displayScaleFactor
                    anchors.rightMargin: 10 * AppFramework.displayScaleFactor

                    placeholderText: qsTr("Port")

                    textColor: addNetworkTab.textColor
                    borderColor: addNetworkTab.textColor
                    selectedColor: addNetworkTab.selectedForegroundColor
                    backgroundColor: addNetworkTab.listBackgroundColor
                    fontFamily: addNetworkTab.fontFamily
                    letterSpacing: addNetworkTab.letterSpacing
                    locale: addNetworkTab.locale
                    isRightToLeft: addNetworkTab.isRightToLeft
                }
            }

            // -----------------------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: addNetworkTab.listDelegateHeightTextBox
                color: addNetworkTab.listBackgroundColor

                SimpleButton {
                    enabled: _item.hostname > "" && Number.isInteger(_item.port) && _item.port > 0
                    opacity: enabled ? 1 : 0.5

                    horizontalPadding: 32 * AppFramework.displayScaleFactor
                    height: 40 * AppFramework.displayScaleFactor

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 18 * AppFramework.displayScaleFactor

                    text: qsTr("ADD")

                    textColor: addNetworkTab.listBackgroundColor
                    backgroundColor: addNetworkTab.selectedForegroundColor
                    pressedTextColor: addNetworkTab.textColor
                    hoveredTextColor: addNetworkTab.textColor
                    pressedBackgroundColor: addNetworkTab.selectedForegroundColor
                    hoveredBackgroundColor: addNetworkTab.hoverBackgroundColor
                    fontFamily: addNetworkTab.fontFamily

                    onClicked: {
                        var networkName = gnssSettings.createNetworkSettings(_item.hostname, _item.port);
                        controller.networkHostSelected(_item.hostname, _item.port);
                        showReceiverSettingsPage(networkName);
                    }
                }
            }

            // -----------------------------------------------------------------

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        // ---------------------------------------------------------------------
    }
}
