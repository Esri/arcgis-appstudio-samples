//------------------------------------------------------------------------------
// DynamicTiledLayerOnline.qml

// Copyright 2015 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the Sample code usage restrictions document for further information.
//
//------------------------------------------------------------------------------

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
        id: mainMap
        anchors.fill: parent
        hidingNoDataTiles: false
        wrapAroundEnabled: true
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        ArcGISDynamicMapServiceLayer {
            url: "http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Specialty/ESRI_StateCityHighway_USA/MapServer"
        }

        onStatusChanged: {
            if (status === Enums.MapStatusReady)
                mainMap.zoomTo(usExtent);
        }
    }

    Envelope {
        id: usExtent
        xMax: -15000000
        yMax: 2000000
        xMin: -7000000
        yMin: 8000000
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }
}

