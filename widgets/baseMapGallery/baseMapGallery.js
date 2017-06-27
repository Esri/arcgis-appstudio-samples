/*global define,dojo,esri */
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
    "dojo/_base/array",
    "dojo/_base/lang",
    "dojo/on",
    "dojo/dom",
    "dojo/query",
    "dojo/text!./templates/baseMapGalleryTemplate.html",
    "dijit/_WidgetBase",
    "dijit/_TemplatedMixin",
    "dijit/_WidgetsInTemplateMixin",
    "esri/layers/ArcGISTiledMapServiceLayer",
    "esri/layers/OpenStreetMapLayer",
    "esri/layers/ArcGISDynamicMapServiceLayer",
    "esri/layers/ArcGISImageServiceLayer",
    "esri/layers/ImageParameters",
    "esri/layers/ImageServiceParameters",
    "esri/layers/VectorTileLayer"
], function (declare, domConstruct, array, lang, on, dom, query, template, _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, ArcGISTiledMapServiceLayer, OpenStreetMapLayer, ArcGISDynamicMapServiceLayer, ArcGISImageServiceLayer, ImageParameters, ImageServiceParameters, VectorTileLayer) {

    //========================================================================================================================//

    return declare([_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin], {
        templateString: template,
        enableToggling: false,
        isBasemapLayerRemoved: false,
        /**
        * create baseMapGallery widget
        *
        * @class
        * @name widgets/baseMapGallery/baseMapGallery
        */
        postCreate: function () {
            //add basemap layer if old basemap is removed
            this.map.on("layer-remove", lang.hitch(this, function (layer) {
                if (this.enableToggling && this.isBasemapLayerRemoved) {
                    this.isBasemapLayerRemoved = false;
                    this._addBasemapLayerOnMap();
                }
            }));
            this.map.on("layer-add", lang.hitch(this, function () {
                this.enableToggling = true;
            }));
            //do not display basemap toggle widget if only one basemap is found
            if (dojo.configData.values.baseMapLayers.length > 1) {
                query(".esriCTRightPanelMap")[0].appendChild(this.esriCTDivLayerContainer);
                this.layerList.appendChild(this._createBaseMapElement());
            }
            if (!this.isWebmap) {
                //add default basemap on map if it is not a webmap
                this._addBasemapLayerOnMap();
            }
        },

        /**
        * create UI for basemap toggle widget
        * @memberOf widgets/baseMapGallery/baseMapGallery
        */
        _createBaseMapElement: function () {
            var divContainer, imgThumbnail, thumbnailPath, basemap;
            this.enableToggling = true;
            if (dojo.selectedBasemapIndex === dojo.configData.values.baseMapLayers.length - 1) {
                basemap = dojo.configData.values.baseMapLayers[0];
            } else {
                basemap = dojo.configData.values.baseMapLayers[dojo.selectedBasemapIndex + 1];
            }
            //set basemap thumbnail URL
            if (basemap.length) {
                thumbnailPath = basemap[0].ThumbnailSource;
            } else {
                thumbnailPath = basemap.ThumbnailSource;
            }
            divContainer = domConstruct.create("div", { "class": "esriCTbaseMapContainerNode" });
            imgThumbnail = domConstruct.create("img", { "class": "esriCTBasemapThumbnail", "src": thumbnailPath }, null);
            //attach click event to basemap toggle div
            on(imgThumbnail, "click", lang.hitch(this, function () {
                if (this.enableToggling) {
                    //change basemap index
                    dojo.selectedBasemapIndex++;
                    this._changeBasemapThumbnail();
                }
            }));
            divContainer.appendChild(imgThumbnail);
            return divContainer;
        },

        /**
        * change basemap layer
        * @memberOf widgets/baseMapGallery/baseMapGallery
        */
        _changeBaseMap: function (preLayerIndex) {
            var basemap, basemapLayers;
            basemapLayers = dojo.configData.values.baseMapLayers[preLayerIndex];
            this.enableToggling = false;
            //check if previous basemap has multilayer
            if (basemapLayers.length) {
                array.forEach(basemapLayers, lang.hitch(this, function (layer, index) {
                    basemap = this.map.getLayer(layer.BasemapId);
                    if (basemapLayers.length - 1 === index) {
                        this.enableToggling = true;
                    }
                    if (basemap) {
                        this.isBasemapLayerRemoved = true;
                        this.map.removeLayer(basemap);
                    }
                }));
            } else {
                //remove previous basemap layer from map
                basemap = this.map.getLayer(basemapLayers.BasemapId);
                if (basemap) {
                    this.enableToggling = true;
                    this.isBasemapLayerRemoved = true;
                    this.map.removeLayer(basemap);
                }
            }
        },

        /**
        * get shared basemap
        * @memberOf widgets/baseMapGallery/baseMapGallery
        */
        _addBasemapLayerOnMap: function () {
            var layer, params, imageParameters, basemapLayers = dojo.configData.values.baseMapLayers[dojo.selectedBasemapIndex];

            //check if basemap has multilayer
            if (basemapLayers.length) {
                array.forEach(basemapLayers, lang.hitch(this, function (basemap, index) {
                    this.enableToggling = false;
                    layer = new ArcGISTiledMapServiceLayer(basemap.MapURL, { id: basemap.BasemapId, visible: true });
                    this.map.addLayer(layer, index);
                }));
            } else {
                this.enableToggling = false;
                //add basemap layer on map
                if (basemapLayers.layerType === "OpenStreetMap") {
                    //add basemap as open street layer
                    layer = new OpenStreetMapLayer({ id: basemapLayers.BasemapId, visible: true });
                } else if (basemapLayers.layerType === "ArcGISMapServiceLayer") {
                    imageParameters = new ImageParameters();
                    layer = new ArcGISDynamicMapServiceLayer(basemapLayers.MapURL, {
                        "imageParameters": imageParameters,
                        id: basemapLayers.BasemapId
                    });
                } else if (basemapLayers.layerType === "ArcGISImageServiceLayer") {
                    //add basemap as image service layer
                    params = new ImageServiceParameters();
                    layer = new ArcGISImageServiceLayer(basemapLayers.MapURL, {
                        imageServiceParameters: params,
                        id: basemapLayers.BasemapId,
                        opacity: 0.75
                    });
                } else if (basemapLayers.layerType === "VectorTileLayer") {
                    //add basemap as vector tile layer
                    layer = new VectorTileLayer(basemapLayers.MapURL, { id: basemapLayers.BasemapId });
                } else {
                    //add basemap as tiled service layer
                    layer = new ArcGISTiledMapServiceLayer(basemapLayers.MapURL, { id: basemapLayers.BasemapId, visible: true });
                }
                this.map.addLayer(layer, 0);
            }
        },

        /**
        * change basemap thumbnail
        * @memberOf widgets/baseMapGallery/baseMapGallery
        */
        _changeBasemapThumbnail: function (preIndex) {
            var baseMapURLCount, presentThumbNail, preLayerIndex, thumbnailPath;
            baseMapURLCount = dojo.configData.values.baseMapLayers.length;
            preLayerIndex = dojo.selectedBasemapIndex - 1;
            //show first basemap map if previous basemap is the last basemap in basemap array
            if (dojo.selectedBasemapIndex === baseMapURLCount) {
                dojo.selectedBasemapIndex = 0;
            }
            //set previous basemap index
            if (dojo.selectedBasemapIndex === 0) {
                preLayerIndex = baseMapURLCount - 1;
            }
            //show basemap thumbnail of next basemap
            presentThumbNail = dojo.selectedBasemapIndex + 1;
            //show first basemap map if previous basemap thumbnail is the last basemap in basemap array
            if (dojo.selectedBasemapIndex === baseMapURLCount - 1) {
                presentThumbNail = 0;
            }
            //display shared basemap
            if (preIndex || preIndex === 0) {
                preLayerIndex = preIndex;
            }
            this._changeBaseMap(preLayerIndex);
            //check if current basemap is a multilayer basemap or not
            if (dojo.configData.values.baseMapLayers[presentThumbNail].length) {
                thumbnailPath = dojo.configData.values.baseMapLayers[presentThumbNail][0].ThumbnailSource;
            } else {
                thumbnailPath = dojo.configData.values.baseMapLayers[presentThumbNail].ThumbnailSource;
            }
            //set basemap thumbnail URL
            query('.esriCTBasemapThumbnail')[0].src = thumbnailPath;
        }

    });
});
