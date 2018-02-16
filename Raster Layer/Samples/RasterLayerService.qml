import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2

Item {

    property real scaleFactor: AppFramework.displayScaleFactor

    MapView {
        anchors.fill: parent
        id: mapView

        Map {
            // create a basemap from a tiled layer and add to the map
            Basemap {
                ArcGISTiledLayer {
                    url: "http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer"
                }
            }

            // create and add a raster layer to the map
            RasterLayer {
                // create the raster layer from an image service raster
                ImageServiceRaster {
                    id: imageServiceRaster
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/NLCDLandCover2001/ImageServer"

                    // zoom to the extent of the raster once it's loaded
                    onLoadStatusChanged: {
                        if (loadStatus === Enums.LoadStatusLoaded) {
                            mapView.setViewpointGeometry(imageServiceRaster.serviceInfo.fullExtent);
                        }
                    }
                }
            }
        }
    }
}



