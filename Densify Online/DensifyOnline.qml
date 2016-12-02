//------------------------------------------------------------------------------
// DensifyOnline.qml
// Created 2015-03-13 13:40:42
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
        property int polygonId
        property int polylineId
        property bool firstPoint: true
        property bool isDone: false

        Map {
            id: mainMap
            anchors.fill: parent
            extent: envelopeInitalExtent
            focus: true

            ArcGISTiledMapServiceLayer {
                url: "http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base/MapServer"
            }

            GraphicsLayer {
                id: graphicsLayer
            }

            onMouseClicked: {
                if (!isDone) {
                    drawPoint(mouse.mapPoint);
                    addPoint(mouse.mapPoint);
                }
            }
        }

        LinearUnit {
            id: linearUnitMeter
            wkid: Enums.LinearUnitCodeMeter
        }

        Rectangle {
            anchors {
                fill: resultsColumn
                margins: -10 * scaleFactor
            }
            color: "lightgrey"
            radius: 5 * scaleFactor
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
            spacing: 10 * scaleFactor

            Row {
                spacing: 10 * scaleFactor

                ExclusiveGroup {
                    id: geometryExclusiveGroup
                }

                RadioButton {
                    id: polygonRadioButton
                    text: qsTr("Polygon")
                    checked: true
                    enabled: firstPoint
                    exclusiveGroup: geometryExclusiveGroup
                    style: RadioButtonStyle {
                        label: Text {
                            renderType: Text.NativeRendering
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 14 * scaleFactor
                            color: "black"
                            text: control.text
                        }
                    }
                }

                RadioButton {
                    id: polylineRadioButton
                    text: qsTr("Polyline")
                    checked: false
                    enabled: firstPoint
                    exclusiveGroup: geometryExclusiveGroup
                    style: polygonRadioButton.style
                }
            }

            Row {
                id: btnRow
                spacing: 10 * scaleFactor

                Button {
                    id: calculateButton
                    text: "Densify"
                    enabled: false
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
                        calculateButton.enabled = false;
                        if (polylineRadioButton.checked)
                            drawDensifyLine();
                        else
                            drawDensifyPolygon();
                    }
                }

                Button {
                    text: "Clear"
                    style: calculateButton.style
                    onClicked: {
                        graphicsLayer.removeAllGraphics();

                        if (polyline.pathCount > 0)
                            polyline.removePath(0);
                        if (polygon.pathCount > 0)
                            polygon.removePath(0);

                        isDone = false;
                        firstPoint = true;
                        calculateButton.enabled = false;
                    }
                }
            }

            Row {
                spacing: 10 * scaleFactor

                CheckBox {
                    id: geodesicCheckbox
                    text: "Geodesic"
                    style: CheckBoxStyle {
                        label: Text {
                            text: control.text
                            color:"black"
                        }
                    }
                    onCheckedChanged: {
                        if (polyline.pointCount > 1)
                            calculateButton.enabled = true;
                        if (polygon.pointCount > 2)
                            calculateButton.enabled = true;
                    }
                }
            }
        }

        Envelope {
            id: envelopeInitalExtent
            xMin: -14321929
            yMin: 2497898
            xMax: -7339385
            yMax: 6587123
            spatialReference: mainMap.spatialReference
        }

        Polyline {
            id: polyline
            spatialReference: mainMap.spatialReference
        }

        Polygon {
            id: polygon
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
            id: densifyPointGraphic
            symbol: SimpleMarkerSymbol {
                color: geodesicCheckbox.checked ? "#00FF00" : "blue"
                style: Enums.SimpleMarkerSymbolStyleCircle
                size: 12
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
            id: polygonGraphic
            symbol: SimpleFillSymbol {
                color: Qt.rgba(0.5, 0, 0, 0.25)
                outline:  SimpleLineSymbol {
                    color: "red"
                    style: Enums.SimpleLineSymbolStyleSolid
                    width: 2
                }
            }
        }

        Graphic {
            id: densifyLineGraphic
            symbol: SimpleLineSymbol {
                color: geodesicCheckbox.checked ? "#00FF00" : "blue"
                style: Enums.SimpleLineSymbolStyleSolid
                width: 2
            }
        }

        Graphic {
            id: densifyPolygonGraphic
            symbol: SimpleFillSymbol {
                color: "transparent"
                outline:  SimpleLineSymbol {
                    color: geodesicCheckbox.checked ? "#00FF00" : "blue"
                    style: Enums.SimpleLineSymbolStyleSolid
                    width: 2
                }
            }
        }

        function drawLine() {
            var lineGraphicClone = lineGraphic.clone();
            lineGraphicClone.geometry = polyline;
            graphicsLayer.updateGraphic(polylineId, lineGraphicClone);
            if (polyline.pointCount > 1)
                calculateButton.enabled = true;
        }

        function drawPolygon() {
            var polygoneGraphicClone = polygonGraphic.clone();
            polygoneGraphicClone.geometry = polygon;
            graphicsLayer.updateGraphic(polygonId, polygoneGraphicClone);
            if (polygon.pointCount > 2)
                calculateButton.enabled = true;
        }

        function drawPoint(mapPoint) {
            var newPoint = redPointGraphic.clone();
            newPoint.geometry = mapPoint;
            graphicsLayer.addGraphic(newPoint);
        }

        function addPoint(mapPoint) {
            if (firstPoint) {
                firstPoint = false;
                if (polylineRadioButton.checked) {
                    polyline.startPath(mapPoint.x, mapPoint.y);
                    var lineGraphicClone = lineGraphic.clone();
                    lineGraphicClone.geometry = polyline;
                    polylineId = graphicsLayer.addGraphic(lineGraphicClone);
                } else {
                    polygon.startPath(mapPoint.x, mapPoint.y);
                    var polygoneGraphicClone = polygonGraphic.clone();
                    polygoneGraphicClone.geometry = polygon;
                    polygonId = graphicsLayer.addGraphic(polygoneGraphicClone);
                }
            } else {
                if (polylineRadioButton.checked) {
                    polyline.lineTo(mapPoint.x, mapPoint.y);
                    drawLine();
                } else {
                    polygon.lineTo(mapPoint.x, mapPoint.y);
                    drawPolygon();
                }
            }
        }

        function drawDensifyLine() {
            var densifyPolyline
            if (geodesicCheckbox.checked)
                densifyPolyline = polyline.geodesicDensify(mainMap.resolution * 10, linearUnitMeter);
            else
                densifyPolyline = polyline.densify(mainMap.resolution * 10);
            var lineGraphicClone = densifyLineGraphic.clone();
            lineGraphicClone.geometry = densifyPolyline;
            graphicsLayer.addGraphic(lineGraphicClone);
            for (var i = 0; i < densifyPolyline.pointCount; i++) {
                var vertex = densifyPolyline.point(i);
                var newPoint = densifyPointGraphic.clone();
                newPoint.geometry = vertex;
                graphicsLayer.addGraphic(newPoint);
            }
        }

        function drawDensifyPolygon() {
            var densifyPolygon;
            if (geodesicCheckbox.checked)
                densifyPolygon = polygon.geodesicDensify(mainMap.resolution * 10, linearUnitMeter);
            else
                densifyPolygon = polygon.densify(mainMap.resolution * 10);
            var polygoneGraphicClone = densifyPolygonGraphic.clone();
            polygoneGraphicClone.geometry = densifyPolygon;
            graphicsLayer.addGraphic(polygoneGraphicClone);
            for (var i = 0; i < densifyPolygon.pointCount; i++) {
                var vertex = densifyPolygon.point(i);
                var newPoint = densifyPointGraphic.clone();
                newPoint.geometry = vertex;
                graphicsLayer.addGraphic(newPoint);
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

