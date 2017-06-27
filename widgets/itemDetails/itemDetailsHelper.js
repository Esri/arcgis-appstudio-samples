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
    "dojo/dom-attr",
    "dijit/_WidgetBase",
    "dijit/_TemplatedMixin",
    "dijit/_WidgetsInTemplateMixin",
    "dojo/i18n!nls/localizedStrings",
    "dojo/dom-class",
    "dojo/on",
    "dojo/keys",
    "dojo/topic",
    "esri/tasks/locator",
    "dojo/string",
    "dojo/dom-style",
    "dojo/dom-geometry",
    "esri/geometry/Point",
    "esri/graphic",
    "esri/request",
    "esri/symbols/PictureMarkerSymbol",
    "dojo/text!./templates/itemDetails.html"
], function (declare, domConstruct, lang, domAttr, _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, nls, domClass, on, keys, topic, Locator, string, domStyle, domGeom, Point, Graphic, esriRequest, PictureMarkerSymbol) {

    return declare([_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin], {
        basemapLayer: null,
        lastSearchString: null,
        stagedSearch: null,
        mapPoint: null,
        map: null,
        location: null,
        tempGraphicsLayerId: "esriGraphicsLayerMapSettings",
        /**
        *@class
        *@name  widgets/itemDetailsHelper/itemDetailsHelper
        */
        attachLocatorEvents: function () {
            domStyle.set(this.hideMapText, "display", "none");
            this.own(on(this.addressSearchIcon, "click", lang.hitch(this, function () {
                domStyle.set(this.hideMapText, "display", "none");
                if (lang.trim(this.txtAddressSearch.value) !== '') {
                    if (dojo.enableGeocodeSuggest) {
                        this._suggestAddress();
                    } else {
                        this._locateAddress();
                    }
                }
            })));

            this.own(on(this.txtAddressSearch, "keyup", lang.hitch(this, function (evt) {
                domStyle.set(this.hideMapText, "display", "block");
                this._submitAddress(evt);
            })));

            this.own(on(this.txtAddressSearch, "dblclick", lang.hitch(this, function (evt) {
                topic.publish("clearDefaultText", evt);
            })));

            this.own(on(this.txtAddressSearch, "focus", lang.hitch(this, function () {
                if (this.txtAddressSearch.value === '') {
                    domStyle.set(this.hideMapText, "display", "none");
                } else {
                    domStyle.set(this.hideMapText, "display", "block");
                }
                domClass.add(this.txtAddressSearch, "esriCTColorChange");
            })));

            this.own(on(this.hideMapText, "click", lang.hitch(this, function () {
                this.txtAddressSearch.value = '';
                domStyle.set(this.hideMapText, "display", "none");
                domAttr.set(this.txtAddressSearch, "defaultAddress", this.txtAddressSearch.value);
                if (domGeom.position(this.autocompleteResults).h > 0) {
                    domClass.replace(this.autocompleteResults, "displayNoneAll", "displayBlockAll");
                }
            })));
        },

        /**
        * search address on every key press
        * @param {object} evt Keyup event
        * @memberOf widgets/itemDetails/itemDetailsHelper
        */
        _submitAddress: function (evt) {
            var locationValue;
            if (evt) {
                locationValue = this.map.extent.getCenter();
                this.location = { "x": locationValue.x, "y": locationValue.y, "spatialReference": this.map.spatialReference };
                if (evt.keyCode === dojo.keys.ENTER) {
                    if (lang.trim(this.txtAddressSearch.value) !== '') {
                        if (dojo.enableGeocodeSuggest) {
                            this._suggestAddress(evt);
                        } else {
                            this._locateAddress();
                        }
                        return;
                    }
                }
            }
            if (dojo.enableGeocodeSuggest) {
                /**
                * do not perform auto complete search if alphabets,
                * numbers,numpad keys,comma,ctl+v,ctrl +x,delete or
                * backspace is pressed
                * @memberOf widgets/itemDetails/itemDetailsHelper
                */
                if (evt.ctrlKey || evt.altKey || evt.keyCode === keys.UP_ARROW || evt.keyCode === keys.DOWN_ARROW || evt.keyCode === keys.LEFT_ARROW || evt.keyCode === keys.RIGHT_ARROW || evt.keyCode === keys.HOME || evt.keyCode === keys.END || evt.keyCode === keys.CTRL || evt.keyCode === keys.SHIFT) {
                    evt.cancelBubble = true;
                    if (evt.stopPropagation) {
                        evt.stopPropagation();
                    }
                    return;
                }

                /**
                * call locator service if search text is not empty
                * @memberOf widgets/itemDetails/itemDetailsHelper
                */
                if (lang.trim(this.txtAddressSearch.value) !== '') {
                    if (this.lastSearchString !== lang.trim(this.txtAddressSearch.value)) {
                        this.lastSearchString = lang.trim(this.txtAddressSearch.value);

                        /**
                        * clear any staged search
                        */
                        clearTimeout(this.stagedSearch);
                        if (lang.trim(this.txtAddressSearch.value).length > 0) {

                            /**
                            * stage a new search, which will launch if no new searches show up
                            * before the timeout
                            */
                            this.stagedSearch = setTimeout(lang.hitch(this, function () {
                                this._suggestAddress();
                            }), 500);
                        }
                    }
                } else {
                    this.lastSearchString = lang.trim(this.txtAddressSearch.value);
                    domConstruct.empty(this.autocompleteResults);
                    domClass.replace(this.autocompleteResults, "displayNoneAll", "displayBlockAll");
                }
            }
        },

        /**
        * suggest valid addresses on every key press
        * @memberOf widgets/itemDetails/itemDetailsHelper
        */
        _suggestAddress: function () {
            if (lang.trim(this.txtAddressSearch.value) !== '') {
                esriRequest({
                    url: dojo.locatorURL + '/suggest?text=' + this.txtAddressSearch.value + '&location=' + dojo.toJson(this.location),
                    content: {
                        'f': 'json'
                    },
                    callbackParamName: 'callback',
                    load: lang.hitch(this, function (response) {
                        this._showLocatedAddress(response.suggestions);
                    }),
                    error: function (response) {
                        alert(response.message);
                        topic.publish("hideProgressIndicator");
                    }
                });
            }
        },

        _showLocatedAddress: function (candidates) {
            var i;
            domConstruct.empty(this.autocompleteResults);

            /**
            * display all the located address in the address container
            * 'this.divAddressResults' div dom element contains located addresses, created in widget template
            */
            if (candidates && candidates.length > 0) {
                for (i = 0; i < candidates.length; i++) {
                    this._displayValidLocations(candidates[i]);
                }
                domClass.replace(this.autocompleteResults, "displayBlockAll", "displayNoneAll");
            } else {
                this.mapPoint = null;
                this._locatorErrBack();
            }
        },

        /**
        * display error message if locator service fails or does not return any results
        * @memberOf widgets/itemDetails/itemDetailsHelper
        */
        _locatorErrBack: function () {
            if (domClass.contains(this.autocompleteResults, "displayNoneAll")) {
                domClass.replace(this.autocompleteResults, "displayBlockAll", "displayNoneAll");
            }
            this.spanErrResults = domConstruct.create('div', { "class": "esriCTCursorDefault", "innerHTML": nls.errorMessages.invalidSearch }, this.autocompleteResults);
        },

        /**
        * display a list of valid results
        * @memberOf widgets/itemDetails/itemDetailsHelper
        */
        _displayValidLocations: function (candidate) {
            var tdData;
            tdData = domConstruct.create("div", { "class": "esriCTBottomBorder esriCTCursorPointer" }, this.autocompleteResults);
            try {
                /**
                * bind x, y co-ordinates and address of search result with respective row in search panel
                */
                tdData.innerHTML = candidate.text;

                domAttr.set(tdData, "magicKey", candidate.magicKey);
                domAttr.set(tdData, "address", candidate.text);
            } catch (err) {
                alert(nls.errorMessages.falseConfigParams);
            }
            on(tdData, "click", lang.hitch(this, function (evt) {
                var target, candidateMagicKey;
                target = evt.currentTarget || evt.srcElement;
                /**
                * display result on map on click of search result
                */
                candidateMagicKey = domAttr.get(target, "magicKey");
                this.txtAddressSearch.value = target.innerHTML;
                domAttr.set(this.txtAddressSearch, "defaultAddress", target.innerHTML);
                domConstruct.empty(this.autocompleteResults);
                domClass.replace(this.autocompleteResults, "displayNoneAll", "displayBlockAll");
                this._locateAddress(candidateMagicKey);
            }));
            return true;
        },

        /**
        * perform find operation to fetch co-ordinates of the selected address
        * @memberOf widgets/itemDetails/itemDetailsHelper
        */
        _locateAddress: function (candidateMagicKey) {
            var queryURL;
            if (dojo.enableGeocodeSuggest) {
                queryURL = dojo.locatorURL + '/find?text=' + this.txtAddressSearch.value + '&location=' + dojo.toJson(this.location) + '&magicKey=' + candidateMagicKey;
            } else {
                queryURL = dojo.locatorURL + '/find?text=' + this.txtAddressSearch.value + '&location=' + dojo.toJson(this.location);
            }
            esriRequest({
                url: queryURL,
                content: {
                    'f': 'json',
                    'outSR': this.map.spatialReference.wkid
                },
                callbackParamName: 'callback',
                load: lang.hitch(this, function (response) {
                    this.mapPoint = new Point(response.locations[0].feature.geometry.x, response.locations[0].feature.geometry.y, this.map.spatialReference);
                    this._locateAddressOnMap(this.mapPoint);
                }),
                error: function (response) {
                    alert(response.message);
                    topic.publish("hideProgressIndicator");
                }
            });
        },

        /**
        * add push pin on the map
        * @param {object} mapPoint Map point of search result
        * @memberOf widgets/locator/locator
        */
        _locateAddressOnMap: function (mapPoint) {
            var geoLocationPushpin, locatorMarkupSymbol, graphic;
            this.map.setLevel(dojo.configData.values.zoomLevel);
            this.map.centerAt(mapPoint);
            if (dojo.configData.values.defaultLocatorSymbol.indexOf("http") === 0) {
                geoLocationPushpin = dojo.configData.values.defaultLocatorSymbol;
            } else {
                geoLocationPushpin = dojoConfig.baseURL + dojo.configData.values.defaultLocatorSymbol;
            }
            locatorMarkupSymbol = new PictureMarkerSymbol(geoLocationPushpin, dojo.configData.values.markupSymbolWidth, dojo.configData.values.markupSymbolHeight);
            graphic = new Graphic(mapPoint, locatorMarkupSymbol, {}, null);
            this.map.getLayer("esriGraphicsLayerMapSettings").clear();
            this.map.getLayer("esriGraphicsLayerMapSettings").add(graphic);
        }
    });
});
