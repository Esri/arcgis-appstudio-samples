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
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Authentication 1.0

Item {
    id: dialog

    anchors.fill: parent
    visible: false

    //-----------------------------------------------------------------------------------

    property string title: ""
    property string description: ""
    property string leftBtnString: ""
    property string rightBtnString: ""
    property var leftFunction
    property var rightFunction

    property color backgroundColor: "#ffffff"
    property color buttonColor: "#007ac2"
    property color titleColor: "#303030"
    property color textColor: "#303030"

    property string fontFamily: Qt.application.font.family
    property string thumbnail: ""

    property var buttonFunctions: []
    property var buttonDisplays: []
    property var cancelFunction

    property int mode: 1 //1 - two buttons, 2 - list buttons

    signal clickLeft()
    signal clickRight()

    signal clickButton(var index)

    readonly property real scaleFactor: AppFramework.displayScaleFactor
    readonly property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    //-----------------------------------------------------------------------------------

    function resetDialog() {
        title = "";
        description = "";
        leftBtnString = "";
        rightBtnString = "";
        thumbnail = ""
        mode = 1

        buttonFunctions = [];
        buttonDisplays = []
        cancelFunction = function() {}
    }

    function openDialog(dialogDescription, dialogLeftStr, dialogRightStr, left, right) {
        resetDialog();

        mode = 1

        description = dialogDescription;
        leftBtnString = dialogLeftStr;
        rightBtnString = dialogRightStr;
        leftFunction = left;
        rightFunction = right;

        dialog.visible = true
    }

    function openDialogWithTitle(dialogTitle, dialogDescription, dialogLeftStr, dialogRightStr, left, right) {
        resetDialog();

        mode = 1

        title = dialogTitle;
        description = dialogDescription
        leftBtnString = dialogLeftStr;
        rightBtnString = dialogRightStr;
        leftFunction = left;
        rightFunction = right;

        dialog.visible = true
    }

    function openComplexDialog(dialogTitle, dialogDescription, dialogButtonDisplays, dialogButtonFunctions, dialogCancelFunction, dialogThumbnail) {
        resetDialog();

        mode = 2

        title = dialogTitle;
        description = dialogDescription
        buttonDisplays = dialogButtonDisplays
        buttonFunctions = dialogButtonFunctions
        cancelFunction = dialogCancelFunction
        thumbnail = dialogThumbnail || ""

        dialog.visible = true
    }

    //-----------------------------------------------------------------------------------
    // backbutton handling

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus();
        }
    }

    Keys.onReleased: {
        if (visible) {
            if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
                event.accepted = true
                visible = false;
            }
        }
    }

    //-----------------------------------------------------------------------------------
    // mask

    Rectangle {
        anchors.fill: parent
        color: "#66000000"

        MouseArea {
            anchors.fill: parent
            preventStealing: true
            onClicked: {
                cancelFunction();
                dialog.visible = false;
            }
        }
    }

    Item {
        width: Math.min(280 * scaleFactor, parent.width * 0.8)
        height: container.height
        anchors.centerIn: parent
        visible: true

        MouseArea {
            anchors.fill: parent
            preventStealing: true
            onClicked: {

            }
        }

        //-----------------------------------------------------------------------------------
        // popup background

        Rectangle {
            id: rect
            color: backgroundColor
            anchors.fill: parent
        }

        //-----------------------------------------------------------------------------------

        ColumnLayout {
            id: container

            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 24 * scaleFactor
            }

            Label {
                Layout.preferredWidth: parent.width - 48 * scaleFactor
                Layout.alignment: Qt.AlignHCenter

                text: title
                visible: title > ""

                font.pixelSize: 20 * scaleFactor
                font.family: dialog.fontFamily
                font.letterSpacing: 0.15 * scaleFactor
                font.bold: true
                color: dialog.titleColor
                lineHeight: 27 * scaleFactor
                lineHeightMode: Text.FixedHeight

                padding: 0

                wrapMode: Text.Wrap

                LayoutMirroring.enabled: false

                horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
            }

            Image {
                Layout.preferredHeight: 120 * scaleFactor
                Layout.preferredWidth: 120 * scaleFactor
                Layout.alignment: Qt.AlignHCenter

                source: thumbnail
                fillMode: Image.PreserveAspectFit
                visible: thumbnail > ""
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: thumbnail > "" ? 24 * scaleFactor : 8 * scaleFactor
                visible: (title > "" || thumbnail > "") && description > ""
            }

            Label {
                Layout.preferredWidth: parent.width - 48 * scaleFactor
                Layout.alignment: Qt.AlignHCenter

                text: description
                visible: description > ""

                font.pixelSize: 16 * scaleFactor
                font.family: dialog.fontFamily
                color: dialog.textColor
                font.letterSpacing: 0
                lineHeight: 24 * scaleFactor
                lineHeightMode: Text.FixedHeight

                padding: 0

                wrapMode: Text.Wrap

                horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 24 * scaleFactor
            }

            //-----------------------------------------------------------------------------------

            Item {
                Layout.preferredWidth: parent.width - 32 * scaleFactor
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 36 * scaleFactor

                visible: mode === 1

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Label {
                        Layout.preferredWidth: Math.min(implicitWidth, parent.width / 2)
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter

                        text: leftBtnString
                        visible: text > ""
                        rightPadding: 8 * scaleFactor
                        leftPadding: rightPadding

                        font.pixelSize: 14 * scaleFactor
                        font.family: dialog.fontFamily
                        font.letterSpacing: 0.75 * scaleFactor
                        font.bold: true
                        lineHeight: 19 * scaleFactor
                        lineHeightMode: Text.FixedHeight
                        color: buttonColor
                        elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                dialog.visible = false
                                leftFunction();
                                clickLeft();
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 8 * scaleFactor
                    }

                    Label {
                        id: rightBtn

                        Layout.preferredWidth: Math.min(implicitWidth, parent.width / 2)
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter

                        text: rightBtnString
                        visible: text > ""
                        rightPadding: 8 * scaleFactor
                        leftPadding: rightPadding

                        font.pixelSize: 14 * scaleFactor
                        font.family: dialog.fontFamily
                        font.letterSpacing: 0.75 * scaleFactor
                        font.bold: true
                        lineHeight: 19 * scaleFactor
                        lineHeightMode: Text.FixedHeight
                        color: buttonColor
                        elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                dialog.visible = false
                                rightFunction();
                                clickRight();
                            }
                        }
                    }
                }
            }

            Item {
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: buttonsLayout.height
                visible: mode === 2

                ColumnLayout {
                    id: buttonsLayout
                    width: parent.width
                    spacing: 0

                    Repeater {
                        model: buttonDisplays

                        delegate: Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52 * scaleFactor

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0

                                Item {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 8 * scaleFactor
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                }

                                Label {
                                    Layout.maximumWidth: parent.width - 16 * scaleFactor
                                    Layout.preferredHeight: 36 * scaleFactor
                                    font.pixelSize: 14 * scaleFactor
                                    font.family: dialog.fontFamily
                                    font.letterSpacing: 0.75 * scaleFactor
                                    color: buttonDisplays[index].color || buttonColor
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 12 * scaleFactor
                                    rightPadding: leftPadding
                                    text: buttonDisplays[index].title
                                    elide: isRightToLeft ? Text.ElideLeft : Text.ElideRight

                                    LayoutMirroring.enabled: false
                                    horizontalAlignment: isRightToLeft ? Text.AlignRight : Text.AlignLeft

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            buttonFunctions[index]()
                                            clickButton(index)
                                            dialog.visible = false
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 8 * scaleFactor
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16 * scaleFactor
            }
        }
    }
}
