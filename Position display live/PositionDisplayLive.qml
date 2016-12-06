/* Copyright 2015 Esri
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

import QtGraphicalEffects 1.0
import QtPositioning 5.2
import QtQuick 2.3
import QtQuick.Controls 1.2
import QtSensors 5.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 800
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor
    property Point locationPoint : Point {
        property bool valid : false
        spatialReference: SpatialReference {
            wkid: 4326
        }
    }

    ListModel {
        id: modesModel

        ListElement { text: "Off" }
        ListElement { text: "Autopan" }
        ListElement { text: "Navigation" }
        ListElement { text: "Compass" }
    }

    Map {
        id: mainMap
        anchors.fill: parent
        wrapAroundEnabled: true
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        positionDisplay {
            compass: Compass {
                id: compass
            }

            positionSource: PositionSource {
                id: positionSource
                onPositionChanged: {
                    locationPoint.valid = position.longitudeValid && position.latitudeValid
                    locationPoint.x = position.coordinate.longitude;
                    locationPoint.y = position.coordinate.latitude;
                    locationPointChanged();
                }
            }

            onModeChanged: {
                modesCombo.currentIndex = mainMap.positionDisplay.mode;
            }
        }
    }

    Rectangle {
        visible: !positionSource.active
        anchors {
            fill: showPosition
            margins: -10 * scaleFactor
        }
        color: "lightgrey"
        radius: 5 * scaleFactor
        border.color: "black"
        opacity: 0.77
    }

    Button {
        id: showPosition
        visible: !positionSource.active
        text: "Show My Position"
        anchors {
            left: parent.left
            top: parent.top
            margins: 20
        }
        enabled: mainMap.status === Enums.MapStatusReady

        onClicked: {
            positionSource.active = true;
            compass.active = true;
        }
    }

    Rectangle {
        visible: positionSource.active
        color: "lightgrey"
        radius: 5
        border.color: "black"
        opacity: 0.77
        anchors {
            fill: columnControls
            margins: -10
        }
    }

    Column {
        id: columnControls
        anchors {
            left: parent.left
            top: parent.top
            margins: 20 * scaleFactor
        }

        spacing: 5
        visible: positionSource.active

        Row {
            spacing: 50

            Button {
                id: closeButton
                text: "X"

                onClicked: {
                    positionSource.active = false;
                    compass.active = false;
                }
            }

            Text {
                text: "Source: " + positionSource.name
                color: "#00b2ff"
                font {
                    pointSize: 12
                    italic: true
                }
            }
        }

        Text {
            text: locationPoint.isEmpty || !locationPoint.valid
                  ? "Invalid Coordinates"
                  : locationPoint.toDegreesMinutesSeconds(2) +
                    (positionSource.position.horizontalAccuracyValid
                     ? " ± " + Math.round(positionSource.position.horizontalAccuracy.toString()) + "m"
                     : "")
            color: locationPoint.valid ? "white": "red"
            font {
                bold: true
                pointSize: 16
            }
        }

        Text {
            visible: positionSource.position.altitudeValid
            text: "Altitude: " +
                  Math.round(positionSource.position.coordinate.altitude).toString() +
                  (positionSource.position.verticalAccuracy
                   ? " ± " + Math.round(positionSource.position.verticalAccuracy).toString() + "m"
                   : "")
            color: "white"
            font {
                pointSize: 14
            }
        }

        Text {
            visible: positionSource.position.speedValid
            text: "Speed: " + Math.round(positionSource.position.speed).toString() + " kp/h"
            color: "white"
            font {
                pointSize: 14
                italic: true
            }
        }

        Text {
            text: "Date: " + positionSource.position.timestamp.toString()
            color: "white"
            font {
                pointSize: 12
            }
        }

        Row {
            spacing: 15

            Text {
                text: "Display mode"
                color: "white"
                font {
                    pointSize: 12
                }
            }

            ComboBox {
                id: modesCombo
                model: modesModel
                onActivated: mainMap.positionDisplay.mode = index
                width: 200
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }
}

