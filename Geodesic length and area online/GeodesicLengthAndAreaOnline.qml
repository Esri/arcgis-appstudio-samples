//------------------------------------------------------------------------------
// GeodesicLengthAndAreaOnline.qml
// Created 2015-02-13 13:45:07
//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 800
    height: 532
    property double scaleFactor: AppFramework.displayScaleFactor
    property string platform: Qt.platform.os
    property int  polygonId
    property int  polylineId
    property bool firstPoint: true
    property bool isDone: false
    property double geodesicLength: 0.0
    property double geodesicArea: 0.0
    property string geodesicLengthText: "Length: " + geodesicLength.toFixed(3) + " miles." + "\n"
    property string geodesicAreaText:"Area: " + geodesicArea.toFixed(3) + " square miles."

    Map {
        id: mainMap
        anchors.fill: parent
        extent: envelopeInitalExtent
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        GraphicsLayer {
            id: graphicsLayer
            selectionColor: "red"
        }

        onMouseClicked: {
            if (isDone)
                return;

            drawPoint(mouse.mapPoint);
            addPoint(mouse.mapPoint);
        }
    }

    LinearUnit {
        id: linearUniMeter
        wkid: Enums.LinearUnitCodeMeter
    }

    LinearUnit {
        id: linearUnitMile
        wkid: Enums.LinearUnitCodeMileUS
    }

    AreaUnit {
        id: areaUnitMile
        wkid: Enums.AreaUnitCodeSquareMileUS
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

        MouseArea {
            anchors.fill: parent
            onClicked: {
                mouse.accepted = true
            }
        }
    }

    Column {
        id: resultsColumn
        anchors {
            top: parent.top
            left: parent.left
            margins: 20 * scaleFactor
        }
        spacing: 10 * scaleFactor

        width: {
            if (!(platform === "android" || platform === "ios"))
                width: 250 * scaleFactor
        }

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

        TextArea {
            id: geodesicResultsTextArea
            anchors {
                left: parent.left
                right: parent.right
                margins: 5 * scaleFactor
            }
            textColor: "black"
            text : geodesicLengthText + geodesicAreaText
            font.pixelSize: {
                if (!(platform === "android" || platform === "ios"))
                    pixelSize: 14 * scaleFactor
                else
                    pixelSize: 11 * scaleFactor
            }

            height: {
              if (!(platform === "android" || platform === "ios"))
                  height: 60 * scaleFactor
              else
                  height: 40 * scaleFactor
            }
            readOnly: true
        }

        Row {
            spacing: 10 * scaleFactor

            Button {
                id: calculateButton
                text: "Calculate"
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
                    if (polylineRadioButton.checked) {
                        drawDensifyLine();
                        geodesicLength = polyline.geodesicLength(linearUnitMile);
                    } else {
                        drawDensifyPolygon();
                        geodesicLength = polygon.geodesicLength(linearUnitMile);
                        geodesicArea = polygon.geodesicArea(areaUnitMile);
                    }
                    geodesicResultsTextArea.text = geodesicLengthText + geodesicAreaText;
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
                    geodesicLength = 0.0;
                    geodesicArea = 0.0;
                    calculateButton.enabled = false;
                    geodesicResultsTextArea.text = geodesicLengthText + geodesicAreaText;
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
        id: bluePointGraphic
        symbol: SimpleMarkerSymbol {
            color: "blue"
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
            color: "blue"
            style: Enums.SimpleLineSymbolStyleSolid
            width: 2
        }
    }

    Graphic {
        id: densifyPolygonGraphic
        symbol: SimpleFillSymbol {
            color: Qt.rgba(0.0, 0, 0.5, 0.5)

            outline:  SimpleLineSymbol {
                color: "blue"
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
        var densifyPolyline = polyline.geodesicDensify(mainMap.resolution * 10, linearUniMeter);
        var lineGraphicClone = densifyLineGraphic.clone();
        lineGraphicClone.geometry = densifyPolyline;
        graphicsLayer.addGraphic(lineGraphicClone);
        for (var i = 0; i < densifyPolyline.pointCount; i++) {
            var vertex = densifyPolyline.point(i);
            var newPoint = bluePointGraphic.clone();
            newPoint.geometry = vertex;
            graphicsLayer.addGraphic(newPoint);
        }
    }

    function drawDensifyPolygon() {
        var densifyPolygon = polygon.geodesicDensify(mainMap.resolution * 10, linearUniMeter);

        var polygoneGraphicClone = densifyPolygonGraphic.clone();
        polygoneGraphicClone.geometry = densifyPolygon;
        graphicsLayer.addGraphic(polygoneGraphicClone);
        for (var i = 0; i < densifyPolygon.pointCount; i++) {
            var vertex = densifyPolygon.point(i);
            var newPoint = bluePointGraphic.clone();
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

