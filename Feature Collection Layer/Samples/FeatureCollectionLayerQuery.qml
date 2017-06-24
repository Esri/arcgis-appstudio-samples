import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1

Item {

    property real scaleFactor: AppFramework.displayScaleFactor
    property bool busy: featureTable.queryFeaturesStatus === Enums.TaskStatusInProgress

    MapView {
        id: mapView
        anchors.fill: parent

        Map {
            id: map
            BasemapOceans {}
        }
    }

    ServiceFeatureTable {
        id: featureTable
        url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Wildfire/FeatureServer/0"

        onQueryFeaturesStatusChanged: {
            if (queryFeaturesStatus !== Enums.TaskStatusCompleted)
                return;

            var featureCollectionTable = ArcGISRuntimeEnvironment.createObject("FeatureCollectionTable", {featureSet: queryFeaturesResult});

            var featureCollection = ArcGISRuntimeEnvironment.createObject("FeatureCollection");
            featureCollection.tables.append(featureCollectionTable);

            featureCollectionLayer.featureCollection = featureCollection;
        }

        Component.onCompleted: {
            queryFeatures(queryParams);
        }
    }

    QueryParameters {
        id: queryParams
        whereClause: "1=1"
    }

    FeatureCollectionLayer {
        id: featureCollectionLayer
        onFeatureCollectionChanged: {
            map.operationalLayers.append(featureCollectionLayer);
        }
    }

    BusyIndicator {
        Material.accent: "#8f499c"
        anchors.centerIn: parent
        visible: busy
        height: 48 * scaleFactor
        width: height
    }
}


