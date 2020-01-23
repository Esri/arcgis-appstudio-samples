import QtQuick 2.6
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.2

Item {

    property real scaleFactor: AppFramework.displayScaleFactor

    // add a mapView component
    MapView {
        anchors.fill: parent

        // add a map to the mapView
        Map {
            id: map

            // create tiled layer using url
            ArcGISTiledLayer {
                url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/WorldTimeZones/MapServer"
            }

            // create a map image layer using a url
            ArcGISMapImageLayer {
                url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Census/MapServer"
                minScale: 40000000
                maxScale: 2000000
            }

            //create a feature layer using a url
            FeatureLayer {
                ServiceFeatureTable {
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Recreation/FeatureServer/0"
                }
            }

            // create initial viewpoint
            ViewpointCenter {
                targetScale: 5e7

                Point {
                    x: -11e6
                    y: 45e5
                    spatialReference: SpatialReference {
                        wkid: 102100
                    }
                }
            }

            onLoadStatusChanged: {
                if (loadStatus === Enums.LoadStatusLoaded)
                    for (var i = 0; i < map.operationalLayers.count; i++)
                        layerViewModel.append({"name": map.operationalLayers.get(i).name, "status": "Unknown"});
            }
        }

        onLayerViewStateChanged: {
            // find index of changed layer
            var index = getindex(layer);
            // get Current Status
            var status = viewStatusString(layerViewState);
            // change name if layer loaded
            layerViewModel.setProperty(index, "name", layer.name);
            // update Status in ListModel
            layerViewModel.setProperty(index, "status", status);
        }

        function viewStatusString(layerViewState) {
            switch(layerViewState.status) {
            case Enums.LayerViewStatusActive:
                return "Active";
            case Enums.LayerViewStatusNotVisible:
                return "Not Visible";
            case Enums.LayerViewStatusOutOfScale:
                return "Out of Scale";
            case Enums.LayerViewStatusLoading:
                return "Loading";
            case Enums.LayerViewStatusError:
                return "Error";
            default:
                return "Unknown";
            }
        }

        function getindex(layer) {
            for (var i = 0; i < layerViewModel.count; i++) {
                if (layer === map.operationalLayers.get(i))
                    return i;
            }
        }
    }

    // listview to display layer names and statuses
    Rectangle{
        id:tableViewRect

        height: 120 * scaleFactor
        width: 230 * scaleFactor
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 25 * scaleFactor
        }

        color: "white"
        border.color: "black"
        radius: 10
        opacity: 0.95

        ListView {
            id: tableView

            anchors.fill: parent
            anchors.margins: 10 * scaleFactor
            model: layerViewModel
            clip: true  //block components outside the rectangle when scroll up or down

            delegate:
                Row {
                padding: 5 * scaleFactor
                height: tableView.height* 1 / 3
                Text {
                    width: tableView.width * 0.75 - tableViewRect.anchors.margins
                    text: name
                    leftPadding: tableView.anchors.margins
                    renderType: Text.NativeRendering
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font {
                        weight: Font.Black
                        pixelSize: tableView.height * 0.12
                    }

                }
                Text {
                    width: tableView.width * 0.25
                    text: status
                    leftPadding: tableView.anchors.margins + tableViewRect.anchors.margins
                    renderType: Text.NativeRendering
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: tableView.height * 0.12
                    color: "steelblue"
                }
            }
            ListModel {
                id: layerViewModel
            }
        }
    }
}
