import QtQuick 2.7
import QtQuick.Controls 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

Item {
    id:setInitialMapArea

    property double mousePointX
    property double mousePointY
    property string damageType

    // Create MapView that contains a Map with the Imagery Basemap
    // Create MapView that contains a Map
    MapView {
        id: mapView
        anchors.fill: parent
        wrapAroundMode: Enums.WrapAroundModeDisabled

        Map {
            // Set the initial basemap to Streets
            BasemapStreets { }

            // Set the initial viewpoint over The United States
            ViewpointCenter {
                Point {
                    x: -10800000
                    y: 4500000
                    spatialReference: SpatialReference {
                        wkid: 102100
                    }
                }
                targetScale: 3e7
            }

            FeatureLayer {
                id: featureLayer

                selectionColor: "cyan"
                selectionWidth: 3

                // declare as child of feature layer, as featureTable is the default property
                ServiceFeatureTable {
                    id: featureTable
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0"

                    // make sure edits are successfully applied to the service
                    onApplyEditsStatusChanged: {
                        if (applyEditsStatus === Enums.TaskStatusCompleted) {
                            console.log("successfully deleted feature");
                        }
                    }

                    // signal handler for the asynchronous deleteFeature method
                    onDeleteFeatureStatusChanged: {
                        if (deleteFeatureStatus === Enums.TaskStatusCompleted) {
                            // apply the edits to the service
                            featureTable.applyEdits();
                        }
                    }
                }

                // signal handler for asynchronously fetching the selected feature
                onSelectedFeaturesStatusChanged: {
                    if (selectedFeaturesStatus === Enums.TaskStatusCompleted) {
                        while (selectedFeaturesResult.iterator.hasNext) {
                            // obtain the feature
                            var feat = selectedFeaturesResult.iterator.next();

                            // delete the feature in the feature table asynchronously
                            featureTable.deleteFeature(feat);
                        }
                    }
                }

                // signal handler for selecting features
                onSelectFeaturesStatusChanged: {
                    if (selectFeaturesStatus === Enums.TaskStatusCompleted) {
                        if (!selectFeaturesResult.iterator.hasNext)
                            return;

                        var feat  = selectFeaturesResult.iterator.next();
                        damageType = feat.attributes.attributeValue("typdamage");

                        // show the callout
                        callout.x = mousePointX;
                        callout.y = mousePointY;
                        callout.visible = true;
                    }
                }
            }
        }

        QueryParameters {
            id: params
            maxFeatures: 1
        }

        // hide the callout after navigation
        onViewpointChanged: {
            callout.visible = false;
        }

        onMouseClicked: {
            // reset the map callout and update window
            featureLayer.clearSelection();
            callout.visible = false;

            mousePointX = mouse.x;
            mousePointY = mouse.y - callout.height;
            //! [DeleteFeaturesFeatureService identify feature]
            // call identify on the feature layer
            var tolerance = 10;
            var returnPopupsOnly = false;
            mapView.identifyLayer(featureLayer, mouse.x, mouse.y, tolerance, returnPopupsOnly);
            //! [DeleteFeaturesFeatureService identify feature]
        }

        onIdentifyLayerStatusChanged: {
            if (identifyLayerStatus === Enums.TaskStatusCompleted) {
                if (identifyLayerResult.geoElements.length > 0) {
                    // get the objectid of the identifed object
                    params.objectIds = [identifyLayerResult.geoElements[0].attributes.attributeValue("objectid")];
                    // query for the feature using the objectid
                    featureLayer.selectFeaturesWithQuery(params, Enums.SelectionModeNew);
                }
            }
        }
    }

    // map callout window
    Rectangle {
        id: callout
        width: row.width + (10 * scaleFactor) // add 10 for padding
        height: 40 * scaleFactor
        radius: 5
        border {
            color: "lightgrey"
            width: .5
        }
        visible: false

        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true
        }

        Row {
            id: row
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                margins: 5 * scaleFactor
            }
            spacing: 10

            Text {
                text: damageType
                font.pixelSize: 18 * scaleFactor
            }

            Rectangle {
                radius: 100
                width: 22 * scaleFactor
                height: width
                color: "transparent"
                antialiasing: true
                border {
                    width: 2
                    color: "red"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: -4 * scaleFactor

                    text: "-"
                    font {
                        bold: true
                        pixelSize: 22 * scaleFactor
                    }
                    color: "red"
                }

                // create a mouse area over the (-) text to delete the feature
                MouseArea {
                    anchors.fill: parent
                    // once the delete button is clicked, hide the window and fetch the currently selected features
                    onClicked: {
                        callout.visible = false;
                        featureLayer.selectedFeatures();
                    }
                }
            }
        }
    }
}
