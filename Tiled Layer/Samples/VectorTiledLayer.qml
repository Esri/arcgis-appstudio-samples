import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.2

Item {

    property real scaleFactor: AppFramework.displayScaleFactor

    // Create MapView that contains a Map
    MapView {
        id: mapView
        anchors.fill: parent
        Map {
            id: map
            Basemap {
                // Nest an ArcGISVectorTiledLayer Layer in the Basemap
                ArcGISVectorTiledLayer {
                    url: "http://www.arcgis.com/home/item.html?id=dcbbba0edf094eaa81af19298b9c6247"
                }
            }
            initialViewpoint: ViewpointCenter {
                center: Point { x:-80.18; y: 25.778135; spatialReference: SpatialReference { wkid: 4326 } }
                targetScale: 150000
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
    //! [display vector tiled layer]

    ComboBox {
        id: comboBoxBasemap
        anchors {
            left: parent.left
            top: parent.top
            margins: 15 * scaleFactor
        }
        width: 140 * scaleFactor
        Material.accent: "#8f499c"
        model: ["Navigation","Streets","Night","Dark Gray"]
        onCurrentTextChanged: {
            // Call this JavaScript function when the current selection changes
            if (map.loadStatus === Enums.LoadStatusLoaded)
                changeBasemap();
        }

        function changeBasemap() {
            // Determine the selected basemap, create that type, and set the Map's basemap
            var layer;
            switch (comboBoxBasemap.currentText) {
            case "Navigation":
            default:
                layer = ArcGISRuntimeEnvironment.createObject("ArcGISVectorTiledLayer", {url:"http://www.arcgis.com/home/item.html?id=dcbbba0edf094eaa81af19298b9c6247"});
                break;
            case "Streets":
                layer = ArcGISRuntimeEnvironment.createObject("ArcGISVectorTiledLayer", {url:"http://www.arcgis.com/home/item.html?id=4e1133c28ac04cca97693cf336cd49ad"});
                break;
            case "Night":
                layer = ArcGISRuntimeEnvironment.createObject("ArcGISVectorTiledLayer", {url:"http://www.arcgis.com/home/item.html?id=bf79e422e9454565ae0cbe9553cf6471"});
                break;
            case "Dark Gray":
                layer = ArcGISRuntimeEnvironment.createObject("ArcGISVectorTiledLayer", {url:"http://www.arcgis.com/home/item.html?id=850db44b9eb845d3bd42b19e8aa7a024"});
                break;
            }
            var newBasemap = ArcGISRuntimeEnvironment.createObject("Basemap");
            newBasemap.baseLayers.append(layer);
            map.basemap = newBasemap;
        }
    }
}

