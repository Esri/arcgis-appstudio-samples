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
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.3

import ArcGIS.AppFramework 1.0

import "../controls"

SettingsTab {
    id: addNemaLogTab

    title: qsTr("File information")

    property bool isAndroid: Qt.platform.os === "android"
    property bool isIOS: Qt.platform.os === "ios"

    property string logFileLocation: AppFramework.userHomePath + "/ArcGIS/" + Qt.application.name
    property string fileName
    property url fileUrl

    signal showReceiverSettingsPage(var deviceName)
    signal clear()

    //--------------------------------------------------------------------------

    onClear: {
        fileName = "";
        fileUrl = "";
    }

    //--------------------------------------------------------------------------

    Item {
        id: _item

        Accessible.role: Accessible.Pane

        // Internal properties -------------------------------------------------

        property bool initialized

        // ---------------------------------------------------------------------

        Component.onCompleted: {
            _item.initialized = true;

            controller.onDetailedSettingsPage = true;
        }

        // ---------------------------------------------------------------------

        Component.onDestruction: {
            controller.onDetailedSettingsPage = false;
            clear();
        }

        // ---------------------------------------------------------------------

        ColumnLayout {
            anchors.fill: parent

            spacing: 0

            Accessible.role: Accessible.Pane

            // -----------------------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: addNemaLogTab.listDelegateHeight
                color: addNemaLogTab.listBackgroundColor

                AppTextField {
                    id: fileNameTextField

                    anchors.fill: parent
                    anchors.topMargin: 2 * AppFramework.displayScaleFactor
                    anchors.bottomMargin: 2 * AppFramework.displayScaleFactor
                    anchors.leftMargin: 10 * AppFramework.displayScaleFactor
                    anchors.rightMargin: 10 * AppFramework.displayScaleFactor

                    placeholderText: qsTr("NMEA log file")

                    text: fileName
                    textColor: addNemaLogTab.textColor
                    borderColor: addNemaLogTab.textColor
                    selectedColor: addNemaLogTab.selectedForegroundColor
                    backgroundColor: addNemaLogTab.listBackgroundColor
                    fontFamily: addNemaLogTab.fontFamily
                    letterSpacing: addNemaLogTab.letterSpacing
                    locale: addNemaLogTab.locale
                    isRightToLeft: addNemaLogTab.isRightToLeft

                    readOnly: true

                    onPressed: {
                        fileDialog.folder = fileFolder.url
                        fileDialog.open()
                    }

                    onCleared: addNemaLogTab.clear()
                }
            }

            // -----------------------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: addNemaLogTab.listDelegateHeight
                color: addNemaLogTab.listBackgroundColor

                SimpleButton {
                    enabled: fileUrl > ""
                    opacity: enabled ? 1 : 0.5

                    horizontalPadding: 32 * AppFramework.displayScaleFactor
                    height: 40 * AppFramework.displayScaleFactor

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 18 * AppFramework.displayScaleFactor

                    text: qsTr("ADD")

                    textColor: addNemaLogTab.listBackgroundColor
                    backgroundColor: addNemaLogTab.selectedForegroundColor
                    pressedTextColor: addNemaLogTab.textColor
                    hoveredTextColor: addNemaLogTab.textColor
                    pressedBackgroundColor: addNemaLogTab.selectedForegroundColor
                    hoveredBackgroundColor: addNemaLogTab.hoverBackgroundColor
                    fontFamily: addNemaLogTab.fontFamily

                    onClicked: {
                        var file = isAndroid ? AppFramework.file("" + fileUrl) : AppFramework.file(fileUrl);
                        var path = isIOS ? file.path.replace(AppFramework.userHomePath + "/", "") : file.path;

                        var name = gnssSettings.createNmeaLogFileSettings(path);
                        controller.nmeaLogFileSelected(path);
                        showReceiverSettingsPage(name);
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

        // XXX This is a workaround for issue https://devtopia.esri.com/Melbourne/Player/issues/837
        // XXX The app crashes after selecting a file if the FileDialog is instantiated more than once
        // XXX See also GNSSPlugin/GNSSSettingsPages.qml
        /*
        FileDialog {
            id: fileDialog

            title: qsTr("Select a GPS log file")
            nameFilters: ["GPS log files (*.txt *.log *.nmea)"]
            folder: fileFolder.url

            onAccepted: {
                addNetworkTab.fileUrl = fileUrl

                var name = fileUrl.toString().replace(/%2F/g, "/")
                fileName = name.substring(name.lastIndexOf("/") + 1)
            }
        }
        */
        Connections {
            target: fileDialog

            onAccepted: {
                addNemaLogTab.fileUrl = fileDialog.fileUrl

                var name = fileDialog.fileUrl.toString().replace(/%2F/g, "/")
                fileName = name.substring(name.lastIndexOf("/") + 1)
            }
        }

        // ---------------------------------------------------------------------

        FileFolder {
            id: fileFolder

            path: logFileLocation
        }

        // ---------------------------------------------------------------------
    }
}
