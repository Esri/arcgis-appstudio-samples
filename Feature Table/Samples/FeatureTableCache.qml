import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1

Item {
    // Create MapView that contains a Map with the Imagery with Labels Basemap
    // Map view UI presentation at top
    MapView {
        id: mapView
        anchors.fill: parent
        wrapAroundMode: Enums.WrapAroundModeDisabled

        Map {
            BasemapLightGrayCanvas {}

            FeatureLayer {
                ServiceFeatureTable {
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/PoolPermits/FeatureServer/0"
                    featureRequestMode: Enums.FeatureRequestModeOnInteractionCache
                }
            }
            onLoadStatusChanged: {
                if (loadStatus === Enums.LoadStatusLoaded) {
                    mapView.setViewpoint(viewPoint);
                }
            }
        }

        ViewpointExtent {
            id: viewPoint
            extent: Envelope {
                xMin: -1.30758164047166E7
                yMin: 4014771.46954516
                xMax: -1.30730056797177E7
                yMax: 4016869.78617381
                spatialReference: SpatialReference {
                    wkid: 102100
                }
            }
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
}
