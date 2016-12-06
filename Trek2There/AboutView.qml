/* Copyright 2016 Esri
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

import QtQuick 2.5
import QtQml 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtPositioning 5.4

import ArcGIS.AppFramework 1.0

Item {
    id: aboutView

    property int sideMargin: 14 * AppFramework.displayScaleFactor

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.fill: parent
        color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            //------------------------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                id: navBar
                color: nightMode === false ? dayModeSettings.background : nightModeSettings.background

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        id: backButtonContainer
                        Layout.fillHeight: true
                        Layout.preferredWidth: 50 * AppFramework.displayScaleFactor

                        Button {
                            anchors.fill: parent
                            style: ButtonStyle {
                                background: Rectangle {
                                    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                    anchors.fill: parent

                                    Image {
                                        id: backArrow
                                        source: "images/back_arrow.png"
                                        anchors.left: parent.left
                                        anchors.leftMargin: sideMargin
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - (30 * AppFramework.displayScaleFactor)
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    ColorOverlay {
                                        source: backArrow
                                        anchors.fill: backArrow
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    }
                                }
                            }

                            onClicked: {
                                mainStackView.pop();
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                        Text {
                            anchors.fill: parent
                            anchors.rightMargin: backButtonContainer.width
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("About")
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                        }
                    }
                }
            }

            //------------------------------------------------------------------

            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: 16 * AppFramework.displayScaleFactor
                color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground

                ColumnLayout{
                    anchors.fill: parent
                    spacing:0

                    //----------------------------------------------------------

                    Rectangle {
                        Layout.preferredHeight: 30 * AppFramework.displayScaleFactor
                        Layout.bottomMargin: 5 * AppFramework.displayScaleFactor
                        Layout.fillWidth: true
                        color: "transparent"

                        Text {
                            anchors.fill: parent
                            textFormat: Text.RichText
                            text: qsTr("<b>DESCRIPTION</b>")
                            verticalAlignment: Text.AlignBottom
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                        }
                    }

                    TextArea{
                        Layout.fillHeight: true
                        //Layout.preferredHeight: 200 * AppFramework.displayScaleFactor
                        Layout.fillWidth: true
                        readOnly: true
                        frameVisible: false
                        backgroundVisible: false
                        textFormat: Text.RichText
                        textColor: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                        text: "%1".arg(app.info.description)
                    }
                    //----------------------------------------------------------

                    Rectangle {
                        Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                        Layout.bottomMargin: 5 * AppFramework.displayScaleFactor
                        Layout.fillWidth: true
                        color: "transparent"

                        Text {
                            anchors.fill: parent
                            textFormat: Text.RichText
                            text: qsTr("<b>ACCESS AND USE CONSTRAINTS</b>")
                            verticalAlignment: Text.AlignBottom
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                        }
                    }

                    Rectangle{
                        Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.topMargin: 0
                        color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground

                        Text{
                            anchors.fill: parent
                            textFormat: Text.RichText
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                            text: qsTr("<a href='http://esriurl.com/labseula' style='color:#007ac2'>View the license agreement</a> ")
                            onLinkActivated: {
                                 Qt.openUrlExternally(link);
                            }
                        }
                    }

                    //----------------------------------------------------------

                    Rectangle{
                        Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                        Layout.fillWidth: true
                        Layout.topMargin: 0
                        color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                        MouseArea{
                            anchors.fill: parent
                            onPressAndHold: {
                                logTreks = logTreks === false ? true : false;
                                if(logTreks){
                                    logTreksIndicator.text = "<b>+</b>";
                                }else{
                                    logTreksIndicator.text = "<b>-</b>";
                                }
                            }
                        }

                        RowLayout{
                            anchors.fill: parent
                            spacing:0
                            Text{
                                id: softwareVersion
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                textFormat: Text.RichText
                                horizontalAlignment: Text.AlignLeft
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                text: "<b>v%1.%2.%3</b>".arg(app.info.value("version").major).arg(app.info.value("version").minor).arg(app.info.value("version").micro)
                            }
                            Text{
                                id: logTreksIndicator
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                textFormat: Text.RichText
                                horizontalAlignment: Text.AlignRight
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                            }
                        }
                    }
                }
            }
            //------------------------------------------------------------------
        }
    }
}
