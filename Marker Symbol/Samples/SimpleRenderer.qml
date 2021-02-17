import QtQuick 2.6

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

Item {
    property real scaleFactor: AppFramework.displayScaleFactor

    // Map view UI presentation at top
    MapView {
        id: mapView
        anchors.fill: parent

        Map {
            BasemapImagery {}

            Envelope {
                id: envelope
                xMin: -110.828140
                yMin: 44.460458
                xMax: -110.829381
                yMax: 44.462735
                spatialReference: Factory.SpatialReference.createWgs84()
            }

            // set initial Viewpoint
            onLoadStatusChanged: {
                if (loadStatus === Enums.LoadStatusLoaded)
                    mapView.setViewpointGeometryAndPadding(envelope, 50);
            }
        }

        // create graphic overlay
        GraphicsOverlay {

            // set renderer for overlay
            SimpleRenderer {

                // set symbol as red cross
                SimpleMarkerSymbol {
                    style: Enums.SimpleMarkerSymbolStyleCross
                    color: "red"
                    size: 12
                }
            }

            // add the points to be rendered
            Graphic {

                // Old Faithful
                Point {
                    x: -110.828140
                    y: 44.460458
                    spatialReference: Factory.SpatialReference.createWgs84()
                }
            }

            Graphic {

                // Cascade Geyser
                Point {
                    x: -110.829004
                    y: 44.462438
                    spatialReference: Factory.SpatialReference.createWgs84()
                }
            }

            Graphic {

                // Plume Geyser
                Point {
                    x: -110.829381
                    y: 44.462735
                    spatialReference: Factory.SpatialReference.createWgs84()
                }
            }
        }
    }





}
