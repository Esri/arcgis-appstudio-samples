import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1

Item {

    property real scaleFactor: AppFramework.displayScaleFactor

    // Map view UI presentation at top
    MapView {
        id: mv
        anchors.fill: parent

        //! [Display Feature Service]
        Map {
            BasemapTerrainWithLabels {}
            initialViewpoint: vc

            FeatureLayer {
                ServiceFeatureTable {
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Energy/Geology/FeatureServer/9"
                }
            }
        }
        //! [Display Feature Service]

        ViewpointCenter {
            id: vc
            center: Point {
                x: -13176752
                y: 4090404
                spatialReference: SpatialReference {
                    wkid: 102100
                }
            }
            targetScale: 300000
        }

        // Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (mv.drawStatus === Enums.DrawStatusInProgress)
        }
    }
}
