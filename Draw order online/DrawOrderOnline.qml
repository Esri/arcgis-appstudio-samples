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
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0
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
    property string currentSelection: "Red Circle"
    property int selectedIndex: 0
    property string platform: Qt.platform.os

    Rectangle {
        id: info
        anchors {
            left: parent.left
            right: graphicTable.left
            top: parent.top
            margins: 10 * scaleFactor
        }

        width: 160 * scaleFactor
        height: 140 * scaleFactor
        focus: true
        border.width: 1 * scaleFactor

        Column {
            anchors {
                left: parent.left
                top: parent.top
                margins: 10 * scaleFactor
            }
            spacing: 10 * scaleFactor

            Row {
                id: graphicOperation

                Text {
                    text: "Move :"
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * scaleFactor
                    font.bold: true
                    font.pixelSize: 14 * scaleFactor
                }
            }

            Row {
                id: typeName
                spacing: 5 * scaleFactor
                anchors.top: graphicOperation.bottom
                anchors.topMargin: 20 * scaleFactor

                ComboBox {
                    id: bringSendGraphic
                    width: 125 * scaleFactor
                    height: 30 * scaleFactor
                    model: graphicElements
                    textRole: "name"
                    anchors.centerIn: bringSendGraphic
                    smooth: true
                    style: ComboBoxStyle {
                        textColor: "black"
                    }

                    onCurrentIndexChanged: {
                        currentSelection = model.get(currentIndex).name;
                        selectedIndex = currentIndex;
                        console.log(graphicElements.get(selectedIndex).drawOrder, graphicsLayer.maxDrawOrder)
                    }
                }

                Text {
                    id: toText
                    text: "To :"
                    font.bold: true
                    font.pixelSize: 14 * scaleFactor

                    anchors{
                        top: bringSendGraphic.bottom
                        topMargin: 10 * scaleFactor
                        left: parent.left
                        leftMargin: 15
                    }
                }

                Button {
                    id: frontButton
                    width: 60 * scaleFactor
                    height: 30 * scaleFactor

                    Text{
                        text: "Front"
                        anchors.centerIn: frontButton
                    }

                    enabled: graphicElements.get(selectedIndex).drawOrder === graphicsLayer.maxDrawOrder ? false : true

                    anchors {
                        top: toText.bottom
                        topMargin: 5 * scaleFactor
                    }

                    MouseArea{
                        anchors.fill: frontButton
                        hoverEnabled: true

                        onClicked: {
                            var graphic = {
                                "Red Circle" : redCircle,
                                "Black Circle" : blackCircle,
                                "Blue Line" : blueLine,
                                "Green Square" : greenSquare
                            }[currentSelection];
                            graphicElements.setProperty(selectedIndex, "drawOrder", graphicsLayer.maxDrawOrder + 1);
                        }
                    }
                }

                Button {
                    id: back
                    width: 60 * scaleFactor
                    height: 30 * scaleFactor

                    Text{
                        text: "Back"
                        anchors.centerIn: back
                    }

                    enabled: graphicElements.get(selectedIndex).drawOrder === graphicsLayer.minDrawOrder ? false : true
                    anchors {
                        top: toText.bottom
                        topMargin: 5 * scaleFactor
                        left: frontButton.right
                        leftMargin: 5 * scaleFactor
                    }

                    MouseArea{
                        anchors.fill: back
                        hoverEnabled: true

                        onClicked: {
                            var graphic = {
                                "Red Circle" : redCircle,
                                "Black Circle" : blackCircle,
                                "Blue Line" : blueLine,
                                "Green Square" : greenSquare
                            }[currentSelection];
                            graphicElements.setProperty(selectedIndex, "drawOrder", graphicsLayer.minDrawOrder - 1);
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: graphicTable
        anchors {
            left: info.right
            right: parent.right
            top: parent.top
            margins: 10 * scaleFactor
        }
        height: 140 * scaleFactor
        width: Screen.width / 2
        border.width: 1 * scaleFactor
        clip: true
        visible: {
            if (platform == "ios" || "android") {
                if (Screen.width < Screen.height)
                    visible: false
                else
                    visible: true
            } else
                visible: true
        }
        Text {
            id: graphicTableLabel
            anchors {
                left: graphicTable.left
                top: graphicTable.top
                margins: 10 * scaleFactor
            }
            text: "Choose from table:"
            font.pixelSize: 14 * scaleFactor
            font.bold: true
        }

        ListModel {
            id: graphicElements

            ListElement {
                name: "Red Circle"
                drawOrder: 2
            }

            ListElement {
                name: "Black Circle"
                drawOrder: 0
            }

            ListElement {
                name: "Blue Line"
                drawOrder: 3
            }

            ListElement {
                name: "Green Square"
                drawOrder: 1
            }
        }

        Component {
            id: editDelegate

            TextInput {
                id: editText
                text: styleData.value
                anchors {
                    right: parent.right
                    left: parent.left
                    leftMargin: 25 * scaleFactor
                }

                onTextChanged: {
                    graphicElements.setProperty(styleData.row, styleData.role, editText.text*1);
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    onClicked: {
                        editText.forceActiveFocus();
                    }
                }
            }
        }

        TableView {
            id:tableView

            anchors {
                top: graphicTableLabel.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 5 * scaleFactor
                horizontalCenter: parent.horizontalCenter
            }
            style: TableViewStyle {
                textColor: "black"
            }

            TableViewColumn {
                role: "name"
                title: "Name"
                width: graphicTable.width * 0.5
            }

            TableViewColumn {
                role: "drawOrder"
                title: "Order"
                width: graphicTable.width * 0.45
                delegate: editDelegate
            }
            model: graphicElements

        }
    }

    Map {
        id: main_map
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: info.bottom
            margins: 10 * scaleFactor
        }
        extent: mapExtent

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/USA_Topo_Maps/MapServer"
        }

        GraphicsLayer {
            id: graphicsLayer

            Graphic {
                id: redCircle
                drawOrder: graphicElements.get(0).drawOrder
                geometry: Point {
                    json: { "spatialReference":{"latestWkid": 3857,"wkid":102100},"x": 9000000, "y": 6000000 }
                }
                symbol: SimpleMarkerSymbol {
                    style: Enums.SimpleMarkerSymbolStyleCircle
                    color: "red"
                    size: 24
                }
            }

            Graphic {
                id: blackCircle
                drawOrder: graphicElements.get(1).drawOrder
                geometry: Point {
                    json: { "spatialReference":{"latestWkid": 3857,"wkid":102100}, "x": 7000000, "y": 6000000 }
                }
                symbol: SimpleMarkerSymbol {
                    style: Enums.SimpleMarkerSymbolStyleCircle
                    color: "black"
                    size: 18
                }
            }

            Graphic {
                id: blueLine
                drawOrder: graphicElements.get(2).drawOrder
                geometry: Polyline {
                    json: { "spatialReference":{"latestWkid": 3857,"wkid":102100}, "paths" : [[ [5000000,6000000], [12000000,6000000] ]] }
                }
                symbol: SimpleLineSymbol {
                    color: "blue"
                    width: 4
                }
            }

            Graphic {
                id: greenSquare
                drawOrder: graphicElements.get(3).drawOrder
                geometry: Polygon {
                    json: { "spatialReference":{"latestWkid": 3857,"wkid":102100}, "rings" : [[ [6000000,8000000], [10000000,8000000], [10000000,4000000], [6000000,4000000] ]] }
                }
                symbol: SimpleFillSymbol {
                    color: "#a000ff00"
                    outline:  SimpleLineSymbol {
                        color: "green"

                    }
                }
            }
        }
    }

    Envelope {
        id: mapExtent
        xMin: -901687
        yMin: 179071
        xMax: 19135181
        yMax: 12442024
        spatialReference: main_map.spatialReference
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

