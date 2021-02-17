import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

Item {

    property real scaleFactor: AppFramework.displayScaleFactor

    MapView {
        id:mapView
        anchors.fill: parent
        Map {
            BasemapImageryWithLabels {}
            // Set the initialViewpoint property to a ViewpointCenter object
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
    ViewpointCenter {
        id: viewpoint
        // Specify the center Point
        center: Point {
            x: -7122777.61840761
            y: -4011076.1090391986
            spatialReference: SpatialReference { wkid: 102100 }
        }
        // Specify the scale
        targetScale: 15000
    }
}


