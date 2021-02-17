import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

Item {

    property real scaleFactor: AppFramework.displayScaleFactor

    // create MapView
    MapView {
        id:mapView
        anchors.fill: parent

        // create map using topographic basemap
        Map {
            BasemapTopographic {}

            // create FeatureLayer using a service URL
            FeatureLayer {
                ServiceFeatureTable {
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0"
                }
            }

            // set initial viewpoint
            ViewpointExtent {
                Envelope {
                    xMin: -13639984
                    yMin: 4537387
                    xMax: -13606734
                    yMax: 4558866
                    spatialReference: Factory.SpatialReference.createWebMercator()
                }
            }
        }

        // display drawing status
        onDrawStatusChanged: {
            drawStatus === Enums.DrawStatusInProgress ? mapDrawingWindow.visible = true : mapDrawingWindow.visible = false;
        }
        Rectangle {
            id:mapDrawingWindow
            anchors.centerIn: parent
            width: 100 * scaleFactor
            height: 100 * scaleFactor
            radius: 3
            opacity: 0.85
            color: "#E0E0E0"
            border.color: "black"

            Column {
                anchors.centerIn: parent
                topPadding: 5 * scaleFactor
                spacing: 5 * scaleFactor

                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 48 * scaleFactor
                    width: height
                    running: true
                    Material.accent: "#8f499c"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font {
                        weight: Font.Black
                        pixelSize: 12 * scaleFactor
                    }
                    height: 20 * scaleFactor
                    horizontalAlignment: Text.AlignHCenter
                    renderType: Text.NativeRendering
                    text: "Drawing..."
                }
            }
        }
    }
}

