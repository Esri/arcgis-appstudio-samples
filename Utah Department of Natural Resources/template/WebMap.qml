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

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "WebMap.js" as JS

Map {
    id: webMap

    property Portal portal
    property FileFolder fileFolder
    property string webMapId
    property alias itemInfo: webMapDownloadItemInfo.itemInfo
    property var webMapInfo
    property var searchInfo
    property Envelope defaultExtent : Envelope {
        xMin: -180
        yMin: -90
        xMax: 180
        yMax: 90
        spatialReference: SpatialReference {
            wkid: 4326
        }
    }

    readonly property real pixelSize: mapScale / Screen.pixelDensity / 1000 // Size of a pixel in metres

    //--------------------------------------------------------------------------

    onWebMapIdChanged: {
        if (webMapId > "") {
            load(webMapId);
        }
    }

    //--------------------------------------------------------------------------

    onStatusChanged: {
        switch (status) {
        case Enums.MapStatusReady:
            loadOperationalLayers(webMapInfo, false);
            break;
        }
    }

    //--------------------------------------------------------------------------

    BusyIndicator {
        id: busyIndicator

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

        fileFolder.writeJsonFile("webMap.json", webMapInfo);

        webMap.searchInfo = null;

        if (webMapInfo.applicationProperties) {
            if (webMapInfo.applicationProperties.viewing) {
                if (webMapInfo.applicationProperties.viewing.search) {
                    searchInfo = webMapInfo.applicationProperties.viewing.search;
                }
            }
        }

        //        reset();

        webMap.webMapInfo = webMapInfo;

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
        console.log("*** Basemap url", baseMapLayer.url);

        var layer = ArcGISRuntime.createObject(baseMapLayer.layerType, { "url": baseMapLayer.url });

        if (groupLayer) {
            groupLayer.add(layer);
        } else {
            addLayer(layer);
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
        console.log("Operational Layer:", operationalLayer.title);

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
                    //                    console.log("OL", operationalLayer.minScale, operationalLayer.maxScale);

                    if (operationalLayer.minScale) {
                        layer.minScale = operationalLayer.minScale;
                    }

                    if (operationalLayer.maxScale) {
                        layer.maxScale = operationalLayer.maxScale;
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
        //layer = ArcGISRuntime.createObject("ArcGISDynamicMapServiceLayer", { "url": operationalLayer.url });

        var layer = null;

        switch (layerInfo.layerType) {
        case "ArcGISFeatureLayer":
            layer = createFeatureLayer(layerInfo);
            break;

        case undefined:
            layer = featureLayer.createObject(null, { "layerInfo": layerInfo, "url": layerInfo.url });
            break;

        case "ArcGISMapServiceLayer":
            layer = mapServiceLayer.createObject(null, { "layerInfo": layerInfo, "url": layerInfo.url });
            break;

        case "ArcGISImageServiceLayer":
            layer = imageServiceLayer.createObject(null, { "layerInfo": layerInfo, "url": layerInfo.url });
            break;

        default:
            console.warn("Layer not created", layerInfo.layerType, layerInfo.id);
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

                    console.log("Tickling layer legend", target.name);
                    var legendInfos = target.legend;

                    for (var infoIndex = 0; infoIndex < legendInfos.length; infoIndex++) {
                        var legendInfo = legendInfos[infoIndex];
                        var legendItems = legendInfo.legendItems;

                        for (var itemIndex = 0; itemIndex < legendItems.length; itemIndex++) {
                            var legendItem = legendItems[itemIndex];
                            var v = legendItem.label + legendItem.image.toString();
                        }
                    }

                    hideBusy();
                } else {
                    console.log("layerConnection status", status);
                }
            }
        }
    }

    function createFeatureLayer(layerInfo) {
        console.log("Creating table:", layerInfo.url);
        var table = ArcGISRuntime.createObject("GeodatabaseFeatureServiceTable", {"url": layerInfo.url});
        console.log(table);

        var layer = featureTableLayer.createObject(null, { "layerInfo": layerInfo });
        layer.featureTable = table;

        return layer;
    }

    Component {
        id: featureTableLayer

        FeatureLayer {
            property var layerInfo

            visible: layerInfo.visibility
            opacity: layerInfo.opacity

            Component.onCompleted: {
                name = layerInfo.id;

                console.log("FeatureLayer name:", name, visible);
            }
        }
    }

    Component {
        id: featureLayer

        ArcGISFeatureLayer {
            property var layerInfo

            visible: layerInfo.visibility
            opacity: layerInfo.opacity

            Component.onCompleted: {
                name = layerInfo.id;

                console.log("ArcGISFeatureLayer name:", name, visible);
            }
        }
    }

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

        console.log(layerInfo.title, "#layers=", layers.length);

        for (var i = 0; i < layers.length; i++) {
            var name = layerInfo.id + "-" + i.toString();
            var layer = featureCollectionLayer.createObject(null, { "layerInfo": layers[i], "name": name });
            addLayer(layer);
        }
    }

    Component {
        id: featureCollectionLayer

        GraphicsLayer {
            property var layerInfo

            Component.onCompleted: {
                renderer = ArcGISRuntime.createObject("Renderer", layerInfo.layerDefinition.drawingInfo.renderer);

                //                console.log("Renderer", renderer);
                //                console.log(JSON.stringify(renderer.json));

                var features = layerInfo.featureSet.features;

                console.log(name, "Features #:", features.length);

                for (var i = 0; i < features.length; i++) {
                    addGraphic(features[i]);
                }
            }
        }
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
                break;
            }
        }

        function onCompleted() {
            console.log("Webmap iteminfo downloaded");

            // Workaround as itemInfo.extent is broken

            var json = itemInfo.json;
            fileFolder.writeJsonFile("itemInfo.json", json);

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
