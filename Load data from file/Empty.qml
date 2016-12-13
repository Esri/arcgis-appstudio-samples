/* Copyright 2015 Esri
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

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "./Components"

App {
    id: app
    width: 800
    height: 640

    property real formWidth: 10
    property real formMaxWidth: app.width * 0.8
    property bool isLandscape : width > height

    Envelope {
        id: env
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        ContentBlock {
            Map {
                id: map
                anchors.fill: parent
                ArcGISTiledMapServiceLayer {
                    url: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer"
                }

                GraphicsLayer {
                    id: graphicsLayerProjectPoint
                }
            }

            ToolBar {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 10

                }
                RowLayout {
                    ToolButton {
                        text: "Add Points from JSON file"
                        enabled: map.status === Enums.MapStatusReady
                        onClicked: addPoints()
                    }
                }
            }
        }

    }

    Graphic {
        id: projectPointGraphic
        symbol: projectPoint
    }

    SimpleMarkerSymbol {
        id: projectPoint
        color: "red"
        style: Enums.SimpleMarkerSymbolStyleCross
        size: 10
    }

    FileFolder {
        id: fileFolder
        path: app.folder.filePath("data")
    }

    FileInfo {
         id: fileInfo
         filePath: fileFolder.path
    }

    function addPoints(){
        var fileName = "toilets.json"
        if (fileInfo.exists){
            var jsonData = fileFolder.readJsonFile(fileName);

            var longArray = jsonData.toilets.map(function(e){return e.geom.longitude;});
            var latArray = jsonData.toilets.map(function(e){return e.geom.latitude;});

            var xArray = [];
            var yArray = [];

            for ( var i in longArray){

                var geometry = ArcGISRuntime.geometryEngine.project(longArray[i],latArray[i], map.spatialReference);
                var tempPoint = projectPointGraphic.clone();
                tempPoint.geometry = geometry;

                graphicsLayerProjectPoint.addGraphic(tempPoint);

                xArray.push(geometry.x);
                yArray.push(geometry.y);
            }

            env.xMin = Math.min.apply(null, xArray) -5000;
            env.xMax = Math.max.apply(null, xArray) +5000;
            env.yMin = Math.min.apply(null, yArray) -5000;
            env.yMax = Math.max.apply(null, yArray) +5000;

            map.zoomTo(env);
       }
    }
}

