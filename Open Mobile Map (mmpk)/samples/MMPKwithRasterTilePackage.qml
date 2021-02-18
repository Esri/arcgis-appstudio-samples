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
import Esri.ArcGISRuntime 100.10



Item {

    property string inputdata: "PalmSprings.mmpk"
    property string outputdata: dataPath + "/" + inputdata

    // Create MapView
    MapView {
        id: mapView
        anchors.fill: parent
    }

    // Create a Mobile Map Package and set the path
    MobileMapPackage {
        id: mmpk
        path: AppFramework.resolvedPathUrl(copyLocalData(inputdata, outputdata))

        // load the mobile map package
        Component.onCompleted: {
            mmpk.load();
        }

        // wait for the mobile map package to load
        onLoadStatusChanged: {
            if (loadStatus === Enums.LoadStatusLoaded) {
                // set the map view's map to the first map in the mobile map package
                mapView.map = mmpk.maps[0];
            }
        }
    }
    //! [open mobile map package qml api snippet]
}


