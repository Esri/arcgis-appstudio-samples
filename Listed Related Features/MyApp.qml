/* Copyright 2021 Esri
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

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)
    property FeatureLayer alaskaNationalParks: null

    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle {
            anchors.top:header.bottom

            MapView {
                id: mapView
                anchors.fill: parent

                // bind the insets to the attribute view so the attribution text shows when the view expands
                viewInsets.bottom: attributeView.height / scaleFactor

                Map {
                    id: map
                    initUrl: "https://arcgis.com/home/item.html?id=dcc7466a91294c0ab8f7a094430ab437"

                    onLoadStatusChanged: {
                        if (loadStatus !== Enums.LoadStatusLoaded)
                            return;

                        // get the Alaska National Parks feature layer
                        map.operationalLayers.forEach(function(fl) {
                            if (fl.name.indexOf("- Alaska National Parks") !== -1) {
                                alaskaNationalParks = fl;
                                alaskaNationalParks.selectionColor = "yellow";
                                alaskaNationalParks.selectionWidth = 5;
                            }
                        });
                    }
                }

                onMouseClicked: {
                    // hide the attribute view
                    attributeView.height = 0;

                    // clear the list model
                    relatedFeaturesModel.clear();

                    // create objects required to do a selection with a query
                    var clickPoint = mouse.mapPoint;
                    var mapTolerance = 10 * mapView.unitsPerDIP;
                    var envelope = ArcGISRuntimeEnvironment.createObject("Envelope", {
                                                                             xMin: clickPoint.x - mapTolerance,
                                                                             yMin: clickPoint.y - mapTolerance,
                                                                             xMax: clickPoint.x + mapTolerance,
                                                                             yMax: clickPoint.y + mapTolerance,
                                                                             spatialReference: map.spatialReference
                                                                         });
                    var queryParams = ArcGISRuntimeEnvironment.createObject("QueryParameters");
                    queryParams.geometry = envelope;
                    queryParams.spatialRelationship = Enums.SpatialRelationshipIntersects;

                    // clear any selections
                    alaskaNationalParks.clearSelection();

                    // select features
                    alaskaNationalParks.selectFeaturesWithQuery(queryParams, Enums.SelectionModeNew);
                }
            }

            Connections {
                target: alaskaNationalParks

                function onSelectFeaturesStatusChanged() {
                    if (alaskaNationalParks.selectFeaturesStatus === Enums.TaskStatusErrored) {
                        var errorString = "Error: %1".arg(alaskaNationalParks.error.message);
                        msgDialog.text = errorString;
                        msgDialog.open();
                        console.log(errorString);
                    } else if (alaskaNationalParks.selectFeaturesStatus === Enums.TaskStatusCompleted) {
                        var featureQueryResult = alaskaNationalParks.selectFeaturesResult;

                        // iterate over features returned
                        while (featureQueryResult.iterator.hasNext) {
                            var arcGISFeature = featureQueryResult.iterator.next();
                            var selectedTable = arcGISFeature.featureTable;

                            // connect signal
                            selectedTable.queryRelatedFeaturesStatusChanged.connect(function() {
                                if (selectedTable.queryRelatedFeaturesStatus !== Enums.TaskStatusCompleted)
                                    return;

                                var relatedFeatureQueryResultList = selectedTable.queryRelatedFeaturesResults;

                                // iterate over returned RelatedFeatureQueryResults
                                for (var i = 0; i < relatedFeatureQueryResultList.length; i++) {

                                    // iterate over Features returned
                                    var iter = relatedFeatureQueryResultList[i].iterator;
                                    while (iter.hasNext) {
                                        var feat = iter.next();
                                        var displayFieldName = feat.featureTable.layerInfo.displayFieldName;
                                        var serviceLayerName = feat.featureTable.layerInfo.serviceLayerName;
                                        var displayFieldValue = feat.attributes.attributeValue(displayFieldName);

                                        // add the related feature info to a list model
                                        var listElement = {
                                            "displayFieldName" : displayFieldName,
                                            "displayFieldValue" : displayFieldValue,
                                            "serviceLayerName" : serviceLayerName
                                        };
                                        relatedFeaturesModel.append(listElement);
                                    }
                                }

                                // show the attribute view
                                attributeView.height = 200 * scaleFactor
                            });

                            // zoom to the feature
                            mapView.setViewpointGeometryAndPadding(arcGISFeature.geometry, 100)

                            // query related features
                            selectedTable.queryRelatedFeatures(arcGISFeature);
                        }
                    }
                }
            }

            Rectangle {
                id: attributeView
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 0

                // Animate the expand and collapse of the legend
                Behavior on height {
                    SpringAnimation {
                        spring: 3
                        damping: 0.4
                    }
                }

                ListView {
                    anchors {
                        fill: parent
                        margins: 5 * scaleFactor
                    }

                    clip: true
                    model: relatedFeaturesModel
                    spacing: 5 * scaleFactor

                    // Create delegate to display the attributes
                    delegate: Rectangle {
                        width: app.width
                        height: 15 * scaleFactor
                        color: "transparent"

                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.margins: 10  * scaleFactor
                            text: displayFieldValue
                            font.pixelSize: 12 * scaleFactor
                        }
                    }

                    // Create a section to separate features by table
                    section {
                        property: "serviceLayerName"
                        criteria: ViewSection.FullString
                        labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels
                        delegate: Rectangle {
                            width: app.width
                            height: 20 * scaleFactor
                            color: "#8f499c"

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: section
                                font {
                                    bold: true
                                    pixelSize: 13 * scaleFactor
                                }
                                elide: Text.ElideRight
                                clip: true
                                color: "white"
                            }
                        }
                    }
                }
            }

            ListModel {
                id: relatedFeaturesModel
            }

            MessageDialog {
                id: msgDialog
            }

            //Busy Indicator
            BusyIndicator {
                id:mapDrawingWindow
                anchors.centerIn: parent
                height: 48 * scaleFactor
                width: height
                running: true
                Material.accent:"#8f499c"
                visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
            }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

