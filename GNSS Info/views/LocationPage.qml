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
import QtQuick.Controls.Material 2.2
import QtPositioning 5.8
import QtLocation 5.9
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Devices 1.0
import ArcGIS.AppFramework.Positioning 1.0
import ArcGIS.AppFramework.Sql 1.0

import "../controls" as Controls

Item {
    id: locationPage

    property var coordinate: position.coordinate
    property var coordinateInfo: Coordinate.convert(coordinate, "dd" , { precision: 8 } ).dd

    property var latitude: coordinate.isValid && coordinateInfo && coordinateInfo.latitudeText ? coordinateInfo.latitudeText : qsTr("No Data")
    property var longitude: coordinate.isValid && coordinateInfo && coordinateInfo.longitudeText ? coordinateInfo.longitudeText : qsTr("No Data")
    property var gridReference: coordinate.isValid && coordinateInfo && coordinateInfo.text ? coordinateInfo.text : qsTr("No Data")
    property var altitude: position.altitudeValid ? app.convertValueToLengthString(coordinate.altitude) : qsTr("No Data")
    property var geoidSeparation: position.geoidSeparationValid ? app.convertValueToLengthString(position.geoidSeparation) : qsTr("No Data")
    property var speed: position.speedValid ? app.convertValueToSpeedString(position.speed) : qsTr("No Data")
    property string course: position.directionValid ? qsTr("%1°").arg(Math.round(position.direction)) : qsTr("No Data")
    property string timestamp: coordinate.isValid ? Qt.formatDate(position.timestamp) + " " + Qt.formatTime(position.timestamp, Qt.DefaultLocaleLongDate) : qsTr("No Data")

    property real locationAge

    property string clearBtnText: qsTr("Graphics Cleared")

    //--------------------------------------------------------------------------

    onCoordinateChanged: {
        if (coordinate.isValid) {
            map.center = coordinate;
//            positionMarker.coordinate = coordinate;
//            positionCircle.radius = position.horizontalAccuracyValid ? position.horizontalAccuracy : 0;
        }
    }

    //--------------------------------------------------------------------------

    Map {
        id: map

        anchors.fill: parent

        plugin: Plugin {
            preferred: ["AppStudio", "ArcGIS", "esri"]
        }

        activeMapType: supportedMapTypes[0]
        zoomLevel: 19
        center {
            latitude: 34.056249
            longitude: -117.195664
        }

        onCopyrightLinkActivated: {
            Qt.openUrlExternally(link);
        }

        MapItemView {
            model: trackPointsModel

            delegate: trackPointItem
        }

        Controls.PositionIndicator {
            id: positionIndicator

            positionSource: app.positionSource

            z: 10001
        }

        Controls.PositionAccuracyIndicator {
            positionIndicator: positionIndicator

            z: 10002
        }

        Controls.PositionMarker {
            positionIndicator: positionIndicator

            z: 10003
        }

        Column {
            id: mapControls
            spacing: 5

            anchors{
                right: parent.right
                rightMargin: 16 * scaleFactor
                verticalCenter: map.verticalCenter
            }

            RoundButton {
                width: 50 * scaleFactor
                height: this.width

                Material.elevation: 6
                Material.background:"white"
                opacity: map.mapRotation ? 1 : 0
                rotation: map.mapRotation

                contentItem: Image{
                    id:compassImage

                    source: "../assets/compass.png"
                    anchors.centerIn: parent
                    mipmap: true
                }

                onClicked: map.setViewpointRotation(map.initialMapRotation)
            }

            RoundButton {
                width: 50 * scaleFactor
                height: this.width

                Material.elevation: 6
                Material.background:"white"

                contentItem: Image{
                    id:locationImage

                    source: "../assets/location.png"
                    anchors.centerIn: parent
                    mipmap: true
                }

                ColorOverlay{
                    id: colorOverlay

                    anchors.fill: locationImage
                    source: locationImage
                    color: "#4c4c4c"
                }

                onClicked: {
                    //map.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeRecenter
                    colorOverlay.color = "steelblue"
                }
            }

            RoundButton {
                width: 50 * scaleFactor
                height: this.width

                Material.elevation: 6
                Material.background:"white"

                contentItem: Image{
                    id:clearImage

                    source: "../assets/clear.png"
                    anchors.centerIn: parent
                    mipmap: true
                }

                ColorOverlay{
                    anchors.fill: clearImage
                    source: clearImage
                    color: "#4c4c4c"
                }

                onClicked: {
                    if (clearToastMessage.visible === false) {
                        clearToastMessage.visible = true
                        clear();
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    BusyIndicator {
        running: !coordinate.isValid === true
        visible: running

        height: 48 * scaleFactor
        width: height
        anchors.centerIn: parent

        Material.accent:"#8f499c"
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: infoBackground

        width: parent.width
        height: parent.height * 0.30
        anchors.top: parent.top

        color: lightPrimaryColor
        opacity: 0.8

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 3 * scaleFactor
            anchors.bottomMargin: 3 * scaleFactor

            Controls.LocationRow {
                nameText: "Grid Reference: "
                valueText: gridReference
                visible: coordBox.currentText === "MGRS"
            }

            Controls.LocationRow {
                visible: coordBox.currentText === "MGRS"
            }

            Controls.LocationRow {
                nameText: "Latitude: "
                valueText: latitude
                visible: coordBox.currentText !== "MGRS"
            }

            Controls.LocationRow {
                nameText: "Longitude: "
                valueText: longitude
                visible: coordBox.currentText !== "MGRS"
            }

            Controls.LocationRow {
                nameText: "Altitude: "
                valueText: altitude
            }

            Controls.LocationRow {
                nameText: "Geoid Separation: "
                valueText: geoidSeparation
            }

            Controls.LocationRow {
                nameText: "Timestamp: "
                valueText: timestamp
            }

            Controls.LocationRow {
                nameText: "Speed Over Ground: "
                valueText: speed
            }

            Controls.LocationRow {
                nameText: "True Course Over Ground: "
                valueText: course
            }
        }

        ComboBox {
            id: coordBox
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: 5 * scaleFactor

            font.pixelSize: baseFontSize * 0.9
            background.implicitWidth: 90 * scaleFactor
            background.implicitHeight: 32 * scaleFactor

            delegate: ItemDelegate {
                width: coordBox.width
                contentItem: Text {
                    text: modelData
                    font: coordBox.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: coordBox.highlightedIndex === index
            }

            model: ["DD", "DDM", "DMS", "MGRS"]

            currentIndex: 2

            onCurrentIndexChanged: {
                if (coordinate.isValid) {
                    setCoordinateInfo();
                }
            }

            function setCoordinateInfo() {
                switch(model[currentIndex]) {
                case "DD":
                    coordinateInfo = Coordinate.convert(coordinate, "dd", { precision: 8 }).dd;
                    break;
                case "DDM":
                    coordinateInfo = Coordinate.convert(coordinate, "ddm", { precision: 6 }).ddm;
                    break;
                case "DMS":
                    coordinateInfo = Coordinate.convert(coordinate, "dms", { precision: 4 }).dms;
                    break;
                case "MGRS":
                    // "precision" here is in metres, whereas it's the number of digits in the above
                    coordinateInfo = Coordinate.convert(coordinate, "mgrs", { precision: 1, spaces: true }).mgrs;
                    break;
                }
            }
        }
    }

    Connections {
        target: positionSource

        onPositionChanged: {
            if (position.coordinate.isValid) {
                coordBox.setCoordinateInfo();
            }
        }
    }

    //--------------------------------------------------------------------------

    Text {
        id: warning

        visible: locationAge > 30 || !devicePage.isConnected

        anchors {
            top: infoBackground.bottom
            horizontalCenter: parent.horizontalCenter
        }

        text: !devicePage.isConnected ? qsTr("Device disconnected") : qsTr("%1s since last location received").arg(Math.round(locationAge))
        color: app.primaryColor
        font.bold: true
        font.pointSize: baseFontSize
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: clearToastMessage

        visible: false

        height: 40 * scaleFactor
        width:  clearBtnLabel.width + 50 * scaleFactor

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15* scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 20 * scaleFactor
        color: app.primaryColor
        opacity: 0.8

        Label {
            id: clearBtnLabel
            anchors.centerIn: parent
            font.bold: true
            font.pixelSize: baseFontSize * 1.1
            color: "white"
            text: clearBtnText
        }
    }

    Timer {
        running: true
        interval: 5000
        repeat: true

        onTriggered: {
            if (clearToastMessage.visible) {
                clearToastMessage.visible = false
            }
        }
    }

    //--------------------------------------------------------------------------

    ListModel {
        id: trackPointsModel
    }

    //--------------------------------------------------------------------------

    Component {
        id: trackPointItem

        MapCircle {
            center {
                latitude: trackLatitude
                longitude: trackLongitude
            }

            radius: horizontalAccuracy
            color: '#40ff0000'
            border {
                color: "#40ffffff"
                width: 1
            }
        }

    }

    //--------------------------------------------------------------------------

    Timer {
        running: devicePage.isConnected && coordinate.isValid
        interval: 10000
        repeat: true

        onTriggered: {
            addTrackPoint(position.coordinate, position.horizontalAccuracyValid ? position.horizontalAccuracy : 10);
            locationAge =  coordinate.isValid ? (((new Date().getTime()) - position.timestamp.getTime()))/1000 : 0
        }
    }

    //--------------------------------------------------------------------------

    function addTrackPoint(coordinate, horizontalAccuracy) {
        var trackPoint = {
            trackLatitude: coordinate.latitude,
            trackLongitude: coordinate.longitude,
            horizontalAccuracy: horizontalAccuracy
        };

        console.log("trackPoint:", JSON.stringify(trackPoint, 2, undefined));

        trackPointsModel.append(trackPoint);
    }

    //--------------------------------------------------------------------------

    function clear() {
        trackPointsModel.clear();
    }

    //--------------------------------------------------------------------------
}


