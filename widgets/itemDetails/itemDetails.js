/*global define,dojo,alert,esri,dojoConfig */
/*jslint browser:true,sloppy:true,nomen:true,unparam:true,plusplus:true,indent:4 */
/*
 | Copyright 2014 Esri
 |
 | Licensed under the Apache License, Version 2.0 (the "License");
 | you may not use this file except in compliance with the License.
 | You may obtain a copy of the License at
 |
 |    http://www.apache.org/licenses/LICENSE-2.0
 |
 | Unless required by applicable law or agreed to in writing, software
 | distributed under the License is distributed on an "AS IS" BASIS,
 | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 | See the License for the specific language governing permissions and
 | limitations under the License.
 */
//============================================================================================================================//
define([
    "dojo/_base/declare",
    "dojo/dom-construct",
    "dojo/_base/lang",
    "dojo/_base/array",
    "dojo/dom-attr",
    "dojo/dom",
    "dojo/text!./templates/itemDetails.html",
    "dojo/i18n!nls/localizedStrings",
    "dojo/query",
    "dojo/dom-class",
    "dojo/on",
    "dojo/Deferred",
    "dojo/promise/all",
    "dojo/topic",
    "esri/arcgis/utils",
    "esri/dijit/Legend",
    "esri/map",
    "widgets/geoLocation/geoLocation",
    "widgets/baseMapGallery/baseMapGallery",
    "esri/layers/ArcGISImageServiceLayer",
    "esri/layers/ArcGISTiledMapServiceLayer",
    "esri/layers/ArcGISDynamicMapServiceLayer",
    "esri/layers/ImageParameters",
    "esri/layers/FeatureLayer",
    "esri/layers/KMLLayer",
    "esri/layers/WMSLayer",
    "esri/layers/OpenStreetMapLayer",
    "esri/layers/ImageServiceParameters",
    "esri/layers/VectorTileLayer",
    "esri/tasks/GeometryService",
    "esri/geometry/Extent",
    "esri/layers/GraphicsLayer",
    "esri/dijit/HomeButton",
    "dojo/dom-style",
    "dojo/dom-geometry",
    "esri/request",
    "esri/arcgis/utils",
    "esri/dijit/OverviewMap",
    "esri/dijit/BasemapGallery",
    "./itemDetailsHelper"
], function (declare, domConstruct, lang, array, domAttr, dom, template, nls, query, domClass, on, Deferred, all, topic, utils, Legend, Map, GeoLocation, BasemapGallery, ArcGISImageServiceLayer, ArcGISTiledMapServiceLayer, ArcGISDynamicMapServiceLayer, ImageParameters, FeatureLayer, KMLLayer, WMSLayer, OpenStreetMapLayer, ImageServiceParameters, VectorTileLayer, GeometryService, Extent, GraphicsLayer, HomeButton, domStyle, domGeom, esriRequest, arcgisUtils, OverviewMap, ArcGISBasemapGallery, itemDetailsHelper) {

    return declare([itemDetailsHelper], {
        templateString: template,
        nls: nls,
        basemapLayer: null,
        lastSearchString: null,
        stagedSearch: null,
        mapPoint: null,
        map: null,
        mapExtent: null,
        searchPortalURL: null,
        tempGraphicsLayerId: "esriGraphicsLayerMapSettings",
        /**
        *@class
        *@name  widgets/itemDetails/itemDetails
        */
        startup: function () {
            var basemapDeferred, applicationHeaderDiv;
            domClass.add(query(".esriCTGalleryContent")[0], "displayNoneAll");
            domClass.replace(query(".esriCTApplicationIcon")[0], "esriCTCursorPointer", "esriCTCursorDefault");
            domClass.replace(query(".esriCTMenuTabLeft")[0], "esriCTCursorPointer", "esriCTCursorDefault");
            applicationHeaderDiv = dom.byId("esriCTParentDivContainer");
            domClass.replace(query(".esriCTMenuTabRight")[0], "displayNoneAll", "displayBlockAll");
            // If item has thumbnail image, display it else display no thumbnail image
            if (this.data.thumbnailUrl && this.data.thumbnailUrl !== 'null') {
                domStyle.set(this.itemIcon, "background", 'url(' + this.data.thumbnailUrl + ') no-repeat center center');
            } else {
                domClass.add(this.itemIcon, "esriCTNoThumbnailImage");
            }
            domConstruct.place(this.itemDetailsLeftPanel, applicationHeaderDiv);
            domAttr.set(this.itemTitle, "innerHTML", this.data.title || "");
            domAttr.set(this.spanItemTitleText, "innerHTML", this.data.title || "");
            if (!dojo.configData.values.baseMapLayers) {
                topic.subscribe("filterRedundantBasemap", lang.hitch(this, function (bmLayers) {
                    this._filterRedundantBasemap(bmLayers, dojo.configData.values.baseMapLayers, true);
                }));
                basemapDeferred = new Deferred();
                this._fetchBasemapCollection(basemapDeferred);
                basemapDeferred.then(lang.hitch(this, function (baseMapLayers) {
                    dojo.configData.values.baseMapLayers = baseMapLayers;
                    this._createMapLayers(this.data);
                }));
            } else {
                this._createMapLayers(this.data);
            }

            domAttr.set(this.txtAddressSearch, "defaultAddress", dojo.configData.values.locatorDefaultAddress);
            domAttr.set(this.txtAddressSearch, "value", domAttr.get(this.txtAddressSearch, "defaultAddress"));
            this.own(on(this.divLegendLayer, "click", lang.hitch(this, function () {
                this._slideLegendsPanel();
            })));

            // Handle click of 'back to map' icon
            this.own(on(this.divBackToMap, "click", lang.hitch(this, function () {
                this._slideLegendsPanel();
            })));

            // Handle click of legend tab in left panel
            this.own(on(this.legendTab, "click", lang.hitch(this, function () {
                this._switchTabs(this.legendTab, this.infoTab, this.legendDetails, this.layerDescription);
            })));

            // Handle click of info tab in left panel
            this.own(on(this.infoTab, "click", lang.hitch(this, function () {
                this._switchTabs(this.infoTab, this.legendTab, this.layerDescription, this.legendDetails);
            })));

            //display gallery view on clicking of back button
            this.own(on(this.backToGalleryBtn, "click", lang.hitch(this, function () {
                topic.publish("backToGalleryView");
            })));

            //display gallery view on clicking of back button
            this.own(on(this.backToGallery, "click", lang.hitch(this, function () {
                topic.publish("backToGalleryView");
            })));

            // Handle window resize
            on(window, "resize", lang.hitch(this, function () {
                if (query(".esriRightControlPanelLegend")[0]) {
                    var titleWidth = domGeom.position(query(".esriRightControlPanelLegend")[0]).w - (domGeom.position(this.divBackToMapContainer).w + 50) + "px";
                    domStyle.set(this.spanItemTitleText, "width", titleWidth);
                }
                setTimeout(lang.hitch(this, function () {
                    if (query(".esriCTLegendContainer")[0]) {
                        var legendContainerHeight, infoLegendContainerHeight;
                        legendContainerHeight = dojo.window.getBox().h - (domGeom.position(query(".esriCTRightControlPanel")[0]).h + 70) + "px";
                        infoLegendContainerHeight = dojo.window.getBox().h - (domGeom.position(query(".labelLegendTab")[0]).h + domGeom.position(query(".esriCTInnerLeftPanelTopMap")[0]).h + 90) + "px";
                        if (query(".esriMapGeoInfo")[0]) {
                            if (domStyle.get(query(".esriMapGeoInfo")[0], "display") === "block") {
                                domStyle.set(query(".esriCTLegendContainer")[0], "height", legendContainerHeight);
                            } else {
                                domStyle.set(query(".esriCTLegendContainer")[0], "height", infoLegendContainerHeight);
                            }
                        } else if (query(".esriCTBackToMapBtn")[0]) {
                            if (domStyle.get(query(".esriCTBackToMapBtn")[0], "display") === "block") {
                                domStyle.set(query(".esriCTLegendContainer")[0], "height", legendContainerHeight);
                            } else {
                                domStyle.set(query(".esriCTLegendContainer")[0], "height", infoLegendContainerHeight);
                            }
                        }
                    }
                }), 100);
            }));
            /**
            * if showMapSearch flag is set to true in config file then show textbox for map search or hide the textbox
            */
            if (dojo.configData.values.showMapSearch) {
                this.attachLocatorEvents();
            } else {
                domStyle.set(query(".esriCTMapInput")[0], "display", "none");
            }
        },

        /**
        * Check if basemap group is configured or not in the configuration file, if not configured display AGOL BasemapGallery widget
        * @memberOf widgets/itemDetails/itemDetails
        */

        _fetchBasemapCollection: function (basemapDeferred) {
            var groupUrl, deferred, agolBasemapsCollection, baseMapArray = [], tokenString, groupRequest;
            /**
            * If group owner & title are configured, create request to fetch the group id
            */
            if (dojo.configData.values.token) {
                tokenString = "&token=" + dojo.configData.values.token;
            } else {
                tokenString = '';
            }
            // Query basemap group
            if (dojo.configData.values.basemapGroupTitle && dojo.configData.values.basemapGroupOwner) {
                groupUrl = dojo.configData.values.portalURL + "/sharing/rest/community/groups?q=title:\"" + dojo.configData.values.basemapGroupTitle + "\" AND owner:" + dojo.configData.values.basemapGroupOwner + "&f=json";
                groupRequest = esriRequest({
                    url: groupUrl,
                    callbackParamName: "callback"
                });
                groupRequest.then(lang.hitch(this, function (groupInfo) {
                    // If basemap group is not present in the portal or the group is invalid, query org basemap group
                    if (groupInfo.results.length === 0) {
                        this._queryOrgBasemapGroup(tokenString, basemapDeferred);
                    } else {
                        // If results are found for the configured basemap group, fetch basemap group details
                        this.searchPortalURL = dojo.configData.values.portalURL;
                        this._fetchBasemapDetails(basemapDeferred, groupInfo);
                    }
                }), function (err) {
                    alert(err.message);
                });
            } else if (!dojo.privateBaseMapGroup) {
                /**
                * If group owner & title are not configured, fetch the basemap collections from AGOL using BasemapGallery widget
                */
                agolBasemapsCollection = new ArcGISBasemapGallery({
                    showArcGISBasemaps: true
                });
                this.searchPortalURL = "http://www.arcgis.com";
                on(agolBasemapsCollection, "load", lang.hitch(this, function () {
                    /**
                    * onLoad, loop through each basemaps in the basemap gallery and push it into "baseMapArray"
                    */
                    deferred = new Deferred();
                    this._fetchBasemapFromGallery(agolBasemapsCollection, baseMapArray, deferred);
                    deferred.then(function () {
                        basemapDeferred.resolve(baseMapArray);
                    });
                }));
            } else if (dojo.privateBaseMapGroup) {
                //If group owner & title are not configured and user is signed in to view the private items, create request to fetch basemap layers
                this._queryOrgBasemapGroup(tokenString, basemapDeferred);
            }
        },

        /**
        * If basemap group owner & title are not configured, query org basemap group to fetch basemap layers
        * @memberOf widgets/itemDetails/itemDetails
        */
        _queryOrgBasemapGroup: function (tokenString, basemapDeferred) {
            var groupUrl = dojo.configData.values.portalURL + "/sharing/rest/community/groups?q=" + dojo.BaseMapGroupQuery + "&f=json" + tokenString;
            this.searchPortalURL = dojo.configData.values.portalURL;
            this._fetchBaseMapLayers(groupUrl, basemapDeferred);
        },

        /**
        * Check if items are present or not in the basemap group
        * @memberOf widgets/itemDetails/itemDetails
        */
        _fetchBaseMapLayers: function (groupUrl, basemapDeferred) {
            var groupRequest;
            groupRequest = esriRequest({
                url: groupUrl,
                callbackParamName: "callback"
            });
            groupRequest.then(lang.hitch(this, function (groupInfo) {
                if (groupInfo.results.length === 0) {
                    alert(nls.errorMessages.invalidBasemapQuery);
                    topic.publish("hideProgressIndicator");
                    return;
                }
                this._fetchBasemapDetails(basemapDeferred, groupInfo);
            }), function (err) {
                alert(err.message);
            });
        },

        /**
        * Fetch items from basemap group
        * @memberOf widgets/itemDetails/itemDetails
        */
        _fetchBasemapDetails: function (basemapDeferred, groupInfo) {
            var deferred, webmapRequest, thumbnailSrc, basemapId, searchUrl, deferredArray = [], baseMapArray = [];
            /**
            * Create request using group id to fetch all the items from that group
            */
            searchUrl = this.searchPortalURL + '/sharing/rest/search?q=group:' + groupInfo.results[0].id + "&sortField=name&sortOrder=desc&num=50&f=json";
            webmapRequest = esriRequest({
                url: searchUrl,
                callbackParamName: "callback"
            });
            webmapRequest.then(lang.hitch(this, function (groupInfo) {
                /**
                * Loop for each item in the group
                */
                array.forEach(groupInfo.results, lang.hitch(this, function (info, index) {
                    /**
                    * If type is "Map Service", create the object and push it into "baseMapArray"
                    */
                    if (info.type === "Map Service") {
                        thumbnailSrc = (groupInfo.results[index].thumbnail === null) ? dojo.configData.values.noThumbnail : dojo.configData.values.portalURL + "/sharing/rest/content/items/" + info.id + "/info/" + info.thumbnail;
                        basemapId = groupInfo.results[index].name || groupInfo.results[index].id;
                        baseMapArray.push({
                            BasemapId: basemapId,
                            ThumbnailSource: thumbnailSrc,
                            Name: info.title,
                            MapURL: info.url
                        });
                        /**
                        * If type is "Web Map", create requests to fetch all the items of the webmap (asynchronous request)
                        */
                    } else if (info.type === "Web Map") {
                        var mapDeferred = arcgisUtils.getItem(info.id);
                        mapDeferred.then(lang.hitch(this, function () {
                            deferred = new Deferred();
                            deferred.resolve();
                        }));
                        deferredArray.push(mapDeferred);
                    } if (info.type === "Vector Tile Service") {
                        //if item is vector tile layer
                        thumbnailSrc = (groupInfo.results[index].thumbnail === null) ? dojo.configData.values.noThumbnail : dojo.configData.values.portalURL + "/sharing/rest/content/items/" + info.id + "/info/" + info.thumbnail;
                        basemapId = groupInfo.results[index].name || groupInfo.results[index].id;
                        info.layerUrl = dojo.configData.values.portalURL + "/sharing/content/items/" + info.id + "/resources/styles/root.json";
                        baseMapArray.push({
                            BasemapId: basemapId,
                            ThumbnailSource: thumbnailSrc,
                            Name: info.title,
                            MapURL: info.layerUrl,
                            layerType: "VectorTileLayer"
                        });
                        /**
                        * If type is "Web Map", create requests to fetch all the items of the webmap (asynchronous request)
                        */
                    }
                }));
                if (deferredArray.length > 0) {
                    all(deferredArray).then(lang.hitch(this, function (res) {
                        /**
                        *If result of webmaps are empty
                        */
                        if (res.length === 0) {
                            basemapDeferred.resolve(baseMapArray);
                            return;
                        }
                        /**
                        * Else for each items in the webmap, create the object and push it into "baseMapArray"
                        */
                        array.forEach(res, lang.hitch(this, function (data) {
                            this._filterRedundantBasemap(data, baseMapArray, false);
                        }));
                        basemapDeferred.resolve(baseMapArray);
                    }));
                } else {
                    basemapDeferred.resolve(baseMapArray);
                }
            }), function (err) {
                alert(err.message);
            });
        },

        /**
        * remove basemap which is added by earlier selected webmap
        * @memberOf coreLibrary/widgetLoader
        */
        _removeItemBasemap: function () {
            var i, temBaseMapArray = [], baseMapArray = dojo.configData.values.baseMapLayers;
            for (i = 0; i < baseMapArray.length; i++) {
                if (baseMapArray[i].length) {
                    if (!baseMapArray[i][0].isItemBasemap) {
                        temBaseMapArray.push(baseMapArray[i]);
                    }
                } else {
                    if (!baseMapArray[i].isItemBasemap) {
                        temBaseMapArray.push(baseMapArray[i]);
                    }
                }
            }
            dojo.configData.values.baseMapLayers = temBaseMapArray;
        },

        /**
        *If basemap layer is already present in the "baseMapArray", skip it
        * @memberOf coreLibrary/widgetLoader
        */
        _filterRedundantBasemap: function (bmLayers, baseMapArray, isItemBasemap) {
            var i, bmLayerData, multiBasemap = [];
            if (bmLayers.itemData.baseMap) {
                if (bmLayers.itemData.baseMap.baseMapLayers) {
                    bmLayerData = bmLayers.itemData.baseMap.baseMapLayers;
                } else {
                    bmLayerData = [];
                    bmLayerData.push(bmLayers);
                }
                //check if basemap is an open street map
                if (bmLayerData[0].layerType === "OpenStreetMap" || bmLayerData[0].type === "OpenStreetMap") {
                    if (!bmLayerData[0].id) {
                        //set default id for basemap
                        bmLayerData[0].id = "defaultBasemapId";
                    }
                    bmLayerData[0].url = bmLayerData[0].id;
                } else if ((bmLayerData[0].type === "VectorTileLayer") || (bmLayerData[0].layerType === "VectorTileLayer")) {
                    bmLayerData[0].url = bmLayerData[0].styleUrl;
                }
                if (this._isUniqueBasemap(baseMapArray, bmLayerData)) {
                    if (bmLayerData[0].visibility || isItemBasemap) {
                        dojo.selectedBasemapIndex = baseMapArray.length;
                    }
                    if (bmLayerData.length === 1) {
                        this._setBasemapAttribute(baseMapArray, bmLayerData[0], bmLayers, isItemBasemap);
                    } else if (bmLayerData.length > 1) {
                        for (i = 0; i < bmLayerData.length; i++) {
                            this._setBasemapAttribute(multiBasemap, bmLayerData[i], bmLayers, isItemBasemap);
                        }
                        baseMapArray.push(multiBasemap);
                    }
                }
            }
        },

        /**
        * set required basemap attribute
        * @memberOf coreLibrary/widgetLoader
        */
        _setBasemapAttribute: function (baseMapArray, bmLayerData, bmLayers, isItemBasemap) {
            bmLayerData.isItemBasemap = isItemBasemap;
            bmLayerData.basemapId = bmLayerData.id;
            bmLayerData.id = bmLayers.item.id;
            bmLayerData.thumbnail = bmLayers.item.thumbnail;
            bmLayerData.title = bmLayers.itemData.baseMap.title;
            this._storeUniqueBasemap(bmLayerData, baseMapArray);
        },

        /**
        * check new basemap exists in basemap array or not
        * @memberOf coreLibrary/widgetLoader
        */
        _isUniqueBasemap: function (baseMapArray, bmLayerData) {
            var i, j, k, pushBasemap = true, count = 1;
            for (i = 0; i < baseMapArray.length; i++) {
                if (!baseMapArray[i].length) {
                    if (bmLayerData[0].url === baseMapArray[i].MapURL) {
                        if (bmLayerData.length > 1) {
                            pushBasemap = true;
                        } else {
                            pushBasemap = false;
                        }
                        if (bmLayerData[0].visibility) {
                            dojo.selectedBasemapIndex = i;
                        }
                        break;
                    }
                } else {
                    for (j = 0; j < baseMapArray[i].length; j++) {
                        if (bmLayerData[0].url === baseMapArray[i][j].MapURL) {
                            for (k = 1; k < bmLayerData.length; k++) {
                                if (bmLayerData[k].url === baseMapArray[i][j].MapURL) {
                                    count++;
                                }
                            }
                            if (bmLayerData[0].visibility) {
                                dojo.selectedBasemapIndex = i;
                            }
                            break;
                        }
                    }
                    if (i === baseMapArray.length - 1) {
                        if (count === baseMapArray[i].length) {
                            pushBasemap = false;
                        } else {
                            pushBasemap = true;
                        }
                    }
                }
            }
            return pushBasemap;
        },

        /**
        * store unique base map
        * @memberOf coreLibrary/widgetLoader
        */
        _storeUniqueBasemap: function (bmLayer, baseMapArray) {
            var thumbnailSrc, layerType, tokenString;
            if (bmLayer.url || (bmLayer.layerType === "OpenStreetMap" || bmLayer.type === "OpenStreetMap")) {
                if (dojo.configData.values.token) {
                    tokenString = "?token=" + dojo.configData.values.token;
                } else {
                    tokenString = '';
                }
                thumbnailSrc = (bmLayer.thumbnail === null) ? dojo.configData.values.noThumbnail : (this.searchPortalURL + "/sharing/rest/content/items/" + bmLayer.id + "/info/" + bmLayer.thumbnail + tokenString);
                if (bmLayer.layerType) {
                    layerType = bmLayer.layerType;
                } else {
                    layerType = bmLayer.type;
                }
                baseMapArray.push({
                    BasemapId: bmLayer.basemapId,
                    ThumbnailSource: thumbnailSrc,
                    Name: bmLayer.title,
                    MapURL: bmLayer.url,
                    isItemBasemap: bmLayer.isItemBasemap,
                    layerType: layerType
                });
            }
        },

        /**
        * get basemap from basemap gallery
        * @memberOf coreLibrary/widgetLoader
        */
        _fetchBasemapFromGallery: function (agolBasemapsCollection, baseMapArray, basemapDeferred) {
            var deferred, deferredArray = [];
            array.forEach(agolBasemapsCollection.basemaps, lang.hitch(this, function (basemap) {
                var basemapRequest, basemapLayersArray = [], basemapId, layerType;
                basemapRequest = basemap.getLayers();
                basemapRequest.then(lang.hitch(this, function () {
                    //If array contains only single layer object, push it into "baseMapArray"
                    if (basemap.layers.length === 1) {
                        basemapId = basemap.id || "defaultBasemapId";
                        layerType = basemap.layers[0].type || basemap.layers[0].layerType;
                        baseMapArray.push({
                            BasemapId: basemapId,
                            ThumbnailSource: basemap.thumbnailUrl,
                            Name: basemap.title,
                            MapURL: basemap.layers[0].url,
                            layerType: layerType
                        });
                    } else {
                        array.forEach(basemap.layers, lang.hitch(this, function (basemapLayers, index) {
                            basemapId = basemap.id + index;
                            layerType = basemapLayers.type || basemapLayers.layerType;
                            basemapLayersArray.push({
                                BasemapId: basemapId,
                                ThumbnailSource: basemap.thumbnailUrl,
                                Name: basemap.title,
                                MapURL: basemapLayers.url,
                                layerType: layerType
                            });
                        }));
                        baseMapArray.push(basemapLayersArray);
                    }
                    /** If array contains more than one layer object, loop through each layer, create object for each one of them
                    and push it into "basemapLayersArray", finally push "basemapLayersArray" into "baseMapArray" */

                    deferred = new Deferred();
                    deferred.resolve();
                }));
                deferredArray.push(basemapRequest);
            }));
            all(deferredArray).then(function () {
                basemapDeferred.resolve(baseMapArray);
            });
        },


        /**
        * Add and remove classes on switching tabs in tab container
        * @memberOf widgets/itemDetails/itemDetails
        */
        _switchTabs: function (selectedTab, firstUnselectedTab, selectedContainer, firstUnselectedContainer) {
            if (!domClass.contains(selectedTab, "select")) {
                domClass.add(selectedTab, "select");
            }
            if (domClass.contains(firstUnselectedTab, "select")) {
                domClass.remove(firstUnselectedTab, "select");
            }
            domClass.replace(selectedContainer, "displayBlockAll", "displayNoneAll");
            domClass.replace(firstUnselectedContainer, "displayNoneAll", "displayBlockAll");
        },

        /**
        * Slides in and out the legends panel on the right upon clicking the info icon. Only for smart phone devices.
        * @memberOf widgets/itemDetails/itemDetails
        */
        _slideLegendsPanel: function () {
            var titleWidth;
            if (query(".esriCTRightControlPanel")[0]) {
                domClass.toggle(query(".esriCTBackToMapPosition")[0], "displayNoneAll");
            }
            if (domClass.contains(query(".esriCTRightControlPanel")[0], "esriRightControlPanelMap")) {
                domClass.replace(query(".esriCTRightControlPanel")[0], "esriRightControlPanelLegend", "esriRightControlPanelMap");
                domClass.replace(query(".esriCTHomeIcon")[0], "displayNone", "displayBlock");
                domClass.replace(query(".esriCTMapInput")[0], "displayNone", "displayBlock");
                domClass.replace(this.divItemTitle, "displayBlockAll", "displayNoneAll");
                titleWidth = domGeom.position(query(".esriRightControlPanelLegend")[0]).w - (domGeom.position(this.divBackToMapContainer).w + 50) + "px";
                domStyle.set(this.spanItemTitleText, "width", titleWidth);
            } else {
                domClass.replace(query(".esriCTRightControlPanel")[0], "esriRightControlPanelMap", "esriRightControlPanelLegend");
                domClass.replace(query(".esriCTHomeIcon")[0], "displayBlock", "displayNone");
                domClass.replace(query(".esriCTMapInput")[0], "displayBlock", "displayNone");
                domClass.replace(this.divItemTitle, "displayNoneAll", "displayBlockAll");
            }
            if (domClass.contains(query(".esriCTLegendTab")[0], "esriCTLegendTabMargin")) {
                domClass.replace(query(".esriCTLegendTab")[0], "esriCTLegendTabToggle", "esriCTLegendTabMargin");
            } else {
                domClass.add(query(".esriCTLegendTab")[0], "esriCTLegendTabMargin", "esriCTLegendTabToggle");
            }
            if (query(".esriCTRightPanelMap")[0]) {
                domClass.toggle(query(".esriCTRightPanelMap")[0], "esriCTShiftLeft");
            }
            if (query(".esriCTMenuTabLeft")[0]) {
                if (domClass.contains(query(".esriCTMenuTabLeft")[0], "displayBlock")) {
                    domClass.replace(query(".esriCTMenuTabLeft")[0], "displayNone", "displayBlock");
                } else {
                    domClass.replace(query(".esriCTMenuTabLeft")[0], "displayBlock", "displayNone");
                }
            }
            if (query(".esriCTLegendTab")[0]) {
                domClass.toggle(query(".esriCTLegendTab")[0], "displayBlock");
                domClass.toggle(query(".esriCTRightPanelMap")[0], "esriCTMapPanelShift");
                if (domClass.contains(query(".esriCTMapInfoIcon")[0], "esriMapGeoInfo")) {
                    this.mapExtent = this.map.extent;
                    domClass.remove(query(".esriCTMapInfoIcon")[0], "esriMapGeoInfo icon-info-circled-alt");
                } else {
                    domClass.add(query(".esriCTMapInfoIcon")[0], "esriMapGeoInfo icon-info-circled-alt");
                    setTimeout(lang.hitch(this, function () {
                        if (this.map) {
                            this.map.resize();
                            this.map.reposition();
                        }
                    }), 100);
                    setTimeout(lang.hitch(this, function () {
                        this.map.setExtent(this.mapExtent);
                    }), 500);
                }
                if (query(".esriCTMapGeoLocation")[0]) {
                    domClass.toggle(query(".esriCTMapGeoLocation")[0], "displayNone");
                }
            }
            if (this.map && this.map.extent) {
                this.map.setExtent(this.map.extent);
            }
        },

        /**
        * Add full screen functionality.
        * @memberOf widgets/itemDetails/itemDetails
        */
        _toggleFullScreen: function () {
            var element, requestMethod, wscript;

            element = document.documentElement;
            // Supports most browsers and their versions.
            requestMethod = element.requestFullScreen || element.webkitRequestFullScreen || element.mozRequestFullScreen || element.msRequestFullScreen;
            try {
                if (requestMethod) { // Native full screen.
                    requestMethod.call(element);
                } else if (window.ActiveXObject !== undefined) {
                    wscript = new window.ActiveXObject("WScript.shell");
                    wscript.SendKeys("{F11}");
                } else {
                    alert(nls.errorMessages.noFullScreenSupport);
                }
            } catch (ex) {
                alert(nls.errorMessages.noFullScreenSupport);
            }
        },

        /**
        * Identify different item types
        * @memberOf widgets/itemDetails/itemDetails
        */
        _createMapLayers: function (data) {
            var mapId = data.id, _self = this, dataType, layerType, url1, mapServiceLayerType;
            this._removeItemBasemap();
            if (mapId) {
                if (data) {
                    dataType = data.type.toLowerCase();
                    // If item is of type 'kml', 'wms', 'feature service', 'map service' and 'image service', create map object
                    // If item is of type 'web map, fetch web map data
                    if (dataType === "kml") {
                        this.addLayerToMap(mapId, data.url, data.title, dataType);
                    } else if (dataType === "web map") {
                        this.addWebMap(mapId);
                    } else if (dataType === "feature service") {
                        layerType = data.url.substring(((data.url.lastIndexOf("/")) + 1), (data.url.length));
                        if (!isNaN(layerType)) {
                            this.addLayerToMap(mapId, data.url, data.title, dataType);
                        } else {
                            url1 = data.url + "?f=json";
                            esriRequest({
                                url: url1,
                                handleAs: "json",
                                load: function (jsondata) {
                                    if (jsondata.layers.length > 0) {
                                        _self.addLayerToMap(mapId, data.url, data.title, dataType, jsondata.layers);
                                    }
                                },
                                error: function (err) {
                                    alert(err.message);
                                    topic.publish("hideProgressIndicator");
                                }
                            });
                        }
                    } else if (dataType === "map service") {
                        mapServiceLayerType = data.url.substring(((data.url.lastIndexOf("/")) + 1), (data.url.length));
                        if (!isNaN(mapServiceLayerType)) {
                            this.addLayerToMap(mapId, data.url, data.title, "feature service");
                        } else {
                            this.addLayerToMap(mapId, data.url, data.title, dataType);
                        }
                    } else if (dataType === "image service") {
                        this.addLayerToMap(mapId, data.url, data.title, dataType);
                    } else if (dataType === "wms") {
                        this.addLayerToMap(mapId, data.url, data.title, dataType);
                    } else if (dataType === "vector tile service") {
                        this.addLayerToMap(mapId, data.url, data.title, dataType);
                    }
                    this._createItemDescriptionContent(data);
                }
            }
        },

        /**
        * Create legend
        * @memberOf widgets/itemDetails/itemDetails
        */
        createLegend: function (layerObj, itemMap, legendDiv) {
            var legendContainerHeight, infoLegendContainerHeight, legendDijit;
            // Set legend container height
            legendContainerHeight = dojo.window.getBox().h - (domGeom.position(query(".esriCTRightControlPanel")[0]).h + 70) + "px";
            infoLegendContainerHeight = dojo.window.getBox().h - (domGeom.position(query(".labelLegendTab")[0]).h + domGeom.position(query(".esriCTInnerLeftPanelTopMap")[0]).h + 90) + "px";
            if (query(".esriMapGeoInfo")[0]) {
                if (domStyle.get(query(".esriMapGeoInfo")[0], "display") === "block") {
                    domStyle.set(query(".esriCTLegendContainer")[0], "height", legendContainerHeight);
                } else {
                    domStyle.set(query(".esriCTLegendContainer")[0], "height", infoLegendContainerHeight);
                }
            }
            legendDijit = new Legend({
                map: itemMap,
                layerInfos: layerObj
            }, legendDiv);
            legendDijit.startup();
        },

        /**
        * Fetch data from webmap
        * @memberOf widgets/itemDetails/itemDetails
        */
        addWebMap: function (mapId) {
            topic.publish("showProgressIndicator");
            utils.createMap(mapId, this.itemMap, {
                mapOptions: {
                    showAttribution: dojo.configData.values.showAttribution,
                    slider: true
                },
                geometryServiceURL: dojo.configData.values.geometryService
            }).then(lang.hitch(this, function (response) {
                var i, layerInfo, graphicsLayer, home, geoLocation, basemapGallery;

                layerInfo = utils.getLegendLayers(response);
                this.map = response.map;
                dojo.selectedBasemapIndex = null;
                topic.publish("filterRedundantBasemap", response.itemInfo);
                graphicsLayer = new GraphicsLayer();
                graphicsLayer.id = this.tempGraphicsLayerId;
                this.map.addLayer(graphicsLayer);
                this.createLegend(layerInfo, response.map, this.legendDiv);
                home = this._addHomeButton();
                domConstruct.place(home.domNode, query(".esriSimpleSliderIncrementButton")[0], "after");
                home.startup();

                // If basemap group contains basemaps and showBasemapGallery flag is set to true in the config file, show basemap switcher
                if (dojo.configData.values.baseMapLayers.length > 1) {
                    if (dojo.configData.values.showBasemapGallery) {
                        basemapGallery = new BasemapGallery({
                            map: this.map,
                            isWebmap: true
                        }, domConstruct.create("div", {}, null));
                        basemapGallery.startup();
                    }
                }
                // If showOverviewMap flag is set to true in the configuration file, display oveview map
                if (dojo.configData.values.showOverviewMap) {
                    //add overview map
                    this._addOverviewMap(this.map);
                }
                // Initialize geolocation widget
                geoLocation = new GeoLocation({
                    map: response.map,
                    basemap: response.itemInfo.itemData.baseMap.baseMapLayers[0].id,
                    graphicsLayer: graphicsLayer
                });
                geoLocation.startup();
                // If errors are found while displaying the webmap, show error messages
                if (response.errors.length > 0) {
                    for (i = 0; i < response.errors.length; i++) {
                        alert(response.errors[i].message);
                    }
                }
                topic.publish("hideProgressIndicator");
            }), function (err) {
                alert(err.message);
                topic.publish("hideProgressIndicator");
            });
        },

        /**
        * Create map object for items of type "feature service","map service","image service","kml" and "wms".
        * @memberOf widgets/itemDetails/itemDetails
        */
        addLayerToMap: function (mapId, url, title, type, layers) {
            var home, basemapGallery;
            dojo.selectedBasemapIndex = null;
            topic.publish("showProgressIndicator");
            // If no basemap layers found in basemap group, show error message
            if (dojo.configData.values.baseMapLayers.length === 0) {
                alert(nls.errorMessages.invalidBasemapQuery);
                topic.publish("hideProgressIndicator");
                return;
            }

            this.map = new Map(this.itemMap, {
                zoom: 2,
                showAttribution: dojo.configData.values.showAttribution,
                autoResize: true
            });
            home = this._addHomeButton();
            this.map.on("load", lang.hitch(this, function () {
                var graphicsLayer, geolocation, layerInfo = [], layerURL, j, flag;

                domConstruct.place(home.domNode, query(".esriSimpleSliderIncrementButton")[0], "after");
                home.startup();
                if (dojo.configData.values.showOverviewMap) {
                    /**add overview map
                    */
                    this._addOverviewMap(this.map);
                }
                /**add graphics layer
                */
                graphicsLayer = new GraphicsLayer();
                graphicsLayer.id = this.tempGraphicsLayerId;
                this.map.addLayer(graphicsLayer);

                geolocation = new GeoLocation({
                    map: this.map,
                    graphicsLayer: graphicsLayer
                });
                geolocation.startup();
                if (type === "kml") {
                    this._addKMLLayer(this.map, mapId, url, title);
                } else if (type === "feature service") {
                    if (layers) {
                        for (j = 0; j < layers.length; j++) {
                            layerURL = url + "/" + layers[j].id;
                            if (j === layers.length - 1) {
                                flag = true;
                            } else {
                                flag = false;
                            }
                            this._addFeatureLayer(this.map, layers[j].id, layerURL, layers[j].name, flag, layerInfo);
                        }
                    } else {
                        this._addFeatureLayer(this.map, mapId, url, title, true, layerInfo);
                    }
                } else if (type === "map service") {
                    this._addCachedAndDynamicService(this.map, mapId, url, title);
                } else if (type === "image service") {
                    this._addImageService(this.map, mapId, url, title);
                } else if (type === "wms") {
                    this._addWMSLayer(this.map, url);
                } else if (type === "vector tile service") {
                    this._addVectorTilesLayer(this.map, url);
                }
            }));

            dojo.selectedBasemapIndex = 0;
            // if showBasemapGallery flag is set to true in config file
            if (dojo.configData.values.baseMapLayers.length >= 1) {
                if (dojo.configData.values.showBasemapGallery) {
                    basemapGallery = new BasemapGallery({
                        map: this.map,
                        isWebmap: false
                    }, domConstruct.create("div", {}, null));
                    basemapGallery.startup();
                }
            }
        },

        /**
        * Add overview map
        * @memberOf widgets/itemDetails/itemDetails
        */
        _addOverviewMap: function (map) {
            var overviewMapDijit = new OverviewMap({
                map: map,
                attachTo: "bottom-left",
                visible: true
            });
            overviewMapDijit.startup();
        },

        /**
        * Add KML layer to map
        * @memberOf widgets/itemDetails/itemDetails
        */
        _addKMLLayer: function (map, mapId, url, title) {
            var kml, layerInfo = [];

            kml = new KMLLayer(url);
            kml.id = mapId;
            map.addLayer(kml);
            layerInfo.push({
                layer: kml,
                title: title
            });
            this.createLegend(layerInfo, map, this.legendDiv);
            topic.publish("hideProgressIndicator");
        },

        /**
        * Add WMS layer to map
        * @memberOf widgets/itemDetails/itemDetails
        */
        _addWMSLayer: function (map, url) {
            var wmsLayer;
            wmsLayer = new WMSLayer(url, {
                format: "png"
            });
            map.addLayer(wmsLayer);
            this.own(on(wmsLayer, "load", function () {
                var i, layerInfos = [];

                for (i = 0; i < wmsLayer.layerInfos.length; i++) {
                    layerInfos.push(wmsLayer.layerInfos[i].name);
                }
                wmsLayer.setVisibleLayers([layerInfos]);
                if (wmsLayer.spatialReferences.indexOf(map.spatialReference.wkid) === -1 && wmsLayer.spatialReferences.indexOf(4326) === -1 && wmsLayer.spatialReferences.indexOf(900913) === -1) {
                    alert(nls.errorMessages.wmsSpatialReferenceError);
                }
            }));
            this.own(on(wmsLayer, "error", function (err) {
                alert(err.error);
            }));
            domAttr.set(this.legendDiv, "innerHTML", nls.noLegendText);
            topic.publish("hideProgressIndicator");
        },

        /**
        * add vector layer on map
        * @memberOf widgets/itemDetails/itemDetails
        */
        _addVectorTilesLayer: function (map, url) {
            //The URL referenced in the constructor may point to a style url JSON
            var vectorLayer = new VectorTileLayer(url);
            map.addLayer(vectorLayer);
            topic.publish("hideProgressIndicator");
        },

        /**
        * Add Home button to the esri slider
        * @memberOf widgets/itemDetails/itemDetails
        */
        _addHomeButton: function () {
            this.home = new HomeButton({
                map: this.map
            }, domConstruct.create("div", {}, null));
            return this.home;
        },

        /**
        * Extract the feature layer url
        * @memberOf widgets/itemDetails/itemDetails
        */
        _addFeatureLayer: function (map, id, url, title, flag, layerInfo) {
            var lastIndex, dynamicLayerId, dynamicLayer, dynamicLayerUrl;

            lastIndex = url.lastIndexOf('/');
            dynamicLayerId = url.substr(lastIndex + 1);
            if (isNaN(dynamicLayerId) || dynamicLayerId === "") {
                if (isNaN(dynamicLayerId)) {
                    dynamicLayer = url + "/";
                    this._fetchFeaturelayerDetails(map, dynamicLayer, layerInfo);
                } else if (dynamicLayerId === "") {
                    dynamicLayerUrl = url;
                    this._fetchFeaturelayerDetails(map, dynamicLayerUrl, layerInfo);
                }
            } else {
                this._addFeaturelayerToMap(map, id, url, title, layerInfo, flag);
            }
        },

        /**
        * Fetch the feature layer details
        * @memberOf widgets/itemDetails/itemDetails
        */
        _fetchFeaturelayerDetails: function (map, url, layerInfo) {
            var p;

            esriRequest({
                url: url + "?f=json",
                load: lang.hitch(this, function (data) {
                    var lyr;

                    for (p = 0; p < data.layers.length; p++) {
                        lyr = url + data.layers[p].id;
                        this._addFeaturelayerToMap(map, data.layers[p].name, lyr, data.layers[p].name, layerInfo, false);
                    }
                    this.createLegend(layerInfo, map, this.legendDiv);
                    this._setExtentForLayer(map, url, true);
                }),
                error: function (err) {
                    alert(err.message);
                }
            });
        },

        /**
        * Add feature layer to map
        * @memberOf widgets/itemDetails/itemDetails
        */
        _addFeaturelayerToMap: function (map, layerId, url, title, layerInfo, layerFlag) {
            var layerTitle, featureLayerMap;
            layerTitle = title + layerId;
            featureLayerMap = new FeatureLayer(url, {
                mode: FeatureLayer.MODE_ONDEMAND,
                id: layerTitle,
                outFields: ["*"]
            });
            // Load feature layer
            this.own(on(featureLayerMap, "load", lang.hitch(this, function (currentLayer) {
                if (currentLayer.layer.defaultVisibility) {
                    map.addLayer(featureLayerMap);
                    map.getLayer(featureLayerMap.id).show();
                    layerInfo.push({
                        layer: featureLayerMap,
                        title: title
                    });
                }
            })));
            // On error
            this.own(on(featureLayerMap, "error", function (err) {
                alert(err.error);
            }));

            if (layerFlag) {
                setTimeout(lang.hitch(this, function () {
                    this.createLegend(layerInfo, map, this.legendDiv);
                    this._setExtentForLayer(map, url, false);
                    topic.publish("hideProgressIndicator");
                }), 2000);
            }
            topic.publish("hideProgressIndicator");
        },

        /**
        * Add cached and dynamic map services to map
        * @memberOf widgets/itemDetails/itemDetails
        */
        _addCachedAndDynamicService: function (map, id, url, title) {
            var url1, defObj;

            url1 = url + "?f=json";
            defObj = new Deferred();
            defObj.then(lang.hitch(this, function (data) {
                var mapServiceLayer, imageParameters, layerInfo = [];

                if (data) {
                    if (data.singleFusedMapCache) {
                        mapServiceLayer = new ArcGISTiledMapServiceLayer(url, {
                            id: id
                        });
                    } else {
                        imageParameters = new ImageParameters();
                        mapServiceLayer = new ArcGISDynamicMapServiceLayer(url, {
                            "imageParameters": imageParameters,
                            id: id
                        });
                    }
                    map.addLayer(mapServiceLayer);
                    layerInfo.push({
                        layer: mapServiceLayer,
                        title: title
                    });
                    this.createLegend(layerInfo, map, this.legendDiv);
                    this._setExtentForLayer(map, url, true);
                } else {
                    alert(nls.errorMessages.layerNotFound);
                }
                topic.publish("hideProgressIndicator");
            }), function (err) {
                alert(err.message);
                topic.publish("hideProgressIndicator");
            });
            topic.publish("queryItemInfo", url1, defObj);
        },

        /**
        * Add image services to map
        * @memberOf widgets/itemDetails/itemDetails
        */
        _addImageService: function (map, id, url, title) {
            var params, imageServiceLayer, layerInfo = [];
            params = new ImageServiceParameters();
            params.noData = 0;
            imageServiceLayer = new ArcGISImageServiceLayer(url, {
                imageServiceParameters: params,
                id: id,
                opacity: 0.75
            });
            map.addLayer(imageServiceLayer);
            layerInfo.push({
                layer: imageServiceLayer,
                title: title
            });
            this.createLegend(layerInfo, map, this.legendDiv);
            this._setExtentForLayer(map, url, true);
            topic.publish("hideProgressIndicator");
        },

        /**
        *Store the data to be displayed in the INFO tab of the tab container
        * @memberOf widgets/itemDetails/itemDetails
        */
        _createLayerInfoContent: function (_self, layerInfo) {
            var i, layerContainer;

            layerContainer = domConstruct.create("div", {}, _self.layerDetails);
            for (i = 0; i < layerInfo.length; i++) {
                this.layerContent = domConstruct.create("div", { "class": "esriCTLayerInfo esriCTBreakWord", "innerHTML": layerInfo[i].title }, layerContainer);
                domAttr.set(this.layerContent, "index", i);
                _self.own(on(this.layerContent, "click", this._makeSelectedInfoItemHandler(layerInfo)));
            }
        },

        /**
        * Creates a handler for a click on an info item
        * @memberOf widgets/itemDetails/itemDetails
        */
        _makeSelectedInfoItemHandler: function (layerInfo) {
            return function () {
                var index = domAttr.get(this, "index");
                window.open(layerInfo[index].layer.url);
            };
        },

        /**
        * Store the data to be displayed in the LAYER tab of the tab container
        * @memberOf widgets/itemDetails/itemDetails
        */
        _createItemDescriptionContent: function (data) {
            domAttr.set(this.layerDescription, "innerHTML", (data.description) || (nls.showNullValue));
        },

        /**
        * Create the default extent of the map
        * @memberOf widgets/itemDetails/itemDetails
        */
        _setExtentForLayer: function (map, url, type) {
            var _self = this, url1 = url + "?f=json";

            esriRequest({
                url: url1,
                load: function (data) {
                    var geometryService, layerExtent;

                    geometryService = new GeometryService(dojo.configData.values.geometryService);
                    if (type) {
                        layerExtent = _self._createExtent(data.fullExtent);
                    } else {
                        layerExtent = _self._createExtent(data.extent);
                    }
                    if (layerExtent.spatialReference.wkid === map.spatialReference.wkid) {
                        map.setExtent(layerExtent);
                        _self.home.extent = layerExtent;
                    } else {
                        geometryService.project([layerExtent], map.spatialReference, function (results) {
                            if (results.length) {
                                map.setExtent(results[0]);
                            }
                        }, function (error) {
                            alert(error.message);
                        });
                    }
                },
                error: function (err) {
                    alert(err.message);
                }
            });
        },

        /**
        * Create the extent object
        * @memberOf widgets/itemDetails/itemDetails
        */
        _createExtent: function (ext) {
            var projExtent = new Extent({
                "xmin": ext.xmin,
                "ymin": ext.ymin,
                "xmax": ext.xmax,
                "ymax": ext.ymax,
                "spatialReference": {
                    "wkid": ext.spatialReference.wkid,
                    "wkt": ext.spatialReference.wkt
                }
            });
            return projExtent;
        }
    });
});
