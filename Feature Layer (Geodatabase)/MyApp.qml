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
import Esri.ArcGISRuntime 100.2

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

    property string dataPath:  AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data")

    property string inputVTPK: "LosAngeles.vtpk"
    property string outputVTPK: dataPath + "/" + inputVTPK

    property string inputGDB: "LA_Trails.geodatabase"
    property string outputGDB: dataPath + "/" + inputGDB

    function copyLocalData(input, output) {
        var resourceFolder = AppFramework.fileFolder(app.folder.folder("data").path);
        AppFramework.userHomeFolder.makePath(dataPath);
        resourceFolder.copyFile(input, output);
        console.log("output",output)
        return output
    }


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
            // Map view UI presentation at top
            MapView {
                anchors.fill: parent

                Map {
                    id: map

                    // set an initial viewpoint
                    ViewpointCenter {
                        Point {
                            x: -13214155
                            y: 4040194
                            spatialReference: SpatialReference.createWebMercator()
                        }
                        targetScale: 35e4
                    }

                    //! [FeatureLayer Geodatabase add basemap]
                    // create a basemap from a local vector tile package
                    Basemap {
                        ArcGISVectorTiledLayer {
                            url: AppFramework.resolvedPathUrl(copyLocalData(inputVTPK, outputVTPK))
                        }
                    }
                    //! [FeatureLayer Geodatabase add basemap]

                    //! [FeatureLayer Geodatabase create]
                    // create a feature layer
                    FeatureLayer {
                        // obtain the feature table from the geodatabase by name
                        featureTable: gdb.geodatabaseFeatureTablesByTableName["Trailheads"]

                        // create the geodatabase
                        Geodatabase {
                            id: gdb
                            path: AppFramework.resolvedPathUrl(copyLocalData(inputGDB, outputGDB))
                        }
                    }
                    //! [FeatureLayer Geodatabase create]
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

