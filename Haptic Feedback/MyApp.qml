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

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Notifications 1.0

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736

    Material.accent: "#8f499c"
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle{
            anchors.top:header.bottom
            ColumnLayout {
                spacing: 0
                width: parent.width

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20 * scaleFactor
                }

                Label {
                    Layout.fillWidth: true
                    text: "Haptic Feedback is %1 on your device.".arg(HapticFeedback.supported? "supported":"not supported").arg(HapticFeedback.supported? "Please make sure to enable vibration settings on your deivce.":"You can use it on iOS and Android platforms.")

                    font.pixelSize: 14 * scaleFactor
                    color: "#DE000000"
                    wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                    elide: Label.ElideRight
                    font.bold: true

                    leftPadding: 8 * scaleFactor
                    rightPadding: 8 * scaleFactor

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }

                Label {
                    Layout.fillWidth: true
                    visible: text > ""
                    text: "%1".arg(HapticFeedback.supported? (Qt.platform.os === "ios" ? "Please make sure to enable vibration setting on your deivce." : ""):"It is supported on iOS and Android platforms.")

                    font.pixelSize: 12 * scaleFactor
                    color: "#DE000000"
                    wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                    elide: Label.ElideRight
                    opacity: 0.6

                    leftPadding: 8 * scaleFactor
                    rightPadding: 8 * scaleFactor

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20 * scaleFactor
                }

                Label {
                    Layout.fillWidth: true
                    text: "IMPACT"

                    font.pixelSize: 20 * scaleFactor
                    color: "#DE000000"
                    wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                    elide: Label.ElideRight
                    font.bold: true

                    leftPadding: 16 * scaleFactor
                    rightPadding: 16 * scaleFactor

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8 * scaleFactor
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 116 * scaleFactor

                    RowLayout {
                        width: parent.width - 16 * scaleFactor
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 0

                        Controls.HapticFeedbackDelegate2 {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/3

                            imgSource: "../assets/wave1.svg"
                            title: "Light"
                            desc: "Light Vibration"
                            iconColor: Qt.darker("#8f499c")
                            type: "image"
                            hapticType: 0
                        }

                        Controls.HapticFeedbackDelegate2 {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/3

                            imgSource: "../assets/wave2.svg"
                            title: "Medium"
                            desc: "Medium Vibration"
                            iconColor: Qt.darker("#8f499c")
                            type: "image"
                            hapticType: 1
                        }

                        Controls.HapticFeedbackDelegate2 {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/3

                            imgSource: "../assets/wave3.svg"
                            title: "Heavy"
                            desc: "Heavy Vibration"
                            iconColor: Qt.darker("#8f499c")
                            type: "image"
                            hapticType: 2
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20 * scaleFactor
                }

                Label {
                    Layout.fillWidth: true
                    text: "NOTIFICATION"

                    font.pixelSize: 20 * scaleFactor
                    color: "#DE000000"
                    wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                    elide: Label.ElideRight
                    font.bold: true

                    leftPadding: 16 * scaleFactor
                    rightPadding: 16 * scaleFactor

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8 * scaleFactor
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 116 * scaleFactor

                    RowLayout {
                        width: parent.width - 16 * scaleFactor
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 0

                        Controls.HapticFeedbackDelegate2 {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/3

                            imgSource: "../assets/check-circle-32.svg"
                            title: "Success"
                            desc: "Action completed."
                            iconColor: "green"
                            type: "image"
                            hapticType: 4
                        }

                        Controls.HapticFeedbackDelegate2 {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/3

                            imgSource: "../assets/exclamation-mark-triangle-32.svg"
                            title: "Warning"
                            desc: "Action produced warning."
                            iconColor: "#e3bf09"
                            type: "image"
                            hapticType: 6
                        }

                        Controls.HapticFeedbackDelegate2 {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/3

                            imgSource: "../assets/exclamation-mark-circle-32.svg"
                            title: "Error"
                            desc: "Action failed."
                            iconColor: "red"
                            type: "image"
                            hapticType: 5
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20 * scaleFactor
                }

                Label {
                    Layout.fillWidth: true
                    text: "FEEDBACK"

                    font.pixelSize: 20 * scaleFactor
                    color: "#DE000000"
                    wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                    elide: Label.ElideRight
                    font.bold: true

                    leftPadding: 16 * scaleFactor
                    rightPadding: 16 * scaleFactor

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8 * scaleFactor
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 116 * scaleFactor

                    RowLayout {
                        width: parent.width - 16 * scaleFactor
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 0

                        Controls.HapticFeedbackDelegate2 {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/2

                            title: "Tick"
                            desc: "Feedback on tick gesture."
                            type: "check"
                            hapticType: 3
                        }

                        Controls.HapticFeedbackDelegate2 {
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width/2

                            title: "Select"
                            desc: "Feedback on select gesture."
                            type: "select"
                            hapticType: 7
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
             }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

