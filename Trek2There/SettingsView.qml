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
    id: settingsView

    // PROPERTIES //////////////////////////////////////////////////////////////

    property var distanceFormats: ["Decimal degrees", "Degrees, minues and seconds", "Degrees and decimal minutes", "MGRS", "US national degrees"]
    property int currentDistanceFormat: 0
    property var currentDestination: null
    property int sideMargin: 14 * AppFramework.displayScaleFactor

    // UI //////////////////////////////////////////////////////////////////////

    Rectangle {
        anchors.fill: parent
        color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                id: navBAr
                color: nightMode ===false ? dayModeSettings.background : nightModeSettings.background

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
                                var previousItem = mainStackView.get( settingsView.Stack.index - 1 );
                                if(destinationLatitude.acceptableInput && destinationLongitude.acceptableInput){
                                    requestedDestination = (destinationLatitude.length > 0  && destinationLongitude.length > 0) ? QtPositioning.coordinate(destinationLatitude.text, destinationLongitude.text) : null;
                                }
                                Qt.inputMethod.hide();

                                mainStackView.push( { item: previousItem } );
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("Settings")
                            color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                        }
                    }

                    Rectangle {
                        id: aboutButtonContainer
                        Layout.fillHeight: true
                        Layout.preferredWidth: 50 * AppFramework.displayScaleFactor

                        Button {
                            anchors.fill: parent
                            style: ButtonStyle {
                                background: Rectangle {
                                    color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                    anchors.fill: parent

                                    Image {
                                        id: aboutIcon
                                        source: "images/about.png"
                                        anchors.left: parent.left
                                        anchors.leftMargin: sideMargin
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - (30 * AppFramework.displayScaleFactor)
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    ColorOverlay {
                                        source: aboutIcon
                                        anchors.fill: aboutIcon
                                        color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                    }
                                }
                            }

                            onClicked: {
                                mainStackView.push(aboutView);
                            }
                        }
                    }
                }
            }

            //------------------------------------------------------------------

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground

                Flickable {
                    width: parent.width
                    height: parent.height
                    contentHeight: contentItem.children[0].childrenRect.height
                    contentWidth: parent.width
                    interactive: true
                    flickableDirection: Flickable.VerticalFlick
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing:0

                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.bottomMargin: 5 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            color: "transparent"


                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                text: qsTr("DESTINATION")
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            Layout.bottomMargin: 2 * AppFramework.displayScaleFactor
                            color: !nightMode ? "#fff" : nightModeSettings.background
                            visible: false // OFF FOR V1.0
                            enabled: false // OFF FOR V1.0

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin
                                spacing: 0

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 120 * AppFramework.displayScaleFactor
                                    text: qsTr("Format")
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                }

                                Button {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    style: ButtonStyle {
                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: !nightMode ? "#fff" : nightModeSettings.background

                                            Text {
                                                anchors.fill: parent
                                                anchors.leftMargin: 5 * AppFramework.displayScaleFactor
                                                verticalAlignment: Text.AlignVCenter
                                                horizontalAlignment: Text.AlignLeft
                                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                                text: distanceFormats[currentDistanceFormat]
                                            }
                                        }
                                    }

                                    onClicked: {
                                        // TODO Provide dialog to change format
                                    }
                                }
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            Layout.bottomMargin: 2 * AppFramework.displayScaleFactor
                            color: !nightMode ? "#fff" : nightModeSettings.background

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin
                                spacing: 0

                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 120 * AppFramework.displayScaleFactor
                                    text: qsTr("Latitude")
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                }

                                TextField {
                                    id: destinationLatitude
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    placeholderText: qsTr("Enter latitude")
                                    text: (requestedDestination === null) ? "" : requestedDestination.latitude
                                    inputMethodHints: Qt.ImhPreferNumbers
                                    validator: latitudeValidator
                                    style: TextFieldStyle {
                                        background: Rectangle {
                                            anchors.fill: parent
                                            anchors.topMargin: 3 * AppFramework.displayScaleFactor
                                            anchors.bottomMargin: 3 * AppFramework.displayScaleFactor
                                            border.width: 1 * AppFramework.displayScaleFactor
                                            border.color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                                            color: dayModeSettings.background
                                        }
                                        textColor: dayModeSettings.foreground
                                    }
                                }
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            color: !nightMode ? "#fff" : nightModeSettings.background

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                anchors.rightMargin: sideMargin
                                spacing: 0
                                Text {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 120 * AppFramework.displayScaleFactor
                                    text: qsTr("Longitude")
                                    verticalAlignment: Text.AlignVCenter
                                    color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                }
                                TextField {
                                    id: destinationLongitude
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    placeholderText: qsTr("Enter longitude")
                                    text: (requestedDestination === null) ? "" : requestedDestination.longitude
                                    inputMethodHints: Qt.ImhPreferNumbers
                                    validator: longitudeValidator
                                    style: TextFieldStyle {
                                        background: Rectangle {
                                            anchors.fill: parent
                                            anchors.topMargin: 3 * AppFramework.displayScaleFactor
                                            anchors.bottomMargin: 3 * AppFramework.displayScaleFactor
                                            border.width: 1 * AppFramework.displayScaleFactor
                                            border.color: !nightMode ? dayModeSettings.secondaryBackground : nightModeSettings.secondaryBackground
                                            color: dayModeSettings.background
                                        }
                                        textColor: dayModeSettings.foreground
                                    }
                                }
                            }
                        }


                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            Layout.topMargin: 8 * AppFramework.displayScaleFactor
                            Layout.bottomMargin: 5 * AppFramework.displayScaleFactor
                            color: "transparent"

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: sideMargin
                                text: qsTr("DISTANCE UNIT")
                                verticalAlignment: Text.AlignBottom
                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            Button {
                                anchors.fill: parent
                                style: ButtonStyle {
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: 0
                                            anchors.leftMargin: sideMargin
                                            anchors.rightMargin: sideMargin
                                            Rectangle {
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                                RadioButton{
                                                    id: metricChecked
                                                    anchors.centerIn: parent
                                                    width: parent.width - (30 * AppFramework.displayScaleFactor)
                                                    checked: usesMetric === true
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
                                            Text {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                Layout.leftMargin: sideMargin
                                                text: qsTr("Metric")
                                                verticalAlignment: Text.AlignVCenter
                                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                            }
                                        }
                                    }
                                }

                                onClicked: {
                                    usesMetric = true;
                                }
                            }
                        }

                        //------------------------------------------------------

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            Button {
                                anchors.fill: parent
                                style: ButtonStyle {
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: 0
                                            anchors.leftMargin: sideMargin
                                            anchors.rightMargin: sideMargin
                                            Rectangle {
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                                RadioButton{
                                                    id: imperialChecked
                                                    anchors.centerIn: parent
                                                    width: parent.width - (30 * AppFramework.displayScaleFactor)
                                                    checked: usesMetric === false
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
                                            Text {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                Layout.leftMargin: sideMargin
                                                text: qsTr("Imperial")
                                                verticalAlignment: Text.AlignVCenter
                                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                            }
                                        }
                                    }
                                }

                                onClicked: {
                                    usesMetric = false;
                                }
                            }
                        }

                        // SECTION /////////////////////////////////////////////

                        Rectangle {
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            Layout.fillWidth: true
                            Layout.topMargin: 10 * AppFramework.displayScaleFactor
                            visible: false
                            enabled: false
                            color: !nightMode ? dayModeSettings.background : nightModeSettings.background

                            Button {
                                anchors.fill: parent
                                style: ButtonStyle {
                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                        RowLayout {
                                            anchors.fill: parent
                                            spacing: 0
                                            anchors.leftMargin: sideMargin
                                            anchors.rightMargin: sideMargin
                                            Rectangle {
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: 50 * AppFramework.displayScaleFactor
                                                color: !nightMode ? dayModeSettings.background : nightModeSettings.background
                                                Image {
                                                    id: useOuterArrowCheckmark
                                                    anchors.centerIn: parent
                                                    width: parent.width - (30 * AppFramework.displayScaleFactor)
                                                    fillMode: Image.PreserveAspectFit
                                                    visible: useDirectionOfTravelCircle === true ? true : false
                                                    source: "images/checkmark.png"
                                                }
                                            }
                                            Text {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                Layout.leftMargin: sideMargin
                                                text: qsTr("Use outer arrow")
                                                verticalAlignment: Text.AlignVCenter
                                                color: !nightMode ? dayModeSettings.foreground : nightModeSettings.foreground
                                            }
                                        }
                                    }
                                }

                                onClicked: {
                                    useDirectionOfTravelCircle = (useDirectionOfTravelCircle === false) ? true : false;
                                }
                            }
                        }


                        //------------------------------------------------------

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                        }


                        //------------------------------------------------------

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50 * AppFramework.displayScaleFactor
                            color: "transparent"
                        }
                    } // end contentItem
                } // end flicable
            }
        }

        //------------------------------------------------------------------
    }
}
