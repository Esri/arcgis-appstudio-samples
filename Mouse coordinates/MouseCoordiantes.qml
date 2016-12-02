//------------------------------------------------------------------------------
// MouseCoordiantes.qml

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

import QtQuick 2.3
import QtQuick.Controls 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 800
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor

    Map {
        id: mainMap
        anchors.fill: parent
        wrapAroundEnabled: true
        focus: true
        extent:initialExtent

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer"
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onPositionChanged: {
                var mapPoint = mainMap.toMapGeometry(mapToItem(mainMap, mouseX, mouseY));

                coordsText.text = mapPoint.toDegreesMinutesSeconds(2);
                mouseText.text = "Mouse: X=" + mouseX.toString() + " Y=" + mouseY.toString();
            }
        }

            ZoomButtons {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 10
                }

                map: mainMap
                homeExtent: initialExtent
                fader.minumumOpacity: ornamentsMinimumOpacity
            }

    }

    Envelope {
        id: initialExtent
        xMax: -15000000
        yMax: 2000000
        xMin: -7000000
        yMin: 8000000
    }

    Rectangle {
        id: rectangleControls
        color: "lightgrey"
        radius: 5
        border.color: "black"
        opacity: 0.77
        anchors {
            fill: columnControls
            margins: -10 * scaleFactor
        }
    }

    Column {
        id: columnControls
        anchors {
            top: parent.top
            left: parent.left
            margins: 20 * scaleFactor
        }
        spacing: 5 * scaleFactor

        Text {
            id: coordsText
        }

        Text {
            id: mouseText
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

