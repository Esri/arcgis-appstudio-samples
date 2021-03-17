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
import ArcGIS.AppFramework.Platform 1.0

import "../controls"

SettingsTab {
    id: addNmeaLogTab

    title: qsTr("Select file")

    property string logFileLocation: AppFramework.userHomePath + "/ArcGIS/" + Qt.application.name + "/Logs/"
    property string fileName
    property url fileUrl

    readonly property bool isAndroid: Qt.platform.os === "android"
    readonly property bool isIOS: Qt.platform.os === "ios"

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
                Layout.preferredHeight: addNmeaLogTab.listDelegateHeightTextBox
                color: addNmeaLogTab.listBackgroundColor

                AppTextField {
                    id: fileNameTextField

                    anchors.fill: parent
                    anchors.topMargin: 2 * AppFramework.displayScaleFactor
                    anchors.bottomMargin: 2 * AppFramework.displayScaleFactor
                    anchors.leftMargin: 10 * AppFramework.displayScaleFactor
                    anchors.rightMargin: 10 * AppFramework.displayScaleFactor

                    placeholderText: qsTr("NMEA log file")

                    text: fileName
                    textColor: addNmeaLogTab.textColor
                    borderColor: addNmeaLogTab.textColor
                    selectedColor: addNmeaLogTab.selectedForegroundColor
                    backgroundColor: addNmeaLogTab.listBackgroundColor
                    fontFamily: addNmeaLogTab.fontFamily
                    letterSpacing: addNmeaLogTab.letterSpacing
                    locale: addNmeaLogTab.locale
                    isRightToLeft: addNmeaLogTab.isRightToLeft

                    readOnly: true

                    onPressed: {
                        fileDialog.folder = fileFolder.url
                        fileDialog.open()
                    }

                    onCleared: addNmeaLogTab.clear()
                }
            }

            // -----------------------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: addNmeaLogTab.listDelegateHeightTextBox
                color: addNmeaLogTab.listBackgroundColor

                SimpleButton {
                    enabled: fileUrl > ""
                    opacity: enabled ? 1 : 0.5

                    horizontalPadding: 32 * AppFramework.displayScaleFactor
                    height: 40 * AppFramework.displayScaleFactor

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 18 * AppFramework.displayScaleFactor

                    text: qsTr("ADD")

                    textColor: addNmeaLogTab.listBackgroundColor
                    backgroundColor: addNmeaLogTab.selectedForegroundColor
                    pressedTextColor: addNmeaLogTab.textColor
                    hoveredTextColor: addNmeaLogTab.textColor
                    pressedBackgroundColor: addNmeaLogTab.selectedForegroundColor
                    hoveredBackgroundColor: addNmeaLogTab.hoverBackgroundColor
                    fontFamily: addNmeaLogTab.fontFamily

                    onClicked: {
                        var path = gnssSettings.fileUrlToPath(fileUrl)
                        gnssSettings.createNmeaLogFileSettings(path);
                        controller.nmeaLogFileSelected(path);
                        showReceiverSettingsPage(path);
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

        DocumentDialog {
            id: fileDialog

            title: qsTr("Select a GPS log file")
            nameFilters: ["GPS log files (*.txt *.log *.nmea)"]
            folder: fileFolder.url

            onAccepted: {
                var url = fileUrl;

                var src = AppFramework.fileInfo(fileUrl);
                var dest = fileFolder.filePath(src.fileName);

                if (src.filePath !== dest) {
                    if (!src.folder.copyFile(src.fileName, dest)) {
                        dest = fileFolder.filePath("%1-%2.%3".arg(src.baseName).arg(_item.dateStamp()).arg(src.suffix));

                        if (!src.folder.copyFile(src.fileName, dest)) {
                            clear();

                            gnssDialog.parent = stackView.currentItem;
                            gnssDialog.openDialogWithTitle(
                                        qsTr("Unable to add file"),
                                        qsTr("Please select another NMEA log file."),
                                        qsTr("OK"), qsTr(""),
                                        function() {}, function() {});

                            return;
                        }
                    }

                    url = AppFramework.fileInfo(dest).url;
                }

                addNmeaLogTab.fileUrl = url;
                addNmeaLogTab.fileName = gnssSettings.fileUrlToLabel(url);
            }
        }

        // ---------------------------------------------------------------------

        FileFolder {
            id: fileFolder

            path: logFileLocation

            onPathChanged: {
                makeFolder();
            }

            Component.onCompleted: {
                makeFolder();
            }
        }

        //-------------------------------------------------------------------------

        AppDialog {
            id: gnssDialog

            backgroundColor: addNmeaLogTab.listBackgroundColor
            buttonColor: addNmeaLogTab.selectedTextColor
            titleColor: addNmeaLogTab.textColor
            textColor: addNmeaLogTab.textColor
            fontFamily: addNmeaLogTab.fontFamily
        }

        //--------------------------------------------------------------------------

        function dateStamp(date) {
            if (!date) {
                date = new Date();
            }

            return "%1%2%3-%4%5%6"
            .arg(date.getFullYear().toString())
            .arg((date.getMonth() + 1).toString().padStart(2, "0"))
            .arg(date.getDate().toString().padStart(2, "0"))
            .arg(date.getHours().toString().padStart(2, "0"))
            .arg(date.getMinutes().toString().padStart(2, "0"))
            .arg(date.getSeconds().toString().padStart(2, "0"));
        }

        // ---------------------------------------------------------------------
    }
}
