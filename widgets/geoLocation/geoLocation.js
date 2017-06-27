/*global define,dojo,alert,Modernizr,dojoConfig */
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
    "dojo/_base/lang",
    "dojo/dom-construct",
    "dojo/on",
    "dijit/_WidgetBase",
    "esri/tasks/GeometryService",
    "esri/geometry/Point",
    "esri/symbols/PictureMarkerSymbol",
    "esri/SpatialReference",
    "esri/graphic",
    "dojo/query",
    "dojo/i18n!nls/localizedStrings"
], function (declare, lang, domConstruct, on, _WidgetBase, GeometryService, Point, PictureMarkerSymbol, SpatialReference, Graphic, query, nls) {

    return declare([_WidgetBase], {
        nls: nls,
        /**
        * create geolocation widget
        *
        * @class
        * @name widgets/geoLocation/geoLocation
        */
        startup: function () {
            /**
            * Modernizr.geolocation checks for support for geolocation on client browser
            * if browser is not supported, geolocation widget is not created
            */
            if (!Modernizr.geolocation) {
                console.log('navigator.geolocation unsupported.');
            } else if (window.hasOwnProperty("isSecureContext") && !window.isSecureContext) {
                console.log('navigator.geolocation requires a secure origin.');
            } else {
                this.domNode = domConstruct.create("div", { "class": "esriCTMapGeoLocation", "title": nls.title.geolocationBtnTitle });
                domConstruct.create("span", { "class": "icon-gps esriCTGeolocationIcon esriCTHeaderTextColor esriCTHeaderBackgroundColor" }, this.domNode);
                this.own(on(this.domNode, "click", lang.hitch(this, function () {
                    this._showCurrentLocation();
                })));
                domConstruct.place(this.domNode, query(".esriSimpleSliderDecrementButton")[0], "after");
            }
        },

        /**
        * get device location from geolocation service
        * @param {string} dojo.configData.GeometryService Geometry service url specified in configuration file
        * @memberOf widgets/geoLocation/geoLocation
        */

        _showCurrentLocation: function () {
            var mapPoint, self = this, currentBaseMap,
                geometryServiceUrl = dojo.configData.values.geometryService,
                geometryService = new GeometryService(geometryServiceUrl);

            /**
            * get device location using geolocation service
            * @param {object} position Co-ordinates of device location in spatialReference of wkid:4326
            */
            navigator.geolocation.getCurrentPosition(function (position) {
                mapPoint = new Point(position.coords.longitude, position.coords.latitude, new SpatialReference({
                    wkid: 4326
                }));

                /**
                * projects the device location on the map
                * @param {string} dojo.configData.zoomLevel Zoom level specified in configuration file
                * @param {object} mapPoint Map point of device location in spatialReference of wkid:4326
                * @param {object} newPoint Map point of device location in spatialReference of map
                */
                geometryService.project([mapPoint], self.map.spatialReference).then(function (newPoint) {
                    currentBaseMap = self.map.getLayer("defaultBasemap");
                    if (!currentBaseMap) {
                        currentBaseMap = self.map.getLayer("defaultBasemap0");
                    }
                    if (currentBaseMap.visible) {
                        if (!currentBaseMap.fullExtent.contains(newPoint[0])) {
                            alert(nls.errorMessages.invalidLocation);
                            return;
                        }
                    }
                    mapPoint = newPoint[0];
                    self.map.centerAndZoom(mapPoint, dojo.configData.values.zoomLevel);
                    self._addGraphic(mapPoint);
                }, function (error) {
                    alert(nls.errorMessages.invalidProjection);
                });
            }, function (error) {
                alert(nls.errorMessages.invalidLocation);
            });
        },

        /**
        * add push pin on the map
        * @param {object} mapPoint Map point of device location in spatialReference of map
        * @memberOf widgets/geoLocation/geoLocation
        */
        _addGraphic: function (mapPoint) {
            var geoLocationPushpin, locatorMarkupSymbol, graphic;

            if (dojo.configData.values.defaultLocatorSymbol.indexOf("http") === 0) {
                geoLocationPushpin = dojo.configData.values.defaultLocatorSymbol;
            } else {
                geoLocationPushpin = dojoConfig.baseURL + dojo.configData.values.defaultLocatorSymbol;
            }
            locatorMarkupSymbol = new PictureMarkerSymbol(geoLocationPushpin, dojo.configData.values.markupSymbolWidth, dojo.configData.values.markupSymbolHeight);
            graphic = new Graphic(mapPoint, locatorMarkupSymbol, null, null);
            this.map.getLayer("esriGraphicsLayerMapSettings").clear();
            this.map.getLayer("esriGraphicsLayerMapSettings").add(graphic);
        }
    });
});
