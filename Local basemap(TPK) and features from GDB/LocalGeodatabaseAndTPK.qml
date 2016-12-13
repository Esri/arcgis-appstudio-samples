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

    property string runtimePath: AppFramework.userHomeFolder.filePath("ArcGIS/Runtime")
    property string dataPath: runtimePath + "/Data"

    property string inputTPK: "SFTPK.tpk"
    property string outputTPK: dataPath + "/" + inputTPK

    property string inputGDB: "offlineSample.geodatabase"
    property string outputGDB: dataPath + "/" + inputGDB

    function copyLocalData(input, output) {
        var resourceFolder = AppFramework.fileFolder(app.folder.folder("Data").path);
        AppFramework.userHomeFolder.makePath(dataPath);
        resourceFolder.copyFile(input, output);
        return output
    }

    Envelope {
        id: sfExtent
        xMin: -13643665.582273144
        yMin: 4533030.152110769
        xMax: -13618899.985108782
        yMax: 4554203.2089457335
    }

    Map {
        id: mainMap
        anchors.fill: parent
        extent: sfExtent
        focus: true


        ArcGISLocalTiledLayer {
            path: copyLocalData(inputTPK, outputTPK)
        }

        FeatureLayer {
            id: offlineLayer
            selectionColor: "cyan"
            featureTable: local
        }

        GeodatabaseFeatureTable {
            id: local
            geodatabase: geodatabase
            featureServiceLayerId: 0
        }

        Geodatabase {
            id: geodatabase
            path: copyLocalData(inputGDB, outputGDB)
        }
    }
}

