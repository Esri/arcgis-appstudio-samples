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
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import QtQuick.Window 2.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0
import Esri.ArcGISRuntime 100.10

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

    function ppmmToDpi(ppmm) {
        return Math.round(ppmm * 25.4 * 100) / 100;
    }

    property real referenceDpi: Qt.platform.os === "windows" ? 96 : 72
    property real displayScaleFactor: (Screen.logicalPixelDensity * 25.4) / (Qt.platform.os === "windows" ? 96 : 72)

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

            Flickable {
                anchors.fill: parent
                contentWidth: infoColumn.width
                contentHeight:infoColumn.height

                Column {
                    id:infoColumn
                    width: app.width - 20 * scaleFactor
                    anchors.left: parent.left
                    anchors.leftMargin:  10 * scaleFactor
                    anchors.rightMargin: 10 * scaleFactor
                    spacing: 3

                    Item {
                        height: 10 * scaleFactor
                        width: parent.width
                    }

                    Text {
                        id: screenInfoText
                        text: qsTr("Screen Information")
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        id: swidth
                        text: "width: " + Screen.width
                    }

                    Text {
                        id: sheight
                        text: "height: " + Screen.height
                    }

                    Text {
                        id:desktopAvailableWidth
                        text: "desktopAvailableWidth: " + Screen.desktopAvailableWidth
                    }

                    Text {
                        id: desktopAvailableHeight
                        text: "desktopAvailableHeight: " + Screen.desktopAvailableHeight
                    }

                    Text {
                        id:orientation
                        text: "orientation: " + Screen.orientation
                    }

                    Text {
                        id: primaryOrientation
                        text: "primaryOrientation: " + Screen.primaryOrientation
                    }

                    Text {
                        id: pixelDensity
                        text: "pixelDensity: " + Screen.pixelDensity.toFixed(2) + " <i>(" + ppmmToDpi(Screen.pixelDensity).toString() + " dpi)</i>"
                    }

                    Text {
                        id: logicalPixelDensity
                        text: "logicalPixelDensity: " + Screen.logicalPixelDensity.toFixed(2) + " <i>(" + ppmmToDpi(Screen.logicalPixelDensity).toString() + " dpi)</i>"
                    }

                    Text {
                        id: referenceDPi
                        text: "referenceDPi: " + referenceDpi + " os:" + Qt.platform.os
                    }

                    Text {
                        id:displayScaleFactorT
                        text: "displayScaleFactor: " + displayScaleFactor
                    }

                    Item {
                        height: 20 * scaleFactor
                        width: parent.width
                    }

                    Text {
                        text: qsTr("System Information")
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        id:familyText
                        text: "family: " + AppFramework.systemInformation.family
                    }

                    Text {
                        id:manufacturerText
                        text: "manufacturer: " + AppFramework.systemInformation.manufacturer
                    }

                    Text {
                        id:modelText
                        text: "model: " + AppFramework.systemInformation.model
                    }

                    Text {
                        id:unixMachineText
                        text: "unixMachine: " + AppFramework.systemInformation.unixMachine
                    }

                    Text {
                        id:unixNodeNameText
                        text: "unixNodeName: " + AppFramework.systemInformation.unixNodeName
                    }

                    Text {
                        id:unixReleaseText
                        text: "unixRelease: " + AppFramework.systemInformation.unixRelease
                    }

                    Text {
                        id:unixSysNameText
                        text: "unixSysName: " + AppFramework.systemInformation.unixSysName
                    }

                    Text {
                        id:unixVersionText
                        width:parent.width
                        text: "unixVersion: " + AppFramework.systemInformation.unixVersion
                        wrapMode: Text.Wrap
                    }

                    Text {
                        id:batterylevel
                        text: "Battery Level: %1%".arg(Battery.level)
                    }

                    Text {
                        id:batteryState
                        text:{
                            switch (Battery.state){
                                case Battery.BatteryStateUnknown:
                                    return "Battery State: Unknown"
                                case Battery.BatteryStateNotCharging:
                                    return "Battery State: Not Charging"
                                case Battery.BatteryStateDischarging:
                                    return "Battery State: Discharging"
                                case Battery.BatteryStateCharging:
                                    return "Battery State: Charging"
                                case Battery.BatteryStateFull:
                                    return "Battery State: Full"
                                default:
                                    return Battery.state
                            }

                        }
                    }

                    Text {
                        id:powerSource
                        text: {
                            switch (Battery.source) {
                            case Battery.PowerSourceUnknown:
                                return "Power Source: Unknown";
                            case Battery.PowerSourceAC:
                                return "Power Source: AC";
                            case Battery.PowerSourceUSB:
                                return "Power Source: USB​";
                            case Battery.PowerSourceWireless:
                                return "Power Source: Wireless";
                            case Battery.PowerSourceBattery:
                                return "Power Source: Battery";
                            }}
                    }

                    Text {
                        id: powerMode
                        text: {
                            switch (Battery.mode) {
                            case Battery.PowerModeUnknown:
                                return "Power Mode: Unknown";
                            case Battery.PowerModeBalanced:
                                return "Power Mode: Balanced";
                            case Battery.PowerModeBatterySaver:
                                return "Power Mode: BatterySaver​";
                            }}
                    }


                    Item {
                        height: 10 * scaleFactor
                        width: parent.width
                    }

                    Button {
                        text: qsTr("Share")
                        onClicked: {
                            AppFramework.clipboard.share(swidth.text + "\n" + sheight.text + "\n" + desktopAvailableWidth.text +
                                                         "\n" + desktopAvailableHeight.text + "\n" + orientation.text + "\n" +
                                                         primaryOrientation.text + "\n" + pixelDensity.text + "\n" +
                                                         logicalPixelDensity.text + "\n" + referenceDPi.text + "\n" +
                                                         displayScaleFactorT.text + "\n"
                                                         + familyText.text + "\n"+ manufacturerText.text + "\n"+ modelText.text + "\n"
                                                         + unixMachineText.text + "\n"+ unixNodeNameText.text + "\n"+ unixReleaseText.text + "\n"
                                                         + unixSysNameText.text + "\n"+ unixVersionText.text + "\n"+ batterylevel.text+ "\n"
                                                         + batteryState.text + "\n" + powerSource.text + "\n" + powerMode.text)
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

