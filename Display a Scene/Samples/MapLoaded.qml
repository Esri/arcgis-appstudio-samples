import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2

Item {
    property real scaleFactor: AppFramework.displayScaleFactor
    property string statusText

    // Create MapView that contains a Map
    MapView {
        id:mapView
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: statusBar.top
        }

        Map {
            // Set the initial basemap to Streets
            BasemapStreets {}
            initialViewpoint: ViewpointCenter {
                center: Point {
                    x: -11e6
                    y: 6e6
                    spatialReference: SpatialReference {wkid: 102100}
                }
                targetScale: 9e7
            }

            // Set up signal handler to determine load status
            // Load status should be loaded once the basemap successfully loads
            onLoadStatusChanged: {
                switch (loadStatus) {
                case Enums.LoadStatusFailedToLoad:
                    statusText = "Failed to Load";
                    break;
                case Enums.LoadStatusLoaded:
                    statusText = "Loaded";
                    break;
                case Enums.LoadStatusLoading:
                    statusText = "Loading...";
                    break;
                case Enums.LoadStatusNotLoaded:
                    statusText = "Not Loaded";
                    break;
                case Enums.LoadStatusUnknown:
                    statusText = "Unknown";
                    break;
                default:
                    statusText = "Unknown";
                    break;
                }
            }
        }
        // Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
        }
    }

    Rectangle {
        id: statusBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 30 * scaleFactor
        color: "lightgrey"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }

        Text {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 10 * scaleFactor
            }
            text: "Map Load Status: %1".arg(statusText)
            font.pixelSize: 14 * scaleFactor
        }
    }
}

