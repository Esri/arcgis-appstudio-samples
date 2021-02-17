import QtQuick 2.3
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.4

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

Item {
    property real scaleFactor: AppFramework.displayScaleFactor

    // Map view UI presentation at top
    MapView {

        anchors.fill: parent

        Map {
            BasemapImagery {}

            // create initial viewpoint
            ViewpointCenter {
                targetScale: 7500

                Point {
                    x: -226773
                    y: 6550477
                    spatialReference: Factory.SpatialReference.createWebMercator()
                }
            }
        }

        // create a new GraphicsOverlay for the MapView
        GraphicsOverlay {

            // add graphic to overlay
            Graphic {

                // define position of graphic
                Point {
                    x: -226773
                    y: 6550477
                    spatialReference: Factory.SpatialReference.createWebMercator()
                }

                // set graphic to be rendered as a red circle symbol
                SimpleMarkerSymbol {
                    style: Enums.SimpleMarkerSymbolStyleCircle
                    color: "red"
                    size: 12
                }
            }
        }
    }
}

