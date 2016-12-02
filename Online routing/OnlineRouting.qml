//------------------------------------------------------------------------------
// OnlineRouting.qml
// Created 2015-03-20 15:28:17
//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
       property double scaleFactor: AppFramework.displayScaleFactor
       property string errorMsg

       id: app
       height: 600
       width: 800

       Envelope {
           id: initialExtent
           xMax: -117.2
           yMax: 32.68
           xMin: -117.1
           yMin: 32.74
           spatialReference: SpatialReference {
               wkid: 4326
           }
       }

       OnlineRouteTask {
           id: routeTask
           url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/NetworkAnalysis/SanDiego/NAServer/Route"

           onSolveStatusChanged: {
               if (solveStatus === Enums.SolveStatusCompleted) {
                   for (var index = 0; index < solveResult.routes.length; index++) {
                       var route = solveResult.routes[index];
                       var graphic = route.route;
                       graphic.symbol = routeSymbol;
                       routeResultLayer.addGraphic(graphic);
                   }
               } else if (solveStatus === Enums.SolveStatusErrored) {
                   errorMsg = "Route error:" + solveError.message;
                   messageDialog.visible = true;
               }
           }
       }

       OnlineRouteTaskParameters {
           id: taskParameters
           json: {
               "outSpatialReference": {
                   "wkid": map.spatialReference.wkid
               },
               "returnDirections": true,
           }
       }

       NAFeaturesAsFeature {
           id: stops
           compressedRequest: true
           property int stopCount: 0
       }

       NAFeaturesAsFeature {
           id: barriers
           property int barrierCount: 0
       }

       SimpleLineSymbol {
           id: routeSymbol
           width: 3
           color: "#00b2ff"
           style: Enums.SimpleLineSymbolStyleSolid
       }

       PictureMarkerSymbol {
           id: stopSymbol
           image: "RedShinyPin.png"
           xOffset: 0
           yOffset: 10
           opacity: 0.75
           height: 25
           width: 25
       }

       Graphic {
           id: stopGraphic
           symbol: stopSymbol
       }

       SimpleMarkerSymbol {
           id: barrierSymbol
           size: 15
           style: Enums.SimpleMarkerSymbolStyleCross
           color: "black"
       }

       Graphic {
           id: barrierGraphic
           symbol: barrierSymbol
       }

       Map {
           id: map
           anchors.fill: parent
           focus: true

           onStatusChanged: {
               if(map.status === Enums.MapStatusReady) {
                   taskParameters.outSpatialReference = spatialReference;
                   extent = initialExtent;
               }
           }

           ArcGISTiledMapServiceLayer {
               id: basemap
               url: "http://services.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"
           }

           GraphicsLayer {
               id: routeResultLayer
           }

           GraphicsLayer {
               id: graphicsLayer
           }

           onMouseClicked: {
               if (routeTask.solveInProgress)
                   return;

               // add stops
               if (addStopsCheckBox.checked) {
                   var graphic1 = stopGraphic.clone();
                   graphic1.geometry = mouse.mapPoint;
                   stops.addFeature(graphic1);
                   stops.stopCount += 1;

                   var graphic2 = stopGraphic.clone();
                   graphic2.geometry = mouse.mapPoint;
                   graphicsLayer.addGraphic(graphic2);
               }
               // add barriers
               else {
                   var graphic3 = barrierGraphic.clone();
                   graphic3.geometry = mouse.mapPoint;
                   barriers.addFeature(graphic3);
                   barriers.barrierCount += 1;

                   var graphic4 = barrierGraphic.clone();
                   graphic4.geometry = mouse.mapPoint;
                   graphicsLayer.addGraphic(graphic4);
               }
               if (stops.stopCount < 2)
                   return;
               taskParameters.stops = stops;
               if (barriers.barrierCount > 0)
                   taskParameters.pointBarriers = barriers;
               taskParameters.outSpatialReference = map.spatialReference;
               var json = taskParameters.json;
               routeResultLayer.removeAllGraphics();
               routeTask.solve(taskParameters);
           }
       }

       Rectangle {
           id: rectangleControls
           anchors {
               fill: columnControls
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

       Row {
           id: columnControls
           anchors {
               left: app.left
               leftMargin: 20 * scaleFactor
               top: app.top
               topMargin: 20 * scaleFactor
           }
           spacing: 10 * scaleFactor

           RadioButton {
               id: addStopsCheckBox
               height: 25 * scaleFactor
               text: "Add Stops"
               checked: true
               style: RadioButtonStyle {
                   label: Text {
                       text: control.text
                       font.pixelSize: 14 * scaleFactor
                       verticalAlignment: Text.AlignVCenter
                       horizontalAlignment: Text.AlignHCenter
                   }

                   indicator: Rectangle {
                       implicitWidth: 12 * scaleFactor
                       implicitHeight: 12 * scaleFactor
                       radius: 9 * scaleFactor
                       border {
                           color: control.activeFocus ? "darkblue" : "gray"
                           width: 1 * scaleFactor
                       }

                       Rectangle {
                           anchors {
                               fill: parent
                               margins: 4 * scaleFactor
                           }
                           visible: control.checked
                           color: "#555"
                           radius: 9 * scaleFactor
                       }
                   }
               }

               onCheckedChanged: {
                   addBarriersCheckBox.checked = !checked;
               }
           }

           RadioButton {
               id: addBarriersCheckBox
               height: 25 * scaleFactor
               text: "Add Barriers"
               checked: false
               style: RadioButtonStyle {
                   label: Text {
                       text: control.text
                       font.pixelSize: 14 * scaleFactor
                       verticalAlignment: Text.AlignVCenter
                       horizontalAlignment: Text.AlignHCenter
                   }

                   indicator: Rectangle {
                       implicitWidth: 12 * scaleFactor
                       implicitHeight: 12 * scaleFactor
                       radius: 9 * scaleFactor
                       border {
                           color: control.activeFocus ? "darkblue" : "gray"
                           width: 1 * scaleFactor
                       }

                       Rectangle {
                           anchors {
                               fill: parent
                               margins: 4 * scaleFactor
                           }
                           visible: control.checked
                           color: "#555"
                           radius: 9 * scaleFactor
                       }
                   }
               }

               onCheckedChanged: {
                   addStopsCheckBox.checked = !checked;
               }
           }

           Button {
               text: "Reset"
               width: 60 * scaleFactor
               style: ButtonStyle {
                   label: Text {
                       renderType: Text.NativeRendering
                       verticalAlignment: Text.AlignVCenter
                       horizontalAlignment: Text.AlignHCenter
                       font.pixelSize: 14 * scaleFactor
                       color: "black"
                       text: control.text
                   }
               }

               onClicked: {
                   graphicsLayer.removeAllGraphics();
                   routeResultLayer.removeAllGraphics();
                   stops.setFeatures(0);
                   barriers.setFeatures(0);
                   barriers.barrierCount = 0;
                   stops.stopCount = 0;
               }
           }
       }

       ProgressBar {
           id: progressBar
           anchors {
               bottom: parent.bottom
               horizontalCenter: parent.horizontalCenter
           }
           indeterminate: true
           visible: routeTask.solveStatus === Enums.SolveStatusInProgress
       }

       MessageDialog {
           id: messageDialog
           title: "Error"
           icon: StandardIcon.Warning
           modality: Qt.WindowModal
           standardButtons: StandardButton.Ok
           text: errorMsg
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

