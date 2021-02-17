import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

Item {
    id:setInitialMapArea

    // Create MapView that contains a Map with the Imagery Basemap
    MapView {
        id: mapView
        anchors.fill: parent
        Map {
            BasemapImagery {}
            initialViewpoint: viewpoint
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

    // Create the intial Viewpoint
    ViewpointExtent {
        id: viewpoint
        extent: Envelope {
            xMin: -12211308.778729
            yMin: 4645116.003309
            xMax: -12208257.879667
            yMax: 4650542.535773
            spatialReference: SpatialReference { wkid: 102100 }
        }
    }
}
