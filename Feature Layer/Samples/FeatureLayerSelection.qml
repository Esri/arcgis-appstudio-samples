import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

Item {
    property real scaleFactor: AppFramework.displayScaleFactor
    property string displayText: "Click or tap to select features."


    // Map view UI presentation at top
    MapView {
        id: mapView
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: messageBar.top
        }
        wrapAroundMode: Enums.WrapAroundModeDisabled

        Map {
            id: map
            BasemapStreets {}

            FeatureLayer {
                id: featureLayer

                selectionColor: "cyan"
                selectionWidth: 3

                // feature table
                ServiceFeatureTable {
                    id: featureTable
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0"
                }
            }

            onLoadStatusChanged: {
                if (loadStatus === Enums.LoadStatusLoaded) {
                    mapView.setViewpoint(viewPoint);
                }
            }
        }

        // initial viewpoint
        ViewpointCenter {
            id: viewPoint
            Point {
                x: -10800000
                y: 4500000
                spatialReference: SpatialReference {
                    wkid: 102100
                }
            }
            targetScale: 3e7
        }

        //! [identify feature layer qml api snippet]
        onMouseClicked: {
            var tolerance = 22;
            var returnPopupsOnly = false;
            var maximumResults = 1000;
            mapView.identifyLayerWithMaxResults(featureLayer, mouse.x, mouse.y, tolerance, returnPopupsOnly, maximumResults);
        }

        onIdentifyLayerStatusChanged: {
            if (identifyLayerStatus === Enums.TaskStatusCompleted) {
                // clear any previous selections
                featureLayer.clearSelection();

                // create an array to store the features
                var identifiedObjects = [];
                for (var i = 0; i < identifyLayerResult.geoElements.length; i++){
                    var elem = identifyLayerResult.geoElements[i];
                    identifiedObjects.push(elem);
                }
                // cache the number of identifyLayerResult
                var count = identifyLayerResult.geoElements.length;

                // select the features in the feature layer
                featureLayer.selectFeatures(identifiedObjects);
                displayText = "%1 %2 selected.".arg(count).arg(count > 1 ? "features" : "feature");
            }
        }
        //! [identify feature layer qml api snippet]

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

    Rectangle {
        id: messageBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 30 * scaleFactor
        color: "lightgrey"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }

        Text {
            id: msgText
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 10 * scaleFactor
            }
            text: displayText
            font.pixelSize: 14 * scaleFactor
        }
    }
}

