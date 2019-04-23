/* Copyright 2017 Esri
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
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Management 1.0

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)
    property bool isTablet: AppFramework.systemInformation.family === "tablet"
    property bool isPhone: (AppFramework.systemInformation.family === "phone")

    property bool isSupported:ManagedAppConfiguration.supported
    
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
        contentItem: Rectangle {
            anchors.top:header.bottom

            Connections {
                target: ManagedAppConfiguration

                onPolicyDefaultsChanged : {
                    defaultPortalName.text = ManagedAppConfiguration.defaultValue("portalName");
                    defaultPortalUrl.text = ManagedAppConfiguration.defaultValue("portalUrl");
                    defaultJson.text = JSON.stringify(ManagedAppConfiguration.policyDefaults, null, 2);
                }

                onPolicySettingsChanged : {
                    portalName.text = ManagedAppConfiguration.value("portalName", false, "ArcGIS");
                    portalUrl.text = ManagedAppConfiguration.value("portalUrl", false, "www.arcgis.com");
                    settingsJson.text = JSON.stringify(ManagedAppConfiguration.policySettings, null, 2);
                }
            }

            Rectangle {
                anchors.margins: 5 * scaleFactor
                anchors.fill: parent
                color:"#F5F5F5"

                Rectangle {
                    anchors.margins: 4 * scaleFactor
                    anchors.fill: parent
                    color:"#F5F5F5"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            Layout.preferredHeight: 35 * scaleFactor
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Controls.CustomizedText {
                                    Layout.preferredWidth: isTablet ? Math.max(0.18 * parent.width, 10 * scaleFactor) : Math.max(0.3 * parent.width, 10 * scaleFactor)
                                    cusText: qsTr("Default portalUrl: ")
                                }

                                Item {
                                    Layout.fillWidth: true
                                    TextField {
                                        id: defaultPortalUrl
                                        width: parent.width
                                        text: "portalUrl"
                                        Material.accent: "#8f499c"
                                        font.pixelSize: 11 * scaleFactor
                                        clip: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.preferredHeight: 35 * scaleFactor
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Controls.CustomizedText {
                                    Layout.preferredWidth: isTablet ? Math.max(0.18 * parent.width, 10 * scaleFactor) : Math.max(0.3 * parent.width, 10 * scaleFactor)
                                    cusText: qsTr("Default portalName: ")
                                }

                                Item {
                                    Layout.fillWidth: true

                                    TextField {
                                        id: defaultPortalName
                                        width: parent.width
                                        anchors.verticalCenter: parent.verticalCenter
                                        placeholderText: "portalName"
                                        Material.accent: "#8f499c"
                                        selectByMouse: true
                                        font.pixelSize: 11 * scaleFactor
                                    }
                                }
                            }
                        }


                        Item {
                            Layout.preferredHeight: (parent.height - 140)/2.1
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Item {
                                    Layout.preferredWidth:  isTablet ? Math.max(0.18 * parent.width, 10 * scaleFactor) : Math.max(0.3 * parent.width, 10 * scaleFactor)
                                    Layout.preferredHeight: parent.height

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        Controls.CustomizedText {
                                            text: "Default JSON: "
                                            Layout.preferredWidth: parent.width

                                        }

                                        Item {
                                            Layout.fillHeight: true
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    clip: true

                                    Flickable {
                                        anchors.fill: parent
                                        contentWidth: this.width
                                        contentHeight:defaultJson.height
                                        boundsBehavior: Flickable.StopAtBounds

                                        Label {
                                            id: defaultJson
                                            wrapMode: TextArea.Wrap
                                            width: parent.width
                                            font.pixelSize: 11 * scaleFactor
                                        }
                                    }
                                }
                            }
                        }


                        Item {
                            Layout.preferredHeight: 35 * scaleFactor
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Controls.CustomizedText {
                                    Layout.preferredWidth: isTablet ? Math.max(0.18 * parent.width, 10 * scaleFactor) : Math.max(0.3 * parent.width, 10 * scaleFactor)
                                    cusText: qsTr("Settings portalUrl: ")
                                }

                                Item {
                                    Layout.fillWidth: true

                                    TextField {
                                        id: portalUrl
                                        width: parent.width
                                        anchors.verticalCenter: parent.verticalCenter
                                        placeholderText:  "portalUrl"
                                        Material.accent: "#8f499c"
                                        selectByMouse: true
                                        font.pixelSize: 11 * scaleFactor
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.preferredHeight: 35 * scaleFactor
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Controls.CustomizedText {
                                    Layout.preferredWidth: isTablet ? Math.max(0.18 * parent.width, 10 * scaleFactor) : Math.max(0.3 * parent.width, 10 * scaleFactor)
                                    cusText: qsTr( "Settings portalName: ")
                                }

                                Item {
                                    Layout.fillWidth: true

                                    TextField {
                                        id: portalName
                                        width: parent.width
                                        anchors.verticalCenter: parent.verticalCenter
                                        placeholderText: "portalName"
                                        Material.accent: "#8f499c"
                                        selectByMouse: true
                                        font.pixelSize: 11 * scaleFactor
                                    }
                                }
                            }
                        }


                        Item {
                            Layout.preferredHeight: (parent.height - 140)/2.1
                            Layout.preferredWidth: parent.width

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10 * scaleFactor

                                Item {
                                    Layout.preferredWidth:  isTablet ? Math.max(0.18 * parent.width, 10 * scaleFactor) : Math.max(0.3 * parent.width, 10 * scaleFactor)
                                    Layout.fillHeight: true

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        Controls.CustomizedText {
                                            text: "Settings JSON: "
                                            Layout.preferredWidth: parent.width
                                        }

                                        Item {
                                            Layout.fillHeight: true
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    clip: true

                                    Flickable {
                                        anchors.fill: parent
                                        contentWidth: this.width
                                        contentHeight:defaultJson.height
                                        boundsBehavior: Flickable.StopAtBounds

                                        Label {
                                            id: settingsJson
                                            wrapMode: TextArea.Wrap
                                            width: parent.width
                                            font.pixelSize: 11 * scaleFactor
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    Component.onCompleted: {
        defaultPortalName.text = ManagedAppConfiguration.defaultValue("portalName");
        defaultPortalUrl.text = ManagedAppConfiguration.defaultValue("portalUrl");
        defaultJson.text = JSON.stringify(ManagedAppConfiguration.policyDefaults, null, 2);

        console.log("defaults: ", JSON.stringify(ManagedAppConfiguration.policyDefaults, null, 1));

        portalName.text = ManagedAppConfiguration.value("portalName", false, "ArcGIS");
        portalUrl.text = ManagedAppConfiguration.value("portalUrl", false, "www.arcgis.com")
        settingsJson.text = JSON.stringify(ManagedAppConfiguration.policySettings, null, 2);

        console.log("settings: ", JSON.stringify(ManagedAppConfiguration.policySettings));
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}


