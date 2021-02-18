/* Copyright 2021 Esri
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

    property string dataPath:  AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data/Shapefile")

    property FileFolder sourceFolder: app.folder.folder("data/Shapefile")
    property FileFolder destFolder: AppFramework.userHomeFolder.folder("ArcGIS/AppStudio/Data/Shapefile")

    function copyLocalData() {
        if(!destFolder.exists)
            AppFramework.userHomeFolder.makePath(dataPath);
        var filesList = sourceFolder.fileNames()
        for(var i =0; i < sourceFolder.fileNames().length; i++)
        {
            if(!destFolder.fileExists(filesList[i]))
                sourceFolder.copyFile(filesList[i], dataPath + "/" + filesList[i]);
        }
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

            MapView {
                id: mapView
                anchors.fill: parent

                Map {
                    id: map
                    BasemapStreetsVector {}

                    FeatureLayer {

                        ShapefileFeatureTable {
                            id:shpTable

                            path: AppFramework.userHomeFolder.fileUrl(dataPath + "/Public_Art.shp")
                        }

                        onLoadStatusChanged: {
                            if (loadStatus !== Enums.LoadStatusLoaded)
                                return;

                            mapView.setViewpointCenterAndScale(fullExtent.center, 80000);
                        }
                    }
                }
            }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }

    Component.onCompleted: {
        copyLocalData()
    }
}

