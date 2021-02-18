import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

Item {

    property real scaleFactor: AppFramework.displayScaleFactor

    // Create MapView that contains a Map
    MapView {
        id:mapView
        anchors.fill: parent
        Map {
            id: map
            // Set the initial basemap to Topographic
            BasemapTopographic {}
            initialViewpoint: ViewpointCenter {
                center: Point {
                    x: -11e6
                    y: 6e6
                    spatialReference: SpatialReference {wkid: 102100}
                }
                targetScale: 9e7
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

    ComboBox {
        id: comboBoxBasemap
        anchors {
            left: parent.left
            top: parent.top
            margins: 15 * scaleFactor
        }
        width: 140 * scaleFactor
        height: 30 * scaleFactor
        Material.accent:"#8f499c"
        background: Rectangle {
            radius: 6 * scaleFactor
            border.color: "darkgrey"
            width: 140 * scaleFactor
            height: 30 * scaleFactor
        }

        model: ["Topographic","Streets","Imagery","Oceans"]
        onCurrentTextChanged: {
            // Call this JavaScript function when the current selection changes
            if (map.loadStatus === Enums.LoadStatusLoaded)
                changeBasemap();
        }

        function changeBasemap() {
            // Determine the selected basemap, create that type, and set the Map's basemap
            switch (comboBoxBasemap.currentText) {
            case "Topographic":
                map.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                break;
            case "Streets":
                map.basemap = ArcGISRuntimeEnvironment.createObject("BasemapStreets");
                break;
            case "Imagery":
                map.basemap = ArcGISRuntimeEnvironment.createObject("BasemapImagery");
                break;
            case "Oceans":
                map.basemap = ArcGISRuntimeEnvironment.createObject("BasemapOceans");
                break;
            default:
                map.basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");
                break;
            }
        }
    }
}
