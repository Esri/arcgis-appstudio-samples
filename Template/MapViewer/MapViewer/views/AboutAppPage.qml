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
 *
 */

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1


import "../controls" as Controls

Controls.PopupPage {
    id: aboutAppPage

    property string poweredby:qsTr("Powered by")

    contentItem: Controls.BasePage {

        header: ToolBar {

            id: header

            height: app.headerHeight
            width: parent.width

            RowLayout {
                anchors.fill: parent

                Controls.Icon {
                    id: closeBtn

                    visible: true
                    imageSource: "../controls/images/close.png"
                    Layout.alignment: Qt.AlignLeft
                    onClicked: {
                        aboutAppPage.close()
                    }
                }

                Controls.BaseText {
                    text: qsTr("About the App")
                    maximumLineCount: 1
                    fontSizeMode: Text.Fit
                    color: "#FFFFFF"
                    font {
                        pointSize: app.subtitleFontSize
                    }
                    Layout.alignment: Qt.AlignLeft
                }

                Controls.SpaceFiller {
                    Layout.fillWidth: true
                }

            }
        }

        contentItem: Flickable {

            contentHeight: flickableContent.height
            contentWidth: parent.width

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: app.defaultMargin
            }

            ColumnLayout {
                id: flickableContent

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                width: Math.min(parent.width - 2 * app.defaultMargin, app.preferredContentWidth)

                Controls.SubtitleText {
                    text: qsTr("Description")
                    visible: descriptionTxt.text > ""
                    Layout.preferredWidth: parent.width
                    textFormat: Text.StyledText
                }
                Controls.BaseText {
                    id: descriptionTxt

                    visible: descriptionTxt.text > ""
                    text: app.info.itemInfo.description
                    Layout.preferredWidth: parent.width
                    textFormat: Text.StyledText
                    onLinkActivated: {
                        app.openUrlInternally(link)
                    }
                }

                Controls.SpaceFiller { Layout.preferredHeight: app.defaultMargin }

                Controls.SubtitleText {
                    visible: licenseInfo.text > ""
                    text: qsTr("Access and Use Constraints")
                    Layout.preferredWidth: parent.width
                    textFormat: Text.StyledText
                }
                Controls.BaseText {
                    id: licenseInfo

                    visible: licenseInfo.text > ""
                    text: app.info.itemInfo.licenseInfo
                    Layout.preferredWidth: parent.width
                    textFormat: Text.StyledText
                    onLinkActivated: {
                        app.openUrlInternally(link)
                    }
                }

                Controls.SpaceFiller { Layout.preferredHeight: app.defaultMargin }

                Controls.SubtitleText {
                    visible: accessInfo.text > ""
                    text: qsTr("Credits")
                    Layout.preferredWidth: parent.width
                    textFormat: Text.StyledText
                }
                Controls.BaseText {
                    id: accessInfo

                    visible: accessInfo.text > ""
                    text: app.info.itemInfo.accessInformation
                    Layout.preferredWidth: parent.width
                    textFormat: Text.StyledText
                    onLinkActivated: {
                        app.openUrlInternally(link)
                    }
                }

                Controls.SpaceFiller { Layout.preferredHeight: app.defaultMargin }

                Controls.SubtitleText {
                    visible: versionTxt.text > ""
                    text: qsTr("App Version")
                    Layout.preferredWidth: parent.width
                    textFormat: Text.StyledText
                }
                Controls.BaseText {
                    id: versionTxt

                    visible: versionTxt.text > ""
                    text: app.info.version
                    Layout.preferredWidth: parent.width
                    textFormat: Text.StyledText
                    onLinkActivated: {
                        app.openUrlInternally(link)
                    }
                }

                Controls.SpaceFiller { Layout.preferredHeight: app.defaultMargin }

                Controls.SubtitleText {
                    visible:true
                    text: qsTr("About the App")
                    Layout.preferredWidth: parent.width
                    textFormat: Text.StyledText
                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8
                }
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48 * scaleFactor

                    RowLayout {
                        id: powerByRow

                        anchors.fill: parent

                        spacing: 0



                        IconImage {
                            Layout.preferredWidth: 48 * scaleFactor
                            Layout.fillHeight: true

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {

                                    openAppStudioUrl();
                                }
                            }
                        }

                        Item {
                            Layout.preferredWidth: 16 * scaleFactor
                            Layout.fillHeight: true
                        }
                        Controls.BaseText {
                            id: poweredbyTxt

                            visible: true
                            text: poweredby

                            textFormat: Text.StyledText

                        }

                        Item {
                            Layout.preferredWidth: 4 * scaleFactor
                            Layout.fillHeight: true
                        }

                        Controls.BaseText {
                            id: appstudioTitle

                            visible: true
                            text: "AppStudio for ArcGIS"
                            Layout.preferredWidth: parent.width
                            textFormat: Text.StyledText
                            color: app.black_87
                            elide: Label.ElideRight
                            clip: true

                            font.bold: true
                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    openAppStudioUrl();
                                }
                            }
                        }




                        Item {
                            Layout.preferredWidth: 16 * scaleFactor
                            Layout.fillHeight: true
                        }
                    }
                }



                Controls.SpaceFiller { Layout.preferredHeight: app.defaultMargin }
            }
        }

        footer: Pane {
            height: app.heightOffset
            width: parent.width
        }
    }
    function openAppStudioUrl() {
        var _url = "https://appstudio.arcgis.com/";

        app.openUrlInternally(_url)


    }

    onVisibleChanged: {
        app.focus = true
    }


}
