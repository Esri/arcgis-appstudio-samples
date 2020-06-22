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

 * This file is modified in version 4.1 to show the sublayers if it is a group layer
 */

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Pane {
    id: root

    property color imageColor: "transparent"
    property bool clickable: false
    property bool isChecked: false
    property bool showRightButton: false
    property string txt: ""
    property string rightButtonImage: "images/arrowDown.png"
    property url imageSource: ""
    property alias rightButton: rightButton

    property color primaryColor: "steelBlue"
    property color accentColor: Qt.lighter(primaryColor)
    property real iconSize: root.units(48)
    property real defaultMargin: root.units(16)

    signal checked (bool checked)
    signal rightButtonClicked ()
    signal clicked ()


    height:  root.units(56)
    width: parent ? parent.width : 0
    padding: 0

    contentItem: Item{

        RowLayout {
            id:legrow

            anchors {
                fill: parent
                leftMargin: 0.5 * root.defaultMargin
                rightMargin: 0.5 * root.defaultMargin
            }
            Rectangle {
                color: "transparent"
                visible: imageSource.toString().length > 0
                Layout.preferredHeight: Math.min(parent.height, 0.6 * root.iconSize)
                Layout.preferredWidth: 0.6 * root.iconSize
                Layout.alignment: Qt.AlignVCenter
                Layout.margins: 0

                Image {
                    id: img

                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: imageSource
                }

                ColorOverlay{
                    anchors.fill: img
                    source: img
                    color: root.imageColor
                }
            }

            CheckBox {
                id: chkBox

                checked: isChecked
                visible: typeof checkBox !== "undefined"
                Material.accent: root.accentColor
                Material.primary: root.primaryColor
                Layout.alignment: Qt.AlignLeft

                onClicked: {
                    root.checked(checked)
                }

            }

            BaseText {
                id: lbl

                objectName: "label"
                visible: txt.length > 0
                text: txt
                Layout.preferredWidth: root.computeTextWidth(parent.width, parent) - 70 * AppFramework.displayScaleFactor
                Layout.preferredHeight: contentHeight
                elide: Text.ElideMiddle
                wrapMode: Text.NoWrap

                //clip: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (chkBox.visible) {
                            chkBox.checked = !chkBox.checked
                        }
                    }
                }
            }

            SpaceFiller {
                objectName: "spaceFiller"
                //visible: img.visible || chkBox.visible || lbl.visible
            }

            Icon {
                id: rightButton

                objectName: "rightButton"
                visible: root.showRightButton
                maskColor: root.primaryColor
                imageSource: root.rightButtonImage
                Layout.alignment: Qt.AlignRight

                onClicked: {
                    root.rightButtonClicked()
                }
            }

        }

        Ink {
            objectName: "ink"
            visible: root.clickable
            anchors.fill: parent

            onClicked: {
                root.clicked()
            }
        }
    }
    function computeTextWidth (maxWidth, parentItem) {
        var textWidth = maxWidth,
                ommit = ["label", "spaceFiller", "ink"]
        for (var i=0; i<parentItem.children.length; i++) {
            if (ommit.indexOf(parentItem.children[i].objectName) === -1 && parentItem.children[i].visible) {
                textWidth -= parentItem.children[i].width
            }
        }
        return textWidth - root.defaultMargin
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}

