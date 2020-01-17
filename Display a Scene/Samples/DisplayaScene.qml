import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.2

Item {

    property real scaleFactor: AppFramework.displayScaleFactor

    //! [create the scene with a basemap and surface]
    // Create a scene view
    SceneView {
        id:sceneView
        anchors.fill: parent

        // create a scene...scene is a default property of sceneview
        // and thus will get added to the sceneview
        Scene {
            // add a basemap
            BasemapImagery {}

            // add a surface...surface is a default property of scene
            Surface {
                // add an arcgis tiled elevation source...elevation source is a default property of surface
                ArcGISTiledElevationSource {
                    url: "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
                }
            }
        }

        Component.onCompleted: {
            // set viewpoint to the specified camera
            setViewpointCameraAndWait(camera);
        }

        //Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (sceneView.drawStatus === Enums.DrawStatusInProgress)
        }
    }
    //! [create the scene with a basemap and surface]

    //! [create the camera to be used as the scene view's viewpoint]
    Camera {
        id: camera
        heading: 10.0
        pitch: 80.0
        roll: 0

        Point {
            x: 83.9
            y: 28.4
            z: 10010.0
            spatialReference: SpatialReference.createWgs84()
        }
    }
}
