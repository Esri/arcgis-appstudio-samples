import QtQuick 2.7
import QtQuick.Controls 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10


Item {
    //! [Create MapView that contains a Map with the Imagery with Labels Basemap]

    // Create MapView that contains a Map
    MapView {
        id: mapView
        anchors.fill: parent
        wrapAroundMode: Enums.WrapAroundModeDisabled

        Map {
            // Set the initial basemap to Streets
            BasemapStreets { }

            // set initial viewpoint to The United States
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
                            console.log("successfully added feature");
                        }
                    }

                    // signal handler for the asynchronous addFeature method
                    onAddFeatureStatusChanged: {
                        if (addFeatureStatus === Enums.TaskStatusCompleted) {
                            // apply the edits to the service
                            featureTable.applyEdits();
                        }
                    }
                }
            }
        }


        //! [AddFeaturesFeatureService new feature at mouse click]
        onMouseClicked: {  // mouseClicked came from the MapView
            // create attributes json for the new feature
            var featureAttributes = {"typdamage" : "Minor", "primcause" : "Earthquake"};

            // create a new feature using the mouse's map point
            var feature = featureTable.createFeatureWithAttributes(featureAttributes, mouse.mapPoint);

            // add the new feature to the feature table
            featureTable.addFeature(feature);
        }
        //! [AddFeaturesFeatureService new feature at mouse click]

    }
}

