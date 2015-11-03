import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

import "components"

Item {

    Envelope {
        id: extent
        xMin: -9814842.76890117
        yMin: 5125201.006590235
        xMax: -9810642.951896958
        yMax: 5129088.380780631
    }

    Map {
        id: map

        anchors.fill: parent

        wrapAroundEnabled: true
        zoomByPinchingEnabled: true
        extent: extent

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        ArcGISFeatureLayer {
            id: fLayer
            url: "http://tryitlive.arcgis.com/arcgis/rest/services/TaxParcelQueryIL/MapServer/0"
            maxAllowableOffset: map.resolution
        }

        FeatureFinder {
            height: 40*scaleFactor
            width: 540*app.scaleFactor

            // Required properties
            featLayer: fLayer
            queryField: "PARCELID"

            // Optional properties
            searchBoxPlaceHolderText: "Parcel ID"
            fontFamilyName: app.fontSourceSansProReg.name

            anchors {
                top: parent.top
                topMargin: 15*app.scaleFactor
                horizontalCenter: parent.horizontalCenter
            }

            onSelect: {
                map.zoomToResolution(0.5, featGeometry)
            }

        }
    }

}

