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
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
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
       property alias graphicColor: colorRectangle.color
       property alias graphicSize: sizeSpinBox.value

       GraphicsLayer {
           id: graphicsLayer
       }

       Map {
           id: map
           anchors.fill: parent
           wrapAroundEnabled: true
           focus: true
           extent: initialExtent

           ArcGISTiledMapServiceLayer {
               url: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer"
           }

           onStatusChanged: {
               if(map.status === Enums.MapStatusReady) {
                   graphicsLayer.renderingMode = Enums.RenderingModeStatic;
                   addLayer(graphicsLayer);
               }
           }

           onMouseClicked: {
               var graphic = {
                   geometry: {
                       spatialReference: {latestWkid: 3857,wkid:102100},
                       x: mouse.mapX,
                       y: mouse.mapY
                   },
                   symbol: {
                       type: "esriSMS",
                       size: graphicSize,
                       style: styles.get(stylesCombo.currentIndex).style,
                       color: graphicColor
                   }
               };
               var id = graphicsLayer.addGraphic(graphic);
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

           ComboBox {
               id: stylesCombo
               width: 100 * scaleFactor
               model: ListModel {
                   id: styles
                   ListElement { name: "Circle"; style: "esriSMSCircle" }
                   ListElement { name: "Cross"; style: "esriSMSCross" }
                   ListElement { name: "X"; style: "esriSMSX" }
                   ListElement { name: "Square"; style: "esriSMSSquare" }
                   ListElement { name: "Diamond"; style: "esriSMSDiamond" }
               }
               textRole: "name"
               style: ComboBoxStyle {
                   textColor: "black"
               }
           }

           Rectangle {
               id: colorRectangle
               anchors.verticalCenter: parent.verticalCenter
               width: 20 * scaleFactor
               height: 20 * scaleFactor
               color: "red"

               MouseArea {
                   anchors.fill: parent
                   onClicked: {
                       colorDialog.color = graphicColor;
                       colorDialog.open();
                   }
               }
           }

           Label {
               text: "Size"
               color: "black"
               anchors.verticalCenter: parent.verticalCenter
           }

           SpinBox {
               id: sizeSpinBox
               minimumValue: 1
               maximumValue: 50
               value: 15
               style: SpinBoxStyle {
                   textColor:"black"
               }
           }
       }

       ColorDialog {
           id: colorDialog
           title: "Graphic color"
           color: graphicColor

           onAccepted: {
               graphicColor = currentColor;
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

       Envelope {
           id: initialExtent
           xMax: -17294000
           yMax: -3408000
           xMin: 17928000
           yMin: 10799000

       }
}

