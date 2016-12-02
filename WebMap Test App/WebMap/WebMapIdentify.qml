import QtQuick 2.2
import QtQuick.Controls 1.1
import QtPositioning 5.2
import QtQuick.Window 2.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "WebMap.js" as JS

Item {
    id: webMapIdentify

    property alias model: popupModel

    property int tasksCount: 0

    property WebMap webMap

    readonly property int categoryAddress: -1

    property var defaultLabelFields: [ "title", "name", "label" ]
    property int defaultTolerance: 10

    //--------------------------------------------------------------------------

    ListModel {
        id: popupModel
    }

    //----------------------------------------------------------------------

    function clear() {
        popupModel.clear();
    }

    //----------------------------------------------------------------------

    function identify(mousePoint, tolerance) {
        popupModel.clear();

        var mapPoint = mousePoint.mapPoint;

        if (!webMap.searchInfo || !webMap.searchInfo.disablePlaceFinder) {
            tasksCount++;
            locator.reverseGeocode(mapPoint, 20, mapPoint.spatialReference);
        }

        queryFeatures(mousePoint, tolerance);
    }

    //--------------------------------------------------------------------------

    function queryFeatures(mousePoint, tolerance) {
        var mapPoint = mousePoint.mapPoint;

        if (!tolerance) {
            tolerance = defaultTolerance;
        }

        var querySize = webMap.pixelSize * tolerance * AppFramework.displayScaleFactor;

        console.log("queryFeatures (", mapPoint.x, ",", mapPoint.y, ") tolerance", tolerance, "distance", querySize);

        queryEnvelope.xMin = mapPoint.x;
        queryEnvelope.yMin = mapPoint.y;
        queryEnvelope.xMax = mapPoint.x;
        queryEnvelope.yMax = mapPoint.y;
        queryEnvelope.inflate(querySize, querySize);

        // console.log("queryEnvelope", JSON.stringify(queryEnvelope.json, undefined, 2));

        var task;

        for (var layerIndex = 0; layerIndex < webMap.webMapInfo.operationalLayers.length; layerIndex++) {
            var layer = webMap.webMapInfo.operationalLayers[layerIndex];

            if (layer.layers) {
                for (var subLayerIndex = 0; subLayerIndex < layer.layers.length; subLayerIndex++) {
                    var subLayer = layer.layers[subLayerIndex];

                    if (!subLayer.popupInfo) {
                        continue;
                    }

                    task = queryTask.createObject();
                    task.identifyFeatures(layerIndex, layer, subLayerIndex, subLayer, queryEnvelope);
                }
            } if (layer.featureCollection) {
                if (layer.featureCollection.layers) {
                    for (var collectionIndex = 0; collectionIndex < layer.featureCollection.layers.length; collectionIndex++) {
                        var collectionLayer = layer.featureCollection.layers[collectionIndex];
                        if (collectionLayer.popupInfo) {
                            identifyFeatureCollection(layerIndex, layer, collectionIndex, collectionLayer, mousePoint, tolerance);
                        }
                    }
                }
            } else {
                switch (layer.layerType) {
                case "ArcGISFeatureLayer":
                    if (layer.popupInfo) {
                        if (layer.url > "") {
                            task = queryTask.createObject();
                            task.identifyFeatures(layerIndex, layer, -1, null, queryEnvelope);
                        }
                    }
                    break;
                }
            }
        }
    }

    Envelope {
        id: queryEnvelope
        spatialReference: webMap.spatialReference
    }

    //--------------------------------------------------------------------------

    ServiceLocator {
        id: locator

        url: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"

        onReverseGeocodeStatusChanged: {
            switch (reverseGeocodeStatus)
            {
            case Enums.ReverseGeocodeStatusCompleted:
                addReverseGeocodeResult(reverseGeocodeResult);
                tasksCount--;
                break;

            case Enums.ReverseGeocodeStatusErrored:
                console.log("Reverse Geocode Error: ", findError.message);
                tasksCount--;
                break;

            default:
                console.log("Unhandled reverseGeocodeStatus", reverseGeocodeStatus);
                break;
            }
        }

        function addReverseGeocodeResult(reverseGeocodeResult) {

            if (!reverseGeocodeResult.addressFields["Address"] && !reverseGeocodeResult.addressFields["City"]) {
                return;
            }

            var label = JS.ifString(reverseGeocodeResult.addressFields["Address"]) + " " + JS.ifString(reverseGeocodeResult.addressFields["City"]);

            popupModel.append({
                                  "category": categoryAddress,
                                  "label": label,
                                  "geometry": reverseGeocodeResult.location.json,
                                  "distance": null,
                                  "popup": false,
                                  "popupInfo": {},
                                  "attributes": {},
                                  "icon": "" //images/address.png"
                              });
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: queryTask

        QueryTask {
            property var queryLayer
            property int layerIndex
            property int subLayerIndex
            property var popupInfo

            property Query query : Query {
                where: "1=1"
                returnGeometry: true
                outSpatialReference: webMap.spatialReference
                maxFeatures: 3
                maxAllowableOffset: webMap.pixelSize * 2
                outFields: [ "*" ]
            }

            onQueryTaskStatusChanged: {
                switch (queryTaskStatus) {
                case Enums.QueryTaskStatusCompleted:
                    addQueryResult(queryLayer, queryResult);
                    tasksCount--;
                    break;

                case Enums.QueryTaskStatusErrored:
                    tasksCount--;
                    console.log(queryError.details, queryError.message);
                    break;

                case Enums.QueryTaskStatusInProgress:
                    break;

                default:
                    console.log("WebMapIdentify:Unhandled queryTaskStatus", queryTaskStatus);
                    break;
                }
            }

            function identifyFeatures(layerIdx, layer, subLayerIdx, subLayer, queryGeometry) {
                console.log("identifyFeatures",layerIdx, subLayerIdx);
                layerIndex = layerIdx;
                subLayerIndex = subLayerIdx;
                query.geometry = queryGeometry;
                queryLayer = subLayer;
                url = layer.url;

                if (subLayer) {
                    url += "/" + subLayer.id.toString();
                    popupInfo = subLayer.popupInfo;
                } else {
                    popupInfo  = layer.popupInfo;
                }

                tasksCount++;
                execute(query);
            }

            function addQueryResult(queryLayer, queryResult) {
                var attributeName = queryResult.displayFieldName;

                console.log("Adding Query results", attributeName, queryResult.graphics.length);

                var category = layerIndex * 1000;
                if (subLayerIndex > 0) {
                    category += subLayerIndex;
                }

                addGraphics(popupInfo, category, queryResult.graphics, queryResult.displayFieldName);
            }
        }
    }

    //--------------------------------------------------------------------------

    function identifyFeatureCollection(layerIndex, layer, collectionIndex, collectionLayer, mousePoint, tolerance) {
        var featureLayer = webMap.layerByName(layer.id + "-" + collectionIndex.toString());
        if (!featureLayer) {
            console.log("identifyGraphics layer not found", layer.id);

            return;
        }

        featureLayer.findGraphicsComplete.connect(function onFindGraphicsComplete(graphicIds) {

            if (!webMap.searchInfo) { // Hack fix due to model not being cleared
                popupModel.clear();
            }

            var category = layerIndex * 1000 + collectionIndex;

            var graphics = [];

            for (var graphicIndex = 0; graphicIndex < graphicIds.length; graphicIndex++) {
                graphics.push(featureLayer.graphic(graphicIds[graphicIndex]));
            }

            addGraphics(collectionLayer.popupInfo, category, graphics, undefined);
            tasksCount--;
        });

        tasksCount++;
        featureLayer.findGraphics(mousePoint.x, mousePoint.y, tolerance, 10);
    }

    //--------------------------------------------------------------------------

    function addGraphics(popupInfo, category, graphics, labelField) {

        if (!(labelField > "")) {
            if (popupInfo.fieldInfos) {
                for (var f = 0; f < popupInfo.fieldInfos.length; f++) {
                    var fieldInfo = popupInfo.fieldInfos[f];
                    if (fieldInfo.visible) {
                        labelField = fieldInfo.fieldName;
                        break;
                    }
                }
            }
        }

        for (var i = 0; i < graphics.length; i++) {
            var graphic = graphics[i];
            var label = graphic.attributeValue(labelField);

            if (typeof(label) == 'undefined') {
                var attributes = graphic.attributes;

                var keys = Object.keys(attributes);
                var keyIndex = 0;

                for (var k = 0; k < keys.length; k++) {
                    var fieldIndex = defaultLabelFields.indexOf(keys[k].toLowerCase());
                    if (fieldIndex >= 0) {
                        keyIndex = k;
                        break;
                    }
                }

                if (keys.length > 0) {
                    label = attributes[keys[keyIndex]];
                } else {
                    label = i.toString();
                }
            }

            popupModel.append({
                                  "category": category,
                                  "label": label,
                                  "geometry": graphic.geometry.json,
                                  "distance": null,
                                  "popup": true,
                                  "popupInfo": popupInfo,
                                  "attributes": graphic.attributes,
                                  "icon": "" // TODO image from renderer
                              });
        }
    }

    //--------------------------------------------------------------------------
}
