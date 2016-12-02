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
    id: tourHelper

    property Portal portal
    property PortalItemInfo tourItemInfo
    //property PortalItemInfo mapItemInfo
    property var tourInfo
    property string tourLayerId
    property alias tourItemsListModel: tourItemsListModel

    //property alias tourFeatureServiceTable: tourFeatureServiceTable
    property FeatureLayer tourFeatureLayer;
    property GraphicsLayer tourGraphicsLayer;
    property alias tourFolder: tourFolder
    property alias tourMap: tourMap
    property bool webMapReady: false

    property string mapCredits

    signal exit()
    signal webMapLoaded()
    signal tourError(string message)

    //--------------------------------------------------------------------------

    function loadTour(itemInfo) {

        //sathyanew
        //printJson(itemInfo)

        //printJson(itemInfo.json);

        console.log("##TourPageHelper: ", app.showGallery, app.webmapid, app.tourLayerId)
        //if(itemInfo && itemInfo.json.type === "Web Mapping Application") {
        if(itemInfo && itemInfo.values) {
            tourInfo = itemInfo

            console.log(JSON.stringify(tourInfo));
            console.log("------ Load Tour -------");
            //console.log("Tour ID: ", tourItemInfo.itemId);
            if(tourInfo.values) {
                console.log("Webmap found: ", tourInfo.values.webmap);
                console.log("title found: ", tourInfo.values.title);
                console.log("subtitle found: ", tourInfo.values.subtitle);
                console.log("source layer: ", tourInfo.values.sourceLayer);
                if(tourInfo.values.sourceLayer) {
                    tourLayerId = tourInfo.values.sourceLayer;
                }
            }

            if(!tourLayerId && !app.tourLayerId) {
                tourError("Sorry! Unable to find Map Tour Layer");
            }

            if(!tourInfo.values || !tourInfo.values.webmap) {
                tourError("Sorry! Unable to load this Map Tour");
                busyIndicator.visible = false;
                return;
            }

            tourMap.load(tourInfo.values.webmap, portal);
        } else if(itemInfo && itemInfo.type === "Web Map"){
            console.log("##TourPageHelper:: item is of type webmap !!!");
            tourLayerId = app.tourLayerId;
            tourMap.load(itemInfo.id, portal);
        } else if(itemInfo && itemInfo.operationalLayers) {
            console.log("##TourPageHelper:: item is of time webmap, got json directly!!");
            tourLayerId = app.tourLayerId;
            tourMap.loadWebMap(itemInfo);
        } else if(!app.showGallery && app.tourLayerId && app.webmapid) {
            //webmap provided by user
            console.log("#TourPageHelper:: webmap provided by user");
            //tourMap.loadLayers(app.featureServiceLayer, app.basemapLayer);
            tourLayerId = app.tourLayerId;
            tourMap.load(app.webmapid, portal);
        } else {
            tourError("Unable to get webmap and tour layer to show!");
        }
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: tourFolder
    }

    //--------------------------------------------------------------------------

    WebMapHelper {
        id: tourMap

        //portal: tourView.portal
        fileFolder: tourFolder
        map: mapView.map

        onReady: {
            webMapReady = true;
            busyIndicator.visible = false;
            webMapLoaded();
        }
    }
    //----------------

    //Connections {
    //    target: tourFeatureLayer.featureTable

    //    onFeatureResultChanged: {
    //        console.log("onFeatureResultChanged")
    //        console.log(tourFeatureLayer.featureTable.featureResult.featureCount);
    //    }

    //    onQueryFeaturesStatusChanged: {
    //        console.log("onQueryFeaturesStatusChanged")
    //        console.log("Results: ", queryFeaturesResult.featureCount)
    //     }
    //}

    //--------------------------------------------------------------------------

    Connections {
        target: tourMap

        onReady: {
            console.log("##TourPageHelper ----- WebMapHelper Ready event -----");

            var basemaplayer = map.layerByIndex(0);

            mapCredits = basemaplayer.copyrightText;

            //todo 1. get the map tour layer

            var layerJson = tourMap.findOperationalLayerJson(tourLayerId);

            var name = "";
            var url = "";
            var id = "";

            if(!layerJson) {
                console.log("##TourPageHelper:: ***** ERROR _ NO MAP TOUR LAYER FOUND IN WEBMAP .... CHECK!!!");

                //tourError("Sorry, No Map Tour Layer found!");
                //printJsonFromObject(tourMap);

                //return;
            } else {
                name = layerJson.title || "";
                url = layerJson.url || "";
                id = layerJson.id || "";
                console.log("##TourPageHelper:: Got back map tour layer: ", url);
                console.log("##Tourpagehelper: Checking for name: ", name, id);
            }

            //printJson(layerJson);

            var featureLayer = null;

            for (var index = 0; index < map.layerCount; index++) {
                var layer = map.layerByIndex(index);
                console.log("##TourPageHelper:: Current layer: " , layer.layerId , layer.name, layer.layerType, layer.url);

                //console.log("%% " , layer.json.id , layer.json.title);
                //TODO - this is a hack, need to fix this later
                if(layer.name === name || layer.name.indexOf(id) > -1 || layer.name.indexOf(tourLayerId) > -1 ||  tourLayerId.indexOf(layer.name) > -1 || layer.name.indexOf("MAP_TOUR") > -1 || layer.name.indexOf("maptour") > -1) {


                    console.log("Name or ID matched... layer type is: ", layer.layerType);

                    if(layer.layerType === 4 || layer.layerType === 7 || layer.layerType === 5) {
                        console.log("Tourpagehelper YAY found the feature layer");
                        featureLayer = layer;
                        break;
                    }
                }
            }

            //printJson(featureLayer);

            //2. change renderer

            if(featureLayer) {

                console.log("Feature layer is of type: ", featureLayer.layerType);

                if(app.customRenderer) {
                    uvRenderer.addValue(uvInfoRed);
                    uvRenderer.addValue(uvInfoGreen);
                    uvRenderer.addValue(uvInfoBlue);
                    uvRenderer.addValue(uvInfoPurple);
                    uvRenderer.addValue(uvInfoRed2);
                    uvRenderer.addValue(uvInfoGreen2);
                    uvRenderer.addValue(uvInfoBlue2);
                    uvRenderer.addValue(uvInfoPurple2);
                    featureLayer.renderer = uvRenderer;
                }


                if(tourMap.webMapExtent && tourMap.webMapExtent.valid) {
                    console.log("TourPageHelper:: Web Map Extent debug ");
                    printJson(tourMap.webMapExtent.json);
                    printJson(tourMap.webMapExtent.project(map.spatialReference))
                    map.extent = tourMap.webMapExtent.project(map.spatialReference)
                } else if(featureLayer.extent) {
                    map.extent = featureLayer.extent;

                } else if(featureLayer.fullExtent) {
                    map.extent = featureLayer.fullExtent;
                    //map.zoomTo(featureLayer.fullExtent)
                }

                //featureLayer.featureTable.queryServiceFeatures(queryParams)

                if(featureLayer.featureTable) {
                    tourFeatureLayer = featureLayer;
                    tourFeatureLayer.selectionColor = app.selectColor;
                    console.log("###TourPageHelper: Map tour layer is of type: Feature Service ", url);
                    tourItemsQueryTask.url = url;
                    if(app.customSort) {
                        var orderBy = [];
                        orderBy.push({fieldName : app.customSortField.toString(), order: app.customSortOrder == "desc" ? Enums.OrderByFieldsDescending : Enums.OrderByFieldsAscending});
                        queryParams.orderByFields = orderBy;
                    }

                    //printJson(queryParams.json);
                    console.log("Sending query to: ", tourItemsQueryTask.url);
                    tourItemsQueryTask.execute(queryParams);
                } else {
                    //graphics layer
                    console.log("###TourPageHelper: Map tour layer is of type: Graphics layer");
                    tourGraphicsLayer = featureLayer;
                    tourGraphicsLayer.selectionColor = app.selectColor;
                    tourGraphicsLayer.moveToTop();
                    console.log("###TourPageHelper: Number of features in graphics layer : ", tourGraphicsLayer.graphics.length);
                    for (var i = 0; i < tourGraphicsLayer.graphics.length; i++) {

                        var graphic = tourGraphicsLayer.graphics[i];
                        //console.log("Adding graphic into graphics layer for: ", graphic.uniqueId);
                        if(graphic.geometry && graphic.geometry.x && graphic.geometry.y) {
                            //printJson(graphic.attributes);

                            var json = graphic.json;
                            var dirty = false;

                            if(graphic.attributes.OBJECTID || graphic.attributes.ObjectID || graphic.attributes.ObjectId || graphic.attributes.F__OBJECTID || graphic.attributes.__OBJECTID || graphic.attributes.FID) {
                                dirty = true;
                                json.attributes.objectid = graphic.attributes.OBJECTID || graphic.attributes.ObjectID || graphic.attributes.ObjectId || graphic.attributes.F__OBJECTID || graphic.attributes.__OBJECTID || graphic.attributes.FID;
                            }

                            if(graphic.attributes.Description || graphic.attributes.DESCRIPTION || graphic.attributes.Caption || graphic.attributes.CAPTION || app.descField) {
                                dirty = true;
                                json.attributes.description = graphic.attributes.Description || graphic.attributes.DESCRIPTION || graphic.attributes.Caption || graphic.attributes.CAPTION || graphic.attributes[descField];
                            }

                            if(graphic.attributes.Color || graphic.attributes.Icon_color || graphic.attributes.ICON_COLOR || app.iconColorField) {
                                dirty = true;
                                json.attributes.icon_color = graphic.attributes.Color || graphic.attributes.ICON_COLOR || graphic.attributes.Icon_color || graphic.attributes[app.iconColorField];
                            }

                            if(graphic.attributes.Name || graphic.attributes.NAME || app.titleField) {
                                dirty = true;
                                json.attributes.name = graphic.attributes.Name || graphic.attributes.NAME || graphic.attributes[app.titleField];
                            }

                            if(graphic.attributes.Thumb || graphic.attributes.Thumb_URL || graphic.attributes.THUMB_URL|| app.thumbnailField) {
                                dirty = true;
                                json.attributes.thumb_url = graphic.attributes.Thumb || graphic.attributes.THUMB_URL || graphic.attributes.Thumb_URL || graphic.attributes[app.thumbnailField];
                            }

                            if(graphic.attributes.Picture || graphic.attributes.PIC_URL || graphic.attributes.pic_url || app.imageField) {
                                dirty = true;
                                json.attributes.pic_url = graphic.attributes.Picture || graphic.attributes.PIC_URL || graphic.attributes.pic_url || graphic.attributes[app.imageField];
                            }

                            if(!json.attributes.thumb_url || json.attributes.thumb_url.length < 1) {
                                json.attributes.thumb_url = "images/item_thumbnail.png"
                            }

                            if(!json.attributes.pic_url || json.attributes.pic_url.length < 1) {
                                json.attributes.pic_url = "images/placeholder.jpg"
                            }

                            if(!json.attributes.name || json.attributes.name.length < 1) {
                                json.attributes.name = ""
                            }

                            json.attributes.is_video = false;

                            if(json.attributes.IS_VIDEO || json.attributes.is_video || json.attributes.pic_url.indexOf("www.youtube.com") > 1 || json.attributes.pic_url.indexOf("vimeo.com") > 1 ) {
                                json.attributes.is_video = true;
                            }

                            if(!json.attributes.description || json.attributes.description.length < 1) {
                                json.attributes.description = ""
                            }

                            if(dirty) {
                                graphic.json = json;
                                //console.log(JSON.stringify(graphic.attributes));
                            }

                            //printJsonFromObject(graphic.geometry);
                            mp.add(graphic.geometry);
                            //tourItemsListModel.append(graphic.attributes);
                            tourItemsListModel.append(json);
                        } else {
                            console.log("###TourPageHelper: Invalid Graphic encountered");
                            if(graphic && graphic.uniqueId) {
                                if(graphic.geometry) {
                                    printJsonFromObject(graphic.geometry)
                                }

                                if(graphic.attributes) {
                                    printJson(graphic.attributes)
                                }

                                tourGraphicsLayer.removeGraphic(graphic.uniqueId);
                            }
                        }

                    }

                    if(mp.pointCount > 1) {
                        var extent = mp.queryEnvelope();
                        zoomButtons.homeExtent = extent.scale(1.5);
                        map.zoomTo(extent.scale(1.5));
                    }

                    if(tourItemsListModel.count < 1) {
                        tourError("Sorry! No photos in this Tour.");
                    } else {
                        tourError(null);
                    }

                }

            } else {
                tourError("Cannot find any story map tour layers.");
            }

        }
    }

    //------------------------

    Query {
        id:queryParams
        returnGeometry: true
        where: "1=1"
        outFields: "*"
        outSpatialReference : map.spatialReference
        //orderByFields: {"SortOrder": Enums.OrderByFieldsAscending}
    }

    ListModel {
        id: tourItemsListModel
    }

    QueryTask {
        id: tourItemsQueryTask

        onQueryTaskStatusChanged: {
            console.log("queryTask Status", queryTaskStatus);

            if(queryTaskStatus === Enums.QueryTaskStatusErrored) {
                tourError("Unable to get tour points information from map");

            } else if (queryTaskStatus === Enums.QueryTaskStatusCompleted) {
                console.log("Tour items count: ", queryResult.graphics.length);
                for (var i = 0; i < queryResult.graphics.length; i++) {
                    var graphic = queryResult.graphics[i];

                    if(graphic.geometry && graphic.geometry.x && graphic.geometry.y) {
                        //good to go
                    } else {
                        console.log("Skipping a graphic, bad geometry!");
                        printJsonFromObject(graphic);
                        continue;
                    }

                    //printJsonFromObject(graphic);
                    //printJson(graphic.attributes);
                    //var attributes = graphic.attributes;

                    var json = graphic.json;
                    var dirty = false;

                    //printJson(json.attributes)

                    if(graphic.attributes.OBJECTID || graphic.attributes.ObjectID || graphic.attributes.ObjectId || graphic.attributes.F__OBJECTID || graphic.attributes.__OBJECTID || graphic.attributes.FID) {
                        dirty = true;
                        json.attributes.objectid = graphic.attributes.OBJECTID || graphic.attributes.ObjectID || graphic.attributes.ObjectId || graphic.attributes.F__OBJECTID || graphic.attributes.__OBJECTID || graphic.attributes.FID;
                    }


                    if(graphic.attributes.Description || graphic.attributes.DESCRIPTION || graphic.attributes.Caption  || graphic.attributes.CAPTION || app.descField) {
                        dirty = true;
                        json.attributes.description = graphic.attributes.Description || graphic.attributes.DESCRIPTION || graphic.attributes.Caption || graphic.attributes.CAPTION || graphic.attributes[descField];
                    }

                    if(graphic.attributes.Color || graphic.attributes.Icon_color || graphic.attributes.ICON_COLOR || app.iconColorField) {
                        dirty = true;
                        json.attributes.icon_color = graphic.attributes.Color || graphic.attributes.ICON_COLOR || graphic.attributes.Icon_color || graphic.attributes[app.iconColorField];
                    }

                    if(graphic.attributes.Name || graphic.attributes.NAME || app.titleField) {
                        dirty = true;
                        json.attributes.name = graphic.attributes.Name || graphic.attributes.NAME || graphic.attributes[app.titleField];
                    }

                    if(graphic.attributes.Thumb || graphic.attributes.Thumb_URL || graphic.attributes.THUMB_URL|| app.thumbnailField) {
                        dirty = true;
                        json.attributes.thumb_url = graphic.attributes.Thumb || graphic.attributes.THUMB_URL || graphic.attributes.Thumb_URL || graphic.attributes[app.thumbnailField];
                    }

                    if(graphic.attributes.Picture || graphic.attributes.PIC_URL || graphic.attributes.pic_url || app.imageField) {
                        dirty = true;
                        json.attributes.pic_url = graphic.attributes.Picture || graphic.attributes.PIC_URL || graphic.attributes.pic_url || graphic.attributes[app.imageField];
                    }

                    if(!json.attributes.thumb_url || json.attributes.thumb_url.length < 1) {
                        json.attributes.thumb_url = "images/item_thumbnail.png"
                    }

                    if(!json.attributes.pic_url || json.attributes.pic_url.length < 1) {
                        json.attributes.pic_url = "images/placeholder.jpg"
                    }

                    if(!json.attributes.name || json.attributes.name.length < 1) {
                        json.attributes.name = ""
                    }

                    if(!json.attributes.description || json.attributes.description.length < 1) {
                        json.attributes.description = ""
                    }

                    json.attributes.is_video = false;

                    if(json.attributes.IS_VIDEO || json.attributes.is_video || json.attributes.pic_url.indexOf("www.youtube.com") > 1 || json.attributes.pic_url.indexOf("vimeo.com") > 1 ) {
                        json.attributes.is_video = true;
                    }

                    if(dirty) {
                        graphic.json = json;
                        //console.log(JSON.stringify(graphic.attributes));
                    }


                    mp.add(graphic.geometry);

                    //printJson(json.attributes.objectid);

                    //tourItemsListModel.append(graphic.attributes);
                    tourItemsListModel.append(json);
                }

                if(tourItemsListModel.count < 1) {
                    tourError("Sorry! No photos in this Tour.");
                } else {
                    tourError(null);
                }

                var extent = mp.queryEnvelope();
                zoomButtons.homeExtent = extent.scale(1.5);
                map.zoomTo(extent.scale(1.5));

            }
        }
    }


    //--------------------------------------------------------------------------
    MultiPoint {
        id: mp
    }

    PictureMarkerSymbol {
        id: defaultSymbol
        image: "images/esri_pin_default.png"
        width: 15
        height: 28
        xOffset: -width / 2
        yOffset: height / 2
    }

    PictureMarkerSymbol {
        id: pmsBlue
        image: "images/esri_pin_blue.png"
        width: 15
        height: 28
        xOffset: -width / 2
        yOffset: height / 2
    }

    PictureMarkerSymbol {
        id: pmsGreen
        image: "images/esri_pin_green.png"
        width: 15
        height: 28
        xOffset: -width / 2
        yOffset: height / 2
    }

    PictureMarkerSymbol {
        id: pmsPurple
        image: "images/esri_pin_purple.png"
        width: 15
        height: 28
        xOffset: -width / 2
        yOffset: height / 2
    }

    PictureMarkerSymbol {
        id: pmsRed
        image: "images/esri_pin_red.png"
        width: 15
        height: 28
        xOffset: -width / 2
        yOffset: height / 2
    }

    UniqueValueRenderer {
        id: uvRenderer
        attributeNames: "icon_color"
        defaultSymbol: defaultSymbol
        defaultLabel: "default"
    }

    UniqueValueInfo {
        id: uvInfoRed
        label: "Red"
        symbol: pmsRed
        value: ["R"]
    }

    UniqueValueInfo {
        id: uvInfoRed2
        label: "Red"
        symbol: pmsRed
        value: ["r"]
    }

    UniqueValueInfo {
        id: uvInfoBlue
        label: "Blue"
        symbol: pmsBlue
        value: ["B"]
    }

    UniqueValueInfo {
        id: uvInfoBlue2
        label: "Blue"
        symbol: pmsBlue
        value: ["b"]
    }

    UniqueValueInfo {
        id: uvInfoGreen
        label: "Green"
        symbol: pmsGreen
        value: ["G"]
    }

    UniqueValueInfo {
        id: uvInfoGreen2
        label: "Green"
        symbol: pmsGreen
        value: ["g"]
    }

    UniqueValueInfo {
        id: uvInfoPurple
        label: "Purple"
        symbol: pmsPurple
        value: ["P"]
    }

    UniqueValueInfo {
        id: uvInfoPurple2
        label: "Purple"
        symbol: pmsPurple
        value: ["p"]
    }

    TextSymbol {
        id: textSymbol
        textColor: "white"
        size: 30
        text: ""
    }

    Graphic {
        id: textGraphic
        symbol: textSymbol
    }

    //-------------

    function truncate(name, max) {

        return name.length > max ? (name.slice(0, max-3)+"...") : name;
    }

    function printJsonFromObject(object) {
        console.log("###PrintJsonFromObject:: ", JSON.stringify(object.json));
        console.log();
    }

    function printJson(json) {
        console.log("###PrintJson:: ", JSON.stringify(json));
        console.log();
    }

    function getCurrentItemIndex(objectid) {
        for(var i = 0; i < featureListModel.count; ++i) {
            var item = featureListModel.get(i);
            printJson(item)
            if (item.objectid == objectid)
                return i;
        }
        return -1;
    }

    function getColorName(colorCode)
    {
        var colorName = "unknown";
        if(colorCode) {
            switch(colorCode.toLowerCase())
            {
            case "r" : colorName = "red"; break;
            case "g" : colorName = "green"; break;
            case "b" : colorName = "blue"; break;
            case "p" : colorName = "purple"; break;
            }
        }

        //console.log("got color: ", colorCode , colorName);
        return colorName;
    }


}
