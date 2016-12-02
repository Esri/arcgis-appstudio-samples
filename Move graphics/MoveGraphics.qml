//------------------------------------------------------------------------------
// MoveGraphics.qml
// Created 2015-03-13 14:55:29
//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
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


    property bool graphicSelected: false
    property int graphicID
    property double scaleFactor: AppFramework.displayScaleFactor

    Map {
        id: mainMap
        anchors.fill: parent
        wrapAroundEnabled: true
        focus: true
        extent: initialExtent

        // Create the initial graphics through JSON
        onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                var graphic1 = {
                    geometry: {
                        spatialReference: {latestWkid: 3857,wkid:102100},
                        x: 16130193.189065285,
                        y: -3807126.3427607343
                    },
                    symbol: {
                        type: "esriSMS",
                        size: 20,
                        style: "esriSMSX",
                        color: "blue"
                    }
                };
                var graphic2 = {
                    geometry: {
                        spatialReference: {latestWkid: 3857,wkid:102100},
                        x: -12723816.98764777,
                        y: -1807126.3427607343
                    },
                    symbol: {
                        type: "esriSMS",
                        size: 20,
                        style: "esriSMSCircle",
                        color: "green"
                    }
                };
                var graphic3 = {
                    geometry: {
                        spatialReference: {latestWkid: 3857,wkid:102100},
                        rings: [[[15075826.477499999,3583669.3955999985],
                                 [10445608.883699998,3158445.3308999985],
                                 [13171197.9637,5114476.0285999998],
                                 [10609800.9969,10387254.431299999],
                                 [12645783.201299999,11833016.251400001],
                                 [10642639.419599999,13193733.258599997],
                                 [14353381.179099999,13278778.071500003],
                                 [12645783.201299999,9536806.3018999994],
                                 [15075826.477499999,3583669.3955999985]]]
                    },
                    symbol: {
                        type: "esriSFS",
                        color: "orange",
                        outline: {
                            type: "esriSLS",
                            color: "black",
                            width: 1
                        }
                    }
                };
                var graphic4 = {
                    geometry: {
                        spatialReference: {latestWkid: 3857,wkid:102100},
                        paths: [[[-3958633.2553000003,8739271.0376000032],
                                 [1527893.5370999984,4641738.3698000014],
                                 [-4583680.6114000008,-1192036.9538000003],
                                 [1319544.4184000008,-5845167.2714999989]]]
                    },
                    symbol: {
                        type: "esriSLS",
                        color: "purple",
                        width: 5
                    }
                };
                graphicsLayer.addGraphic(graphic1);
                graphicsLayer.addGraphic(graphic2);
                graphicsLayer.addGraphic(graphic3);
                graphicsLayer.addGraphic(graphic4);
            }
        }

        onMouseClicked: {
            if (graphicSelected) {
                graphicsLayer.graphic(graphicID).moveTo(mouse.mapPoint);
                graphicsLayer.unselectGraphic(graphicID);
                graphicSelected = false;
            } else {
                var tolerance = Qt.platform.os === "ios" || Qt.platform.os === "android" ? 4 : 1;
                graphicsLayer.findGraphic(mouse.x, mouse.y, tolerance * scaleFactor);
            }
        }

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer"
        }

        GraphicsLayer {
            id: graphicsLayer
            renderingMode: Enums.RenderingModeStatic

            onFindGraphicsComplete: {
                for (var i = 0; i < graphicIDs.length; i++) {
                    var graphicId = graphicIDs[i];
                    graphicID = graphicIDs[i];
                    if (!isGraphicSelected(graphicId)) {
                        selectGraphic(graphicId);
                        graphicSelected = true;
                    } else {
                        unselectGraphic(graphicId);
                        graphicSelected = false;
                    }
                }
            }
        }
    }

    Rectangle {
        id: backgroundRectangle
        color: "lightgrey"
        radius: 5
        border.color: "black"
        opacity: 0.77
        anchors {
            fill: backgroundColumn
            margins: -10 * scaleFactor
        }
    }

    Column {
        id: backgroundColumn
        width: 150 * scaleFactor
        anchors {
            top: parent.top
            left: parent.left
            margins: 20 * scaleFactor
        }
        spacing: 7 * scaleFactor

        Text {
            id: descriptionText
            text: qsTr("Click on a graphic to select it. Then, click on another location on the map to move the graphic to the new location.")
            font.pixelSize: 14 * scaleFactor
            width: 150 * scaleFactor
            wrapMode: Text.WordWrap
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

    Envelope {
               id: initialExtent
               xMax: -17294000
               yMax: -3408000
               xMin: 17928000
               yMin: 10799000

           }
}

