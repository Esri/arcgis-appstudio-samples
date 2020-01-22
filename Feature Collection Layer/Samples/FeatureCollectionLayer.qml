import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.2


Item {
    //! [Create MapView that contains a Map with the Imagery with Labels Basemap]
    MapView {
        id: mapView
        anchors.fill: parent

        Map {
            BasemapOceans {}

            // Declare a FeatureCollectionLayer
            FeatureCollectionLayer {

                // Create a FeatureCollection inside the
                FeatureCollection {

                    // Create a Point FeatureCollectionTable inside the FeatureCollection
                    FeatureCollectionTable {
                        id: pointsTable

                        // define the schema of the table
                        geometryType: Enums.GeometryTypePoint
                        spatialReference: SpatialReference.createWgs84()
                        Field {
                            id: placeField
                            alias: "Place Name"
                            name: "Place"
                            length: 50
                            fieldType: Enums.FieldTypeText
                        }

                        // define the renderer
                        SimpleRenderer {
                            SimpleMarkerSymbol {
                                style: Enums.SimpleMarkerSymbolStyleTriangle
                                color: "red"
                                size: 18
                            }
                        }

                        Component.onCompleted: {
                            // Create a new point feature, provide geometry and attribute values
                            var pointFeature = pointsTable.createFeature();
                            pointFeature.attributes.replaceAttribute("Place", "Current location");
                            var point1 = ArcGISRuntimeEnvironment.createObject("Point", {x: -79.497238, y: 8.849289, spatialReference: SpatialReference.createWgs84()});
                            pointFeature.geometry = point1;

                            // Add to the table
                            pointsTable.addFeature(pointFeature);
                        }
                    }

                    // Create a Point FeatureCollectionTable inside the FeatureCollection
                    FeatureCollectionTable {
                        id: linesTable

                        // define the schema of the table
                        geometryType: Enums.GeometryTypePolyline
                        spatialReference: SpatialReference.createWgs84()
                        Field {
                            alias: "Boundary Name"
                            name: "Boundary"
                            length: 50
                            fieldType: Enums.FieldTypeText
                        }

                        // define the renderer
                        SimpleRenderer {
                            SimpleLineSymbol {
                                style: Enums.SimpleLineSymbolStyleDash
                                color: "green"
                                width: 3
                            }
                        }

                        Component.onCompleted: {
                            // Create a new polyline feature, provide geometry and attribute values
                            var lineFeature = linesTable.createFeature();
                            lineFeature.attributes.replaceAttribute("Boundary", "AManAPlanACanalPanama");
                            var point1 = ArcGISRuntimeEnvironment.createObject("Point", {x: -79.497238, y: 8.849289, spatialReference: SpatialReference.createWgs84()});
                            var point2 = ArcGISRuntimeEnvironment.createObject("Point", {x: -80.035568, y: 9.432302, spatialReference: SpatialReference.createWgs84()});
                            var lineBuilder = ArcGISRuntimeEnvironment.createObject("PolylineBuilder", {spatialReference: SpatialReference.createWgs84()});
                            lineBuilder.addPoint(point1);
                            lineBuilder.addPoint(point2);
                            lineFeature.geometry = lineBuilder.geometry;

                            // Add to the table
                            linesTable.addFeature(lineFeature);
                        }
                    }

                    // Create a Point FeatureCollectionTable inside the FeatureCollection
                    FeatureCollectionTable {
                        id: polygonTable

                        // define the schema of the table
                        geometryType: Enums.GeometryTypePolygon
                        spatialReference: SpatialReference.createWgs84()
                        Field {
                            alias: "Area Name"
                            name: "Area"
                            length: 50
                            fieldType: Enums.FieldTypeText
                        }

                        // define the renderer
                        SimpleRenderer {
                            // fill
                            SimpleFillSymbol {
                                style: Enums.SimpleFillSymbolStyleDiagonalCross
                                color: "cyan"

                                // outline
                                SimpleLineSymbol {
                                    style: Enums.SimpleLineSymbolStyleSolid
                                    color: "blue"
                                    width: 2
                                }
                            }
                        }

                        Component.onCompleted: {
                            // Create a new point feature, provide geometry and attribute values
                            var polygonFeature = linesTable.createFeature();
                            polygonFeature.attributes.replaceAttribute("Area", "Restricted area");
                            var point1 = ArcGISRuntimeEnvironment.createObject("Point", {x: -79.497238, y: 8.849289, spatialReference: SpatialReference.createWgs84()});
                            var point2 = ArcGISRuntimeEnvironment.createObject("Point", {x: -79.337936, y: 8.638903, spatialReference: SpatialReference.createWgs84()});
                            var point3 = ArcGISRuntimeEnvironment.createObject("Point", {x: -79.11409, y: 8.895422, spatialReference: SpatialReference.createWgs84()});
                            var polygonBuilder = ArcGISRuntimeEnvironment.createObject("PolygonBuilder", {spatialReference: SpatialReference.createWgs84()});
                            polygonBuilder.addPoint(point1);
                            polygonBuilder.addPoint(point2);
                            polygonBuilder.addPoint(point3);
                            polygonFeature.geometry = polygonBuilder.geometry;

                            // Add to the table
                            polygonTable.addFeature(polygonFeature);
                        }
                    }
                }
            }
            // set initial extent
            ViewpointExtent {
                Envelope {
                    xMax: -8800611.655131537
                    xMin: -8917856.590171767
                    yMax: 1100327.8941287803
                    yMin: 903277.583136797
                    spatialReference: SpatialReference.createWebMercator()
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
}

