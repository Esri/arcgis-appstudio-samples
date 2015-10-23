/* ******************************************
Copyright 2015 Esri

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.​
******************************************* */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

import "components"

Item {

    Envelope {
        id: initialExtent
        xMin: -14603962.659407534
        xMax: -6998481.430034638
        yMin: 449547.35620197933
        yMax: 9101054.657236475
    }

    Map {
        id: map
        anchors.fill: parent

        extent: initialExtent

        wrapAroundEnabled: true

        GroupLayer {
            id: groupLayer

            ArcGISTiledMapServiceLayer {
                id: baseMap
                url: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"
                visible: true
            }
        }
    }

    //container for basemap icon
    Rectangle {
        id: rectBaseMapControlBox
        width: 40*app.scaleFactor
        height: 40*app.scaleFactor
        color: "green"
        radius: 20*app.scaleFactor
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 5*app.scaleFactor
        }
        //basemap icon
        Image {
            width: 30*app.scaleFactor
            height: 30*app.scaleFactor
            source: "assets/images/basemap_control.png"
            anchors.centerIn: parent
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                basemapPicker.visible = !basemapPicker.visible
                mouse.accepted = true
            }
        }
    }

    //BasemapPicker Component
    BasemapPicker {
        id: basemapPicker
        fontFamilyName: app.fontSourceSansProReg.name
        textFontPointSize: app.baseFontSize*0.65
        currentBaseMapName: "Topography"

        anchors {
            right: rectBaseMapControlBox.left
            bottom: rectBaseMapControlBox.bottom
            bottomMargin: -60*app.scaleFactor
        }

        onChange: {
            //This function gets called when a new basemap has been selected
            console.log("Got: ", name, url);

            //1. Remove any exisiting basemap layer
            groupLayer.removeAllLayers();

            //2. Create a new tiled layer
            var layer = ArcGISRuntime.createObject("ArcGISTiledMapServiceLayer");
            layer.url = url;
            layer.name = name;
            layer.initialize();

            //3. Add this new layer to the groupLayer
            groupLayer.add(layer);
        }
    }
}


