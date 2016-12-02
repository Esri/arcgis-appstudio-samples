//------------------------------------------------------------------------------
// SimpleRendererOnline.qml

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

    SimpleRenderer {
        id: simpleRenderer
    }

    DrawingInfo {
        id: drawingInfo
        opacity: 0.7
    }

    SimpleMarkerSymbol {
        id: citiesSymbol
        size: 8
    }

    SimpleLineSymbol {
        id: highwaysSymbol
        width: 8
    }

    SimpleFillSymbol {
        id: statesSymbol
        outline: outlineSymbol
    }

    SimpleLineSymbol {
        id: outlineSymbol
        width: 8
    }

    DrawingInfo {
        id: drawingInfoStates
        opacity: 0.7
    }

    DrawingInfo {
        id: drawingInfoHighways
        opacity: 0.7
    }

    DrawingInfo {
        id: drawingInfoCities
        opacity: 0.7
    }

    Map {
        id: map
        anchors.fill: parent
        extent: usExtent
        wrapAroundEnabled: true
        focus: true

        ArcGISTiledMapServiceLayer {
            id: tiledLayer
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer"
        }

        ArcGISDynamicMapServiceLayer {
            id: dynamicLayer
            url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/USA/MapServer"

            onStatusChanged: {
                if (status === Enums.LayerStatusInitialized) {
                    dynamicLayer.subLayerById(3).visible = false; // hide counties sublayer
                    dynamicLayer.refresh();
                }
            }
        }
    }

    Rectangle {
        anchors {
            margins: -10 * scaleFactor
            fill: grayBackground
        }
        color: "lightgrey"
        radius: 5
        border.color: "black"
        opacity: 0.75
    }

    Row {
        id: grayBackground
        anchors {
            top: parent.top
            left: parent.left
            margins: 20 * scaleFactor
        }
        spacing: 10 * scaleFactor

        Column {
            id: columnControls
            spacing: 10 * scaleFactor

            Text {
                text: "Feature : "
                font {
                    pixelSize: 14 * scaleFactor
                    bold: true
                }
            }

            CheckBox {
                id: citiesCheckBox
                text: qsTr("Cities")
                checked: true
                onCheckedChanged: {
                    updateVisibility(0, checked);
                }
            }

            CheckBox {
                id: highwayCheckBox
                text: qsTr("Highways")
                checked: true
                onCheckedChanged: {
                    updateVisibility(1, checked);
                }
            }

            CheckBox {
                id: statesCheckBox
                text: qsTr("States")
                checked: true
                onCheckedChanged: {
                    updateVisibility(2, checked);
                }
            }
        }

        Column {
            spacing: 10 * scaleFactor

            Text {
                id: action
                text: "Render action :"
                font {
                    pixelSize: 14 * scaleFactor
                    bold: true
                }
            }

            Button {
                text: "Change"
                anchors.horizontalCenter:action.horizontalCenter

                    onClicked: {
                        if (highwayCheckBox.checked) {
                            randomizeHighways();
                            var dynamicLayerInfoList = dynamicLayer.dynamicLayerInfos;
                            var renderer;
                            var dynamicLayerInfo = dynamicLayerInfoList[1]; // get the highways layer
                            if (!dynamicLayerInfo.drawingInfo)
                                dynamicLayerInfo.drawingInfo = drawingInfoHighways;
                            renderer = ArcGISRuntime.createObject("SimpleRenderer");
                            renderer.symbol = highwaysSymbol;
                            dynamicLayerInfo.drawingInfo.renderer = renderer;
                            dynamicLayer.refresh();
                        }

                        if (statesCheckBox.checked) {
                            randomizeStates();
                            var dynamicLayerInfoList = dynamicLayer.dynamicLayerInfos;
                            var renderer;
                            var dynamicLayerInfo = dynamicLayerInfoList[2]; // get the states layer
                            if (!dynamicLayerInfo.drawingInfo)
                                dynamicLayerInfo.drawingInfo = drawingInfoStates;
                            renderer = ArcGISRuntime.createObject("SimpleRenderer");
                            renderer.symbol = statesSymbol;
                            dynamicLayerInfo.drawingInfo.renderer = renderer;
                            dynamicLayer.refresh();
                        }

                        if (citiesCheckBox.checked) {
                            randomizeCities();
                            var dynamicLayerInfoList = dynamicLayer.dynamicLayerInfos;
                            var renderer;
                            var dynamicLayerInfo = dynamicLayerInfoList[0]; // get the cities layer
                            if (!dynamicLayerInfo.drawingInfo)
                                dynamicLayerInfo.drawingInfo = drawingInfoCities;
                            renderer = ArcGISRuntime.createObject("SimpleRenderer");
                            renderer.symbol = citiesSymbol;
                            dynamicLayerInfo.drawingInfo.renderer = renderer;
                            dynamicLayer.refresh();
                        }
                    }
                }

            Button {
                text: "Reset"
                anchors.horizontalCenter:action.horizontalCenter

                    onClicked: {
                        if (highwayCheckBox.checked) {
                            dynamicLayer.dynamicLayerInfos[1].resetToDefault();
                            dynamicLayer.refresh();
                        }

                        if (statesCheckBox.checked) {
                            dynamicLayer.dynamicLayerInfos[2].resetToDefault();
                            dynamicLayer.refresh();
                        }

                        if (citiesCheckBox.checked) {
                            dynamicLayer.dynamicLayerInfos[0].resetToDefault();
                            dynamicLayer.refresh();
                        }
                    }
                }
            }
        }

    Envelope {
        id: usExtent
        xMax: -15000000
        yMax: 2000000
        xMin: -7000000
        yMin: 8000000
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }

    function randInRange(range) {
        return Math.floor(Math.random() * (range + 1));
    }

    function randColor() {
        return Qt.rgba(Math.random(), Math.random(), Math.random(), 150);
    }

    function randSimpleLineSymbolStyle() {
        var rand = randInRange(5);
        switch (rand) {
        case 0:
            return Enums.SimpleMarkerSymbolStyleCircle;
        case 1:
            return Enums.SimpleMarkerSymbolStyleCross;
        case 2:
            return Enums.SimpleMarkerSymbolStyleDiamond;
        case 3:
            return Enums.SimpleMarkerSymbolStyleSquare;
        case 4:
            return Enums.SimpleMarkerSymbolStyleTriangle;
        case 5:
            return Enums.SimpleMarkerSymbolStyleX;
        }
    }

    function randMarkerSymbolStyle() {
        var rand = randInRange(5);
        switch (rand) {
        case 0:
            return Enums.SimpleLineSymbolStyleDash;
        case 1:
            return Enums.SimpleLineSymbolStyleDashDot;
        case 2:
            return Enums.SimpleLineSymbolStyleDashDotDot;
        case 3:
            return Enums.SimpleLineSymbolStyleDot;
        case 4:
            return Enums.SimpleLineSymbolStyleNull;
        case 5:
            return Enums.SimpleLineSymbolStyleSolid;
        }
    }

    function randSimpleFillSymbolStyle() {
        var rand = randInRange(7);
        switch (rand) {
        case 0:
            return Enums.SimpleFillSymbolStyleBackwardDiagonal;
        case 1:
            return Enums.SimpleFillSymbolStyleCross;
        case 2:
            return Enums.SimpleFillSymbolStyleDiagonalCross;
        case 3:
            return Enums.SimpleFillSymbolStyleForwardDiagonal;
        case 4:
            return Enums.SimpleFillSymbolStyleHorizontal;
        case 5:
            return Enums.SimpleFillSymbolStyleNull;
        case 6:
            return Enums.SimpleFillSymbolStyleSolid;
        case 7:
            return Enums.SimpleFillSymbolStyleVertical;
        }
    }

    function randomizeCities() {
        citiesSymbol.size    = randInRange(10);
        citiesSymbol.color   = randColor();
        citiesSymbol.style   = randMarkerSymbolStyle();
    }

    function randomizeHighways() {
        highwaysSymbol.width = randInRange(7);
        highwaysSymbol.color = randColor();
        highwaysSymbol.style = randSimpleLineSymbolStyle();
    }

    function randomizeStates() {
        outlineSymbol.width  = randInRange(5);
        statesSymbol.color   = randColor();
        outlineSymbol.color  = randColor();
        statesSymbol.style   = randSimpleFillSymbolStyle();
        outlineSymbol.style  = randSimpleLineSymbolStyle();
    }

    function updateVisibility(layerIndex, visible) {
        dynamicLayer.subLayerById(layerIndex).visible = visible;
        dynamicLayer.refresh();
    }
}

