import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

Item {
    property real scaleFactor: AppFramework.displayScaleFactor

    // Map view UI presentation at top
    MapView {
        id: mapView
        anchors.fill: parent
        wrapAroundMode: Enums.WrapAroundModeDisabled

        Map {
            BasemapTopographic {}
            initialViewpoint: viewPoint

            FeatureLayer {
                id: featureLayer

                ServiceFeatureTable {
                    id: featureTable
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/SF311/FeatureServer/0"
                    featureRequestMode: Enums.FeatureRequestModeManualCache

                    onPopulateFromServiceStatusChanged: {
                        if (populateFromServiceStatus === Enums.TaskStatusCompleted) {
                            if (!populateFromServiceResult.iterator.hasNext) {
                                return;
                            }

                            var count = populateFromServiceResult.iterator.features.length;
                            console.log("Retrieved %1 features".arg(count));
                        }
                    }
                }
            }
        }

        ViewpointCenter {
            id: viewPoint
            center: Point {
                x: -13630484
                y: 4545415
                spatialReference: SpatialReference {
                    wkid: 102100
                }
            }
            targetScale: 300000
        }

        //Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
        }
    }

    QueryParameters {
        id: params
        whereClause: "req_Type = \'Tree Maintenance or Damage\'"
    }

    Row {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 5 * scaleFactor
            bottomMargin: 25 * scaleFactor
        }
        spacing: 5

        // button to populate from service
        Button {
            text: "Populate"
            enabled: featureTable.loadStatus === Enums.LoadStatusLoaded
            onClicked: {
                featureTable.populateFromService(params, true, ["*"]);
            }
        }
    }
}
