//------------------------------------------------------------------------------
// PositionDisplayLive.qml

// Copyright 2015 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the Sample code usage restrictions document for further information.
//
//------------------------------------------------------------------------------

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

    Button {
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

