import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2


Item {

    property real scaleFactor: AppFramework.displayScaleFactor
    // Map view UI presentation at top
    MapView {
        id: mapView
        anchors.fill: parent
        wrapAroundMode: Enums.WrapAroundModeDisabled

        Map {
            id: map

            BasemapTopographic {}
            initialViewpoint: viewPoint

            FeatureLayer {
                id: featureLayer

                // default property (renderer)
                SimpleRenderer {
                    SimpleFillSymbol {
                        style: Enums.SimpleFillSymbolStyleSolid
                        color: Qt.rgba(1, 1, 0, 0.6)

                        // default property (outline)
                        SimpleLineSymbol {
                            style: Enums.SimpleLineSymbolStyleSolid
                            color: "black"
                            width: 2.0 * scaleFactor
                            antiAlias: true
                        }
                    }
                }

                // feature table
                ServiceFeatureTable {
                    id: featureTable
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/USA/MapServer/2"

                    onQueryFeaturesStatusChanged: {
                        if (queryFeaturesStatus === Enums.TaskStatusCompleted) {
                            if (!queryFeaturesResult.iterator.hasNext) {
                                errorMsgDialog.visible = true;
                                return;
                            }

                            // clear any previous selection
                            featureLayer.clearSelection();

                            var features = []
                            // get the features
                            while (queryFeaturesResult.iterator.hasNext) {
                                features.push(queryFeaturesResult.iterator.next());
                            }

                            // select the features
                            // The ideal way to select features is to call featureLayer.selectFeaturesWithQuery(), which will
                            // automatically select the features based on your query.  This is just a way to show you operations
                            // that you can do with query results. Refer to API doc for more details.
                            featureLayer.selectFeatures(features);

                            // zoom to the first feature
                            mapView.setViewpointGeometryAndPadding(features[0].geometry, 30);
                        }
                    }
                }
            }
        }

        // initial viewPoint
        ViewpointCenter {
            id: viewPoint
            center: Point {
                x: -11e6
                y: 5e6
                spatialReference: SpatialReference {
                    wkid: 102100
                }
            }
            targetScale: 9e7
        }

        QueryParameters {
            id: params
        }

        Row {
            id: findRow

            anchors {
                top: parent.top
                bottom: map.top
                left: parent.left
                right: parent.right
                margins: 10 * scaleFactor
            }
            spacing: 5

            TextField {
                id: findText
                width: parent.width * 0.5
                placeholderText: "Enter a state name to select"
                inputMethodHints: Qt.ImhNoPredictiveText
                Material.accent:"#8f499c"
                Material.background: "white"
                Keys.onReturnPressed: {
                    query();
                }
            }


            Button {
                id:buitton
                Material.background:"#8f499c"
                Material.accent:"white"
                highlighted: true
                text: "Find and Select"
                enabled: featureTable.loadStatus === Enums.LoadStatusLoaded
                onClicked: {
                    query();
                }
            }
        }

        // error message dialog
        MessageDialog {
            id: errorMsgDialog
            visible: false
            text: "No state named " + findText.text.toUpperCase() + " exists."
            onAccepted: {
                visible = false;
            }
        }

        // Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
        }
    }

    // function to form and execute the query
    function query() {
        // set the where clause
        params.whereClause = "STATE_NAME LIKE '" + formatStateNameForQuery(findText.text) + "%'";

        // start the query
        featureTable.queryFeatures(params);
    }

    function formatStateNameForQuery(stateName) {
        // format state names as expected by the service, for instance "Rhode Island"
        if (stateName === "")
            return "";

        var formattedWords = [];

        var lowerStateName = stateName.toLowerCase();
        var words = lowerStateName.split(" ");
        words.forEach(function(word) {
            formattedWords.push(word.charAt(0).toUpperCase() + word.slice(1));
        });

        return formattedWords.join(" ");
    }
}
