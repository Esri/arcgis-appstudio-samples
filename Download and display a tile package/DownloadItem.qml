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
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 800
    height: 532

    property string tpkItemId : "0fd5d58870d24af09ddc171f95203b74"

    Component.onCompleted: portal.signIn()

    Portal {
        id: portal
        url: "http://www.arcgis.com"
        credentials: UserCredentials {
            userName: "samples"
            password: "samples123"
        }

        onSignInComplete: {
            summaryString.text = qsTr("Signed in...");
            if (!downloadPackage.exists(tpkItemId)){
                downloadPackage.download(tpkItemId);
                return;
            }
            else {
                summaryString.text = "Tile Package already downloaded..."
                folder.addLayer();
            }
        }
    }

    FileFolder {
        id: folder

        function addLayer(){
            folder.path = AppFramework.userHomePath + "/ArcGIS/AppStudio/Data/" + tpkItemId;
            var filesList = folder.fileNames("*.tpk");
            var newLayer = ArcGISRuntime.createObject("ArcGISLocalTiledLayer");
            var newFilePath = folder.path + "/" + filesList[0];
            newLayer.path = newFilePath;

            map.addLayer(newLayer);
        }
    }

    ItemPackage {
        id: downloadPackage
        portal: portal

        onDownloadStarted: {
            summaryString.text = qsTr("Download started");
        }
        onDownloadProgress: {
            progressBar.value = percentage;
            summaryString.text = percentage + "%";
        }
        onDownloadComplete: {
            progressBar.enabled = true;
            summaryString.text = qsTr("Download complete!");
            progressBar.visible = false;
            folder.addLayer();
        }
        onDownloadError: {
            progressBar.enabled = true;
            summaryString.text = qsTr("Error on download");
        }
    }

    Envelope {
        id: tpkExtent
        xMin: 16140210.985585788
        yMin: -4563241.821160977
        xMax: 16142421.131222311
        yMax: -4561772.07431269
        spatialReference: SpatialReference {
            wkid: 102100
        }
    }

    Map {
        id: map
        anchors.fill: parent
        focus: true
        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: true
        mapPanningByMagnifierEnabled: true
        zoomByPinchingEnabled: true

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        onStatusChanged: {
            if (status === Enums.MapStatusReady)
                map.zoomTo(tpkExtent);
        }
    }


    ProgressBar {
        id: progressBar
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 20
        }
        height: summaryString.height * 1.1
        minimumValue: 0
        maximumValue: 100
        enabled: false

        Text {
            id: summaryString
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#62366b"
            font {
                pixelSize: 20 * AppFramework.displayScaleFactor
            }
        }
    }
}

