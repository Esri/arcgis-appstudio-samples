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
//------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

App {
    id: app
    width: 400
    height: 640

    property real scaleFactor: AppFramework.displayScaleFactor
    property bool firstPoint: true
    property bool isDone: false
    property var bufferPoint
    property var newPoint
    property int bufferWidth: 100
    property int polyGraphicId
    property int counter: 0

    Rectangle {
        id: titleRect
        height: titleText.paintedHeight + titleText.anchors.margins * 2
        color: "Green"
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        Text {
            id: titleText
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 2 * AppFramework.displayScaleFactor
            }
            text: qsTr("Draw polygons on the map and snap verticies to points from the feature service")
            color: "white"
            font {
                pointSize: 16
            }
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Rectangle {
        id: bottomRect
        height: editButton.height * 3.5 + editButton.anchors.topMargin * 3
        color: "Orange"
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Text {
            id: bottomText
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 5 * AppFramework.displayScaleFactor
            }
            text: qsTr("To start drawing: Press the 'Edit' button.<br>To finish: Press and hold the mouse for 2-3 seconds.<br>To clear the graphics: Press the 'Clear' button.<br>When snap point to existing features the buffer is green,<br> otherwise the snap point is red.
")
            font: {
                pointSize: 10
            }
            color: "black"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 5
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignLeft
        }

        Rectangle {
            id: buttonRect
            height: bottomRect.height
            color: "orange"
            anchors.rightMargin: 2 * AppFramework.displayScaleFactor
            anchors.leftMargin: 2 * AppFramework.displayScaleFactor
            width: editButton.width
            anchors {
                right: parent.right
                bottom: parent.bottom
            }

            Button {
                id: editButton
                x: 0
                y: 13
                text: qsTr("Edit")
                enabled: true
                anchors {
                    topMargin: 1 * AppFramework.displayScaleFactor
                    bottomMargin: 2 * AppFramework.displayScaleFactor
                }
                width: clearButton.width
                style: ButtonStyle {
                    label: Text {
                        id: editBtnTxt
                        renderType: Text.NativeRendering
                        verticalAlignment: Text.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 17 * scaleFactor
                        color: enabled ? "black" : "gray"
                        text: control.text
                    }
                }
                onClicked: {
                    isDone = true;
                    editFlash.start()
                }
            }

            Button {
                id: clearButton
                x: 0
                text: qsTr("Clear")
                anchors.rightMargin: 0
                anchors.topMargin: 13
                style: editButton.style
                enabled: true
                anchors {
                    right: editButton.right
                    top: editButton.bottom
                    bottomMargin: 1 * AppFramework.displayScaleFactor
                }
                onClicked: {
                    var numberPolygonDraw = userPolygon.pathCount;
                    for (counter; counter < numberPolygonDraw; counter++){
                        userPolygon.removePath(0);
                    }
                    isDone = false;
                    firstPoint = true;
                    featureLayer.clearSelection();
                    graphicsLayer.removeAllGraphics();
                    clearFlash.start()

                    if (userPolygon.pathCount > 0)
                        userPolygon.removePath(0);
                }
            }
        }
    }

    Map {
        id: map
        wrapAroundEnabled:  true
        focus: true
        anchors {
            left: parent.left
            right: parent.right
            top: titleRect.bottom
            bottom: bottomRect.top
        }

        NorthArrow {
            anchors {
                left: parent.left
                top: titleRect.bottom
                margins: 10
            }

            visible: map.mapRotation != 0
        }

        ZoomButtons {
            anchors {
                top: parent.top
                left: parent.left
                margins: 10
            }
        }

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer"
        }

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Reference/MapServer"
        }

        GeodatabaseFeatureServiceTable {
            id: featureServiceTable
            url: "https://services1.arcgis.com/FDPKa3De7Gog62xK/arcgis/rest/services/SFPubArt84Mgr/FeatureServer/0"
        }

        GraphicsLayer {
            id: graphicsLayer
        }

        onMouseClicked: {
            if(isDone == true) {
                addPoint(mouse.mapPoint, mouse.x, mouse.y);
            }
        }

        onMousePressAndHold: {
            if(isDone == true) {
                finishdraw()
            }
            finishFlash.start()
        }

        onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                map.zoomTo(sfExtent);
                addLayer(graphicsLayer)
            }
        }

        FeatureLayer {
            id: featureLayer
            featureTable: featureServiceTable
            ColorAnimation on selectionColor {
                to: "red"
                duration: 1000
            }
        }

        Envelope {
            id: sfExtent
            xMin: -13646875.937461125
            yMin: 4537864.794149817
            xMax: -13619530.59059214
            yMax: 4552731.796151265
            spatialReference: map.spatialReference
        }
    }

    Graphic {
        id: redPointGraphic
        symbol: SimpleMarkerSymbol{
            color: "red"
            style: Enums.SimpleMarkerSymbolStyleCircle
            size: 10
        }
    }

    Graphic {
        id: polygonGraphic
        symbol: SimpleFillSymbol {
            color: Qt.rgba(0.5, 0, 0.0, 0.25)
            outline: SimpleLineSymbol {
                color:"orange"
                style: Enums.SimpleLineSymbolStyleDashDot
                width: 4
            }
        }
    }

    Graphic {
        id: bufferGraphic
        symbol: SimpleFillSymbol {
            color: Qt.rgba(0, 0, 0, 0.5)
            outline:  SimpleLineSymbol {
                color: Qt.rgba(0, 255, 0, 1)
                style: Enums.SimpleLineSymbolStyleDashDot
                width: 3.5
            }
        }
    }

    MultiPoint {
        id: points
        spatialReference: {
            "latestWkid": 3857,
            "wkid":102100
        }
    }

    Polygon {
        id: userPolygon
        spatialReference: map.spatialReference
    }

    Rectangle {
        anchors {
            fill: controlsColumn
            margins: .10 * scaleFactor
        }
        color: "lightgrey"
        radius:  .10 * scaleFactor
        border.color: "black"
        opacity: 0.88

        MouseArea {
            anchors.fill: parent
        }
    }

    Text{
        font.pointSize: 30
        color:"Orange"
        id: starEdit
        text: qsTr("Drawing")
        opacity: 0
        anchors {
            top: titleRect.bottom
        }

        SequentialAnimation{
            id: editFlash;
            OpacityAnimator{
                target: starEdit;
                from: 0;
                to: 1;
                duration: 1050
            }
            OpacityAnimator{
                target: starEdit;
                from: 1;
                to: 0;
                duration: 1050
            }
        }
    }

    Text{
        font.pointSize: 30
        id: clear
        color:"Orange"
        text: qsTr("Graphic cleared")
        opacity: 0
        anchors {
            top: titleRect.bottom
        }

        SequentialAnimation{
            id: clearFlash;
            OpacityAnimator{
                target: clear;
                from: 0;
                to: 1;
                duration: 1050

            }
            OpacityAnimator{
                target: clear;
                from: 1;
                to: 0;
                duration: 1050
            }
        }
    }

    Text{
        font.pointSize: 30
        id: finish
        color:"Orange"
        text: qsTr("Finish Draw")
        opacity: 0
        anchors {
            top: titleRect.bottom
        }

        SequentialAnimation{
            id: finishFlash;
            OpacityAnimator{
                target: finish;
                from: 0;
                to: 1;
                duration: 1050

            }
            OpacityAnimator{
                target: finish;
                from: 1;
                to: 0;
                duration: 1050
            }
        }
    }

    Column {
        id: controlsColumn
        x: 283
        y: 75
        anchors.rightMargin: 23
        anchors.topMargin: 27
        spacing: 4
        anchors {
            right: parent.right
            top: titleRect.bottom
            margins: 30 * scaleFactor
        }
    }

    function finishdraw() {
        var featureAdd = ArcGISRuntime.createObject("Feature")
        featureAdd.geometry = userPolygon
        featureAdd.setAttributeValue("symbolid","1")
        graphicsLayer.addGraphic(featureAdd)
        console.log("Feature added")
        isDone = false
        firstPoint = true
        if (userPolygon.pathCount > 0)
            userPolygon.removePath(0);
    }

    function addPoint(mapPoint, mousex, mousey) {
        var newPoint = redPointGraphic.clone();
        var graphicClone = polygonGraphic.clone();

        if(firstPoint) {
            firstPoint = false
            var featureIds = featureLayer.findFeatures(mousex, mousey, 15, 1);
            if (featureIds.length == 0) {
                userPolygon.startPath(mapPoint.x, mapPoint.y);
                graphicClone.geometry = userPolygon;
                polyGraphicId = graphicsLayer.addGraphic(graphicClone);
                newPoint.geometry = mapPoint;
                graphicsLayer.addGraphic(newPoint);
            }

            if (featureIds.length !== 0) {
                var selectedFeatureId = featureIds[0];
                var selectedFeature = featureServiceTable.feature(selectedFeatureId);
                var bufferPoint = selectedFeature.geometry
                bufferPoint.spatialReference = map.spatialReference;
                userPolygon.startPath(bufferPoint.x, bufferPoint.y);
                graphicClone.geometry = userPolygon;
                polyGraphicId = graphicsLayer.addGraphic(graphicClone);
                newPoint.geometry = bufferPoint;
                drawBufferPolygon(bufferPoint);
                graphicsLayer.addGraphic(bufferPoint);
                featureIds = null;
            }
        }
        else {
            var featureIds = featureLayer.findFeatures(mousex, mousey, 15, 1);
            if (featureIds.length == 0) {
                userPolygon.lineTo(mapPoint.x, mapPoint.y);
                graphicClone.geometry = userPolygon;
                graphicsLayer.updateGraphic(polyGraphicId,graphicClone);
                newPoint.geometry = mapPoint;
                graphicsLayer.addGraphic(newPoint);

            }
            else {
                var selectedFeatureId = featureIds[0];
                var selectedFeature = featureServiceTable.feature(selectedFeatureId);
                var bufferPoint = selectedFeature.geometry
                bufferPoint.spatialReference = map.spatialReference;
                userPolygon.lineTo(bufferPoint.x, bufferPoint.y);
                graphicClone.geometry = userPolygon;
                graphicsLayer.updateGraphic(polyGraphicId,graphicClone);
                newPoint.geometry = bufferPoint;
                drawBufferPolygon(bufferPoint);
                graphicsLayer.addGraphic(bufferPoint);
                featureIds = null;
            }
        }
    }

    function drawBufferPolygon(geometry) {
        var bufferPolygon = geometry.buffer(bufferWidth, map.spatialReference.unit);
        var graphic = bufferGraphic.clone();
        graphic.geometry = bufferPolygon;
        graphicsLayer.addGraphic(graphic);
    }
}
