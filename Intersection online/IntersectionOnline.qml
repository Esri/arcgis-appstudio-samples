//------------------------------------------------------------------------------
// IntersectionOnline.qml
// Created 2015-03-13 13:46:41
//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 800
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor
        property bool firstPoint: true
        property bool isDone: false
        property int  polyGraphicId

        Map {
            id: mainMap
            anchors.fill: parent
            width: 800
            height: 800
            extent: envelopeInitalExtent
            focus: true

            ArcGISTiledMapServiceLayer {
                url: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"
            }

            GraphicsLayer {
                id: graphicsLayer
            }

            onStatusChanged: {
                if (status === Enums.MapStatusReady) {
                    samplePolygon.startPath(-7994031.11, 5092024.86);
                    samplePolygon.lineTo(-7992530.05, 4952426.28);
                    samplePolygon.lineTo(-7864939.95, 4951675.75);
                    samplePolygon.lineTo(-7831916.63, 5069508.96);
                    samplePolygon.lineTo(-7832667.16, 5166327.33);
                    samplePolygon.lineTo(-7864189.42, 5233124.5);
                    samplePolygon.lineTo(-7897963.27, 5071010.02);
                    samplePolygon.lineTo(-7969263.62, 5131052.42);
                    samplePolygon.lineTo(-8045817.68, 5119043.94);
                    samplePolygon.lineTo(-8057826.16, 5045492);
                    addSampleGraphic();
                }
            }

            onMouseClicked: {
                if (isDone)
                    return;
                addPoint(mouse.mapPoint);
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

        Column {
            id: resultsColumn
            anchors {
                top: parent.top
                left: parent.left
                margins: 20 * scaleFactor
            }
            width: titleText.width
            spacing: 10 * scaleFactor
            Text {
                id: titleText
                text: "Draw a polygon"
                font.pixelSize: 14 * scaleFactor
            }

            Row {
                id: row
                spacing: 10 * scaleFactor

                Button {
                    id: intersectionButton
                    text: "Intersection"
                    enabled: false
                    width: titleText.width
                    style: ButtonStyle {
                        label: Text {
                            renderType: Text.NativeRendering
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 14 * scaleFactor
                            color: enabled ? "black" : "grey"
                            text: control.text
                        }
                    }

                    onClicked: {
                        isDone = true;
                        intersectionButton.enabled = false;
                        drawIntersectionPolygon();
                    }
                }
            }

            Button {
                text: "Clear"
                style: intersectionButton.style
                width: titleText.width

                onClicked: {
                    if (userPolygon.pathCount > 0)
                        userPolygon.removePath(0);
                    isDone = false;
                    firstPoint = true;
                    intersectionButton.enabled = false;
                    graphicsLayer.removeAllGraphics();
                    addSampleGraphic();
                }
            }
        }

        Envelope {
            id: envelopeInitalExtent
            xMin: -8304000
            yMin: 4920280
            xMax: -7703576
            yMax: 5320810
            spatialReference: mainMap.spatialReference
        }

        Polygon {
            id: userPolygon
            spatialReference: mainMap.spatialReference
        }

        Polygon {
            id: samplePolygon
            spatialReference: mainMap.spatialReference
        }

        Graphic {
            id: redPointGraphic
            symbol: SimpleMarkerSymbol {
                color: "red"
                style: Enums.SimpleMarkerSymbolStyleCircle
                size: 5
            }
        }

        Graphic {
            id: polygonGraphic
            symbol: SimpleFillSymbol {
                color: Qt.rgba(0.5, 0, 0.0, 0.25)
                outline:  SimpleLineSymbol {
                    color: "red"
                    style: Enums.SimpleLineSymbolStyleSolid
                    width: 2
                }
            }
        }

        Graphic {
            id: intersectionGraphic
            symbol: SimpleFillSymbol {
                color: Qt.rgba(0.0, 0, 0.5, 0.5)
                outline:  SimpleLineSymbol {
                    color: "blue"
                    style: Enums.SimpleLineSymbolStyleSolid
                    width: 4
                }
            }
        }

        function addSampleGraphic() {
            var graphicClone = polygonGraphic.clone();
            graphicClone.geometry = samplePolygon;
            graphicsLayer.addGraphic(graphicClone);
        }

        function addPoint(mapPoint) {
            var newPoint = redPointGraphic.clone();
            newPoint.geometry = mapPoint;
            graphicsLayer.addGraphic(newPoint);

            var graphicClone = polygonGraphic.clone();
            if (firstPoint) {
                firstPoint = false;
                userPolygon.startPath(mapPoint.x, mapPoint.y);
                graphicClone.geometry = userPolygon;
                polyGraphicId = graphicsLayer.addGraphic(graphicClone);
            } else {
                userPolygon.lineTo(mapPoint.x, mapPoint.y);
                graphicClone.geometry = userPolygon;
                graphicsLayer.updateGraphic(polyGraphicId, graphicClone);
                if (userPolygon.pointCount > 2)
                    intersectionButton.enabled = true;
            }
        }

        function drawIntersectionPolygon() {
            var intersectionPolygon = samplePolygon.intersect(userPolygon);
            if (intersectionPolygon.pointCount > 1) {
                var graphic = intersectionGraphic.clone();
                graphic.geometry = intersectionPolygon;
                graphicsLayer.addGraphic(graphic);
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

