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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0

Item {

    id: safetyWarningView

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle{
        anchors.fill: parent
        color: !nightMode ? dayModeSettings.background : nightModeSettings.background

        ColumnLayout{
            anchors.fill: parent
            spacing: 0

            Rectangle{
                Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                Layout.fillWidth: true
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                Text{
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Disclaimer")
                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                }
            }

            //------------------------------------------------------------------

            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                Image{
                    source: "images/notice_triangle.png"
                    anchors.centerIn: parent
                    height: 30 * AppFramework.displayScaleFactor
                    fillMode: Image.PreserveAspectFit
                }
            }

            //------------------------------------------------------------------

            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: 16 * AppFramework.displayScaleFactor
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                TextArea{
                    id: disclaimerText
                    property string para1: qsTr("Do not attempt to use this directional information unless you are at a complete stop. Travel safely and use common sense when using Trek2There. Trek2There is not to be used for terrain avoidance as direction and distance information does not consider traveling around physical barriers such as cliffs, water bodies, roadways, moving vehicles, buildings, etc.")
                    property string para2: qsTr("Do not follow any travel suggestions that appear to be hazardous, unsafe, or illegal. Trek2There is provided on an 'As-Is' basis. You assume all risk of using the Trek2There app.")
                    property string para3: qsTr("Please refer to the license agreement for further details.")
                    property string para4: qsTr("I understand that usage metrics may be gathered and used to make Trek2There a better application.")

                    readOnly: true
                    frameVisible: false
                    backgroundVisible: false
                    anchors.fill: parent
                    textFormat: Text.RichText
                    textColor: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                    text: "<p>%1</p><p>%2</p><p>%3</p><p>%4</p>".arg(para1).arg(para2).arg(para3).arg(para4)
                    onLinkActivated: {
                         Qt.openUrlExternally(link);
                    }
                }
            }
            //------------------------------------------------------------------

            Rectangle{
                Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                Layout.fillWidth: true
                Layout.margins: 16 * AppFramework.displayScaleFactor
                Layout.topMargin: 0
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                Text{
                    anchors.fill: parent
                    textFormat: Text.RichText
                    text: qsTr("<a href='http://esriurl.com/labseula' style='color:#007ac2'>License Agreement</a> ")
                    onLinkActivated: {
                         Qt.openUrlExternally(link);
                    }
                }
            }

            //------------------------------------------------------------------

            Rectangle{
                Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                Layout.fillWidth: true
                color: !nightMode ? "#ededed" : "#272727"
                visible: false // disabled for v1.0
                enabled: false // disabled for v1.0

                RowLayout{
                    anchors.fill: parent
                    anchors.leftMargin: 16 * AppFramework.displayScaleFactor
                    anchors.rightMargin: 16 * AppFramework.displayScaleFactor
                    spacing: 0
                    Rectangle{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        Text{
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: qsTr("Don't show this message again.")
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                        }
                    }

                    Rectangle{
                        Layout.preferredWidth: parent.height
                        Layout.fillHeight: true
                        color: "transparent"

                        RadioButton{
                            id: doNotShowWarningAgain
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            style: RadioButtonStyle {
                              indicator: Rectangle {
                                  implicitWidth: 20 * AppFramework.displayScaleFactor
                                  implicitHeight: 20 * AppFramework.displayScaleFactor
                                  radius: 10 * AppFramework.displayScaleFactor
                                  border.width: 2 * AppFramework.displayScaleFactor
                                  border.color: !nightMode ? "#595959" : nightModeSettings.foreground
                                  color: !nightMode ? "#ededed" : "#272727"
                                  Rectangle {
                                      anchors.fill: parent
                                      visible: control.checked
                                      color: !nightMode ? "#595959" : nightModeSettings.foreground
                                      radius: 9 * AppFramework.displayScaleFactor
                                      anchors.margins: 4 * AppFramework.displayScaleFactor
                                  }
                              }
                          }
                        }
                    }
                }
            }

            //------------------------------------------------------------------

            Rectangle{
                Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                Layout.fillWidth: true
                Layout.bottomMargin: 16 * AppFramework.displayScaleFactor
                color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                RowLayout{
                    anchors.fill: parent
                    anchors.leftMargin: 16 * AppFramework.displayScaleFactor
                    anchors.rightMargin: 16 * AppFramework.displayScaleFactor
                    spacing:0
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        visible: false // disabled for v1.0
                        enabled: false // disabled for v1.0
                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                        Button{
                            height: parent.height
                            width: parent.width - 50 * AppFramework.displayScaleFactor
                            anchors.left: parent.left
                            style: ButtonStyle{
                                background: Rectangle{
                                    anchors.fill: parent
                                    color: control.pressed || control.hovered ? "#fff" : ( !nightMode ? dayModeSettings.background : nightModeSettings.background )
                                    Text{
                                        anchors.centerIn: parent
                                        color: buttonTextColor
                                        text: qsTr("Cancel")
                                      }
                                }
                            }
                            onClicked: {
                                Qt.quit();
                            }
                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                        Button{
                            height: parent.height
                            width: parent.width // parent.width - 50 * AppFramework.displayScaleFactor
                            anchors.right: parent.right
                            style: ButtonStyle{
                                background: Rectangle{
                                    anchors.fill: parent
                                    color: control.pressed || control.hovered ? "#fff" : ( !nightMode ? dayModeSettings.background : nightModeSettings.background )
                                    border.color: !nightMode ? "#ddd" : nightModeSettings.secondaryBackground
                                    border.width: 1 * AppFramework.displayScaleFactor
                                    radius: 5 * AppFramework.displayScaleFactor
                                    Text{
                                        anchors.centerIn: parent
                                        color: buttonTextColor
                                        text: qsTr("Accept")
                                    }
                                }
                            }

                            onClicked: {
                                /* // disabled for v1.0
                                if(doNotShowWarningAgain.checked){
                                    app.settings.setValue("showSafetyWarning", false);
                                }
                                app.settings.setValue("safteyWarningAccepted", true);
                                */
                                mainStackView.push({item: navigationView, replace: true});
                            }
                        }
                    }
                }
            }
        }
    }
}
