/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {
    id: webMap

    property Portal portal
    property Map map
    property FileFolder fileFolder
    property var webMapInfo
    property bool autoZoom : false
    property int layersCount : 0
    property int operationalLayersCount: 0
    property int basemapLayersCount: 0
    property Envelope webMapExtent

    signal ready()

    Connections {
        target: map

        onStatusChanged: {

            if(map.status == Enums.MapStatusReady){
                console.log ("***** MapOnready event fired ******");
                if (webMapItemInfo.extent) {
                    console.log("---- Setting extent for webmap ----");
                    webMapExtent = projectEnvelope(webMapItemInfo.extent, map.spatialReference);

                    //map.extent = webMapItemInfo.extent;
                    //map.fullExtent = map.extent; // TODO bug in API

                    if(autoZoom) {
                        map.extent = webMapExtent;
                    }
                }

                loadOperationalLayers(webMapInfo, false);
            }
        }
    }


    //---------------

    function loadWebMap(webmapjson) {
        webMapInfo = webmapjson;
        loadBaseMap(webmapjson, false);
    }

    //--------------------------------------------------------------------------

    function load(itemId, portal) {
        console.log("Loading webmap:", itemId);
        webMap.portal = portal
        webMapItemInfo.itemId = itemId;
        webMapItemData.downloadWebMap(webMapItemInfo);
    }

    PortalItemInfo {
        id: webMapItemInfo
    }

    //--------------------------------------------------------------------------

    function updateMap() {

        //workaround for bug #905
        //webMapInfo = fileFolder.readJsonFile("webMapInfo.json");
        webMapInfo = JSON.parse(webMapItemData.responseText);

        //console.log("updateMap JSON: ", JSON.stringify(webMapInfo));

        //bug
        //map.reset();
        loadBaseMap(webMapInfo, false);
        //loadOperationalLayers(webMapInfo, false);
        //console.log(JSON.stringify(webMapItemInfo.json));
    }

    //--------------------------------------------------------------------------

    function loadBaseMap(webMapInfo, group) {

        //sathyanew
        //printJson(webMapInfo)

        console.log("---- Loading Basemap Layers ---- **Is group? ", group);

        var groupLayer = null;

        if (group) {
            groupLayer = ArcGISRuntime.createObject("GroupLayer");
        }

        console.log("Title:", webMapInfo.baseMap.title);
        for (var index = 0; index < webMapInfo.baseMap.baseMapLayers.length; index++) {
            basemapLayersCount++;
            addBaseMapLayer(groupLayer, webMapInfo.baseMap.baseMapLayers[index]);
        }

        console.log("Total Basemaps: ", basemapLayersCount);

        if (groupLayer) {
            console.log("# Basemap Layers in group", groupLayer.layers.length);

            map.addLayer(groupLayer);
        }


    }

    //--------------------------------------------------------------------------

    function addBaseMapLayer(groupLayer, baseMapLayer) {
        console.log("Basemap url", baseMapLayer.url);

        if(!baseMapLayer.url) {
            baseMapLayer.url = "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        var layer = ArcGISRuntime.createObject("ArcGISTiledMapServiceLayer", { "url": baseMapLayer.url });
        layer.name = baseMapLayer.id;

        //console.log(map.spatialReference == layer.spatialReference);

        if (groupLayer) {
            groupLayer.add(layer);
        } else {
            map.addLayer(layer);
        }
    }

    //--------------------------------------------------------------------------

    function loadOperationalLayers(webMapInfo, group) {
        console.log("---- Operational Layers ----", group);

        var groupLayer = null;

        if (group) {
            groupLayer = ArcGISRuntime.createObject("GroupLayer");
        }

        layersCount = webMapInfo.operationalLayers.length;

        for (var index = 0; index < webMapInfo.operationalLayers.length; index++) {
            addOperationalLayer(groupLayer, webMapInfo.operationalLayers[index]);
        }

        if (groupLayer) {
            console.log("# Operational Layers in group", groupLayer.layers.length);

            map.addLayer(groupLayer);
        }
    }

    //--------------------------------------------------------------------------

    function findOperationalLayerJson(slug) {
        console.log("webmaphelper finding slug: ", slug);
        var json = null;

        if(slug && slug.length > 0) {
            for (var index = 0; index < webMapInfo.operationalLayers.length; index++) {
                console.log("webmaphelper current layer: title=> " , webMapInfo.operationalLayers[index].title, " - id=> ", webMapInfo.operationalLayers[index].id);
                if(webMapInfo.operationalLayers[index].title.indexOf(slug) > -1 || slug === webMapInfo.operationalLayers[index].id || webMapInfo.operationalLayers[index].url&&webMapInfo.operationalLayers[index].url.indexOf(slug)>-1 ||webMapInfo.operationalLayers[index].title.toLowerCase().indexOf(slug)>-1 || webMapInfo.operationalLayers[index].id.toLowerCase().indexOf("maptour")>-1) {
                    json  = webMapInfo.operationalLayers[index];
                    break;
                }
            }
        } else {
            if(webMapInfo.operationalLayers.length === 1 && webMapInfo.operationalLayers[0].title.toLowerCase().indexOf("maptour")>-1 || webMapInfo.operationalLayers[0].id.toLowerCase().indexOf("maptour")>-1) {
                json = webMapInfo.operationalLayers[0];
            }
        }

        if(!json) {
            if(webMapInfo.operationalLayers.length === 1) {
                json = webMapInfo.operationalLayers[0];
            }
        }

        printJson(json);

        return json;
    }

    //------------------------

    function addOperationalLayer(groupLayer, operationalLayer) {
        console.log("** Adding Operational url:", operationalLayer.title);
        var layer;

        if (operationalLayer.featureCollection) {
            addFeatureCollection(operationalLayer);
            layersCount--;
            if(layersCount == 0) {
                ready();
            }
        } else if(operationalLayer.url && operationalLayer.url.indexOf("\/FeatureServer\/") > -1){
            //layer = ArcGISRuntime.createObject("ArcGISFeatureServiceLayer", { "url": operationalLayer.url });

            console.log("## Adding feature service layer for url: ", operationalLayer.url);

            var featureServiceTable = ArcGISRuntime.createObject("GeodatabaseFeatureServiceTable");
            featureServiceTable.url = operationalLayer.url;
            layer = ArcGISRuntime.createObject("FeatureLayer");
            //layer.featureTable = featureServiceTable;
            //layer.initialize()
            layer.featureTable = featureServiceTable.valid ? featureServiceTable : null;

        } else if(operationalLayer.url && operationalLayer.url.indexOf("\/MapServer/") > -1){
            console.log("## Adding Dynamic Map service layer for url: ", operationalLayer.url);

            layer = ArcGISRuntime.createObject("ArcGISDynamicMapServiceLayer")
            layer.url = operationalLayer.url;

        } else if(operationalLayer.url && operationalLayer.url.indexOf("\/ImageServer/") > -1){
            console.log("## Adding Imageservice layer for url: ", operationalLayer.url);

            layer = ArcGISRuntime.createObject("ArcGISImageServiceLayer");
            layer.url = operationalLayer.url;
        } else if (operationalLayer.layerType && operationalLayer.layerType == "ArcGISTiledMapServiceLayer") {
            console.log("## Adding Tiled Map service layer for url: ", operationalLayer.url);

            layer = ArcGISRuntime.createObject("ArcGISTiledMapServiceLayer");
            layer.url = operationalLayer.url;

        } else {
            console.error("Unsupported layer encountered");
            printJson(operationalLayer);
            //printJson(operationalLayer.json);
        }

        if(layer) {

            console.log("##WebMapHelper:: id, title: ", operationalLayer.id, operationalLayer.title);


            if(operationalLayer.visibility) {
                layer.visible = operationalLayer.visibility;
            }

            if(operationalLayer.id) {
                layer.name = operationalLayer.id;
            }

            if(operationalLayer.opacity) {
                layer.opacity = operationalLayer.opacity;
            }

            if(operationalLayer.minScale) {
                layer.minScale = operationalLayer.minScale;
            }

            if(operationalLayer.title) {
                //layer.description = operationalLayer.title;
                layer.description = operationalLayer.id + " " + operationalLayer.title;
            }

            if(operationalLayer.maxScale) {
                layer.maxScale = operationalLayer.maxScale;
            }

            console.log("Layer info: ", layer.name, layer.url);

            layer.statusChanged.connect(function(){
                console.log("layer status is: ", layer.name, layer.status);

                if(layer.status === Enums.LayerStatusInitialized) {
                    layersCount--;
                    if(layersCount == 0) {
                        ready();
                    }
                }

                if(layer.status === Enums.LayerStatusErrored) {
                    layersCount--;
                    if(layersCount == 0) {
                        ready();
                    }
                }
            });

            //            layer.layerCreateComplete.connect(function(){
            //                layersCount--;
            //                if(layersCount == 0) {
            //                    ready();
            //                }
            //            });

            //            layer.layerCreateError.connect(function(){
            //                layersCount--;
            //                if(layersCount == 0) {
            //                    ready();
            //                }
            //            });

            if (groupLayer) {
                groupLayer.add(layer);
            } else {
                map.addLayer(layer);
            }
        }
    }
    //--------------------------------------------------------------------------

    function addFeatureCollection(layerInfo) {
        console.log("**** WebMapHelper: Adding feature collection ****");
        var layers = layerInfo.featureCollection.layers;

        console.log(layerInfo.title, "#layers=", layers.length);

        for (var i = 0; i < layers.length; i++) {
            var layer = addFeatureCollectionLayer(layers[i]);
            layer.name = layerInfo.id;
            map.addLayer(layer);
        }
    }

    //--------------------------------------------------------------------------

    function addFeatureCollectionLayer(layerInfo) {
        var layer = ArcGISRuntime.createObject("GraphicsLayer");
        var renderer = ArcGISRuntime.createObject("Renderer", layerInfo.layerDefinition.drawingInfo.renderer);
        layer.renderer = renderer;

        var features = layerInfo.featureSet.features;

        console.log("##webmaphelper:: addFeatureCollectionLayer : features= ", features.length);

        for (var i = 0; i < features.length; i++) {

            //printJson(features[i].geometry);

            layer.addGraphic(features[i]);
        }

        return layer;
    }


    //--------------------------------------------------------------------------

    PortalDownloadItemData {
        id: webMapItemData

        portal: webMap.portal

        function downloadWebMap(itemInfo) {
            //sathyanew
            console.log("Inside downloadwebmap ..");
            console.log(itemInfo.itemId);
            //workaround for the new bug
            //webMapItemData.responseFilename =  AppFramework.resolvedPathUrl(fileFolder.filePath("webMapInfo.json"));

            //printJson(itemInfo.json);

            //console.log(itemInfo.created)
            //console.log(itemInfo.title)
            //console.log(itemInfo.type)
            //console.log(itemInfo.extent.xMin)

            webMapExtent = webMapItemInfo.extent;

            webMapItemData.downloadItemData(itemInfo);
        }

        onRequestStatusChanged: {
            switch (requestStatus) {
            case Enums.PortalRequestStatusInProgress:
                break;

            case Enums.PortalRequestStatusCompleted:
                updateMap();
                break;

            case Enums.PortalRequestStatusErrored:
                console.log("requestError.code: ", requestError.code);
                console.log("requestError.message: ", requestError.message);
                console.log("requestError.details: ", requestError.details);
                tourError(requestError.details);
                break;
            }
        }
    }

    //--------------------------------------------------------------------------

    function projectEnvelope(envelope4326, sref) {
        point4326.x = envelope4326.xMin;
        point4326.y = envelope4326.yMin;
        var mapPoint = point4326.project(sref);
        envelope.xMin = mapPoint.x;
        envelope.yMin = mapPoint.y;

        point4326.x = envelope4326.xMax;
        point4326.y = envelope4326.yMax;
        mapPoint = point4326.project(sref);
        envelope.xMax = mapPoint.x;
        envelope.yMax = mapPoint.y;

        return ArcGISRuntime.createObject("Envelope", envelope.json);
    }

    Point {
        id: point4326

        spatialReference: SpatialReference {
            wkid: 4326
        }
    }

    Envelope {
        id: envelope
    }



}
