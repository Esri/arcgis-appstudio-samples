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
    id: root1

    property color imageColor: "transparent"
    property bool clickable: false
    property bool isChecked: false
    property bool showRightButton: false
    property string txt: ""
    property bool isVisible:true
    property string rightButtonImage: "images/arrowDown.png"
    property url imageSource: ""
    property ListModel subLayersList
    readonly property color maskColor: "transparent"

    property alias rightButton: rightButton

    property color primaryColor: "steelBlue"
    property color accentColor: Qt.lighter(primaryColor)
    property real iconSize: root1.units(48)
    property real defaultMargin: root1.units(50)

    signal checked (bool checked)
    signal rightButtonClicked ()
    signal clicked ()

    height:  subLayersList.count > 0 ?root1.units(subLayersList.count * 56):root1.units(56)
    width: parent ? parent.width : 0
    padding: 0

    contentItem: Item{


       ColumnLayout{

        RowLayout {
            id:legrow

            Rectangle {
                color: "transparent"
                visible: imageSource.toString().length > 0
                Layout.preferredHeight: Math.min(parent.height, 0.6 * root1.iconSize)
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
                    color: root1.imageColor
                }
            }

            CheckBox {
                id: chkBox

                checked: isChecked
                visible: typeof checkBox !== "undefined"
                Material.accent: root1.accentColor
                Material.primary: root1.primaryColor
                Layout.alignment: Qt.AlignLeft

                onClicked: {
                    root1.checked(checked)
                }


            }



            Label{
                id: root3
                property string fontNameFallbacks: "Helvetica,Avenir"
                property string baseFontFamily: root3.getAppProperty (app.baseFontFamily, fontNameFallbacks)
                property string titleFontFamily: root3.getAppProperty (app.titleFontFamily, "")
                property string accentColor: root3.getAppProperty(app.accentColor)

                color: isVisible?root3.getAppProperty (app.baseTextColor, Qt.darker("#F7F8F8")):"#D3D3D3"
                font {
                    pointSize: root3.getAppProperty (app.baseFontSize, 14)
                    family: "%1,%2".arg(baseFontFamily).arg(fontNameFallbacks)
                }
                text: txt
                Layout.preferredHeight: contentHeight
                Layout.preferredWidth: root1.computeTextWidth()
                elide: Label.ElideMiddle
                Material.accent: accentColor
                wrapMode: Text.WordWrap
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (chkBox.visible) {
                            chkBox.checked = !chkBox.checked
                            root1.checked(chkBox.checked)
                        }
                    }
                }
                function getAppProperty (appProperty, fallback) {
                    if (!fallback) fallback = ""
                    try {
                        return appProperty ? appProperty : fallback
                    } catch (err) {
                        return fallback
                    }
                }

            }



            SpaceFiller {
                objectName: "spaceFiller"

            }

            Icon {
                id: rightButton

                objectName: "rightButton"
                visible: root1.showRightButton
                maskColor: root1.primaryColor
                imageSource: root1.rightButtonImage
                Layout.alignment: Qt.AlignRight

                onClicked: {
                    root1.rightButtonClicked()
                }
            }


        }

        Repeater{
            model:subLayersList
            RowLayout{


                Item{
                    width:1.4 * root1.iconSize
                    height: 0.6 * root1.iconSize
                }
                Image {
                    id: layerimage
                    sourceSize.width: app.fontScale * 0.3 * app.iconSize
                    sourceSize.height: app.fontScale * 0.3 * app.iconSize
                    source: "images/layer.png"
                    asynchronous: true
                    smooth: true
                    fillMode: Image.PreserveAspectCrop
                    mipmap:true


                }

                ColorOverlay{

                    Layout.fillHeight: true
                    source: layerimage
                    color: maskColor
                }



                Item{
                    width:0.4 * root1.iconSize
                    height: 0.5 * root1.iconSize
                }

                BaseText {
                    id: lbl

                    objectName: "label"
                    visible: layerName.length > 0
                    text: layerName
                    Layout.preferredWidth: root1.computeTextWidth() - 80 * AppFramework.displayScaleFactor
                    Layout.preferredHeight: contentHeight
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap

                }
            }
        }
        }


        Ink {
            objectName: "ink"
            visible: root1.clickable
            anchors.fill: parent

            onClicked: {
                root1.clicked()
            }
        }
    }
    function computeTextWidth () {
        var textWidth = parent.width
        return textWidth - root1.defaultMargin
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}



