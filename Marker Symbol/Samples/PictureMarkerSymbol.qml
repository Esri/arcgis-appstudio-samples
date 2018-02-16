
import QtQuick 2.6
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2


Item {
    property real scaleFactor: AppFramework.displayScaleFactor

    // Map view UI presentation at top
    MapView {
        id: mapView
        anchors.fill: parent

        Map {
            BasemapTopographic {}

            Envelope {
                id: envelope
                xMin: -228835
                xMax: -223560
                yMin: 6550763
                yMax: 6552021
                spatialReference: SpatialReference.createWebMercator()
            }

            // set initial viewpoint using envelope with padding
            onLoadStatusChanged: {
                if (loadStatus === Enums.LoadStatusLoaded)
                    mapView.setViewpointGeometryAndPadding(envelope, 30);
            }
        }

        GraphicsOverlay {

            // create Campsite Symbol from URL
            Graphic {

                Point {
                    x: -228835
                    y: 6550763
                    spatialReference: SpatialReference.createWebMercator()
                }

                PictureMarkerSymbol {
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Recreation/FeatureServer/0/images/e82f744ebb069bb35b234b3fea46deae"
                    width: 38.0
                    height: 38.0
                }
            }

            // create blue symbol from local resource
            Graphic {

                Point {
                    x: -223560
                    y: 6552021
                    spatialReference: SpatialReference.createWebMercator()
                }

                PictureMarkerSymbol {
                    url: "./images/blue_symbol.png"
                    width: 80.0
                    height: 80.0
                }
            }

            // create orange symbol from file path
            Graphic {

                Point {
                    x: -226773
                    y: 6550477
                    spatialReference: SpatialReference.createWebMercator()
                }

                PictureMarkerSymbol {
                    url:"./images/orange_symbol.png"
                    width: 64.0
                    height: 64.0
                }
            }
        }
    }
}
