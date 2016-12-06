//------------------------------------------------------------------------------
// MelbourneZoo.qml
// Created 2015-04-14 16:32:59
//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 800
    height: 532

    property string runtimePath: AppFramework.userHomeFolder.filePath("ArcGIS/Runtime")

    property string dataPath: runtimePath + "/Data"
    property string inputTPK: "MelbourneZoo.tpk"
    property string outputTPK: dataPath + "/" + inputTPK

    function copyLocalData() {
        var resourceFolder = AppFramework.fileFolder(app.folder.folder("Data").path);
        AppFramework.userHomeFolder.makePath(dataPath);
        resourceFolder.copyFile(inputTPK, outputTPK);
        return outputTPK
    }

    Map {
        id: map
        anchors.fill: parent

        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: true
        mapPanningByMagnifierEnabled: true
        zoomByPinchingEnabled: true

        positionDisplay {
            positionSource: PositionSource {
            }
        }

        ArcGISLocalTiledLayer {
            path: copyLocalData()
        }


        NorthArrow {
            anchors {
                right: parent.right
                top: parent.top
                margins: 10
            }

            visible: map.mapRotation != 0
        }

        ZoomButtons {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 10
            }
        }
    }
}

