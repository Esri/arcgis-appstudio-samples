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

import ArcGIS.AppFramework.Positioning 1.0

import "../controls" as Controls

Page {
    id: qualityPage

    property PositionSource positionSource
    property Position position: positionSource.position

    property var fixType: position.fixType
    property var gpsMode: gpsModeText(fixType)
    property var accuracyType: position.accuracyType
    property var accuracyMode: accuracyText(accuracyType)

    property var hdop: position.hdopValid ? position.hdop : null
    property var vdop: position.vdopValid ? position.vdop : null
    property var pdop: position.pdopValid ? position.pdop : null

    property var hpe: position.horizontalAccuracyValid ? app.convertValueToLengthString(position.horizontalAccuracy) : null
    property var vpe: position.verticalAccuracyValid   ? app.convertValueToLengthString(position.verticalAccuracy)   : null
    property var epe: position.positionAccuracyValid   ? app.convertValueToLengthString(position.positionAccuracy)   : null

    property var laterr: position.latitudeErrorValid  ? app.convertValueToLengthString(position.latitudeError)  : null
    property var lonerr: position.longitudeErrorValid ? app.convertValueToLengthString(position.longitudeError) : null
    property var alterr: position.altitudeErrorValid  ? app.convertValueToLengthString(position.altitudeError)  : null

    property var diffAge: position.differentialAgeValid ? qsTr("%1 s").arg(Math.round(position.differentialAge)) : null

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

            //--------------------------------------------------------------------------

            ListView {
                id: gpsModeListView

                Layout.preferredWidth: app.width
                Layout.preferredHeight: 70 * scaleFactor
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
                height: 20 * scaleFactor
            }

            //--------------------------------------------------------------------------

            ListView {
                id: positionAccuracyListView

                Layout.preferredWidth: app.width
                Layout.preferredHeight: 140 * scaleFactor
                spacing: 0
                clip: true

                model: positionAccuracyModel
                delegate: Controls.CustomizedDelegate {}
                interactive: false
            }

            ListModel {
                id: positionAccuracyModel

                ListElement {
                    label: qsTr("Accuracy mode: ")
                    attr : "accuracyMode"
                }

                ListElement {
                    label: qsTr("Horizontal accuracy: ")
                    attr : "hpe"
                }

                ListElement {
                    label: qsTr("Vertical accuracy: ")
                    attr : "vpe"
                }

                ListElement {
                    label: qsTr("Position accuracy: ")
                    attr : "epe"
                }
            }

            Rectangle {
                Layout.preferredWidth: app.width
                Layout.preferredHeight: 1 * scaleFactor
                color: "lightgrey"
            }

            Item {
                Layout.preferredHeight: 20 * scaleFactor
            }

            //--------------------------------------------------------------------------

            ListView {
                id: positionErrorListView

                Layout.preferredWidth: app.width
                Layout.preferredHeight: 105 * scaleFactor
                spacing: 0
                clip: true

                model: positionErrorModel
                delegate: Controls.CustomizedDelegate {}
                interactive: false
            }

            ListModel {
                id: positionErrorModel

                ListElement {
                    label: qsTr("Latitude error: ")
                    attr : "laterr"
                }

                ListElement {
                    label: qsTr("Longitude error: ")
                    attr : "lonerr"
                }

                ListElement {
                    label: qsTr("Altitude error: ")
                    attr : "alterr"
                }
            }

            Rectangle {
                Layout.preferredWidth: app.width
                Layout.preferredHeight: 1 * scaleFactor
                color: "lightgrey"
            }

            Item {
                Layout.preferredHeight: 20 * scaleFactor
            }

            //--------------------------------------------------------------------------

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
                Layout.preferredHeight: 20 * scaleFactor
            }

            //--------------------------------------------------------------------------

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

            //--------------------------------------------------------------------------

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
                    label: qsTr("Satellites in view: ")
                    attr : "satVisible"
                }

                ListElement {
                    label: qsTr("Satellites in use: ")
                    attr : "satInUse"
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
        case Position.NoFix:
            result = qsTr("No Fix");
            break;

        case Position.GPS:
            result = qsTr("GPS");
            break;

        case Position.DifferentialGPS:
            result = qsTr("Differential GPS");
            break;

        case Position.PrecisePositioningService:
            result = qsTr("Precise Positioning Service");
            break;

        case Position.RTKFixed:
            result = qsTr("RKT Fixed");
            break;

        case Position.RTKFloat:
            result = qsTr("RKT Float");
            break;

        case Position.Estimated:
            result = qsTr("Estimated");
            break;

        case Position.Manual:
            result = qsTr("Manual");
            break;

        case Position.Simulator:
            result = qsTr("Simulator");
            break;

        case Position.Sbas:
            result = qsTr("Sbas");
            break;
        }

        return result;
    }

    //--------------------------------------------------------------------------

    function accuracyText (accuracyType) {
        var result = "" ;

        switch (accuracyType) {
        case Position.RMS:
            result = qsTr("Error RMS");
            break;

        case Position.DOP:
            result = qsTr("DOP Based");
            break;

        default:
            result = qsTr("Unknown");
            break;
        }

        return result;
    }

    //--------------------------------------------------------------------------
}




