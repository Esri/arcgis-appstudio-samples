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

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
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
    property var symbolsList: []

    Map {
        id: leftMap
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            right: parent.horizontalCenter
            rightMargin: 1 * scaleFactor
        }

        animationDuration: 1.0
        rotationByPinchingEnabled: true
        focus: true
        extent: initialExtent

        onStatusChanged: {
            if (status === Enums.MapStatusReady)
                addGraphics("Static");
        }

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer"
        }

        GraphicsLayer {
            id: graphicsLayerStatic
            renderingMode: Enums.RenderingModeStatic
        }

        Rectangle {
            anchors {
                fill: backgroundRow
                margins: -10 * scaleFactor
            }
            width: backgroundRow.width
            color: "lightgrey"
            radius: 5
            border.color: "black"
            opacity: 0.77
        }

        Column {
            id: backgroundRow
            anchors {
                top: parent.top
                left: parent.left
                margins: 15 * scaleFactor
            }
            spacing: 7 * scaleFactor

            Column {
                Text {
                    text: qsTr("Static Mode")
                    font {
                        bold: true
                        italic: true
                        pixelSize: 15 * scaleFactor
                    }
                }
            }
        }

        RotationToolbar {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 15 * scaleFactor
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

    Map {
        id: rightMap
        anchors {
            left: parent.horizontalCenter
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            leftMargin: 1 * scaleFactor
        }

        animationDuration: 1.0
        rotationByPinchingEnabled: true
        extent: initialExtent

        onStatusChanged: {
            if (status === Enums.MapStatusReady)
                addGraphics("Dynamic");
        }

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer"
        }

        GraphicsLayer {
            id: graphicsLayerDynamic
            renderingMode: Enums.RenderingModeDynamic
        }

        Rectangle {
            anchors {
                fill: backgroundRow2
                margins: -10 * scaleFactor
            }
            width: backgroundRow.width
            color: "lightgrey"
            radius: 5
            border.color: "black"
            opacity: 0.77
        }

        Column {
            id: backgroundRow2
            anchors {
                top: parent.top
                left: parent.left
                margins: 15 * scaleFactor
            }
            spacing: 7 * scaleFactor

            Column {
                Text {
                    text: qsTr("Dynamic Mode")
                    font {
                        bold: true
                        italic: true
                        pixelSize: 15 * scaleFactor
                    }
                }
            }
        }

        RotationToolbar {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 15 * scaleFactor
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

    SimpleLineSymbol {
        id: slsSolid
        color: "cyan"
        width: 20
        style: Enums.SimpleLineSymbolStyleSolid
    }

    SimpleLineSymbol {
        id: slsDashDotDot
        color: "red"
        width: 1
        style: Enums.SimpleLineSymbolStyleDashDotDot
    }

    SimpleFillSymbol {
        id: sfsCross
        color: "green"
        style: Enums.SimpleFillSymbolStyleDiagonalCross
        outline: slsDashDotDot
    }

    TextSymbol {
        id: textSymbolStatic
        textColor: "magenta"
        size: 20
        text: "Static"
    }

    TextSymbol {
        id: textSymbolDynamic
        textColor: "magenta"
        size: 20
        text: "Dynamic"
    }

    PictureMarkerSymbol {
        id: staticPictureMarker
        image: "static.png"
    }

    PictureMarkerSymbol {
        id: dynamicPictureMarker
        image: "dynamic.png"
    }

    Point {
        id: basePoint
        spatialReference: leftMap.spatialReference
    }

    Polyline {
        id: basePolyline
        spatialReference: leftMap.spatialReference
    }

    Polygon {
        id: basePolygon
        spatialReference: leftMap.spatialReference
    }

    Envelope {
        id: initialExtent
        xMax: -17294000
        yMax: -3408000
        xMin: 17928000
        yMin: 10799000

    }

    function randSmsStyle() {
        var num = randInRange(5)
        switch (num)
        {
        case 0:
            return "esriSMSCircle";
        case 1:
            return "esriSMSCross";
        case 2:
            return "esriSMSX";
        case 3:
            return "esriSMSSquare";
        case 4:
            return "esriSMSDiamond";
        case 5:
            return "esriSMSTriangle";
        }
    }

    function randColor() {
        var count = 1;
        var color;
        if (count % 2)
            color = [randInRange(256),
                     randInRange(256),
                     randInRange(256),
                     255];
        else
            color = [randInRange(256),
                     randInRange(256),
                     randInRange(256),
                     100];
        count++;
        return color;
    }

    function randInRange(range) {
        return Math.floor(Math.random() * (range + 1));
    }

    function addGraphics(renderingMode) {
        createSymbolList();
        var graphicsList = [];
        var westEdge = -20000000;
        var eastEdge = 20000000;
        var southEdge = -20000000;
        var northEdge = 18000000;
        var spacing = 8000000;
        var indexX = 0;
        var indexY = 0;
        var baseGraphic = ArcGISRuntime.createObject("Graphic");

        // create simple point graphics
        for (var x = westEdge + spacing; x <= eastEdge; x += spacing, indexX++) {
            for (var y = southEdge; y <= northEdge; y += spacing, indexY++) {
                var index = indexX + indexY;
                var point = basePoint.clone();
                point.setXY(x, y);
                var graphic = ArcGISRuntime.createObject("Graphic");
                graphic.geometry = point;
                graphic.symbol = symbolsList[index];
                graphicsList.push(graphic);
            }
        }
        for (var tempGraphic = 0; tempGraphic < graphicsList.length; tempGraphic++) {
            if (renderingMode === "Dynamic")
                graphicsLayerDynamic.addGraphic(graphicsList[tempGraphic]);
            else
                graphicsLayerStatic.addGraphic(graphicsList[tempGraphic]);
        }

        // create picture marker symbol point graphic
        var picPoint = ArcGISRuntime.createObject("Point", {json: {spatialReference:{latestWkid: 3857,wkid:102100}, x: 10000000.0, y: -8000000.0}});
        var picGraphic = baseGraphic.clone();
        picGraphic.geometry = picPoint;
        var picGraphic2  = picGraphic.clone();
        picGraphic.symbol = staticPictureMarker;
        picGraphic2.symbol = dynamicPictureMarker;
        if (renderingMode === "Dynamic")
            graphicsLayerDynamic.addGraphic(picGraphic2);
        else
            graphicsLayerStatic.addGraphic(picGraphic);

        // create text symbol point graphic
        var textGraphic = baseGraphic.clone();
        textGraphic.geometry = ArcGISRuntime.createObject("Point", {json: {spatialReference:{latestWkid: 3857,wkid:102100}, x: -18000000, y: -15000000}});
        var textGraphic2 = textGraphic.clone();
        textGraphic.symbol = textSymbolStatic;
        textGraphic2.symbol = textSymbolDynamic;
        if (renderingMode === "Dynamic")
            graphicsLayerDynamic.addGraphic(textGraphic2);
        else
            graphicsLayerStatic.addGraphic(textGraphic);

        // create polyline graphics
        var simplePolyline = basePolyline.clone();
        simplePolyline.startPath(ArcGISRuntime.createObject("Point", {json: {spatialReference:{latestWkid: 3857,wkid:102100}, x: -15000000, y: 1000000}}));
        simplePolyline.lineTo(ArcGISRuntime.createObject("Point", {json: {spatialReference:{latestWkid: 3857,wkid:102100}, x: 10000000, y: 10000000}}));

        var lineGraphic = baseGraphic.clone();
        lineGraphic.geometry = simplePolyline;
        lineGraphic.symbol = slsSolid;
        if (renderingMode === "Dynamic")
            graphicsLayerDynamic.addGraphic(lineGraphic);
        else
            graphicsLayerStatic.addGraphic(lineGraphic);

        var lineGraphic2 = baseGraphic.clone();
        lineGraphic2.geometry = simplePolyline;
        lineGraphic2.symbol = slsDashDotDot;
        if (renderingMode === "Dynamic")
            graphicsLayerDynamic.addGraphic(lineGraphic2);
        else
            graphicsLayerStatic.addGraphic(lineGraphic2);

        // create polygon graphics
        basePolygon.startPath(ArcGISRuntime.createObject("Point", {json: {spatialReference:{latestWkid: 3857,wkid:102100}, x: -8000000.0, y: -2000000.0}}));
        basePolygon.lineTo(-4000000.0,2000000.0);
        basePolygon.lineTo(-2000000.0,-2000000.0);
        basePolygon.closeAllPaths();
        var polyGraphic = baseGraphic.clone();
        polyGraphic.geometry = basePolygon;
        polyGraphic.symbol = sfsCross;
        if (renderingMode === "Dynamic")
            graphicsLayerDynamic.addGraphic(polyGraphic);
        else
            graphicsLayerStatic.addGraphic(polyGraphic);
    }

    function createSymbolList() {
        var evenSimpleLineSymbol = ArcGISRuntime.createObject("SimpleLineSymbol",
                                                              {   json: {
                                                                      type:"esriSLS",
                                                                      color: [255,100,100,255],
                                                                      width: 2,
                                                                      style: "esriSLSSolid"
                                                                  }
                                                              }
                                                              );

        var oddSimpleLineSymbol = ArcGISRuntime.createObject("SimpleLineSymbol",
                                                             {   json: {
                                                                     type: "esriSLS",
                                                                     color: [100,100,255,255],
                                                                     width: 2,
                                                                     style: "esriSLSDashDotDot"
                                                                 }
                                                             }
                                                             );

        for (var i = Enums.SimpleMarkerSymbolStyleCircle; i <  Enums.SimpleMarkerSymbolStyleTriangle; i++) {
            for (var color = 1; color < 10; color++) {
                var symbol;
                if (color % 2)
                    symbol = ArcGISRuntime.createObject("SimpleMarkerSymbol",
                                                        {   json: {
                                                                type: "esriSMS",
                                                                style: randSmsStyle(),
                                                                color: randColor(),
                                                                size: 20,
                                                                outline: evenSimpleLineSymbol.json
                                                            }
                                                        }
                                                        );
                else
                    symbol = ArcGISRuntime.createObject("SimpleMarkerSymbol",
                                                        {   json: {
                                                                type: "esriSMS",
                                                                style: randSmsStyle(),
                                                                color: randColor(),
                                                                size: 20,
                                                                outline: oddSimpleLineSymbol.json
                                                            }
                                                        }
                                                        );
                symbolsList.push(symbol);
            }
        }
    }

    Rectangle {
        id: borderRectangle
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }
}

