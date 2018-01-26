/* Copyright 2017 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    property real size: 0.01
    property int maxZ: 1000
    property var colors: []

    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle{
            anchors.top:header.bottom
            // Create a scene view
            SceneView{
                id: sceneView
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

                GraphicsOverlay {
                    id: graphicsOverlay

                    SimpleRenderer {
                        RendererSceneProperties {
                            extrusionMode: Enums.ExtrusionModeBaseHeight
                            extrusionExpression: "[height]"
                        }
                        SimpleFillSymbol{
                            style: Enums.SimpleFillSymbolStyleSolid;
                            color: "#8f499c"
                        }
                    }
                }

                Component.onCompleted: {
                    // set viewpoint to the specified camera
                    setViewpointCameraAndWait(camera);
                    createGraphics();
                }


                // create the camera to be used as the scene view's viewpoint
                Camera {
                    id: camera
                    location: Point {
                        x: 83.9
                        y: 28.4
                        z: 10010.0
                        spatialReference: SpatialReference.createWgs84()
                    }
                    heading: 10.0
                    pitch: 80.0
                    roll: 0
                }

                function createGraphics(){
                    var lon = camera.location.x;
                    var lat = camera.location.y + 0.2;

                    // create a random set of points
                    var points = [];
                    for (var i = 0; i <= 100; i++) {
                        var point = ArcGISRuntimeEnvironment.createObject("Point", {x:i / 10 * (size * 2) + lon, y:i % 10 * (size * 2) + lat, spatialReference:sceneView.spatialReference});
                        points.push(point);
                    }

                    // for each point construct a polygon by manipulating the co-ordinates
                    points.forEach(function(item){
                        var randNum = Math.ceil(Math.random() * 6);
                        var z = maxZ * randNum;
                        var newPoints = [createPoint(item.x, item.y, z),
                                         createPoint(item.x + size, item.y, z),
                                         createPoint(item.x + size, item.y + size, z),
                                         createPoint(item.x, item.y + size, z)];

                        // create a graphic
                        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: createPolygonFromPoints(newPoints)});
                        graphic.attributes.insertAttribute("height", z);
                        graphicsOverlay.graphics.append(graphic);
                    });
                }

                // create a polygon from a list of points
                function createPolygonFromPoints(pointsList) {
                    var polygonBuilder = ArcGISRuntimeEnvironment.createObject("PolygonBuilder");
                    polygonBuilder.spatialReference = sceneView.spatialReference;

                    pointsList.forEach(function(pnt){
                        polygonBuilder.addPoint(pnt);
                    });
                    return polygonBuilder.geometry;
                }

                // create a point
                function createPoint(x, y, z) {
                    return ArcGISRuntimeEnvironment.createObject("Point", {x:x, y:y, z:z, spatialReference: sceneView.spatialReference});
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
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

