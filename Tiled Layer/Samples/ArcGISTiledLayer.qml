import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2


Item {
    //! [Create MapView that contains a Map with the Imagery with Labels Basemap]
    MapView {
        id:mapView
        anchors.fill: parent
        // Nest the Map as a child of the MapView
        Map {
            // Nest the Basemap to add it as the Map's Basemap
            Basemap {
                // Nest the ArcGISTiledLayer to add it as one of the Basemap's baseLayers
                ArcGISTiledLayer {
                    url: "http://services.arcgisonline.com/arcgis/rest/services/NatGeo_World_Map/MapServer"
                }
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
    //! [Create MapView that contains a Map with the Imagery with Labels Basemap]
}
