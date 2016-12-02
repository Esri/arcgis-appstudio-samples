import QtQuick 2.2
import QtQuick.Controls 1.1
import QtPositioning 5.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "WebMap.js" as JS

Item {
    id: searchTextField

    property WebMap webMap
    property var info //: webMap.webMapInfo.applicationProperties.viewing.search

    property string searchText
    property alias resultsModel: resultsModel
    property bool canSearchLayers: false //: webMap && webMap.searchInfo && webMap.searchInfo.layers && webMap.searchInfo.layers.length > 0
    property bool canSearchPlaces: false //webMap && !webMap.searchInfo || (webMap.searchInfo && typeof webMap.searchInfo.disablePlaceFinder != 'undefined' && webMap.searchInfo.disablePlaceFinder === false)
    property bool canSearch: false //webMap && webMap.searchInfo && webMap.searchInfo.enabled && canSearchLayers || canSearchPlaces
    property bool searching: tasksCount > 0 // locator.findStatus === Enums.FindStatusInProgress


    property url geocodeServerUrl: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
    property var recentSearches: []
    property int tasksCount: 0
    property bool queryResults: false // True if there are any query results

    readonly property int categoryRecentSearches: -2
    readonly property int categorySuggestions: -1
    readonly property int categoryPlaces: 10000


    signal searchReady();
    signal resultsReady();
    signal resultUpdated(int index);

    //--------------------------------------------------------------------------

    Connections {
        target: webMap

        onWebMapInfoChanged: {
            console.log("WebMapSearch: webMapInfo changed");

            info = undefined;
            canSearch = false;
            canSearchLayers = false;
            canSearchPlaces = true;

            if (!webMap) {
                return;
            }

            if (!webMap.searchInfo) {
                console.log("No search info defined");
                return;
            }

            info = webMap.searchInfo;

            canSearchLayers = webMap.searchInfo.layers && webMap.searchInfo.layers.length > 0;
            canSearchPlaces = webMap.searchInfo.disablePlaceFinder !== true;
            canSearch = webMap.searchInfo.enabled && canSearchLayers || canSearchPlaces;

            //console.log("Searchinfo", JSON.stringify(info, undefined, 2));
            //console.log("canSearch", canSearch, "canSearchPlaces", canSearchPlaces, "canSearchlayers", canSearchLayers);
        }
    }

    //--------------------------------------------------------------------------

    ListModel {
        id: resultsModel
    }

    //--------------------------------------------------------------------------

    function clear() {
        queryResults = false;
        resultsModel.clear();
        tasksCount = 0;
    }

    //--------------------------------------------------------------------------

    function executeSearch(text, clearPrevious) {

        if (clearPrevious) {
            resultsModel.clear();
        }

        if (!(text > "")) {
            return;
        }

        addRecent(text);
        searchText = text;
        tasksCount = 0;

        updateSearchPoint();

        /*
        if (canSearchPlaces) {
            executePlaceSearch();
        }
        */

        if (canSearchLayers) {
            executeLayersSearch();
        }
    }

    //--------------------------------------------------------------------------

    function addRecent(text) {
        recentSearches.push(text);

        // Remove duplicates

        recentSearches = recentSearches.filter( function( item, index, inputArray ) {
            return inputArray.indexOf(item) === index;
        });
    }

    function addRecentSearches() {
        recentSearches.forEach(function(text) {
            resultsModel.append({
                                    "category": categoryRecentSearches,
                                    "displayText": text,
                                    "geometry": null,
                                    "distance": -1,
                                    "icon": "",
                                    "info": null
                                });
        });
    }

    //--------------------------------------------------------------------------

    function suggest(text) {
        if (text > "") {
            suggestionsTask.suggest(text,
                                    webMap.extent.center.project(wgs84),
                                    Math.round(Math.max(webMap.extent.width, webMap.extent.height) / 2));
        } else {
            suggestionsTask.suggestCancel();
        }
    }

    function updateSuggestion(text, magicKey) {
        //console.log("updateSuggestion", text, magicKey);

        suggestionsTask.magicKey = magicKey;
        suggestionsTask.find(text, magicKey);
    }

    SuggestionsTask {
        id: suggestionsTask

        property string magicKey

        url: geocodeServerUrl
        outputSpatialReference: webMap.spatialReference


        onSuggestionsChanged: {
            suggestions.forEach(function(suggestion) {
                resultsModel.append({
                                        "category": categorySuggestions,
                                        "displayText": suggestion.text,
                                        "geometry": null,
                                        "distance": -1,
                                        "icon": suggestion.isCollection
                                                ? "images/pinCollection_star_grey.png"
                                                : "",
                                                  "info": {
                                                      "magicKey": suggestion.magicKey,
                                                      "isCollection": suggestion.isCollection
                                                  }
                                    });
            });
        }


        onLocationsChanged: {
            if (locations.length >= 0) {
                for (var i = 0; i < resultsModel.count; i++) {
                    var item = resultsModel.get(i);

                    if (item.category === categorySuggestions && item.info.magicKey === magicKey) {
                        if (item.info.isCollection) {
                            console.log(locations.length, "collection locations");

                            locations.forEach(function(location) {
                                resultsModel.insert(i + 1, {
                                                        "category": categorySuggestions,
                                                        "displayText": location.name,
                                                        "geometry": location.feature.geometry.json,
                                                        "distance": -1,
                                                        "icon": "",
                                                        "info": null
                                                    });
                            });
                            resultsModel.remove(i);
                        } else {
                            var location = locations[0];

                            item.geometry = location.feature.geometry;

                            //                            var g = ArcGISRuntime.createObject("Point", { json: item.geometry });
                            //                            g.spatialReference = outputSpatialReference;
                            //                            item.distance = searchPoint.distance(g);
                        }
                        resultUpdated(i);
                        break;
                    }
                }
            }
        }
    }

    SpatialReference {
        id: wgs84

        wkid: 4326
    }

    //--------------------------------------------------------------------------

    function executePlaceSearch() {
        console.log("Searching", findTextParams.text);
        tasksCount++;
        locator.find(findTextParams);
    }


    //--------------------------------------------------------------------------

    ServiceLocator {
        id: locator

        url: geocodeServerUrl

        onFindStatusChanged: {
            switch (findStatus) {
            case Enums.FindStatusCompleted:
                addFindResults();
                tasksCount--;
                break;

            case Enums.FindStatusErrored:
                console.log("Find Error: ", findError.message);
                tasksCount--;
                break;

            default:
                console.warn("Unhandled findStatus", findStatus);
            }
        }

        function addFindResults() {
            for (var i = 0; i < findResults.length; i++) {
                var result = findResults[i];

                //            console.log("Result", i, result.address, result.score, result.location.x, result.location.y);

                resultsModel.append({
                                        "category": categoryPlaces,
                                        "displayText": result.address,
                                        "geometry": result.location.json,
                                        "distance": searchPoint.distance(result.location),
                                        "icon": "",
                                        "info": null
                                    });
            }

            if (findResults.length > 0) {
                queryResults = true;
                sortResults();
            }
        }
    }

    LocatorFindParameters {
        id: findTextParams
        text: searchText
        outSR: !webMap ? null : webMap.spatialReference
        maxLocations: 10
        //        searchExtent: webMap.extent
        sourceCountry: "US"
    }

    //--------------------------------------------------------------------------

    function executeLayersSearch() {
        for (var i = 0; i <webMap.searchInfo.layers.length; i++) {
            var task = queryTask.createObject();

            task.searchLayer(i);
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: queryTask

        QueryTask {
            property int searchIndex: 0
            property var searchLayerInfo
            property var layerInfo
            property var subLayerInfo
            property string textFieldName
            property var popupInfo

            property Query query: Query {
                returnGeometry: true
                outSpatialReference: webMap.spatialReference
                maxFeatures: 10
                maxAllowableOffset: webMap.pixelSize * 2
                outFields: [ "*" ]
            }

            function searchLayer(index) {
                searchLayerInfo = webMap.searchInfo.layers[index];

                console.log("searchLayer", index, "\r\nsearch", JSON.stringify(searchLayerInfo, undefined, 2));

                var layer = webMap.findOperationalLayer(searchLayerInfo.id);
                if (!layer) {
                    console.log("Operational layer not found", searchLayerInfo.id);
                    return;
                }

                var subLayer = findSubLayer(layer, searchLayerInfo.subLayer);

                query.where = "LOWER(" + searchLayerInfo.field.name + ") LIKE LOWER('%" + searchText + "%')";
                //query.where = searchLayerInfo.field.name + " LIKE '%" + searchText + "%'";

                searchIndex = index;
                layerInfo = layer;
                subLayerInfo = subLayer;
                url = layer.url;
                if (subLayer) {
                    url += "/" + searchLayerInfo.subLayer.toString();
                    popupInfo = subLayer.popupInfo;
                } else {
                    popupInfo = layer.popupInfo;
                }

                console.log("Starting search", url, "\r\nquery", JSON.stringify(query.json, undefined, 2));
                tasksCount++;
                execute(query);
            }

            onQueryTaskStatusChanged: {
                switch (queryTaskStatus) {
                case Enums.QueryTaskStatusCompleted:
                    console.log("QueryComplete: displayNameField", queryResult.displayFieldName, "count", queryResult.graphics.length, query.where);
                    addQueryResult();
                    tasksCount--;
                    break;

                case Enums.QueryTaskStatusErrored:
                    console.log("QueryError: ", queryError.message);
                    tasksCount--;
                    break;

                case Enums.QueryTaskStatusInProgress:
                    break;

                default:
                    console.log("WebMapSearch:Unhandled queryTaskStatus", queryTaskStatus);
                    break;
                }
            }


            function addQueryResult() {
                for (var i = 0; i < queryResult.graphics.length; i++) {
                    var graphic = queryResult.graphics[i];
                    var text = graphic.attributeValue(searchLayerInfo.field.name);
                    var resultInfo  = {
                        "feature": graphic.json
                    };

                    if (popupInfo) {
                        resultInfo.popupInfo = popupInfo;
                    }

                    resultsModel.append({
                                            "category": searchIndex,
                                            "displayText": text,
                                            "geometry": graphic.geometry.json,
                                            "distance": searchPoint.distance(graphic.geometry),
                                            "icon": "",
                                            "info": resultInfo
                                        });
                }

                if (queryResult.graphics.length > 0) {
                    queryResults = true;
                    sortResults();
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    function findSubLayer(opLayer, subLayer) {
        if (!opLayer.layers) {
            return null;
        }

        for (var i = 0; i < opLayer.layers.length; i++) {
            var layer = opLayer.layers[i];
            if (layer.id == subLayer) {
                return layer;
            }
        }

        return null;
    }

    //--------------------------------------------------------------------------

    function updateSearchPoint() {
        // Default search location is map centre

        searchPoint.spatialReference = webMap.spatialReference;
        searchPoint.x = webMap.extent.centerX;
        searchPoint.y = webMap.extent.centerY;

        // If available, use current position as search point

        if (webMap.positionDisplay.positionSource && webMap.positionDisplay.positionSource.active) {
            var position = webMap.positionDisplay.positionSource.position;

            myPosition.valid = position.longitudeValid && position.latitudeValid;
            myPosition.x = position.coordinate.longitude;
            myPosition.y = position.coordinate.latitude;

            // Reproject current position to map coordinates

            if (myPosition.valid) {
                var mapPosition = myPosition.project(webMap.spatialReference);

                searchPoint.x = mapPosition.x;
                searchPoint.y = mapPosition.y;
            }
        }
    }

    Point {
        id: myPosition

        property bool valid : false

        spatialReference: SpatialReference {
            wkid: 4326
        }
    }

    Point {
        id: searchPoint
    }

    //--------------------------------------------------------------------------

    Timer {
        id: sortTimer
        interval: 500

        onTriggered: {
            sortResults();
            resultsReady();
        }
    }

    //--------------------------------------------------------------------------

    function sortResults(updateDistances)
    {
        var n;

        if (updateDistances) {
            updateSearchPoint();

            for (n = 0; n < resultsModel.count; n++) {
                var result = resultsModel.get(n);
                result.distance = searchPoint.distance(result.geometry);
                resultsModel.set(n, result);
            }
        }

        if (resultsModel.count <= 1) {
            return;
        }

        for (n = 0; n < resultsModel.count; n++) {
            for (var i = n + 1; i < resultsModel.count; i++) {
                if (compareResults(resultsModel.get(n), resultsModel.get(i))) {
                    resultsModel.move(i, n, 1);
                    n = 0;
                }
            }
        }
    }

    function compareResults(a, b) {
        return a.category > b.category || (a.category === b.category && a.distance > b.distance);
    }

    //--------------------------------------------------------------------------
}
