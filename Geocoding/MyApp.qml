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
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2

import QtPositioning 5.3
import QtSensors 5.3

import "./controls"
import "./views"

App {
    id: app
    width: 421
    height: 750

    property double scaleFactor: AppFramework.displayScaleFactor

    MapArea{
        id: mapArea
        anchors.fill: parent

        GeocodeView{
            anchors.fill: parent
            currentPoint: parent.currentViewpointCenter.center
            compassDegree: parent.compass.reading.azimuth
            onResultSelected: {
                mapArea.zoomToPoint(point);
                mapArea.showPin(point);
            }
            onSearchTextChanged: {
//                mapArea.pointGraphicsOverlay.visible = false;
            }
        }


    }
}

