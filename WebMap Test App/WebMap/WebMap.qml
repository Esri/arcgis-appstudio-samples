/*******************************************************************************
 * Copyright 2012-2014 Esri
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 ******************************************************************************/

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "WebMap.js" as JS

/*
Web Map Spec:
http://resources.arcgis.com/en/help/arcgis-rest-api/index.html#/Web_map_format/02r30000004n000000/
*/

Map {
    id: webMap

    property Portal portal: Portal {}
    property FileFolder fileFolder
    property string webMapId
    property alias itemInfo: webMapDownloadItemInfo.itemInfo
    property alias legendModel : legendModel
    property alias bookmarksModel: bookmarksModel
    property var webMapInfo
    property var searchInfo
    property string niceScale: JS.niceScale(mapScale)
    property Envelope defaultExtent : Envelope {
        xMin: -180
        yMin: -90
        xMax: 180
        yMax: 90
        spatialReference: SpatialReference {
            wkid: 4326
        }
    }
    property Envelope initialExtent

    property alias mapControls: mapControls
    property alias northArrow: northArrow

    property int webmapLayersCount: 0
    property int operationalLayersCount: 0
    property int basemapLayersCount: 0

    readonly property real pixelSize: mapScale / Screen.pixelDensity / 1000 // Size of a pixel in metres

    signal webMapError(var message)

    //--------------------------------------------------------------------------

    wrapAroundEnabled: true
    rotationByPinchingEnabled: true
    magnifierOnPressAndHoldEnabled: true
    mapPanningByMagnifierEnabled: true
    zoomByPinchingEnabled: true
    hidingNoDataTiles: false

    //--------------------------------------------------------------------------


    Component.onCompleted: {
        console.log("WebMap.onCompleted");

        if (portal && webMapId > "") {
            load(webMapId);
        }
    }

    onWebMapIdChanged: {
        console.log("onWebMapIdChanged", webMapId);

        if (webMap.status === Enums.MapStatusReady) {
            webMap.reset();
        }

        if (portal && webMapId > "") {
            load(webMapId);
        }
    }

    onPortalChanged: {
        console.log("onPortalChanged", portal);

        if (portal && webMapId > "") {
            load(webMapId);
        }
    }

    //--------------------------------------------------------------------------

    onStatusChanged: {
        switch (status) {
        case Enums.MapStatusReady:
            mapReady();
            break;
        }
    }

    function mapReady() {
        console.log("#### Inside WebMap Ready!!! ####");
        loadOperationalLayers(webMapInfo, false);

        initialExtent = defaultExtent.project(spatialReference);

        zoomTo(initialExtent);

        updateBookmarksModel();

        //updateLegendModel();
    }
    //-------------------------------------------------------------------------

    ListModel {
        id: bookmarksModel
    }

    function updateBookmarksModel() {
        bookmarksModel.clear()

        var bookmark = null;

        if(webMapInfo && webMapInfo.bookmarks) {
            console.log("#### SETTING UP BOOKMARKS FOR WEBMAP ####");
            for(var i=0;i <webMapInfo.bookmarks.length; i++) {
                bookmark = webMapInfo.bookmarks[i];
                //console.log(JSON.stringify(bookmark))
                bookmarksModel.append({name:webMapInfo.bookmarks[i].name, extent: webMapInfo.bookmarks[i].extent});
            }
        }

    }


    //-----------------------------------------

    ListModel {
        id: legendModel
    }

    function updateLegendModel() {
        legendModel.clear();

        console.log("############ Preparing Legend Model #########");
        console.log("Total layers in webmap: ", webMap.layerCount);

        if(webMap.layerCount < 1) return;

        //for (var layerIndex = 0; layerIndex < webMap.layerCount; layerIndex++) {
        for (var layerIndex = webMap.layerCount-1; layerIndex>=0; layerIndex--) {
            var layer = webMap.layerByIndex(layerIndex);

            console.log("Layer (id,name,type,visible,minScale,maxScale): ", layer.layerId, layer.layerName || layer.name, layer.layerType, layer.visible, layer.minScale, layer.maxScale);

            if (!layer.visible) {
                continue;
            }

            //            if(layer.layerType === Enums.LayerTypeArcGISImageService || layer.layerType === Enums.LayerTypeArcGISTiledMapService) {
            //                continue;
            //            }

            if(layer.minScale) {
                console.log("Min Scale: ",layer.minScale, " | Map Scale: ", webMap.mapScale);
                console.log(layer.minScale < parseFloat(webMap.mapScale))
            }

            if(layer.maxScale) {
                console.log("Max Scale: ",layer.maxScale, " | Map Scale: ", webMap.mapScale);
                console.log(layer.maxScale > parseFloat(webMap.mapScale));
            }

            if(layer.minScale && layer.minScale < parseFloat(webMap.mapScale)) {
                console.log("Min Scale: ",layer.minScale);
                continue;
            }

            if(layer.maxScale && layer.maxScale > parseFloat(webMap.mapScale)) {
                console.log("Max Scale: ",layer.maxScale);
                continue;
            }

            var legendInfos = layer.legend;

            if(layer.customLegends) {
                //console.log(layer.customLegends)

                for (var i in layer.customLegends) {
                    var info = layer.customLegends[i];
                    //console.log(JSON.stringify(info));
                    legendModel.append(
                                {
                                    "layerName": info.layerName,
                                    "image": info.image,
                                    "label": info.label || "",
                                    "imageHeight": info.height,
                                    "imageWidth" : info.width
                                });
                }

            } else {
                //console.log("Legend Infos for: ", layer.name, " is ", legendInfos.length, " layerType is ", layer.layerType);

                for (var infoIndex = 0; infoIndex < legendInfos.length; infoIndex++) {
                    var legendInfo = legendInfos[infoIndex];

                    //console.log(JSON.stringify(legendInfo));

                    var legendItems = legendInfo.legendItems;
                    //console.log("Legend Items", legendInfo.layerName, legendItems.length);

                    for (var itemIndex = 0; itemIndex < legendItems.length; itemIndex++) {
                        var legendItem = legendItems[itemIndex];

                        console.log(legendInfo.layerName, legendItem.label,legendItem.image.toString());

                        if(legendItem.image) {

                            legendModel.append(
                                        {
                                            "layerName": legendInfo.layerName || layer.name,
                                            "image": legendItem.image.toString(),
                                            "label": legendItem.label || "",
                                            "imageWidth": -1,
                                            "imageHeight": -1
                                        });
                        }
                    }
                }
            }

            console.log(" ~~~~~~ ");
        }

    }

    //--------------------------------------------------------------------------

    NorthArrow {
        id: northArrow

        anchors {
            right: parent.right
            top: parent.top
            margins: 10
        }

        visible: map.mapRotation !== 0
        map: webMap
    }

    ZoomButtons {
        id: mapControls

        z:11

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: 10
        }

        map: webMap
        homeExtent: initialExtent
    }

    //--------------------------------------------------------------------------

    BusyIndicator {
        id: busyIndicator

        z:11

        property int busyCount: 0

        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 10
        }

        visible: busyCount > 0
        running: visible
    }

    function showBusy() {
        busyIndicator.busyCount++;
    }

    function hideBusy() {
        busyIndicator.busyCount--;
    }

    function clearBusy() {
        busyIndicator.busyCount = 0;
    }

    //--------------------------------------------------------------------------

    function load(itemId) {
        console.log("Loading webMap id:", itemId);
        webMapDownloadItemInfo.downloadItemInfo(itemId);
        //        webMapItemInfo.itemId = itemId;
        //        webMapItemData.downloadWebMap(webMapItemInfo);
    }

    //    PortalItemInfo {
    //        id: webMapItemInfo
    //    }

    //--------------------------------------------------------------------------

    function loadItem(itemId) {
        console.log("Loading webMap item id:", itemId);
    }

    //--------------------------------------------------------------------------

    function updateMap(text) {

        var webMapInfo = JSON.parse(text);

        if (fileFolder) {
            fileFolder.writeJsonFile("webMap.json", webMapInfo);
        }

        webMap.searchInfo = null;

        if (webMapInfo.applicationProperties) {
            if (webMapInfo.applicationProperties.viewing) {
                if (webMapInfo.applicationProperties.viewing.search) {
                    searchInfo = webMapInfo.applicationProperties.viewing.search;
                }
            }
        }

        webMap.webMapInfo = webMapInfo;


        webmapLayersCount= webMapInfo.baseMap.baseMapLayers.length + webMapInfo.operationalLayers.length;

        console.log("*** Total layers from webmap to be added: ", webmapLayersCount)

        loadBaseMap(webMapInfo, false);

        //loadOperationalLayers(webMapInfo, false);
    }

    //--------------------------------------------------------------------------

    function loadBaseMap(webMapInfo, group) {

        console.log("*** Basemap Layers - group:", group);

        var groupLayer = null;

        if (group) {
            groupLayer = ArcGISRuntime.createObject("GroupLayer");
        }

        console.log("Title:", webMapInfo.baseMap.title);
        for (var index = 0; index < webMapInfo.baseMap.baseMapLayers.length; index++) {
            addBaseMapLayer(groupLayer, webMapInfo.baseMap.baseMapLayers[index]);
        }

        if (groupLayer) {
            console.log("# Basemap Layers in group", groupLayer.layers.length);

            addLayer(groupLayer);
        }
    }

    //--------------------------------------------------------------------------

    function addBaseMapLayer(groupLayer, baseMapLayer) {

        if(!baseMapLayer.url || baseMapLayer.url.length < 1) {

            console.log(JSON.stringify(baseMapLayer));

            if(baseMapLayer.type === "OpenStreetMap") {
                addOpenStreetMapLayer(groupLayer, baseMapLayer);
                return;
            }

            webMapError("Basemap is not supported. Using default. " + baseMapLayer.id  + " - " + baseMapLayer.type);
            baseMapLayer.url = "http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        console.log("*** Basemap url: ", baseMapLayer.url);
        console.log("**** Layer type: ", baseMapLayer.layerType||"(Inferred) ArcGISTiledMapServiceLayer");

        var isReference = baseMapLayer.isReference || false;

        console.log("*** Is a Refernce layer: ", isReference)

        basemapLayersCount++;

        var layer = ArcGISRuntime.createObject(baseMapLayer.layerType||"ArcGISTiledMapServiceLayer", { "url": baseMapLayer.url });

        if (groupLayer) {
            groupLayer.add(layer);
        } else {
            //            if(isReference) {
            //                insertLayer(layer, webmapLayersCount-1);
            //            } else {
            //                addLayer(layer);
            //            }
            addLayer(layer);
        }
    }

    //----------------------------------------------------------------------

    function addOpenStreetMapLayer(groupLayer, baseMapLayer) {

        if(baseMapLayer.type === "OpenStreetMap") {
            basemapLayersCount++;
            var layer = ArcGISRuntime.createObject("OpenStreetMapLayer");
            layer.tileServerUrls = ["http://otile1.mqcdn.com/tiles/1.0.0/osm/",
                                    "http://otile2.mqcdn.com/tiles/1.0.0/osm/",
                                    "http://otile3.mqcdn.com/tiles/1.0.0/osm/",
                                    "http://otile4.mqcdn.com/tiles/1.0.0/osm/"];
            layer.attributionText =  "Data, imagery and map information provided " +
                    "by MapQuest, OpenStreetMap.org and contributors, CCBYSA"
            layer.minZoomLevel = 0
            layer.maxZoomLevel = 20
            if (groupLayer) {
                groupLayer.add(layer);
            } else {
                addLayer(layer);
            }
        }

    }

    //--------------------------------------------------------------------------

    function loadOperationalLayers(webMapInfo, group) {
        console.log("*** Operational Layers - group:", group);

        var groupLayer = null;

        if (group) {
            groupLayer = ArcGISRuntime.createObject("GroupLayer");
        }

        for (var index = 0; index < webMapInfo.operationalLayers.length; index++) {
            addOperationalLayer(groupLayer, webMapInfo.operationalLayers[index]);
        }

        if (groupLayer) {
            console.log("# Operational Layers in group", groupLayer.layers.length);

            addLayer(groupLayer);
        }
    }

    //--------------------------------------------------------------------------

    function addOperationalLayer(groupLayer, operationalLayer) {
        console.log("Adding Operational Layer with title: ", operationalLayer.title);

        operationalLayersCount++;

        var layer;

        if (operationalLayer.featureCollection) {
            addFeatureCollection(operationalLayer);
        } else {
            layer = createOperationalLayer(operationalLayer);
        }

        if (layer) {
            if (groupLayer) {
                groupLayer.add(layer);
            } else {
                if (addLayer(layer)) {
                    //console.log("OL", operationalLayer.minScale, operationalLayer.maxScale);

                    if (operationalLayer.minScale) {
                        layer.minScale = operationalLayer.minScale;
                    }

                    if (operationalLayer.maxScale) {
                        layer.maxScale = operationalLayer.maxScale;
                    }

                    if(operationalLayer.layerDefinition) {
                        if(operationalLayer.layerDefinition.maxScale) {
                            layer.maxScale = operationalLayer.layerDefinition.maxScale;
                        }

                        if(operationalLayer.layerDefinition.minScale) {
                            layer.minScale = operationalLayer.layerDefinition.minScale;
                        }
                    }

                    console.log("Layer added:", operationalLayer.title, layer.visible, layer.minScale, layer.maxScale);
                }
            }
        } else {
            //console.warn("Operational layer not added", JSON.stringify(operationalLayer, undefined, 2));
        }
    }

    //--------------------------------------------------------------------------

    function createOperationalLayer(layerInfo) {
        var layer = null;

        if(!layerInfo.layerType) {

            if(layerInfo.url && layerInfo.url.indexOf("\/FeatureServer\/") > -1){
                layerInfo.layerType = "ArcGISFeatureServiceLayer"
            } else if(layerInfo.url && layerInfo.url.indexOf("\/MapServer") > -1){
                layerInfo.layerType = "ArcGISMapServiceLayer"
            } else if(layerInfo.url && layerInfo.url.indexOf("\/ImageServer") > -1){
                layerInfo.layerType = "ArcGISImageServiceLayer"
            }
        }

        console.log("**** Operational layer type: ", layerInfo.layerType)

        switch (layerInfo.layerType) {

        case "ArcGISFeatureServiceLayer":
            layer = createFeatureServiceLayer(layerInfo);
            break;

        case "ArcGISFeatureLayer":
            layer = featureLayer.createObject(null, { "layerInfo": layerInfo, "url": layerInfo.url });
            break;

        case "ArcGISMapServiceLayer":
            layer = mapServiceLayer.createObject(null, { "layerInfo": layerInfo, "url": layerInfo.url });
            break;

        case "ArcGISImageServiceLayer":
            layer = imageServiceLayer.createObject(null, { "layerInfo": layerInfo, "url": layerInfo.url });
            break;

        case "ArcGISTiledMapServiceLayer":
            layer = tiledMapServiceLayer.createObject(null, { "layerInfo": layerInfo, "url": layerInfo.url });
            break;

        default:
            console.warn("Unsupported layer - Layer cannot be created.", layerInfo.layerType, layerInfo.id);
            break;
        }

        if (layer) {
            layerConnections.createObject(this, { "target": layer });
        }

        return layer;
    }

    Component {
        id: layerConnections

        Connections {
            onStatusChanged: {
                if (status === Enums.LayerStatusInitialized) {
                    showBusy();

                    //                    console.log("Tickling layer legend", target.name);
                    //                    var legendInfos = target.legend;

                    //                    for (var infoIndex = 0; infoIndex < legendInfos.length; infoIndex++) {
                    //                        var legendInfo = legendInfos[infoIndex];
                    //                        var legendItems = legendInfo.legendItems;

                    //                        for (var itemIndex = 0; itemIndex < legendItems.length; itemIndex++) {
                    //                            var legendItem = legendItems[itemIndex];
                    //                            var v = legendItem.label + legendItem.image.toString();
                    //                        }
                    //                    }

                    hideBusy();
                } else {
                    console.log("layerConnection status", status);
                }
            }
        }
    }

    function createFeatureServiceLayer(layerInfo) {
        console.log("Creating table:", layerInfo.url);


        var defExpression = "";

        if(layerInfo.layerDefinition && layerInfo.layerDefinition.definitionExpression) {
            console.log("This service has Layer Definition: ", layerInfo.layerDefinition.definitionExpression)
            //definitionExpression = layerInfo.layerDefinition.definitionExpression;
            defExpression = layerInfo.layerDefinition.definitionExpression;
        }

        var table = ArcGISRuntime.createObject("GeodatabaseFeatureServiceTable", {"url": layerInfo.url, "definitionExpression": defExpression});


        var layer = featureTableLayer.createObject(null, { "layerInfo": layerInfo });
        layer.featureTable = table.valid ? table : null;

        return layer;
    }

    //=======================================

    Component {
        id: featureTableLayer

        FeatureLayer {
            property var layerInfo
            property var customLegends

            visible: layerInfo.visibility
            opacity: layerInfo.opacity

            onStatusChanged: {

                if(status === Enums.LayerStatusInitialized) {
                    customLegends = [];

                    if(layerInfo.layerDefinition) {

                        if(layerInfo.layerDefinition.definitionExpression) {
                            //TODO : set definition expression of the featuretable
                            console.log("Layer Definition: ", layerInfo.layerDefinition.definitionExpression)
                            //definitionExpression = layerInfo.layerDefinition.definitionExpression;

                        }

                        if(layerInfo.layerDefinition.drawingInfo) {
                            if(layerInfo.layerDefinition.drawingInfo.renderer.type === "simple") {
                                var simpleRenderer = ArcGISRuntime.createObject("SimpleRenderer",{json:layerInfo.layerDefinition.drawingInfo.renderer});
                                //console.log(JSON.stringify(simpleRenderer.json));
                                renderer = simpleRenderer
                            } else if(layerInfo.layerDefinition.drawingInfo.renderer.type === "uniqueValue") {
                                var uniqueValueRenderer = ArcGISRuntime.createObject("UniqueValueRenderer",{json:layerInfo.layerDefinition.drawingInfo.renderer});
                                //console.log(JSON.stringify(uniqueValueRenderer.json));
                                renderer = uniqueValueRenderer
                            } else if (layerInfo.layerDefinition.drawingInfo.renderer.type === "classBreaks") {
                                var classBreakRenderer = ArcGISRuntime.createObject("ClassBreaksRenderer",{json:layerInfo.layerDefinition.drawingInfo.renderer});
                                //console.log(JSON.stringify(classBreakRenderer.json));
                                renderer = classBreakRenderer
                            } else {
                                console.log("*** WebMap:: ArcGISFeatureLayer : Unsupported renderer used");
                            }
                        }
                    }

                    console.log(renderer.rendererType)

                    customLegends = getLegendInfoFromRenderer(renderer, layerInfo.title||name);
                }
            }

            Component.onCompleted: {
                name = layerInfo.id;
                console.log("FeatureLayer name:", name, visible);
            }
        }
    }

    //===========================================

    Component {
        id: featureLayer

        ArcGISFeatureLayer {
            property var layerInfo
            property var customLegends

            visible: layerInfo.visibility
            opacity: layerInfo.opacity

            onStatusChanged: {
                if(status == Enums.LayerStatusInitialized) {

                    customLegends = [];

                    if(layerInfo.layerDefinition) {
                        console.log("Layer Definition: ", layerInfo.layerDefinition)

                        if(layerInfo.layerDefinition.definitionExpression) {
                            definitionExpression = layerInfo.layerDefinition.definitionExpression;
                        }

                        if(layerInfo.layerDefinition.drawingInfo) {
                            if(layerInfo.layerDefinition.drawingInfo.renderer.type === "simple") {
                                var simpleRenderer = ArcGISRuntime.createObject("SimpleRenderer",{json:layerInfo.layerDefinition.drawingInfo.renderer});
                                //console.log(JSON.stringify(simpleRenderer.json));
                                renderer = simpleRenderer
                            } else if(layerInfo.layerDefinition.drawingInfo.renderer.type === "uniqueValue") {
                                var uniqueValueRenderer = ArcGISRuntime.createObject("UniqueValueRenderer",{json:layerInfo.layerDefinition.drawingInfo.renderer});
                                //console.log(JSON.stringify(uniqueValueRenderer.json));
                                renderer = uniqueValueRenderer
                            } else if (layerInfo.layerDefinition.drawingInfo.renderer.type === "classBreaks") {
                                var classBreakRenderer = ArcGISRuntime.createObject("ClassBreaksRenderer",{json:layerInfo.layerDefinition.drawingInfo.renderer});
                                //console.log(JSON.stringify(classBreakRenderer.json));
                                renderer = classBreakRenderer
                            } else {
                                console.log("*** WebMap:: ArcGISFeatureLayer : Unsupported renderer used");
                            }
                        }
                    }

                    customLegends = getLegendInfoFromRenderer(renderer, layerInfo.title);

                }
            }


            Component.onCompleted: {
                name = layerInfo.id;
                console.log("ArcGISFeatureLayer name:", name, visible);
            }
        }
    }

    //=============================================

    Component {
        id: tiledMapServiceLayer
        ArcGISTiledMapServiceLayer {
            property var layerInfo
            property bool isReference

            visible: layerInfo.visibility
            opacity: layerInfo.opacity

            Component.onCompleted: {
                name = layerInfo.id;
                console.log("TiledMapServiceLayer name:", name, visible);
            }
        }
    }


    //=======================================

    Component {
        id: mapServiceLayer

        ArcGISDynamicMapServiceLayer {
            id: dynamicMapServiceLayer
            property var layerInfo

            visible: layerInfo.visibility
            opacity: layerInfo.opacity

            Component.onCompleted: {
                name = layerInfo.id;
                console.log("MapServiceLayer name:", name, visible);
            }

            onStatusChanged: {
                if (status === Enums.LayerStatusInitialized) {
                    if (layerInfo.refreshInterval > 0) {
                        refreshTimer.interval = layerInfo.refreshInterval * 60000;
                        refreshTimer.start();
                        console.log(name, "refresh interval", refreshTimer.interval);
                    }

                    if (layerInfo.visibleLayers) {
                        for (var i = 0; i < layers.length; i++) {
                            var sl = layers[i];
                            sl.visible = false;
                        }

                        for (i = 0; i < layerInfo.visibleLayers.length; i++) {
                            sl = subLayerById(layerInfo.visibleLayers[i]);
                            sl.visible = true;
                        }
                    }
                } else {
                    console.log("mapServiceLayer status", status, statusString);
                }
            }

            property Timer refreshTimer : Timer {
                running: false
                triggeredOnStart: false
                repeat: true

                onTriggered: {
                    console.log("Refreshing", dynamicMapServiceLayer.name);
                    dynamicMapServiceLayer.refresh();
                }
            }
        }
    }


    //=========================================

    Component {
        id: imageServiceLayer

        ArcGISImageServiceLayer {
            property var layerInfo

            visible: layerInfo.visibility
            opacity: layerInfo.opacity

            Component.onCompleted: {
                name = layerInfo.id;

                console.log("ImageServiceLayer name:", name, visible);
            }
        }
    }

    //--------------------------------------------------------------------------

    function addFeatureCollection(layerInfo) {
        var layers = layerInfo.featureCollection.layers;

        console.log("**** Operational Layers type: FeatureCollection")
        console.log(layerInfo.title, "#layers=", layers.length);

        for (var i = 0; i < layers.length; i++) {
            var name = layerInfo.id + "-" + i.toString();
            var showLegend = layerInfo.featureCollection.showLegend;
            //console.log("Show legend: ", showLegend, typeof showLegend)
            showLegend = JS.isDefined(showLegend) ? showLegend : true;
            var layer = featureCollectionLayer.createObject(null, { "layerInfo": layers[i], "name": name, "layerId": layerInfo.id, "layerTitle": layerInfo.title, "showLegend": showLegend});
            addLayer(layer);
        }
    }

    //============================================================

    Component {
        id: featureCollectionLayer

        GraphicsLayer {
            property var layerInfo
            property string layerTitle
            property string layerId
            property var customLegends
            property bool showLegend

            onStatusChanged: {
                if(status === Enums.LayerStatusInitialized) {
                    console.log("### Graphics layer: ", layerTitle, " is ready! | Show Legend: ", showLegend);


                    //                    if(renderer && renderer.json && showLegend && customLegends.length < 1) {
                    //                        customLegends = getLegendInfoFromRenderer(renderer, layerTitle);
                    //                        console.log("Inserting # legend items: ", customLegends.length);
                    //                    }

                }
            }

            Component.onCompleted: {
                renderer = ArcGISRuntime.createObject("Renderer", layerInfo.layerDefinition.drawingInfo.renderer);

                //                console.log("Renderer", renderer);
                //                console.log(JSON.stringify(renderer.json));

                var features = layerInfo.featureSet.features;

                console.log(name, "Features #:", features.length);

                for (var j = 0; j < features.length; j++) {
                    addGraphic(features[j]);
                }

                customLegends = [];

                if(renderer && renderer.json && showLegend) {
                    customLegends = getLegendInfoFromRenderer(renderer, layerTitle);
                    console.log("Inserting # legend items: ", customLegends.length);
                }
            }
        }
    }
    //==================================================================

    function printArray(arr) {
        console.log("##### PRINTING ARRAY OF LENGTH ", arr.length, " #####");
        for(var i in arr) {
            if(typeof arr[i] === "object") {
                console.log(JSON.stringify(arr[i]))
            } else {
                console.log(arr[i].toString());
            }

            console.log("");
        }
        console.log("####### - END - ######");
    }


    Point {
        id: pointGeometry
        x: 200
        y: 200
    }

    Line {
        id: lineGeometry
    }

    Polygon {
        id: polygonGeometry

    }


    function getLegendInfoFromRenderer(renderer, layerName) {

        console.log("############ LEGEND for ", layerName, " #######################")

        var legendUrl, legendLabel, legendHeight = -1, legendWidth = -1;

        var legendInfos = [];

        //console.log(JSON.stringify(renderer.json));

        if(renderer.rendererType === Enums.RendererTypeSimple) {

            var simpleSymbol = renderer.symbol;

            console.log("**Simple Renderer **", simpleSymbol.json.type);

            if(simpleSymbol.json.height) {
                legendHeight = simpleSymbol.json.height
            }

            if(simpleSymbol.json.width) {
                legendWidth = simpleSymbol.json.width
            }

            if(simpleSymbol.json.imageData) {
                legendUrl = "data:image/png;base64," + simpleSymbol.json.imageData
            } else {
                //                if(simpleSymbol.json.type === "esriSFS") {
                //                    console.log("**Simple Renderer **", simpleSymbol.json.type);
                //                    //legendUrl = simpleSymbol.symbolImage(polygonGeometry, "transparent").url;
                //                    legendUrl = simpleSymbol.symbolImage("transparent").url;
                //                } else if(simpleSymbol.json.type === "esriSLS")
                //                    legendUrl = simpleSymbol.symbolImage(lineGeometry, "transparent").url;
                //                else
                //                    legendUrl = simpleSymbol.symbolImage(pointGeometry, "transparent").url;
                legendUrl = simpleSymbol.symbolImage("transparent").url;
                legendUrl = Qt.resolvedUrl(legendUrl);
            }

            legendLabel = layerName

            legendInfos.push({image: legendUrl, layerName: layerName, label: legendLabel, height: legendHeight, width: legendWidth})

        } else if(renderer.rendererType === Enums.RendererTypeUniqueValue) {
            var values = renderer.uniqueValues;
            var url = "";
            for(var i=0; i< values.length; i++) {
                //                console.log(JSON.stringify(values[i].json));
                //                console.log("**Unique Value Renderer **", values[i].symbol.json.type);
                //                if(values[i].symbol.json.imageData) {
                //                    url = "data:image/png;base64," + values[i].symbol.json.imageData
                //                    //console.log("image url::", url);
                //                } else {
                //                    if(values[i].symbol.json.type === "esriSFS")
                //                        url = values[i].symbol.symbolImage(polygonGeometry, "transparent").url;
                //                    else if(values[i].symbol.json.type === "esriSLS")
                //                        url = values[i].symbol.symbolImage(lineGeometry, "transparent").url;
                //                    else
                //                        url = values[i].symbol.symbolImage(pointGeometry, "transparent").url;
                //                    url = Qt.resolvedUrl(url);
                //                    ////console.log(AppFramework.resolvedPath(url));
                //                }

                if(values[i].symbol.json.imageData) {
                    url = "data:image/png;base64," + values[i].symbol.json.imageData
                } else {
                    url = values[i].symbol.symbolImage("transparent").url;
                    url = Qt.resolvedUrl(url);
                }

                if(values[i].symbol.json.height) {
                    legendHeight = values[i].symbol.json.height
                }

                if(values[i].symbol.json.width) {
                    legendWidth = values[i].symbol.json.width
                }

                legendLabel = values[i].label || ""

                legendInfos.push({layerName: layerName, label: legendLabel, image: url, height: legendHeight, width: legendWidth});
            }
        } else if( renderer.rendererType === Enums.RendererTypeClassBreak) {
            console.log("$$$$$$ LEGEND CLASSBREAK RENDERER $$$$$$");
            //console.log(JSON.stringify(renderer.json))

            var breaks = renderer.classBreaks;
            for(var j in breaks) {

                console.log(JSON.stringify(breaks[j].json));

                if(breaks[j].symbol.json.height) {
                    legendHeight = breaks[j].symbol.json.height
                }

                if(breaks[j].symbol.json.width) {
                    legendWidth = breaks[j].symbol.json.width
                }

                if(breaks[j].symbol.json.imageData) {
                    legendUrl = "data:image/png;base64," + breaks[j].symbol.json.imageData
                } else {
                    legendUrl = breaks[j].symbol.symbolImage("transparent").url;
                    legendUrl = Qt.resolvedUrl(url);
                }

                legendLabel = breaks[j].label || ""
                legendInfos.push({layerName: layerName, label: legendLabel, image: legendUrl, height: legendHeight, width: legendWidth });
            }

            printArray(legendInfos);
        }

        //printArray(legendInfos);

        return legendInfos;

    }


    //--------------------------------------------------------------------------

    PortalDownloadItemInfo {
        id: webMapDownloadItemInfo

        portal: webMap.portal

        onRequestStatusChanged: {
            switch (requestStatus) {
            case Enums.PortalRequestStatusInProgress:
                break;

            case Enums.PortalRequestStatusCompleted:
                onCompleted();
                break;

            case Enums.PortalRequestStatusErrored:
                console.log("requestError.code: ", requestError.code);
                console.log("requestError.message: ", requestError.message);
                console.log("requestError.details: ", requestError.details);
                webMap.webMapError(requestError.message || "There was an error!");
                break;
            }
        }

        function onCompleted() {
            console.log("Webmap iteminfo downloaded");

            // Workaround as itemInfo.extent is broken

            var json = itemInfo.json;
            if (fileFolder) {
                fileFolder.writeJsonFile("itemInfo.json", json);
            }

            var restExtent = json.extent;
            defaultExtent.xMin = restExtent[0][0];
            defaultExtent.yMin = restExtent[0][1];
            defaultExtent.xMax = restExtent[1][0];
            defaultExtent.yMax = restExtent[1][1];

            //console.log("extent", JSON.stringify(restExtent, undefined, 2), JSON.stringify(extent.json, undefined, 2));

            webMapItemData.downloadWebMap(itemInfo);
        }
    }

    PortalDownloadItemData {
        id: webMapItemData

        portal: webMap.portal

        function downloadWebMap(itemInfo) {
            //webMapItemData.responseFilename = fileFolder.fileUrl("webMap.json");
            webMapItemData.downloadItemData(itemInfo);
        }

        onRequestStatusChanged: {
            switch (requestStatus) {
            case Enums.PortalRequestStatusInProgress:
                break;

            case Enums.PortalRequestStatusCompleted:
                updateMap(webMapItemData.responseText);
                break;

            case Enums.PortalRequestStatusErrored:
                console.log("requestError.code: ", requestError.code);
                console.log("requestError.message: ", requestError.message);
                console.log("requestError.details: ", requestError.details);
                webMap.webMapError(requestError.message || "There was an error!");
                break;
            }
        }
    }

    //--------------------------------------------------------------------------

    function findOperationalLayer(id) {
        for (var i = 0; i < webMapInfo.operationalLayers.length; i++) {
            var opLayer = webMapInfo.operationalLayers[i];
            if (opLayer.id == id) {
                return opLayer;
            }
        }

        return null;
    }

    //--------------------------------------------------------------------------

    function findOperationalSubLayer(layerId, subLayerId) {
        var opLayer = findOperationalLayer(layerId);
        if (!opLayer) {
            return null;
        }

        if (!opLayer.layers) {
            return null;
        }

        for (var i = 0; i < opLayer.layers.length; i++) {
            var subLayer = opLayer.layers[i];
            if (subLayer.id == subLayerId) {
                return subLayer;
            }
        }

        return null;
    }

    //--------------------------------------------------------------------------
}
