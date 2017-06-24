import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1

Item {

    property real scaleFactor: AppFramework.displayScaleFactor
    // Declare a map view inside the rectangle
    MapView {
        id: mapView

        anchors.fill: parent

        // Nest a map inside of the map view
        Map {
            id: map
            // set the basemap
            BasemapTopographic {}
        }

        // Add a graphics overlay to the map view
        GraphicsOverlay {
            id: graphicsOverlay
            // assign a render to the graphics overlay
            renderer: SimpleRenderer {
                symbol: SimpleFillSymbol {
                    style: Enums.SimpleFillSymbolStyleSolid
                    color: Qt.rgba(1, 1, 0, 0.7)
                }
            }
        }

        //! [identify graphics api snippet]
        // Signal handler for mouse click event on the map view
        onMouseClicked: {
            var tolerance = 22;
            var returnPopupsOnly = false;
            var maximumResults = 1000;
            mapView.identifyGraphicsOverlayWithMaxResults(graphicsOverlay, mouse.x, mouse.y, tolerance, returnPopupsOnly, maximumResults);
        }

        // Signal handler for identify graphics overlay
        onIdentifyGraphicsOverlayStatusChanged: {
            if (identifyGraphicsOverlayStatus === Enums.TaskStatusCompleted) {
                if (identifyGraphicsOverlayResult.graphics.length > 0) {
                    msgDialog.open();
                }
            } else if (identifyGraphicsOverlayStatus === Enums.TaskStatusErrored) {
                console.log("error");
            }
        }
        //! [identify graphics api snippet]
    }

    MessageDialog {
        id: msgDialog
        text: "Tapped on graphic"
    }

    Component.onCompleted: {
        // create the polygon by assigning points
        var polygonBuilder = ArcGISRuntimeEnvironment.createObject("PolygonBuilder", {spatialReference: SpatialReference.createWebMercator()});
        polygonBuilder.addPointXY(-20e5, 20e5);
        polygonBuilder.addPointXY(20e5, 20e5);
        polygonBuilder.addPointXY(20e5, -20e5);
        polygonBuilder.addPointXY(-20e5, -20e5);
        // assign the geometry of the graphic to be the polygon
        var polygonGraphic = ArcGISRuntimeEnvironment.createObject("Graphic");
        polygonGraphic.geometry = polygonBuilder.geometry;
        // add the graphic to the polygon graphics overlay
        graphicsOverlay.graphics.append(polygonGraphic);
    }
}
