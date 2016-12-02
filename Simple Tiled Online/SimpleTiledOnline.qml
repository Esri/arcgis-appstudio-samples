//------------------------------------------------------------------------------
// SimpleTiledOnline.qml
// Created 2015-03-20 15:18:45
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
    property double scaleFactor: AppFramework.displayScaleFactor

    width: 800
    height: 600

       Map {
           id: mainMap
           anchors.fill: parent
           wrapAroundEnabled: true
           extent: mapExtent
           focus: true

           ArcGISTiledMapServiceLayer {
               url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Toronto/ImageServer"
           }
       }

       Envelope {
           id: mapExtent
           xMin: -8837769
           yMin: 5409942
           xMax: -8837148
           yMax: 5410564
           spatialReference: mainMap.spatialReference
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

