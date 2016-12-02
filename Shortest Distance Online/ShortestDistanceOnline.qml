//------------------------------------------------------------------------------
// ShortestDistanceOnline.qml
// Created 2015-03-13 14:02:40
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
       property int lineGraphicId
       property bool firstPoint: true

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
               drawPoint(mouse.mapPoint);
               addGeometry(mouse.mapPoint);
           }
       }

       LinearUnit {
           id: linearUnitMile
           wkid: Enums.LinearUnitCodeMileUS
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
           width: distanceRow.width
           spacing: 10 * scaleFactor
            Text {
                id: titleText
                width: resultsColumn.width
                wrapMode: Text.WordWrap
                text: "Left click to start drawing a polyline. To finish the polyline, check the check box. The next left mouse click draws a point. The shortest distance to the polyline is caclulated from this point, and the actual distance is displayed."
            }

           CheckBox {
               id: checkBoxCalcShortestDistance
               text: qsTr("Compute Shortest Distance")
               checked: false
               enabled: false
               style: CheckBoxStyle {
                   label: Text {
                       text: control.text
                       color:"black"
                   }
               }
               onCheckedChanged: {
                   if (checkBoxCalcShortestDistance.checked)
                       checkBoxCalcShortestDistance.enabled = false;
               }
           }

           Row {
               id: distanceRow
               spacing: 10 * scaleFactor

               TextField {
                   id: textFieldShortestDistance
                   placeholderText: "Shortest Distance: "
                   readOnly: true
                   height: clearButton.height
                   style: TextFieldStyle {
                       textColor: "black"
                   }
               }

               Button {
                   id: clearButton
                   text: "Clear"
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
                       graphicsLayer.removeAllGraphics();
                       if (polylineDrawPath.pathCount > 0)
                           polylineDrawPath.removePath(0);

                       firstPoint = true;
                       checkBoxCalcShortestDistance.checked = false;
                       checkBoxCalcShortestDistance.enabled = false;
                       textFieldShortestDistance.text = "";
                   }
               }
           }
       }

       SimpleMarkerSymbol {
           id: simpleMarkerSymbolRedPoint
           color: "red"
           style: Enums.SimpleMarkerSymbolStyleCircle
           size: 10
       }

       Envelope {
           id: envelopeInitalExtent
           xMin: -13106489.7271076
           yMin: 3830046.09815437
           xMax: -12963614.441357
           yMax: 3904499.99706217
           spatialReference: mainMap.spatialReference
       }

       Graphic {
           id: graphicRedPoint
           symbol: simpleMarkerSymbolRedPoint
       }

       Polyline {
           id: polylineDrawPath
           spatialReference: mainMap.spatialReference
       }

       Polyline {
           id: polylineShortestPath
           spatialReference: mainMap.spatialReference
       }

       Graphic {
           id: graphicLine
           symbol: SimpleLineSymbol {
               id: lineSymbol
               color: "red"
               style: Enums.SimpleLineSymbolStyleSolid
               width: 2
           }
       }

       Graphic {
           id: graphicResult
           symbol: SimpleLineSymbol {
               color: "blue"
               style: Enums.SimpleLineSymbolStyleSolid
               width: 2
           }
       }

       function drawLine() {
           var lineGraphicClone = graphicLine.clone();
           lineGraphicClone.geometry = polylineDrawPath;
           checkBoxCalcShortestDistance.enabled = true;
           graphicsLayer.updateGraphic(lineGraphicId,lineGraphicClone);
       }

       function drawPoint(mapPoint) {
           var newPoint = graphicRedPoint.clone();
           newPoint.geometry = mapPoint;
           graphicsLayer.addGraphic(newPoint);
       }

       function addGeometry(mapPoint) {
           if (!checkBoxCalcShortestDistance.checked) {
               if (firstPoint) {
                   firstPoint = false;
                   polylineDrawPath.startPath(mapPoint.x, mapPoint.y);
                   var lineGraphicClone = graphicLine.clone();
                   lineGraphicClone.geometry = polylineDrawPath;
                   lineGraphicId = graphicsLayer.addGraphic(lineGraphicClone);
               } else {
                   checkBoxCalcShortestDistance.enabled = true;
                   polylineDrawPath.lineTo(mapPoint.x, mapPoint.y);
                   drawLine();
               }
           } else {
               var result = polylineDrawPath.nearestCoordinate(mapPoint, false);

               if (polylineShortestPath.pathCount > 0)
                   polylineShortestPath.removePath(0);

               polylineShortestPath.startPath(mapPoint.x, mapPoint.y);
               drawPoint(mapPoint);

               polylineShortestPath.lineTo(result.coordinate.x, result.coordinate.y);
               drawPoint(result.coordinate);
               var shortestPathClone = graphicResult.clone();
               shortestPathClone.geometry = polylineShortestPath;
               graphicsLayer.addGraphic(shortestPathClone);
               textFieldShortestDistance.text = linearUnitMile.convertFromMeters(result.distance).toFixed(3) + " miles";
               textFieldShortestDistance.cursorPosition = 0;
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

