//------------------------------------------------------------------------------
// BufferOnline.qml

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
import ArcGIS.AppFramework.Runtime 1.0
App {
    id: app
    width: 800
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor
    property var  bufferPoint
    property bool firstPoint: true
    property bool isDone: false
    property int  lineGraphicId
    property int  bufferWidth: 10000

    Map {
        id: mainMap
        anchors.fill: parent
        wrapAroundEnabled: true
        extent: envelopeInitalExtent
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"
        }

        GraphicsLayer {
            id: graphicsLayer
        }

        onMouseClicked: {
            if (isDone)
                return;
            drawPoint(mouse.mapPoint);
            addPoint(mouse.mapPoint);
            bufferButton.enabled = true;
        }
    }

    Rectangle {
        anchors {
            fill: resultsColumn
            margins: -10 * scaleFactor
        }
        color: "lightgrey"
        radius: 5
        border.color: "black"
        opacity: 0.77
    }

    Column{
        id: resultsColumn
        anchors {
            top: parent.top
            left: parent.left
            margins: 20 * scaleFactor
        }
        width: row.width
        spacing: 10 * scaleFactor

        Row {
            id: row
            spacing: 10 * scaleFactor

            Button {
                id: bufferButton
                text: "Buffer"
                enabled: false

                onClicked: {
                    isDone = true;
                    bufferButton.enabled = false;
                    if (polyline.pointCount > 1)
                        drawBufferPolygon(polyline);
                    else {
                        drawBufferPolygon(bufferPoint);
                    }
                }
            }

            Button {
                text: "Clear"

                onClicked: {
                    if (polyline.pathCount > 0)
                        polyline.removePath(0);
                    isDone = false;
                    firstPoint = true;
                    bufferButton.enabled = false;
                    graphicsLayer.removeAllGraphics();
                }
            }
        }
    }

    Envelope {
        id: envelopeInitalExtent
        xMin: -8304000
        yMin: 4920280
        xMax: -7703576
        yMax: 5320810
    }

    Polyline {
        id: polyline
        spatialReference: mainMap.spatialReference
    }

    Graphic {
        id: redPointGraphic
        symbol: SimpleMarkerSymbol {
            color: "red"
            style: Enums.SimpleMarkerSymbolStyleCircle
            size: 10
        }
    }

    Graphic {
        id: lineGraphic
        symbol: SimpleLineSymbol {
            color: "red"
            style: Enums.SimpleLineSymbolStyleSolid
            width: 2
        }
    }

    Graphic {
        id: bufferGraphic
        symbol: SimpleFillSymbol {
            color: Qt.rgba(0.0, 0, 0.5, 0.5)
            outline:  SimpleLineSymbol {
                color: "red"
                style: Enums.SimpleLineSymbolStyleSolid
                width: 2
            }
        }
    }

    function drawLine() {
        var lineGraphicClone = lineGraphic.clone();
        lineGraphicClone.geometry = polyline;
        graphicsLayer.updateGraphic(lineGraphicId, lineGraphicClone);
    }

    function drawPoint(mapPoint) {
        var newPoint = redPointGraphic.clone();
        newPoint.geometry = mapPoint;
        graphicsLayer.addGraphic(newPoint);
    }

    function addPoint(mapPoint) {
        if (firstPoint) {
            firstPoint = false;
            polyline.startPath(mapPoint.x, mapPoint.y);
            var lineGraphicClone = lineGraphic.clone();
            lineGraphicClone.geometry = polyline;
            lineGraphicId = graphicsLayer.addGraphic(lineGraphicClone);

            bufferPoint = ArcGISRuntime.createObject("Point", {x: mapPoint.x, y: mapPoint.y});
            bufferPoint.spatialReference = mainMap.spatialReference
        } else {
            polyline.lineTo(mapPoint.x, mapPoint.y);
            drawLine();
        }
    }

    function drawBufferPolygon(geometry) {
        var bufferPolygon = geometry.buffer(bufferWidth, mainMap.spatialReference.unit);
        var graphic = bufferGraphic.clone();
        graphic.geometry = bufferPolygon;
        graphicsLayer.addGraphic(graphic);
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

