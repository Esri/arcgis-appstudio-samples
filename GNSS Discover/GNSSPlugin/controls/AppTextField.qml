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

import ArcGIS.AppFramework 1.0

Item {
    id: control

    property alias length: textField.length
    property alias acceptableInput: textField.acceptableInput
    property alias inputMethodHints: textField.inputMethodHints
    property alias readOnly: textField.readOnly

    property alias text: textField.text
    property alias suffixText: suffixText.text
    property alias placeholderText: placeholderLabel.text

    property color textColor: "#000000"
    property color borderColor: "#c0c0c0"
    property color selectedColor: "#c0c0c0"
    property color backgroundColor: "transparent"

    property string fontFamily: Qt.application.font.family
    property real pixelSize: 14 * AppFramework.displayScaleFactor
    property real letterSpacing: 0
    property bool bold: false
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    property var locale: Qt.locale()

    property int animationDuration: 100

    signal pressed()
    signal cleared()

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        if (Qt.platform.os === "android") {
            inputMethodHints |= Qt.ImhNoPredictiveText;
        }
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: rect

        anchors.fill: parent

        border.width: textField.focus ? 2 * AppFramework.displayScaleFactor :  1 * AppFramework.displayScaleFactor
        border.color: textField.focus ? selectedColor : borderColor
        radius: 4 * AppFramework.displayScaleFactor

        color: backgroundColor

        anchors.top: parent.top
        anchors.margins: 8 * AppFramework.displayScaleFactor

        RowLayout {
            anchors.fill: parent
            spacing: 0

            LayoutMirroring.enabled: false

            layoutDirection: control.isRightToLeft ? Qt.RightToLeft : Qt.LeftToRight

            Item {
                id: startSpacing
                Layout.fillHeight: true
                Layout.preferredWidth: 16 * AppFramework.displayScaleFactor
            }

            TextField {
                id: textField

                Layout.preferredHeight: 24 * AppFramework.displayScaleFactor
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0

                LayoutMirroring.enabled: false

                horizontalAlignment: control.isRightToLeft ? Text.AlignRight : Text.AlignLeft

                font {
                    family: control.fontFamily
                    pixelSize: control.pixelSize
                    letterSpacing: control.letterSpacing
                    bold: control.bold
                }

                color: textColor
                Material.accent: selectedColor

                background: Rectangle {
                    anchors.fill: parent
                    color: backgroundColor
                }

                selectByMouse: true

                onPressed: control.pressed()
            }

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 8 * AppFramework.displayScaleFactor
            }

            AppText {
                id: suffixText

                visible: text > "" && textField.text > ""
                color: control.textColor

                fontFamily: control.fontFamily
                pixelSize: control.pixelSize
                letterSpacing: control.letterSpacing
                bold: control.bold

                wrapMode: Text.NoWrap
            }

            Item {
                visible: suffixText.text > ""
                Layout.fillHeight: true
                Layout.preferredWidth: 8 * AppFramework.displayScaleFactor
            }

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 24 * AppFramework.displayScaleFactor
                visible: textField.text > ""

                StyledImage {
                    width: 24 * AppFramework.displayScaleFactor
                    height: 24 * AppFramework.displayScaleFactor
                    anchors.centerIn: parent
                    source: "../images/clear.png"
                    color: textField.focus ? selectedColor : borderColor
                    visible: textField.text > ""
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (textField.text > "") {
                            textField.clear();
                            cleared();
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 12 * AppFramework.displayScaleFactor
            }
        }

        //--------------------------------------------------------------------------

        Label {
            id: placeholderLabel

            property bool showHintTop: control.text > "" || textField.focus

            visible: text > ""

            topPadding: 0
            bottomPadding: 0
            leftPadding: showHintTop ? 4 * AppFramework.displayScaleFactor : 0
            rightPadding: leftPadding

            font.family: control.fontFamily
            font.pixelSize: showHintTop ? 12 * AppFramework.displayScaleFactor : control.pixelSize
            font.letterSpacing: showHintTop ? 0 : control.letterSpacing

            color: showHintTop ? (textField.focus ? selectedColor : borderColor) : borderColor

            text: placeholderText

            x: isRightToLeft ? (showHintTop ? parent.width - 16 * AppFramework.displayScaleFactor - implicitWidth : parent.width - startSpacing.width - implicitWidth) : (showHintTop ? 16 * AppFramework.displayScaleFactor : startSpacing.width)
            y: showHintTop ? - placeholderLabel.height / 2 : rect.height / 2 - placeholderLabel.height / 2

            background: Rectangle {
                anchors.fill: parent
                color: backgroundColor
            }

            clip: true

            Behavior on x {
                SmoothedAnimation{duration: animationDuration}
            }

            Behavior on y {
                SmoothedAnimation{duration: animationDuration}
            }

            Behavior on font.pixelSize {
                SmoothedAnimation{duration: animationDuration}
            }
        }
    }
}
