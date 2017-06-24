import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1
Item {

    // Map view UI presentation at top
    MapView {
        id: mv

        anchors.fill: parent
        wrapAroundMode: Enums.WrapAroundModeDisabled

        Map {
            BasemapTopographic {}
            initialViewpoint: viewPoint

            FeatureLayer {
                id: featureLayer

                ServiceFeatureTable {
                    id: featureTable
                    url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/SF311/FeatureServer/0"
                }
            }
        }

        ViewpointCenter {
            id: viewPoint
            center: Point {
                x: -13630484
                y: 4545415
                spatialReference: SpatialReference {
                    wkid: 102100
                }
            }
            targetScale: 300000
        }

        // Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (mv.drawStatus === Enums.DrawStatusInProgress)
        }
    }
    //! [Rectangle-mapview-map-viewpoint]

    Row {
        id: expressionRow
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 5 * scaleFactor
            bottomMargin: 25 * scaleFactor
        }
        spacing: 5

        // button to apply a definition expression
        Button {
            text: "Apply Expression"
            enabled: featureTable.loadStatus === Enums.LoadStatusLoaded
            onClicked: {
                featureLayer.definitionExpression = "req_Type = \'Tree Maintenance or Damage\'"
            }
        }

        // button to reset the definition expression
        Button {
            text: "Reset"
            enabled: featureTable.loadStatus === Enums.LoadStatusLoaded
            onClicked: {
                featureLayer.definitionExpression = "";
            }
        }
    }
}

