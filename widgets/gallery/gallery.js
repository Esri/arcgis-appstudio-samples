/*global define,dojo,alert,unescape */
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
    "dojo/text!./templates/gallery.html",
    "dijit/_WidgetBase",
    "dijit/_TemplatedMixin",
    "dijit/_WidgetsInTemplateMixin",
    "dojo/i18n!nls/localizedStrings",
    "widgets/itemDetails/itemDetails",
    "dojo/query",
    "dojo/dom-class",
    "dojo/on",
    "dojo/Deferred",
    "dojo/number",
    "dojo/topic",
    "dojo/dom-style",
    "dojo/dom-geometry",
    "dojo/touch",
    "dojox/gesture/tap"
], function (declare, domConstruct, lang, domAttr, template, _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, nls, ItemDetails, query, domClass, on, Deferred, number, topic, domStyle, domGeom, touch, tap) {

    declare("ItemGallery", [_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin], {
        templateString: template,
        nls: nls,
        /**
        *@class
        *@name  widgets/gallery/gallery
        */
        postCreate: function () {
            domConstruct.place(this.galleryView, query(".esriCTGalleryContent")[0]);
            this.own(topic.subscribe("createPods", lang.hitch(this, this.createItemPods)));

            // Check if the default layout set in the configuration file is list or grid and display the gallery accordingly
            if (dojo.configData.values.defaultLayout.toLowerCase() === "list") {
                dojo.gridView = false;
                domClass.replace(query(".icon-header")[0], "icon-grid", "icon-list");
            } else {
                dojo.gridView = true;
                domClass.replace(query(".icon-header")[0], "icon-list", "icon-grid");
            }
            // Show more items from the group on click of 'Show more' button
            this.own(on(this.galleryNext, "click", lang.hitch(this, function () {
                var defObj;
                topic.publish("showProgressIndicator");
                defObj = new Deferred();
                topic.publish("queryGroupItem", null, null, null, defObj, dojo.nextQuery);
                defObj.then(lang.hitch(this, function (data) {
                    var i;
                    dojo.nextQuery = data.nextQueryParams;
                    for (i = 0; i < data.results.length; i++) {
                        dojo.results.push(data.results[i]);
                    }
                    this.createItemPods(data.results);
                }), function (err) {
                    topic.publish("hideProgressIndicator");
                    alert(err.message);
                });
            })));

            // Handle click event to navigate to gallery view on click of application header, when user is at item details page or map page
            this.own(on(query(".esriCTMenuTabLeft")[0], "click", lang.hitch(this, function () {
                if (query(".esriCTitemDetails")[0]) {
                    dojo.destroy(query(".esriCTitemDetails")[0]);
                    domClass.remove(query(".esriCTGalleryContent")[0], "displayNoneAll");
                    domClass.remove(query(".esriCTApplicationIcon")[0], "esriCTCursorPointer");
                    domClass.remove(query(".esriCTMenuTabLeft")[0], "esriCTCursorPointer");
                }
                if (query(".esriCTInnerRightPanelDetails")[0] && (!query(".esriCTNoResults")[0])) {
                    domClass.replace(query(".esriCTMenuTabRight")[0], "displayBlockAll", "displayNoneAll");
                    domClass.add(query(".esriCTInnerRightPanelDetails")[0], "displayNoneAll");
                    domClass.remove(query(".esriCTGalleryContent")[0], "displayNoneAll");
                    domClass.remove(query(".esriCTInnerRightPanel")[0], "displayNoneAll");
                    domClass.remove(query(".esriCTApplicationIcon")[0], "esriCTCursorPointer");
                    domClass.remove(query(".esriCTMenuTabLeft")[0], "esriCTCursorPointer");
                }
            })));

            // Resize containers on window resize
            on(window, "resize", lang.hitch(this, function () {
                var leftPanelDescHeight, containerHeight, innerLeftPanelHeight, tagContainerHeight, descHeight, descContainerHeight,
                    listSortMenu, i, j;
                if (domClass.contains(query(".esriCTInnerLeftPanelBottom")[0], "esriCTInnerLeftPanelBottomShift")) {
                    innerLeftPanelHeight = dojo.window.getBox().h + "px";
                    domStyle.set(query(".esriCTInnerLeftPanelBottom")[0], "height", innerLeftPanelHeight);
                }
                if (dojo.configData.groupDescription) {
                    if (domStyle.get(query(".esriCTSignInIcon")[0], "display") !== "none") {
                        descHeight = window.innerHeight / 5;
                        leftPanelDescHeight = window.innerHeight - (domGeom.position(query(".esriCTMenuTab")[0]).h + domGeom.position(query(".esriCTInnerLeftPanelBottom")[0]).h - descHeight) + "px";
                        domStyle.set(query(".esriCTGroupDesc")[0], "height", leftPanelDescHeight);
                    }
                }
                containerHeight = (window.innerHeight - domGeom.position(query(".esriCTMenuTab")[0]).h - 20) + "px";
                domStyle.set(query(".esriCTInnerRightPanel")[0], "height", containerHeight);

                // Resize group description container
                if (dojo.configData.groupDescription) {
                    if (domStyle.get(query(".esriCTSignInIcon")[0], "display") === "none") {
                        domClass.remove(query(".esriCTGroupDesc")[0], "esriCTLeftTextReadLess");
                        domStyle.set(query(".esriCTExpand")[0], "display", "none");
                        descContainerHeight = window.innerHeight - (domGeom.position(query(".esriCTGalleryNameSample")[0]).h + 100) + "px";
                        domStyle.set(query(".esriCTGroupDesc")[0], "height", descContainerHeight);
                    } else {
                        domStyle.set(query(".esriCTGroupDesc")[0], "height", "");
                        if (query(query(".esriCTGroupDesc")[0]).text().length > 400) {
                            domClass.add(query(".esriCTGroupDesc")[0], "esriCTLeftTextReadLess");
                            domAttr.set(query(".esriCTExpand")[0], "innerHTML", nls.expandGroupDescText);
                        }
                        domStyle.set(query(".esriCTExpand")[0], "display", "block");
                    }
                }

                // Resize tag cloud container
                if (dojo.configData.values.showTagCloud) {
                    if (domClass.contains(query(".esriCTSignIn")[0], "displayNone")) {
                        tagContainerHeight = window.innerHeight - (domGeom.position(query(".sortByLabelMbl")[0]).h + domGeom.position(query(".esriCTCategoriesHeader")[0]).h + 40) + "px";
                        domStyle.set(query(".esriCTPadding")[0], "height", tagContainerHeight);
                    } else {
                        tagContainerHeight = window.innerHeight - (domGeom.position(query(".esriCTCategoriesHeader")[0]).h + domGeom.position(query(".esriCTMenuTab")[0]).h + domGeom.position(query(".esriCTInnerLeftPanelTop")[0]).h + 30) + "px";
                        domStyle.set(query(".esriCTPadding")[0], "height", tagContainerHeight);
                    }
                }
                if (query(".esriCTListSelected")[0]) {
                    setTimeout(lang.hitch(this, function () {
                        if (query(".esriCTSortMenuListSelected")[0] && domAttr.get(query(".esriCTSortMenuListSelected")[0].parentElement.parentElement, "sortValue") !== dojo.sortBy && domAttr.get(query(".esriCTSortMenuListSelected")[0].parentElement, "sortOrder") !== dojo.sortOrder) {
                            listSortMenu = query(".esriCTSortMenuListSelected")[0].parentElement.parentElement.parentElement;
                            for (i = 0; i < listSortMenu.children.length; i++) {
                                if (domAttr.get(listSortMenu.children[i], "sortValue") === dojo.sortBy) {
                                    for (j = 0; j < listSortMenu.children[i].children.length; j++) {
                                        if (domAttr.get(listSortMenu.children[i].children[j], "sortOrder") === dojo.sortOrder) {
                                            domClass.remove(query(".esriCTSortMenuListSelected")[0], "esriCTSortMenuListSelected");
                                            domClass.add(listSortMenu.children[i].children[j].children[0], "esriCTSortMenuListSelected");
                                            break;
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                    }), 100);
                }
            }));

            //attach 'click' event on 'back' button to show gallery view
            this.own(on(this.backToGalleryBtn, "click", lang.hitch(this, this._backToGalleryView)));
            //handler to display gallery view
            topic.subscribe("backToGalleryView", lang.hitch(this, this._backToGalleryView));
            var panelHeight = (window.innerHeight - domGeom.position(query(".esriCTMenuTab")[0]).h - 20) + "px";
            domStyle.set(query(".esriCTInnerRightPanel")[0], "height", panelHeight);
        },

        /**
        * Display gallery view on clicking of back button
        * @memberOf widgets/gallery/gallery
        */
        _backToGalleryView: function () {
            //hide item details view and display gallery page
            if (query(".esriCTitemDetails")[0]) {
                dojo.destroy(query(".esriCTitemDetails")[0]);
                domClass.remove(query(".esriCTGalleryContent")[0], "displayNoneAll");
                domClass.remove(query(".esriCTApplicationIcon")[0], "esriCTCursorPointer");
            }
            if (query(".esriCTInnerRightPanelDetails")[0] && (!query(".esriCTNoResults")[0])) {
                domClass.replace(query(".esriCTMenuTabRight")[0], "displayBlockAll", "displayNoneAll");
                domClass.add(query(".esriCTInnerRightPanelDetails")[0], "displayNoneAll");
                domClass.remove(query(".esriCTGalleryContent")[0], "displayNoneAll");
                domClass.remove(query(".esriCTInnerRightPanel")[0], "displayNoneAll");
                domClass.remove(query(".esriCTApplicationIcon")[0], "esriCTCursorPointer");
            }
            topic.publish("hideProgressIndicator");
        },
        /**
        * Creates the gallery item pods
        * @memberOf widgets/gallery/gallery
        */
        createItemPods: function (itemResults, clearContainerFlag) {
            var i, divPodParentList, divPodParent;

            if (clearContainerFlag) {
                domConstruct.empty(this.itemPodsList);
            }
            // Display 'show more' button if number of items in the group are more than 100
            if (query(".esriCTShowMoreResults")[0]) {
                if (itemResults.length < 100 || (itemResults.length === 100 && dojo.groupItems.length === 100)) {
                    domClass.replace(query(".esriCTShowMoreResults")[0], "displayNoneAll", "displayBlockAll");
                } else {
                    domClass.replace(query(".esriCTShowMoreResults")[0], "displayBlockAll", "displayNoneAll");
                }
            }
            // Display gallery in list view or grid view
            for (i = 0; i < itemResults.length; i++) {
                if (!dojo.gridView) {
                    //add class to identify selected view mode
                    domClass.replace(this.itemPodsList, "esriCTListView", "esriCTGridView");
                    divPodParentList = domConstruct.create('div', { "class": "esriCTApplicationListBox" }, this.itemPodsList);
                    this._createThumbnails(itemResults[i], divPodParentList);
                    this._createItemOverviewPanel(itemResults[i], divPodParentList);
                } else {
                    //add class to identify selected view mode
                    domClass.replace(this.itemPodsList, "esriCTGridView", "esriCTListView");
                    divPodParent = domConstruct.create('div', { "class": "esriCTApplicationBox" }, this.itemPodsList);
                    this._createThumbnails(itemResults[i], divPodParent);
                    this._createGridItemOverview(itemResults[i], divPodParent);
                }
            }
            topic.publish("hideProgressIndicator");
        },

        /**
        * Create HTML for grid layout
        * @memberOf widgets/gallery/gallery
        */
        _createGridItemOverview: function (itemResult, divPodParent) {
            var divItemTitleRight, divItemTitleText, divItemType, spanItemType, divItemWatchEye, spanItemWatchEyeText, divItemDetailsIcon, dataType;

            divItemTitleRight = domConstruct.create('div', { "class": "esriCTDivClear" }, divPodParent);
            divItemTitleText = domConstruct.create('div', { "class": "esriCTListAppTitle esriCTGridTitleContent esriCTCursorPointer esriCTHeaderBackgroundColorAsTextColor " }, divItemTitleRight);
            divItemDetailsIcon = domConstruct.create('div', { "class": "esriCTItemInfoIcon esriCTHeaderBackgroundColor" }, divItemTitleRight);
            domAttr.set(divItemTitleText, "innerHTML", (itemResult.title) || (nls.showNullValue));
            domAttr.set(divItemTitleText, "title", (itemResult.title) || (nls.showNullValue));
            divItemType = domConstruct.create('div', { "class": "esriCTGridItemType" }, divItemTitleRight);
            spanItemType = domConstruct.create('div', { "class": "esriCTInnerGridItemType" }, divItemType);
            domAttr.set(spanItemType, "innerHTML", (itemResult.type) || (nls.showNullValue));
            domAttr.set(spanItemType, "title", (itemResult.type) || (nls.showNullValue));
            // If showViews flag is set to true in the configuration file, display number of times the item has been viewed
            if (dojo.configData.values.showViews) {
                divItemWatchEye = domConstruct.create('div', { "class": "esriCTEyeNumViews esriCTEyeNumViewsGrid" }, divItemType);
                domConstruct.create('span', { "class": "esriCTEyeIcon icon-eye" }, divItemWatchEye);
                spanItemWatchEyeText = domConstruct.create('span', { "class": "view" }, divItemWatchEye);
                domAttr.set(spanItemWatchEyeText, "innerHTML", (itemResult.numViews >= 0) ? (number.format(parseInt(itemResult.numViews, 10))) : (nls.showNullValue));
                domClass.add(spanItemType, "esriCTGridItemTypeViews");
            } else {
                domClass.add(spanItemType, "esriCTGridItemTypeNoViews");
            }
            // Handle item title click in grid layout
            this.own(on(divItemTitleText, "click", lang.hitch(this, function () {
                dataType = itemResult.type.toLowerCase();
                if (((dataType !== "map service") && (dataType !== "web map") && (dataType !== "feature service") && (dataType !== "image service") && (dataType !== "kml") && (dataType !== "wms") && (dataType !== "vector tile service")) || (dataType === "operation view")) {
                    dojo.downloadWindow = window.open('', "_blank");
                }
                this.showInfoPage(itemResult, false);
            })));

            // Handle item title click in grid layout
            this.own(on(divItemDetailsIcon, "click", lang.hitch(this, function () {
                topic.publish("showProgressIndicator");
                this.showInfoPage(itemResult, true);
            })));
        },

        /**
        * Create the thumbnails displayed for gallery items
        * @memberOf widgets/gallery/gallery
        */
        _createThumbnails: function (itemResult, divPodParent) {
            var divThumbnail, divThumbnailImage, divTagContainer, divTagContent, dataType, thumbnailUrl, divItemSnippet, spanItemReadMore;

            if (!dojo.gridView) {
                divThumbnail = domConstruct.create('div', { "class": "esriCTImageContainerList" }, divPodParent);
            } else {
                divThumbnail = domConstruct.create('div', { "class": "esriCTImageContainer" }, divPodParent);
                divItemSnippet = domConstruct.create('div', { "class": "esriCTItemSnippet" }, divThumbnail);
                //create container to display snippet text of item on hovering of it
                if (itemResult.snippet) {
                    spanItemReadMore = domConstruct.create("div", { "class": "esriCTItemSnippetText" }, divItemSnippet);
                    domAttr.set(spanItemReadMore, "innerHTML", this._truncate(itemResult.snippet, 194));
                }
            }

            divThumbnailImage = domConstruct.create('div', { "class": "esriCTAppImage esriCTHeaderBackgroundColorAsBorder" }, divThumbnail);
            if (itemResult.thumbnailUrl) {
                if (dojo.configData.values.proxyUrl) {
                    thumbnailUrl = dojo.configData.values.proxyUrl + "?" + itemResult.thumbnailUrl;
                } else {
                    thumbnailUrl = itemResult.thumbnailUrl;
                }
                domStyle.set(divThumbnailImage, "background", 'url(' + thumbnailUrl + ') no-repeat center center');
            } else {
                domClass.add(divThumbnailImage, "esriCTNoThumbnailImage");
            }

            divTagContainer = domConstruct.create('div', { "class": "esriCTSharingTag" }, divThumbnailImage);
            divTagContent = domConstruct.create('div', { "class": "esriCTTag" }, divTagContainer);

            if (dojo.configData.values.displaySharingAttribute) {
                this._accessLogoType(itemResult, divTagContent);
            }
            if (dojo.gridView && window.hasOwnProperty && window.hasOwnProperty('orientation')) {
                if (divItemSnippet) {
                    on(divThumbnail, tap.hold, lang.hitch(this, function (e) {
                        domClass.add(divItemSnippet, "esriCTItemSnippetHover");
                    }));
                    on(divThumbnail, touch.release, lang.hitch(this, function (e) {
                        domClass.remove(divItemSnippet, "esriCTItemSnippetHover");
                    }));
                    on(divThumbnail, touch.out, lang.hitch(this, function (e) {
                        domClass.remove(divItemSnippet, "esriCTItemSnippetHover");
                    }));
                }
                // Handle thumbnail image click
                on(divThumbnail, tap, lang.hitch(this, function (e) {
                    topic.publish("showProgressIndicator");
                    dataType = itemResult.type.toLowerCase();
                    if (((dataType !== "map service") && (dataType !== "web map") && (dataType !== "feature service") && (dataType !== "image service") && (dataType !== "kml") && (dataType !== "wms") && (dataType !== "vector tile service")) || (dataType === "operation view")) {
                        dojo.downloadWindow = window.open('', "_blank");
                    }
                    this.showInfoPage(itemResult, false);
                }));
            } else {
                if (divItemSnippet) {
                    on(divThumbnail, "mouseover", lang.hitch(this, function (e) {
                        domClass.add(divItemSnippet, "esriCTItemSnippetHover");
                    }));
                    on(divThumbnail, "mouseout", lang.hitch(this, function (e) {
                        domClass.remove(divItemSnippet, "esriCTItemSnippetHover");
                    }));
                }
                // Handle thumbnail image click
                on(divThumbnail, "click", lang.hitch(this, function (e) {
                    topic.publish("showProgressIndicator");
                    dataType = itemResult.type.toLowerCase();
                    if (((dataType !== "map service") && (dataType !== "web map") && (dataType !== "feature service") && (dataType !== "image service") && (dataType !== "kml") && (dataType !== "wms") && (dataType !== "vector tile service")) || (dataType === "operation view")) {
                        dojo.downloadWindow = window.open('', "_blank");
                    }
                    this.showInfoPage(itemResult, false);
                }));
            }
        },

        /**
        * Show summary text with ellipsis if it doest not fit into the container
        * @memberOf widgets/gallery/gallery
        */
        _truncate: function (text, length) {
            if (text.length > length) {
                text = text.substr(0, length) + "&hellip;";
            }
            return text;
        },

        /**
        * Executed when user clicks on a item thumbnail or clicks the button on the item info page. It performs a query to fetch the type of the selected item.
        * @memberOf widgets/gallery/gallery
        */
        _showItemOverview: function (itemId, thumbnailUrl, itemResult, data) {
            var itemDetails, dataType, tokenString2, downloadPath, tokenString, itemUrl, defObject;

            if (data) {
                data.thumbnailUrl = thumbnailUrl;
                dataType = data.type.toLowerCase();
                if ((dataType === "map service") || (dataType === "web map") || (dataType === "feature service") || (dataType === "image service") || (dataType === "kml") || (dataType === "wms") || (dataType === "vector tile service")) {
                    if ((dataType === "web map") && dojo.configData.values.mapViewer.toLowerCase() === "arcgis") {
                        topic.publish("hideProgressIndicator");
                        window.open(dojo.configData.values.portalURL + '/home/webmap/viewer.html?webmap=' + itemId, "_self");
                    } else {
                        itemDetails = new ItemDetails({ data: data });
                        itemDetails.startup();
                    }
                } else {
                    topic.publish("hideProgressIndicator");
                    // If item has URL, open the URL in a new tab
                    if (data.url) {
                        dojo.downloadWindow.location = data.url;
                    } else if (data.itemType.toLowerCase() === "file" && data.type.toLowerCase() === "cityengine web scene") {
                        dojo.downloadWindow.location = dojo.configData.values.portalURL + "/apps/CEWebViewer/viewer.html?3dWebScene=" + data.id;
                    } else if (data.itemType.toLowerCase() === "text" && data.type.toLowerCase() === "web scene") {
                        dojo.downloadWindow.location = dojo.configData.values.portalURL + "/home/webscene/viewer.html?webscene=" + data.id;
                    } else if (data.itemType.toLowerCase() === "file") {
                        if (dojo.configData.values.token) {
                            tokenString2 = "?token=" + dojo.configData.values.token;
                        } else {
                            tokenString2 = '';
                        }
                        downloadPath = dojo.configData.values.portalURL + "/sharing/content/items/" + itemId + "/data" + tokenString2;
                        dojo.downloadWindow.location = downloadPath;
                    } else if (dataType === "operation view" && data.itemType.toLowerCase() === "text") {
                        if (dojo.configData.values.token) {
                            tokenString = "&token=" + dojo.configData.values.token;
                        } else {
                            tokenString = '';
                        }
                        itemUrl = dojo.configData.values.portalURL + "/sharing/rest/content/items/" + data.id + "/data?f=json" + tokenString;
                        defObject = new Deferred();
                        topic.publish("queryItemInfo", itemUrl, defObject);
                        defObject.then(lang.hitch(this, function (result) {
                            if (dojo.configData.values.token) {
                                tokenString = "?token=" + dojo.configData.values.token;
                            } else {
                                tokenString = '';
                            }
                            if (result.desktopLayout) {
                                downloadPath = dojo.configData.values.portalURL + "/opsdashboard/OperationsDashboard.application?open=" + data.id;
                                dojo.downloadWindow.location = downloadPath;
                            } else if (result.tabletLayout) {
                                downloadPath = dojo.configData.values.portalURL + "/apps/dashboard/index.html#/" + data.id;
                                dojo.downloadWindow.location = downloadPath;
                            }
                        }));
                    } else {
                        alert(nls.errorMessages.unableToOpenItem);
                        if (dojo.downloadWindow) {
                            dojo.downloadWindow.close();
                        }
                    }
                }
            }
        },

        /**
        * Create a tag on the thumbnail image to indicate the access type of the item
        * @memberOf widgets/gallery/gallery
        */
        _accessLogoType: function (itemResult, divTagContent) {
            var title;
            if (itemResult.access === "public") {
                title = nls.allText;
            } else if (itemResult.access === "org") {
                title = nls.orgText;
            } else {
                title = nls.grpText;
            }
            if (divTagContent) {
                domAttr.set(divTagContent, "innerHTML", title);
            }
        },

        /**
        * Create HTML for list layout
        * @memberOf widgets/gallery/gallery
        */
        _createItemOverviewPanel: function (itemResult, divPodParent) {
            var divContent, divTitle, divItemTitle, divItemTitleRight, divItemTitleText, divItemInfo, divItemType,
                divRatings, numberStars, i, imgRating, divItemWatchEye, spanItemWatchEyeText, divItemContent,
                divItemSnippet, spanItemReadMore, divEyeIcon, divItemViewIcon, divItemDetailsIcon, divItemBtnContainer, dataType;

            divContent = domConstruct.create('div', { "class": "esriCTListContent" }, divPodParent);
            divTitle = domConstruct.create('div', { "class": "esriCTAppListTitle" }, divContent);

            divItemTitle = domConstruct.create('div', { "class": "esriCTAppListTitleRight" }, divTitle);
            divItemTitleRight = domConstruct.create('div', { "class": "esriCTDivClear" }, divItemTitle);
            divItemTitleText = domConstruct.create('div', { "class": "esriCTListAppTitle  esriCTCursorPointer esriCTHeaderBackgroundColorAsTextColor" }, divItemTitleRight);
            domAttr.set(divItemTitleText, "innerHTML", (itemResult.title) || (nls.showNullValue));

            divItemInfo = domConstruct.create('div', {}, divItemTitle);

            divItemType = domConstruct.create('div', { "class": "esriCTListItemType" }, divItemInfo);
            domAttr.set(divItemType, "innerHTML", (itemResult.type) || (nls.showNullValue));
            // If showRatings flag is set to true in the configuration file, create rating stars
            if (dojo.configData.values.showRatings) {
                divRatings = domConstruct.create('div', { "class": "esriCTRatingsDiv" }, divItemInfo);
                numberStars = Math.round(itemResult.avgRating);
                for (i = 0; i < 5; i++) {
                    imgRating = document.createElement("span");
                    imgRating.value = (i + 1);
                    divRatings.appendChild(imgRating);
                    if (i < numberStars) {
                        domClass.add(imgRating, "icon-star esriCTRatingStarIcon esriCTRatingStarIconColor");
                    } else {
                        domClass.add(imgRating, "icon-star-empty esriCTRatingStarIcon esriCTRatingStarIconColor");
                    }
                }
            }
            // If showViews flag is set to true in the configuration file, display the number of times the item has been viewed
            if (dojo.configData.values.showViews) {
                divItemWatchEye = domConstruct.create('div', { "class": "esriCTEyeNumViews esriCTEyeNumViewsList" }, divItemInfo);
                divEyeIcon = domConstruct.create('span', { "class": "esriCTEyeIcon icon-eye" }, divItemWatchEye);
                if (dojo.configData.values.showRatings) {
                    domClass.add(divEyeIcon, "esriCTEyeIconPadding");
                }
                spanItemWatchEyeText = domConstruct.create('span', { "class": "view" }, divItemWatchEye);
                domAttr.set(spanItemWatchEyeText, "innerHTML", (itemResult.numViews >= 0) ? (number.format(parseInt(itemResult.numViews, 10))) : (nls.showNullValue));
            }
            divItemContent = domConstruct.create('div', { "class": "esriCTListAppContent" }, divContent);
            divItemSnippet = domConstruct.create('div', { "class": "esriCTAppHeadline esriCTBodyTextColor " }, divItemContent);
            if (itemResult.snippet) {
                spanItemReadMore = domConstruct.create('span', {}, divItemSnippet);
                domAttr.set(spanItemReadMore, "innerHTML", itemResult.snippet);
            }

            // Handle item title click in list layout
            this.own(on(divItemTitleText, "click", lang.hitch(this, function () {
                dataType = itemResult.type.toLowerCase();
                if (((dataType !== "map service") && (dataType !== "web map") && (dataType !== "feature service") && (dataType !== "image service") && (dataType !== "kml") && (dataType !== "wms") && (dataType !== "vector tile service")) || (dataType === "operation view")) {
                    dojo.downloadWindow = window.open('', "_blank");
                }
                this.showInfoPage(itemResult, false);
            })));

            //create container for open/view and info buttons
            divItemBtnContainer = domConstruct.create('div', { "class": "esriCTItemBtnContainer" }, divItemContent);

            //create open/view button
            divItemViewIcon = domConstruct.create('div', { "class": "esriCTItemViewIcon esriCTHeaderBackgroundColor", "title": nls.title.viewBtnTitle }, divItemBtnContainer);

            // Handle item title click in list layout
            this.own(on(divItemViewIcon, "click", lang.hitch(this, function () {
                topic.publish("showProgressIndicator");
                dataType = itemResult.type.toLowerCase();
                if (((dataType !== "map service") && (dataType !== "web map") && (dataType !== "feature service") && (dataType !== "image service") && (dataType !== "kml") && (dataType !== "wms") && (dataType !== "vector tile service")) || (dataType === "operation view")) {
                    dojo.downloadWindow = window.open('', "_blank");
                }
                this.showInfoPage(itemResult, false);
            })));

            //create info button
            divItemDetailsIcon = domConstruct.create('div', { "class": "esriCTItemDetailsIcon esriCTHeaderBackgroundColor", "title": nls.title.infoBtnTitle }, divItemBtnContainer);

            // Handle item title click in list layout
            this.own(on(divItemDetailsIcon, "click", lang.hitch(this, function () {
                topic.publish("showProgressIndicator");
                this.showInfoPage(itemResult, true);
            })));
        },

        /**
        * Show item info page
        * @memberOf widgets/gallery/gallery
        */
        showInfoPage: function (itemResult, itemFlag) {
            this.displayPanel(itemResult, itemFlag);
        },

        /**
        * Create the HTML for item info page
        * @memberOf widgets/gallery/gallery
        */
        displayPanel: function (itemResult, itemFlag) {
            var numberOfComments, numberOfRatings, numberOfViews, itemReviewDetails, itemDescription, accessContainer, accessInfo, itemCommentDetails, itemViewDetails, itemText, containerHeight, dataArray, itemUrl, defObject, tokenString, dataType;

            if (dojo.configData.values.token) {
                tokenString = "&token=" + dojo.configData.values.token;
            } else {
                tokenString = '';
            }
            itemUrl = dojo.configData.values.portalURL + "/sharing/content/items/" + itemResult.id + "?f=json" + tokenString;
            defObject = new Deferred();
            defObject.then(lang.hitch(this, function (data) {
                if (data) {
                    // Check if 'download' or 'try it' button should be displayed in item info page
                    // Download button would be displayed for item of type file, operation view
                    // Try it button would be displayed for rest of the items
                    dataArray = {};
                    if (data.itemType === "file" && data.type.toLowerCase() !== "kml" && data.type.toLowerCase() !== "cityengine web scene") {
                        domAttr.set(this.btnTryItNow, "title", nls.downloadButtonText);
                        domClass.replace(this.btnTryItNow, "esriCTItemDownloadIcon", "esriCTItemViewIcon");
                    } else if (data.type.toLowerCase() === "operation view") {
                        if (dojo.configData.values.token) {
                            tokenString = "&token=" + dojo.configData.values.token;
                        } else {
                            tokenString = '';
                        }
                        itemUrl = dojo.configData.values.portalURL + "/sharing/content/items/" + data.id + "/data?f=json" + tokenString;
                        defObject = new Deferred();
                        topic.publish("queryItemInfo", itemUrl, defObject);
                        defObject.then(lang.hitch(this, function (result) {
                            if (result.desktopLayout) {
                                domAttr.set(this.btnTryItNow, "title", nls.downloadButtonText);
                            } else if (result.tabletLayout) {
                                domAttr.set(this.btnTryItNow, "title", nls.tryItButtonText);
                            }
                        }));
                    } else {
                        domAttr.set(this.btnTryItNow, "title", nls.tryItButtonText);
                        domClass.replace(this.btnTryItNow, "esriCTItemViewIcon", "esriCTItemDownloadIcon");
                    }

                    dataArray = {
                        id: data.id,
                        itemType: data.itemType,
                        type: data.type,
                        url: data.url,
                        title: data.title,
                        description: data.description
                    };
                    //generate style URL for vector tile service
                    if (data.type && data.type.toLowerCase() === "vector tile service") {
                        dataArray.url = dojo.configData.values.portalURL + "/sharing/content/items/" + data.id + "/resources/styles/root.json";
                    }
                    // itemFlag indicates if item details page should be displayed or the item should be opened up
                    if (itemFlag) {
                        this._createPropertiesContent(data, this.detailsContent);
                    } else {
                        this._showItemOverview(itemResult.id, itemResult.thumbnailUrl, itemResult, dataArray);
                    }

                    /**
                    * if showComments flag is set to true in configuration file, display list of comments in comments container
                    */
                    if (dojo.configData.values.showComments) {
                        this._createCommentsContainer(itemResult, this.detailsContent);
                    }
                }
            }), function (err) {
                alert(err.message);
                topic.publish("hideProgressIndicator");
            });
            topic.publish("queryItemInfo", itemUrl, defObject);

            // itemFlag indicates if item details page should be displayed or the item should be opened up
            if (itemFlag) {
                domClass.replace(query(".esriCTApplicationIcon")[0], "esriCTCursorPointer", "esriCTCursorDefault");
                domClass.replace(query(".esriCTMenuTabLeft")[0], "esriCTCursorPointer", "esriCTCursorDefault");
                domClass.replace(query(".esriCTMenuTabRight")[0], "displayNoneAll", "displayBlockAll");
                domClass.replace(query(".esriCTInnerRightPanel")[0], "displayNoneAll", "displayBlockAll");
                domClass.remove(query(".esriCTInnerRightPanelDetails")[0], "displayNoneAll");
                domConstruct.empty(this.detailsContent);
                domConstruct.empty(this.ratingsContainer);
                containerHeight = (window.innerHeight - domGeom.position(query(".esriCTMenuTab")[0]).h - 25) + "px";
                domStyle.set(query(".esriCTInnerRightPanelDetails")[0], "height", containerHeight);

                // If thumbnail is present for the item, display it or display no thumbnail image
                if (itemResult.thumbnailUrl) {
                    domClass.remove(this.appThumbnail, "esriCTNoThumbnailImage");
                    domStyle.set(this.appThumbnail, "background", 'url(' + itemResult.thumbnailUrl + ') no-repeat center center');
                } else {
                    domClass.add(this.appThumbnail, "esriCTNoThumbnailImage");
                }

                domAttr.set(this.applicationType, "innerHTML", (itemResult.type) || (nls.showNullValue));
                domAttr.set(this.appTitle, "innerHTML", itemResult.title || "");
                // If showViews flag is set to true in the configuration file, display the number of times the item has been viewed
                if (dojo.configData.values.showViews) {
                    numberOfComments = (itemResult.numComments) || "0";
                    numberOfRatings = (itemResult.numRatings) || "0";
                    numberOfViews = (itemResult.numViews) ? (number.format(parseInt(itemResult.numViews, 10))) : "0";
                    // If showViews flag is set to true in the configuration file, show comments text beside number of comments
                    if (dojo.configData.values.showComments) {
                        itemCommentDetails = numberOfComments + " " + nls.numberOfCommentsText + ", ";
                    } else {
                        itemCommentDetails = "";
                    }
                    // If showRatings flag is set to true in the configuration file, show ratings text beside number of ratings
                    if (dojo.configData.values.showRatings) {
                        itemReviewDetails = numberOfRatings + " " + nls.numberOfRatingsText + ", ";
                    } else {
                        itemReviewDetails = "";
                    }
                    itemViewDetails = numberOfViews + " " + nls.numberOfViewsText;
                    itemText = "(" + itemCommentDetails + itemReviewDetails + itemViewDetails + ")";
                    domAttr.set(this.numOfCommentsViews, "innerHTML", itemText);
                }
                domAttr.set(this.itemSnippet, "innerHTML", itemResult.snippet || "");
                domConstruct.create('div', { "class": "esriCTReviewHeader esriCTHeaderBackgroundColorAsTextColor", "innerHTML": nls.appDesText }, this.detailsContent);
                itemDescription = domConstruct.create('div', { "class": "esriCTText esriCTReviewContainer esriCTBottomBorder esriCTBodyTextColor" }, this.detailsContent);

                // If showLicenseInfo flag is set to true in the configuration file, show licensing information of the item
                if (dojo.configData.values.showLicenseInfo) {
                    accessContainer = domConstruct.create('div', { "class": "esriCTReviewContainer esriCTBottomBorder esriCTBodyTextColor" }, this.detailsContent);
                    domConstruct.create('div', { "class": "esriCTReviewHeader esriCTHeaderBackgroundColorAsTextColor", "innerHTML": nls.accessConstraintsText }, accessContainer);
                    accessInfo = domConstruct.create('div', { "class": "esriCTText esriCTBodyTextColor" }, accessContainer);
                    domAttr.set(accessInfo, "innerHTML", itemResult.licenseInfo || "");
                }
                domAttr.set(this.btnTryItNow, "title", "");
                this._createItemDescription(itemResult, itemDescription);
                if (this._btnTryItNowHandle) {
                    /**
                    * remove the click event handler if it already exists, to prevent the binding of the event multiple times
                    */
                    this._btnTryItNowHandle.remove();
                }
                dataType = itemResult.type.toLowerCase();
                this._btnTryItNowHandle = on(this.btnTryItNow, "click", lang.hitch(this, function () {
                    if ((domAttr.get(this.btnTryItNow, "title") === nls.downloadButtonText) || ((dataType !== "map service") && (dataType !== "web map") && (dataType !== "feature service") && (dataType !== "image service") && (dataType !== "kml") && (dataType !== "wms") && (dataType !== "vector tile service"))) {
                        dojo.downloadWindow = window.open('', "_blank");
                    }
                    this._showTryItNowView(this.btnTryItNow, itemResult, dataArray);
                }));

                if (this._appThumbnailClickHandle) {
                    /**
                    * remove the click event handler if it already exists, to prevent the binding of the event multiple times
                    */
                    this._appThumbnailClickHandle.remove();
                }
                this._appThumbnailClickHandle = on(this.appThumbnail, "click", lang.hitch(this, function () {
                    if ((dataType !== "map service") && (dataType !== "web map") && (dataType !== "feature service") && (dataType !== "image service") && (dataType !== "kml") && (dataType !== "wms") && (dataType !== "vector tile service")) {
                        dojo.downloadWindow = window.open('', "_blank");
                    }
                    this._showTryItNowView(this.appThumbnail, itemResult, dataArray);
                }));
            }
        },

        _showTryItNowView: function (container, itemResult, dataArray) {
            var itemId, thumbnailUrl;
            topic.publish("showProgressIndicator");
            itemId = domAttr.get(container, "selectedItem");
            thumbnailUrl = domAttr.get(container, "selectedThumbnail");
            this._showItemOverview(itemId, thumbnailUrl, itemResult, dataArray);
        },

        /**
        * Extract the item info (tags, extent) and display it in the created properties container
        * @memberOf widgets/gallery/gallery
        */
        _createPropertiesContent: function (itemInfo, detailsContent) {
            var tagsContent, i, itemTags, sizeContent, itemSizeValue, itemSize, tagsContainer, sizeContainer;

            tagsContainer = domConstruct.create('div', { "class": "esriCTReviewContainer esriCTBottomBorder" }, detailsContent);
            domConstruct.create('div', { "innerHTML": nls.tagsText, "class": "esriCTReviewHeader esriCTHeaderBackgroundColorAsTextColor" }, tagsContainer);
            tagsContent = domConstruct.create('div', {}, tagsContainer);
            for (i = 0; i < itemInfo.tags.length; i++) {
                if (i === 0) {
                    itemTags = itemInfo.tags[i];
                } else {
                    itemTags = itemTags + ", " + itemInfo.tags[i];
                }
            }
            domConstruct.create('div', { "class": "esriCTText esriCTBodyTextColor", "innerHTML": itemTags }, tagsContent);
            sizeContainer = domConstruct.create('div', { "class": "esriCTReviewContainer esriCTBottomBorder" }, detailsContent);
            domConstruct.create('div', { "class": "esriCTReviewHeader esriCTHeaderBackgroundColorAsTextColor", "innerHTML": nls.sizeText }, sizeContainer);
            sizeContent = domConstruct.create('div', {}, sizeContainer);
            if (itemInfo.size > 1048576) {
                itemSizeValue = itemInfo.size / 1048576;
                itemSize = Math.round(itemSizeValue) + " " + nls.sizeUnitMB;
            } else {
                itemSizeValue = itemInfo.size / 1024;
                itemSize = Math.round(itemSizeValue) + " " + nls.sizeUnitKB;
            }
            domConstruct.create('div', { "class": "esriCTText esriCTBodyTextColor", "innerHTML": itemSize }, sizeContent);
            topic.publish("hideProgressIndicator");
        },

        /**
        * Create the item description container
        * @memberOf widgets/gallery/gallery
        */
        _createItemDescription: function (itemResult, itemDescription) {
            var numberStars, i, imgRating;
            domAttr.set(itemDescription, "innerHTML", itemResult.description || "");
            domAttr.set(this.itemSubmittedBy, "innerHTML", (itemResult.owner) || (nls.showNullValue));

            /**
            * if showRatings flag is set to true in config file
            */
            if (dojo.configData.values.showRatings) {
                numberStars = Math.round(itemResult.avgRating);
                for (i = 0; i < 5; i++) {
                    imgRating = document.createElement("span");
                    imgRating.value = (i + 1);
                    this.ratingsContainer.appendChild(imgRating);
                    if (i < numberStars) {
                        domClass.add(imgRating, "icon-star esriCTRatingStarIcon esriCTRatingStarIconColor");
                    } else {
                        domClass.add(imgRating, "icon-star-empty esriCTRatingStarIcon esriCTRatingStarIconColor");
                    }
                }
            }
            domAttr.set(this.btnTryItNow, "selectedItem", itemResult.id);
            domAttr.set(this.btnTryItNow, "selectedThumbnail", itemResult.thumbnailUrl);

            domAttr.set(this.appThumbnail, "selectedItem", itemResult.id);
            domAttr.set(this.appThumbnail, "selectedThumbnail", itemResult.thumbnailUrl);
        },

        /**
        * Query the item to fetch comments and display the data in the comments container displayed on the item info page
        * @memberOf widgets/gallery/gallery
        */
        _createCommentsContainer: function (itemResult, detailsContent) {
            var reviewContainer = domConstruct.create('div', { "class": "esriCTReviewContainer esriCTBottomBorder" }, detailsContent);
            domConstruct.create('div', { "class": "esriCTReviewHeader", "innerHTML": nls.reviewText }, reviewContainer);
            itemResult.getComments().then(function (result) {
                var i, divReview, divReviewHeader, divReviewText, comment;
                // If comments are present for the item, display comments in comment container else display empty comments container
                if (result.length > 0) {
                    for (i = 0; i < result.length; i++) {
                        divReview = domConstruct.create('div', { "class": "esriCTReview" }, reviewContainer);
                        divReviewHeader = domConstruct.create('div', { "class": "esriCTReviewBold" }, divReview);
                        divReviewText = domConstruct.create('div', { "class": "esriCTReviewText esriCTBreakWord" }, divReview);
                        domAttr.set(divReviewHeader, "innerHTML", (result[i].created) ? (result[i].created.toLocaleDateString()) : (nls.showNullValue));
                        try {
                            comment = decodeURIComponent(result[i].comment);
                        } catch (e) {
                            comment = unescape(result[i].comment);
                        }
                        domAttr.set(divReviewText, "innerHTML", (result[i].comment) ? comment : (nls.showNullValue));
                    }
                } else {
                    divReview = domConstruct.create('div', { "class": "esriCTDivClear" }, reviewContainer);
                    domConstruct.create('div', { "class": "esriCTBreakWord" }, divReview);
                }
            }, function () {
                var divReview;
                divReview = domConstruct.create('div', { "class": "esriCTDivClear" }, reviewContainer);
                domConstruct.create('div', { "class": "esriCTBreakWord" }, divReview);
            });
        }

    });
});
