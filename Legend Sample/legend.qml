//------------------------------------------------------------------------------
// legend.qml
// Created 2015-01-20 14:21:55
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


    Map {
        id: map
        anchors.fill: parent

        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: true
        mapPanningByMagnifierEnabled: true
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

// Display of legend for a feature service does not currently work. Coming soon.
//        ArcGISFeatureLayer {
//            url: "http://melbournedev.maps.arcgis.com/home/item.html?id=dd02a223d1b94616b9e195069f3007f1"
//            onStatusChanged: {
//                if( status === Enums.MapStatusReady){
//                    mylegendView.updateModel();
//                }
//            }
//        }

        Envelope {
            id: marylandExtent
            xMax: -8519000
            yMax: 4814600
            xMin: -8501800
            yMin: 4821600
        }

            Rectangle {
            id: legendRectangle
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * 0.3
            anchors.margins: 30

            LegendView {
                id: mylegendView
                map: map
                anchors.fill: parent
            }
        }
    }
}
