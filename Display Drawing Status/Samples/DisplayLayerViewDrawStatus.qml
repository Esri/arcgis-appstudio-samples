import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1

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

    // table to display layer names and statuses
    TableView {
        id: tableView
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 25 * scaleFactor
        }
        height: 120 * scaleFactor
        width: 230 * scaleFactor
        model: layerViewModel
        headerVisible: false
        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        opacity: 0.95

        // set number of layers states to be displayed at once
        rowDelegate: Row {
            height: tableView.height / 3
        }

        // create rectangle to frame the TableView
        style: TableViewStyle {
            backgroundColor: "transparent"
            frame: Rectangle {
                border.color: "black"
                radius: 10

                // make sure mouse actions on table do not affect map behind it
                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse.accepted = true
                    onWheel: wheel.accepted = true
                }
            }
        }

        // create List Model to store Layer View States and names
        ListModel {
            id: layerViewModel
        }

        TableViewColumn {
            role: "name"
            width: tableView.width * 0.75 - tableView.anchors.margins
            delegate: Component {
                Text {
                    text: styleData.value
                    leftPadding: tableView.anchors.margins
                    renderType: Text.NativeRendering
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    font {
                        weight: Font.Black
                        pixelSize: tableView.height * 0.10
                    }
                }
            }
        }

        TableViewColumn {
            role: "status"
            width: tableView.width * 0.25
            delegate: Component {
                Text {
                    text: styleData.value
                    renderType: Text.NativeRendering
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: tableView.height * 0.10
                    color: "steelblue"
                }
            }
        }
    }
}
