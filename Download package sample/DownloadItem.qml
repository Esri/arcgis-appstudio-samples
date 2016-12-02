//------------------------------------------------------------------------------
// DownloadPackageSample.qml
// Created 2015-04-17 09:58:10
//------------------------------------------------------------------------------

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

