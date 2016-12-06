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

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 800
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor

    Map {
        id: map
        anchors.fill: parent
        extent: marylandExtent

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        ArcGISDynamicMapServiceLayer {
            id: dynamicService
            //url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/MapServer"
            //url: "http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Specialty/ESRI_StateCityHighway_USA/MapServer"
            //url: "https://gisapps.dnr.state.md.us/arcgis2/rest/services/AIMS/WaterAccess20140919/MapServer"
            url: "https://gisapps.dnr.state.md.us/arcgis2/rest/services/Environment/Natural_Filters/MapServer"
            onStatusChanged: {
                if( status === Enums.MapStatusReady){
                    mylegendView.updateModel();
                }
            }
        }

        Envelope {
            id: marylandExtent
            xMax: -8519000
            yMax: 4814600
            xMin: -8501800
            yMin: 4821600
        }

        Rectangle {
            id: legendRectangle
            color: "lightgrey"
            radius: 5
            border.color: "black"
            opacity: 0.77
            width: parent.width * 0.3
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                margins: 20 * scaleFactor
            }
        }

        LegendView {
            id: mylegendView
            map: map
            anchors.fill: legendRectangle
            anchors.margins: 10 * scaleFactor
        }

    }
}
