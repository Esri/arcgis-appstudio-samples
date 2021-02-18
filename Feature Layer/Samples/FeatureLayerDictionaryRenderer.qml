import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10



Item {

    property real scaleFactor: AppFramework.displayScaleFactor
    property string dataPath:  AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data")

    property string inputdata1: "mil2525d.stylx"
    property string outputdata1: dataPath + "/" + inputdata1

    property string inputdata2: "militaryoverlay.geodatabase"
    property string outputdata2: dataPath + "/" + inputdata2

    function copyLocalData(input, output) {
        var resourceFolder = AppFramework.fileFolder(app.folder.folder("data").path);
        AppFramework.userHomeFolder.makePath(dataPath);
        resourceFolder.copyFile(input, output);
        return output
    }
    // Create MapView that contains a Map with the Topographic Basemap
    MapView {
        id: mapView
        anchors {
            fill: parent
        }
        Map {
            id: map
            BasemapTopographic {}
        }
    }

    ProgressBar {
        id: progressBar_loading
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: 5
        }
        indeterminate: true
    }

    //! [Create Dictionary Symbol Style QML]
    DictionarySymbolStyle {
        id: dictionarySymbolStyle
        specificationType: "mil2525d"
        styleLocation:AppFramework.resolvedPathUrl(copyLocalData(inputdata1, outputdata1))
    }
    //! [Create Dictionary Symbol Style QML]

    Geodatabase {
        property var gdbLayers: []

        id: geodatabase_militaryOverlay
        path: AppFramework.resolvedPathUrl(copyLocalData(inputdata2, outputdata2))

        onLoadStatusChanged: {
            if (Enums.LoadStatusLoaded === geodatabase_militaryOverlay.loadStatus) {
                var tables = geodatabase_militaryOverlay.geodatabaseFeatureTables;

                // Create a layer for each table
                for (var i = tables.length - 1; i >= 0; i--) {
                    //! [Apply Dictionary Renderer Feature Layer QML]
                    // Create a layer and set the feature table
                    var layer = ArcGISRuntimeEnvironment.createObject("FeatureLayer");
                    layer.featureTable = tables[i];

                    // Create a dictionary renderer and apply to the layer
                    var renderer = ArcGISRuntimeEnvironment.createObject(
                                "DictionaryRenderer",
                                { dictionarySymbolStyle: dictionarySymbolStyle });
                    layer.renderer = renderer;
                    //! [Apply Dictionary Renderer Feature Layer QML]

                    /**
                       * If the field names in your data don't match the contents of DictionarySymbolStyle::symbologyFieldNames(),
                       * you must set DictionaryRenderer::symbologyFieldOverrides to a map of key-value pairs like this:
                       * {
                       *   "dictionaryFieldName1": "myFieldName1",
                       *   "dictionaryFieldName2": "myFieldName2"
                       * }
                       * The following commented-out code demonstrates one way to do it, in a scenario where the dictionary
                       * expects the field name "identity" but the database table contains the field "affiliation" instead.
                       */
                    /**
                      var fieldOverrides = {
                          identity: "affiliation"
                      };
                      renderer.symbologyFieldOverrides = fieldOverrides;
                      */

                    gdbLayers.push(layer);

                    // Connect the layer's loadStatusChanged signal
                    layer.loadStatusChanged.connect(function () {

                        // See if all the layers have loaded.
                        for (var j = 0; j < gdbLayers.length; j++) {
                            if (Enums.LoadStatusLoaded !== gdbLayers[j].loadStatus) {
                                return;
                            }
                        }

                        /**
                           * If we get here, all the layers loaded. Union the extents and set
                           * the viewpoint.
                           */
                        var bbox = gdbLayers[0].fullExtent;
                        for (j = 1; j < gdbLayers.length; j++) {
                            bbox = GeometryEngine.unionOf(bbox, gdbLayers[j].fullExtent);
                        }
                        mapView.setViewpointGeometry(bbox);
                        progressBar_loading.visible = false;
                    });

                    // Add the layer to the map
                    map.operationalLayers.append(layer);
                }
            }
        }
    }
}

