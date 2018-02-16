import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2
Item {

    MapView {
        id:mapView
        anchors.fill: parent
        wrapAroundMode: Enums.WrapAroundModeDisabled

        Map {
            id: map
            // Specify the SpatialReference
            spatialReference: SpatialReference { wkid:54024 }
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

    Basemap {
        id: basemap
        ArcGISMapImageLayer {
            url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/SampleWorldCities/MapServer"
        }
    }

    Component.onCompleted: {
        map.basemap = basemap;
    }
}
