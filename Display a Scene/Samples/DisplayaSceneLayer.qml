import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10


Item {
    //! [Create MapView that contains a Map with the Imagery with Labels Basemap]
    // Create a scene view
    SceneView {
        id:sceneView
        anchors.fill: parent

        // create a scene, which is a default property of scene view
        Scene {
            // add a basemap
            BasemapTopographic {}

            //! [add a scene service with ArcGISSceneLayer]
            ArcGISSceneLayer {
                url: "http://scene.arcgis.com/arcgis/rest/services/Hosted/Buildings_Brest/SceneServer/layers/0"
            }
            //! [add a scene service with ArcGISSceneLayer]

            // add a surface, which is a default property of scene
            Surface {
                // add an arcgis tiled elevation source...elevation source is a default property of surface
                ArcGISTiledElevationSource {
                    url: "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
                }
            }

            // set an initial viewpoint
            ViewpointCenter {
                Point {
                    x: -4.49779155626782
                    y: 48.38282454039932
                    z: 62.013264927081764
                    spatialReference: Factory.SpatialReference.createWgs84()
                }
                targetScale: 62.013264927081764

                Camera {
                    id: camera
                    location: Point {
                        x: -4.49779155626782
                        y: 48.38282454039932
                        z: 62.013264927081764
                        spatialReference: Factory.SpatialReference.createWgs84()
                    }
                    heading: 41.64729875588979
                    pitch: 71.2017391571523
                    roll: 2.194677223e-314
                }
            }
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
}
