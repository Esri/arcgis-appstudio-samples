import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2

Item {
    id:rootRectangle
    property real scaleFactor: AppFramework.displayScaleFactor
    property var supportedFormats: ["img","I12","dt0","dt1","dt2","tc2","geotiff","tif", "tiff", "hr1","jpg","jpeg","jp2","ntf","png","i21","ovr"]
    property var rasterLayer: null

    property string dataPath:  AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data")

    property string inputdata1: "Shasta.tif"
    property string outputdata1: dataPath + "/" + inputdata1


    function copyLocalData(input, output) {
        var resourceFolder = AppFramework.fileFolder(app.folder.folder("data").path);
        AppFramework.userHomeFolder.makePath(dataPath);
        resourceFolder.copyFile(input, output);
        return output
    }

    MapView {
        id: mapView
        anchors.fill: parent
        Rectangle{
            anchors.centerIn: parent
            color:"yellow"
        }

        Map {
            RasterLayer{
                Raster {

                    path: AppFramework.resolvedPathUrl(copyLocalData(inputdata1, outputdata1))

                }
            }
            initialViewpoint: viewpoint
            ViewpointCenter {
                id:viewpoint
                Point {
                    x: -13598892.479
                    y: 4977286.41762
                    spatialReference: SpatialReference { wkid: 102100 }
                }
                targetScale: 15000

            }
        }
    }
}


