/* Copyright 2018 Esri
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

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Positioning 1.0

import "../controls" as Controls

Page {
    id: qualityPage

    property var fixType: position.fixType
    property var gpsMode: gpsModeText (fixType)

    property var hdop: position.hdopValid ? position.hdop : null
    property var vdop: position.vdopValid ? position.vdop : null
    property var pdop: position.pdopValid ? position.pdop : null

    property var hpe: position.horizontalAccuracyValid ? app.convertValueToLengthString(position.horizontalAccuracy) : null
    property var vpe: position.verticalAccuracyValid   ? app.convertValueToLengthString(position.verticalAccuracy)   : null
    property var epe: position.positionAccuracyValid   ? app.convertValueToLengthString(position.positionAccuracy)   : null
    property var diffAge: position.differentialAgeValid ? position.differentialAge : null

    property var satInUse: position.satellitesInUseValid ? position.satellitesInUse : null
    property var satVisible: position.satellitesVisibleValid ? position.satellitesVisible : null

    //--------------------------------------------------------------------------

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: qualityColumn.height
        clip: true

        ColumnLayout {
            id: qualityColumn
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 0

            Column {
                topPadding: 20 * scaleFactor
                spacing: 0

                Label {
                    id: accuracyLabel

                    text: qsTr("GPS ACCURACY")
                    font.pixelSize: baseFontSize * 0.95
                    leftPadding: 12 * scaleFactor
                    bottomPadding: 8 * scaleFactor
                    color: "grey"
                }
            }

            ListView {
                id: gpsModeListView

                Layout.preferredWidth: app.width
                Layout.preferredHeight: 35 * scaleFactor
                spacing: 0
                clip: true

                model: gpsModeListModel
                delegate: Controls.CustomizedDelegate {}
                interactive: false
            }

            ListModel {
                id: gpsModeListModel

                ListElement {
                    label: qsTr("GPS mode: ")
                    attr : "gpsMode"
                }
            }

            Rectangle {
                Layout.preferredWidth: app.width
                Layout.preferredHeight: 1 * scaleFactor
                color: "lightgrey"
            }

            Item {
                height: !isSmallScreen ? 30 * scaleFactor : 20 * scaleFactor
            }

            ListView {
                id: dopListView

                Layout.preferredWidth: app.width
                Layout.preferredHeight: 105 * scaleFactor
                spacing: 0
                clip: true

                model: dopModel
                delegate: Controls.CustomizedDelegate {}
                interactive: false
            }

            ListModel {
                id: dopModel

                ListElement {
                    label: qsTr("HDOP: ")
                    attr : "hdop"
                }

                ListElement {
                    label: qsTr("VDOP: ")
                    attr : "vdop"
                }

                ListElement {
                    label: qsTr("PDOP: ")
                    attr : "pdop"
                }
            }

            Rectangle {
                Layout.preferredWidth: app.width
                Layout.preferredHeight: 1 * scaleFactor
                color: "lightgrey"
            }

            Item {
                Layout.preferredHeight: !isSmallScreen ? 30 * scaleFactor : 20 * scaleFactor
            }

            ListView {
                id: positionErrorListView

                Layout.preferredWidth: app.width
                Layout.preferredHeight: 140 * scaleFactor
                spacing: 0
                clip: true

                model: positionErrorModel
                delegate: Controls.CustomizedDelegate {}
                interactive: false
            }

            ListModel {
                id: positionErrorModel

                ListElement {
                    label: qsTr("Horizontal est. accuracy: ")
                    attr : "hpe"
                }

                ListElement {
                    label: qsTr("Vertical est. accuracy: ")
                    attr : "vpe"
                }

                ListElement {
                    label: qsTr("Position est. accuracy: ")
                    attr : "epe"
                }

                ListElement {
                    label: qsTr("Differential age: ")
                    attr : "diffAge"
                }
            }

            Rectangle {
                Layout.preferredWidth: app.width
                Layout.preferredHeight: 1 * scaleFactor
                color: "lightgrey"
            }

            Item {
                Layout.preferredHeight: !isSmallScreen ? 30 * scaleFactor : 20 * scaleFactor
            }

            Column {
                topPadding: 0 * scaleFactor

                Label {
                    id: satLabel

                    text: qsTr("SATELLITE INFORMATION")
                    font.pixelSize: baseFontSize * 0.95
                    leftPadding: 12 * scaleFactor
                    bottomPadding: 8 * scaleFactor
                    color: "grey"
                }
            }

            ListView {
                id: sateListView

                Layout.preferredWidth: app.width
                Layout.preferredHeight: 70 * scaleFactor
                spacing: 0
                clip: true

                model: sateListModel
                delegate: Controls.CustomizedDelegate {}
                interactive: false
            }

            ListModel {
                id: sateListModel

                ListElement {
                    label: qsTr("Satellites in use: ")
                    attr : "satInUse"
                }

                ListElement {
                    label: qsTr("Satellites in view: ")
                    attr : "satVisible"
                }
            }

            Rectangle {
                Layout.preferredWidth: app.width
                Layout.preferredHeight: 1 * scaleFactor
                color: "lightgrey"
            }
        }
    }

    //--------------------------------------------------------------------------

    function gpsModeText (fixType) {
        var result = "" ;

        switch (fixType) {
        case fixType = 0 :
            result = qsTr("No Fix");
            break;

        case fixType = 1 :
            result = qsTr("GPS");
            break;

        case fixType = 2 :
            result = qsTr("Differential GPS");
            break;

        case fixType = 3 :
            result = qsTr("Precise Positioning Service");
            break;

        case fixType = 4 :
            result = qsTr("RKT Fixed");
            break;

        case fixType = 5 :
            result = qsTr("RKT Float");
            break;

        case fixType = 6 :
            result = qsTr("Estimated");
            break;

        case fixType = 7 :
            result = qsTr("Manual");
            break;

        case fixType = 8 :
            result = qsTr("Simulator");
            break;

        case fixType = 9 :
            result = qsTr("Sbas");
            break;
        }

        return result;
    }

    //--------------------------------------------------------------------------
}




