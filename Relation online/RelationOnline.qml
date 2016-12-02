//------------------------------------------------------------------------------
// RelationOnline.qml

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
    property bool firstPoint: true
    property bool isDone: false
    property int polyGraphicId
    property int lineGraphicId

    Map {
        id: mainMap
        anchors.fill: parent
        extent: envelopeInitalExtent
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/arcgis/rest/services/NatGeo_World_Map/MapServer"
        }

        GraphicsLayer {
            id: graphicsLayer
        }

        Envelope {
            id: envelopeInitalExtent
            xMin: -10248676
            yMin: -4564848
            xMax: -856094
            yMax: 106982
        }

        onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                samplePolygon.startPath(-6886625.371714642, -371576.35919899866);
                samplePolygon.lineTo(-7192266.337922403, -3239899.2728410517);
                samplePolygon.lineTo(-3371754.2603254057, -1876270.3466833541);
                samplePolygon.lineTo(-3971280.7709637033, -289288.4067584481);
                addSampleGraphic();
            }
        }

        onMouseClicked: {
            if (!isDone)
                addPoint(mouse.mapPoint);
        }
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

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse.accepted = true)
        }
    }

    Column {
        id: resultsColumn
        anchors {
            top: parent.top
            left: parent.left
            margins: 20 * scaleFactor
        }
        width: row.width
        spacing: 10 * scaleFactor

        Row {
            id: disjointRow
            spacing: 10 * scaleFactor
            visible: false

            Text {
                text: "Red <b>Disjoint</b> from Blue?"
            }

            Text {
                id: disjointText
            }
        }

        Row {
            id: containsRow
            spacing: 10 * scaleFactor
            visible: false

            Text {
                text: "Red <b>Contains</b> Blue?"
            }

            Text {
                id: containsText
            }
        }

        Row {
            id: crossesRow
            spacing: 10 * scaleFactor
            visible: false

            Text {
                text: "Red <b>Crosses</b> Blue?"
            }

            Text {
                id: crossesText
            }
        }

        Row {
            id: equalsRow
            spacing: 10 * scaleFactor
            visible: false

            Text {
                text: "Red <b>Equals</b> Blue?"
            }

            Text {
                id: equalsText
            }
        }

        Row {
            id: touchesRow
            spacing: 10 * scaleFactor
            visible: false

            Text {
                text: "Red <b>Touches</b> Blue?"
            }

            Text {
                id: touchesText
            }
        }

        Row {
            id: withinRow
            spacing: 10 * scaleFactor
            visible: false

            Text {
                text: "Red <b>Within</b> Blue?"
            }

            Text {
                id: withinText
            }
        }

        Row {
            id: row
            spacing: 10 * scaleFactor

            Button {
                id: relationshipButton
                text: "Calculate Relationship"
                enabled: false

                onClicked: {
                    isDone = true;
                    showRows();
                    calculateContains();
                    calculateCrosses();
                    calculateDisjoint();
                    calculateEquals();
                    calculateTouches();
                    calculateWithin();
                    relationshipButton.enabled = false;
                }
            }

            Button {
                text: "Clear"

                onClicked: {
                    if (userPolygon.pathCount > 0)
                        userPolygon.removePath(0);
                    if (userPolyline.pathCount > 0)
                        userPolyline.removePath(0);
                    hideRows();
                    isDone = false;
                    firstPoint = true;
                    relationshipButton.enabled = false;
                    graphicsLayer.removeAllGraphics();
                    addSampleGraphic();
                }
            }
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
            }

            RadioButton {
                id: polylineRadioButton
                text: qsTr("Polyline")
                checked: false
                enabled: firstPoint
                exclusiveGroup: geometryExclusiveGroup
            }

            RadioButton {
                id: pointRadioButton
                text: qsTr("Point")
                checked: false
                enabled: firstPoint
                exclusiveGroup: geometryExclusiveGroup
            }
        }
    }

    Polygon {
        id: userPolygon
        spatialReference: mainMap.spatialReference
    }

    Polygon {
        id: samplePolygon
        spatialReference: mainMap.spatialReference
    }

    Polyline {
        id: userPolyline
        spatialReference: mainMap.spatialReference
    }

    Point {
        id: userPoint
        spatialReference: mainMap.spatialReference
    }

    Graphic {
        id: bluePointGraphic
        symbol: SimpleMarkerSymbol {
            color: "blue"
            style: Enums.SimpleMarkerSymbolStyleCircle
            size: 5
        }
    }

    Graphic {
        id: blueLineGraphic
        symbol: SimpleLineSymbol {
            color: "blue"
            style: Enums.SimpleLineSymbolStyleSolid
            width: 5
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
        id: userGraphic
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
        var newPoint = bluePointGraphic.clone();
        newPoint.geometry = mapPoint;

        var graphicClone;
        if (pointRadioButton.checked) {
            userPoint.x = newPoint.geometry.x;
            userPoint.y = newPoint.geometry.y;
            newPoint.symbol.width = 15;
            graphicsLayer.removeAllGraphics();
            addSampleGraphic();
            graphicsLayer.addGraphic(newPoint);
            relationshipButton.enabled = true;
            firstPoint = false;
        } else if (polygonRadioButton.checked) {
            graphicsLayer.addGraphic(newPoint);
            graphicClone = userGraphic.clone();
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
                    relationshipButton.enabled = true;
            }
        } else if (polylineRadioButton.checked) {
            graphicsLayer.addGraphic(newPoint);
            graphicClone = blueLineGraphic.clone();
            if (firstPoint) {
                firstPoint = false;
                userPolyline.startPath(mapPoint.x, mapPoint.y);
                graphicClone.geometry = userPolyline;
                lineGraphicId = graphicsLayer.addGraphic(graphicClone);
            } else {
                userPolyline.lineTo(mapPoint.x, mapPoint.y);
                graphicClone.geometry = userPolyline;
                graphicsLayer.updateGraphic(lineGraphicId, graphicClone);
                if (userPolyline.pointCount > 1)
                    relationshipButton.enabled = true;
            }
        }
    }

    function calculateDisjoint() {
        var disjoint;
        if (polygonRadioButton.checked)
            disjoint = samplePolygon.disjoint(userPolygon);
        else if (polylineRadioButton.checked)
            disjoint = samplePolygon.disjoint(userPolyline);
        else if (pointRadioButton.checked)
            disjoint = samplePolygon.disjoint(userPoint);
        disjointText.text = disjoint;
    }

    function calculateContains() {
        var contains;
        if (polygonRadioButton.checked)
            contains = samplePolygon.contains(userPolygon);
        else if (polylineRadioButton.checked)
            contains = samplePolygon.contains(userPolyline);
        else if (pointRadioButton.checked)
            contains = samplePolygon.contains(userPoint);
        containsText.text = contains;
    }

    function calculateCrosses() {
        if (polygonRadioButton.checked || pointRadioButton.checked)
            crossesRow.visible = false; // this relationship is not possible
        else if (polylineRadioButton.checked)
            crossesText.text = samplePolygon.crosses(userPolyline);
    }

    function calculateEquals() {
        if (polygonRadioButton.checked)
            equalsText.text = samplePolygon.equals(userPolygon);
        else
            equalsRow.visible = false; // this relationship is not possible
    }

    function calculateTouches() {
        var touches
        if (polygonRadioButton.checked)
            touches = samplePolygon.touches(userPolygon);
        else if (polylineRadioButton.checked)
            touches = samplePolygon.touches(userPolyline);
        else if (pointRadioButton.checked)
            touches = samplePolygon.touches(userPoint);
        touchesText.text = touches;
    }

    function calculateWithin() {
        if (polygonRadioButton.checked)
            withinText.text = samplePolygon.within(userPolygon);
        else
            withinRow.visible = false; // this relationship is not possible
    }

    function hideRows() {
        disjointRow.visible = false;
        containsRow.visible = false;
        crossesRow.visible = false;
        equalsRow.visible = false;
        touchesRow.visible = false;
        withinRow.visible = false;
    }

    function showRows() {
        disjointRow.visible = true;
        containsRow.visible = true;
        crossesRow.visible = true;
        equalsRow.visible = true;
        touchesRow.visible = true;
        withinRow.visible = true;
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

