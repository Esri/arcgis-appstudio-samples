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
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

//------------------------------------------------------------------------------

App {
    id: app
    width: 640
    height: 480

    property color penColor: colorDialog.color;
    property int penWidth;

    Rectangle {
        id: titleRect

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: titleText.paintedHeight + titleText.anchors.margins * 2
        color: app.info.propertyValue("titleBackgroundColor", "darkblue")



        Text {
            id: titleText

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 2 * AppFramework.displayScaleFactor
            }

            text: app.info.title
            color: app.info.propertyValue("titleTextColor", "white")
            font {
                pointSize: 22
            }
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        ExclusiveGroup {
            id: radioButtons
        }
        Column {
            spacing: 5
            anchors {
                right: capture.left
                margins: 10
                top: parent.top
            }

            RadioButton {
                id: draw
                exclusiveGroup: radioButtons
                text: "Draw"

            }
            RadioButton {
                id: navigate
                exclusiveGroup: radioButtons
                text: "Navigate"
                checked: true
            }
        }
        Button {
            id: capture
            text:"Capture"

            anchors {
                margins: 10
                right: parent.right
                top: parent.top
            }

            onClicked: {

                AppFramework.grabWindowToFile("map1.png", Qt.rect(0,50,map.width,(map.height - 50)));

            }
        }
    }


    Map {
        id: map

        anchors {
            left: parent.left
            right: parent.right
            top: titleRect.bottom
            bottom: parent.bottom
        }

        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        zoomByPinchingEnabled: true

        positionDisplay {
            positionSource: PositionSource {
            }
        }

        ArcGISTiledMapServiceLayer {
            url: app.info.propertyValue("basemapServiceUrl", "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        }
        ZoomButtons {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 10
            }

        }

        GraphicsLayer {
            id: graphicsLayer

            Graphic {
                id: blueLine
                symbol: SimpleLineSymbol {
                    color: penColor
                    width: penWidth
                }
            }

            Graphic {
                id: redLines
                symbol: SimpleLineSymbol {
                    color: penColor
                    width: penWidth
                }
            }
        }

        onMousePressed: pathArray = [];

        onMousePositionChanged:{

            if (draw.checked === true) {

                mouse.accepted = true;
                console.log(mouse.mapX, mouse.y)
                pathArray.push([mouse.mapX, mouse.mapY]);
                line.json = { "spatialReference":{"latestWkid": 3857,"wkid":102100}, "paths" : [pathArray] };

                blueLine.geometry = line }

        }

        onMouseReleased: {

            if (draw.checked === true){
                masterArray.push(pathArray)
                line.json = { "spatialReference":{"latestWkid": 3857,"wkid":102100}, "paths" : masterArray };
                redLines.geometry = line;}
        }
    }


    Polyline {
        id: line
    }

    Row {
        id: drawTools
        visible: draw.checked
        spacing: 20
        anchors {
            top: parent.top
            left: parent.left
            topMargin: 5
            leftMargin: 5
        }
        Rectangle {
            id: colorRect
            width: 40
            height: 40
            radius: 25
            color: colorDialog.color
            anchors.verticalCenter: titleRect.verticalCenter
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    colorDialog.open();
                }
            }
        }
        Column {
            spacing: 5


            Label {
                id:sliderLabel
                text: "Line Width: " + drawWidth.value
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Slider {
                id: drawWidth
                width: 100
                maximumValue: 10
                value: 1
                stepSize: 1
                updateValueWhileDragging: true
                orientation: Qt.Horizontal

                onValueChanged: {
                    penWidth = drawWidth.value;
                }
            }
        }
    }
    ColorDialog {
        id: colorDialog
        title: "Please choose a color:"
        onAccepted: {
            colorDialog.color = color;
            colorDialog.close();
        }
        onRejected: {
            colorDialog.close();
        }
    }
    property var pathArray: []
    property var masterArray: []
}

//------------------------------------------------------------------------------
