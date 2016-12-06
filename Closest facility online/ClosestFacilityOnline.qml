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
    property string errorMsg
    property int incidentCount: 0
    property int facilityCount: 0

    Envelope {
        id: initialExtent
        xMax: -117.10
        yMax: 32.74
        xMin: -117.2
        yMin: 32.68
        spatialReference: map.spatialReference
    }

    ClosestFacilityTaskParameters {
        id: taskParameters
    }

    ClosestFacilityTask {
        id: closestFacilityTask
        url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/NetworkAnalysis/SanDiego/NAServer/ClosestFacility"

        onSolveStatusChanged: {
            if (solveStatus === Enums.SolveStatusCompleted) {
                for (var index = 0; index < solveResult.routes.length; index++) {
                    var route = solveResult.routes[index];
                    var graphic = route.route;
                    graphic.symbol = routeSymbol;
                    graphicsLayer.addGraphic(graphic);
                }
            } else if (solveStatus === Enums.SolveStatusErrored) {
                errorMsg = "Solve error: " + solveError.message + "\nPlease reset and start over.";
                messageDialog.visible = true;
            }
        }
    }

    SimpleLineSymbol {
        id: routeSymbol
        width: 3
        color: "blue"
        style: Enums.SimpleLineSymbolStyleDash
    }

    NAFeaturesAsFeature {
        id: facilitiesFeatures
    }

    NAFeaturesAsFeature {
        id: incidentsFeatures
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
        size: 15
        outline: symbolOutline
    }

    SimpleMarkerSymbol {
        id: incidentSymbol
        color: "red"
        style: Enums.SimpleMarkerSymbolStyleCircle
        size: 10
        outline: symbolOutline
    }

    Graphic {
        id: facilityGraphic
        symbol: facilitySymbol
    }

    Graphic {
        id: incidentGraphic
        symbol: incidentSymbol
    }

    Map {
        id: map
        anchors.fill: parent
        focus: true

        ArcGISTiledMapServiceLayer {
            id: basemap
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"
        }

        GraphicsLayer {
            id: graphicsLayer
        }

        onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                extent = initialExtent;
            }
        }

        onMouseClicked: {
            if (addFacilitiesRadioButton.checked) {
                // add facilities
                var graphic1 = facilityGraphic.clone();
                graphic1.geometry = mouse.mapPoint;
                facilitiesFeatures.addFeature(graphic1);

                var graphic2 = facilityGraphic.clone();
                graphic2.geometry = mouse.mapPoint;
                graphicsLayer.addGraphic(graphic2);
                facilityCount++;
            } else {
                // add incidents
                var graphic3 = incidentGraphic.clone();
                graphic3.geometry = mouse.mapPoint;
                incidentsFeatures.addFeature(graphic3);

                var graphic4 = incidentGraphic.clone();
                graphic4.geometry = mouse.mapPoint;
                graphicsLayer.addGraphic(graphic4);
                incidentCount++;
            }
        }
    }

    Rectangle {
        anchors {
            fill: controlColumn
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

    Column {
        id: controlColumn
        anchors {
            top: parent.top
            left: parent.left
            margins: 20 * scaleFactor
        }
        spacing: 10 * scaleFactor

        Row {
            spacing: 10 * scaleFactor

            ExclusiveGroup {
                id: facilityExclusiveGroup
            }

            RadioButton {
                id: addFacilitiesRadioButton
                text: qsTr("Add Facility")
                checked: true
                exclusiveGroup: facilityExclusiveGroup
                style: RadioButtonStyle {
                    label: Text {
                        renderType: Text.NativeRendering
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 14 * scaleFactor
                        color: "black"
                        text: control.text
                    }
                }
            }

            RadioButton {
                id: addIncidentsRadioButton
                text: qsTr("Add Incidents")
                checked: false
                exclusiveGroup: facilityExclusiveGroup
                style: addFacilitiesRadioButton.style
            }
        }

        Row {
            spacing: 10 * scaleFactor

            Button {
                id: solveButton
                text: "Solve"
                enabled: facilityCount > 0 && incidentCount > 0
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
                    taskParameters.incidents = incidentsFeatures;
                    taskParameters.facilities = facilitiesFeatures;
                    taskParameters.defaultCutoff = 30.0;
                    taskParameters.outSpatialReference = map.spatialReference;
                    closestFacilityTask.solve(taskParameters);
                }
            }

            Button {
                text: "Reset"
                style: solveButton.style
                onClicked: {
                    graphicsLayer.removeAllGraphics();
                    incidentsFeatures.setFeatures(0);
                    facilitiesFeatures.setFeatures(0);
                    incidentCount = 0;
                    facilityCount = 0;
                }
            }
        }
    }

    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: map.bottom
            bottomMargin: 5 * scaleFactor
        }

        ProgressBar {
            id: progressBar
            indeterminate: true
            visible: closestFacilityTask.solveStatus === Enums.SolveStatusInProgress
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

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }
}

