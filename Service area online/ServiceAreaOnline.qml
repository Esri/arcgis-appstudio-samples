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
    width: 640
    height: 480

    property string errorMsg
    property double scaleFactor: AppFramework.displayScaleFactor
    property int facilities: 0

    Envelope {
        id: initialExtent
        xMax: -117.10
        yMax: 32.74
        xMin: -117.2
        yMin: 32.68
        spatialReference: map.spatialReference
    }

    ServiceAreaTaskParameters {
        id: taskParameters
    }

    ServiceAreaTask {
        id: serviceAreaTask
        url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/NetworkAnalysis/SanDiego/NAServer/ServiceArea"

        onSolveStatusChanged: {
            if (solveStatus === Enums.SolveStatusCompleted) {
                var polygons = solveResult.serviceAreaPolygons.graphics;
                for (var index = 0; index < polygons.length; index++) {
                    var polygon = polygons[index];
                    polygonFill.color = Qt.rgba(Math.random()%255, Math.random()%255, Math.random()%255, 150);
                    serviceAreaPolygonGraphic.symbol = polygonFill; // re-randomize the color
                    var graphic = serviceAreaPolygonGraphic.clone();
                    graphic.geometry = polygon.geometry;
                    graphicsLayer.addGraphic(graphic);
                }
            } else if (solveStatus === Enums.SolveStatusErrored) {
                errorMsg = "Solve error:" + solveError.message+ "\nPlease reset and start over.";
                messageDialog.visible = true;
            }
        }
    }

    NAFeaturesAsFeature {
        id: facilitiesFeatures
    }

    SimpleFillSymbol {
        id: polygonFill
    }

    Graphic {
        id: serviceAreaPolygonGraphic
    }

    SimpleLineSymbol {
        id: symbolOutline
        color: "black"
        width: 0.5
    }

    SimpleMarkerSymbol {
        id: facilitySymbol
        color: "blue"
        style: Enums.SimpleMarkerSymbolStyleSquare
        size: 16
        outline: symbolOutline
    }

    Graphic {
        id: facilityGraphic
        symbol: facilitySymbol
    }

    Map {
        id: map
        anchors.fill: parent
        focus: true
        extent: initialExtent

        ArcGISTiledMapServiceLayer {
            id: basemap
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"
        }

        GraphicsLayer {
            id: graphicsLayer
        }

        onMouseClicked: {
            facilities++;
            var graphic1 = facilityGraphic.clone();
            graphic1.geometry = mouse.mapPoint;
            facilitiesFeatures.addFeature(graphic1);

            var graphic2 = facilityGraphic.clone();
            graphic2.geometry = mouse.mapPoint;
            graphicsLayer.addGraphic(graphic2);
        }
    }

    Rectangle {
        id: controlsBackground
        anchors {
            fill: menuColumn
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
        id: menuColumn
        anchors {
            left: app.left
            leftMargin: 20 * scaleFactor
            top: app.top
            topMargin: 20 * scaleFactor
        }
        spacing: 10 * scaleFactor

        Button {
            id: solveButton
            text: "Solve"
            enabled: facilities > 0
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
                taskParameters.facilities = facilitiesFeatures;
                taskParameters.defaultBreaks = [1.0, 2.0, 3.0];
                taskParameters.outSpatialReference = map.spatialReference;
                serviceAreaTask.solve(taskParameters);
            }
        }

        Button {
            text: "Reset"
            style: solveButton.style
            onClicked: {
                graphicsLayer.removeAllGraphics();
                facilitiesFeatures.setFeatures(0);
                facilities = 0;
            }
        }
    }

    MessageDialog {
        id: messageDialog
        title: "Error"
        icon: StandardIcon.Warning
        modality: Qt.WindowModal
        standardButtons: StandardButton.Ok
        text: errorMsg
    }

    ProgressBar {
        id: progressBar
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        indeterminate: true
        visible: serviceAreaTask.solveStatus === Enums.SolveStatusInProgress
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

