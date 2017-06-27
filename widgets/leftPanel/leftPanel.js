/*global define,dojo,alert,CollectUniqueTags,TagCloudObj,ItemGallery */
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
    "dojo/dom-attr",
    "dojo/dom",
    "dojo/on",
    "dojo/_base/lang",
    "dojo/text!./templates/leftPanel.html",
    "dijit/_WidgetBase",
    "dijit/_TemplatedMixin",
    "dijit/_WidgetsInTemplateMixin",
    "dojo/i18n!nls/localizedStrings",
    "dojo/topic",
    "dojo/Deferred",
    "dojo/query",
    "dojo/dom-class",
    "dojo/dom-style",
    "dojo/dom-geometry",
    "dojo/_base/array",
    "dojo/NodeList-manipulate",
    "widgets/gallery/gallery"
], function (declare, domConstruct, domAttr, dom, on, lang, template, _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, nls, topic, Deferred, query, domClass, domStyle, domGeom, array) {

    declare("CollectUniqueTags", null, {

        setNodeValue: function (node, text) {
            if (text) {
                domAttr.set(node, "innerHTML", text);
            }
        },

        /**
        * Collect all the tags in an array
        * @memberOf widgets/leftPanel/leftPanel
        */
        collectTags: function (results) {
            var i, j, tagsObj, groupItemsTagsdata = [];

            for (i = 0; i < results.length; i++) {
                for (j = 0; j < results[i].tags.length; j++) {
                    if (!groupItemsTagsdata[results[i].tags[j]]) {
                        groupItemsTagsdata[results[i].tags[j]] = 1;
                    } else {
                        groupItemsTagsdata[results[i].tags[j]]++;
                    }
                }
            }
            groupItemsTagsdata = this._sortArray(groupItemsTagsdata);
            if (groupItemsTagsdata.length === 0) {
                groupItemsTagsdata = null;
            }
            tagsObj = {
                "groupItemsTagsdata": groupItemsTagsdata
            };
            return tagsObj;
        },

        /**
        * Sort the the tag cloud array in order
        * @memberOf widgets/leftPanel/leftPanel
        */
        _sortArray: function (tagArray) {
            var i, sortedArray = [];

            for (i in tagArray) {
                if (tagArray.hasOwnProperty(i)) {
                    sortedArray.push({
                        key: i,
                        value: tagArray[i]
                    });
                }
            }
            sortedArray.sort(function (a, b) {
                if (a.value > b.value) {
                    return -1;
                }
                if (a.value < b.value) {
                    return 1;
                }
                return 0;
            });
            return sortedArray;
        },

        /**
        * Search for the tags with the geographiesTagText tag configured
        * @memberOf widgets/leftPanel/leftPanel
        */
        _searchGeoTag: function (tag, geoTag) {
            var geoTagValue = tag.toLowerCase().indexOf(geoTag.toLowerCase());
            return geoTagValue;
        }
    });

    declare("TagCloudObj", null, {

        /**
        * Generate the Tag cloud based on the inputs provided
        * @memberOf widgets/leftPanel/leftPanel
        */
        generateTagCloud: function (tagsCollection) {
            var fontSizeArray, tagCloudTags;

            fontSizeArray = this._generateFontSize(dojo.configData.values.tagCloudFontMinValue, dojo.configData.values.tagCloudFontMaxValue, tagsCollection);
            tagCloudTags = this._mergeTags(tagsCollection, fontSizeArray);
            return tagCloudTags;
        },

        /**
        * Generate the required font ranges for each and every tag in tag cloud according to the min and max font range
        * @memberOf widgets/leftPanel/leftPanel
        */
        _generateFontSize: function (min, max, tagsCollection) {
            var i, nextValue, fontSizeArray = [];
            for (i = 0; i < tagsCollection.length; i++) {
                if (tagsCollection[i].value > 1) {
                    nextValue = (tagsCollection[i].value / tagsCollection[0].value) * (max - min) + min;
                } else {
                    nextValue = min;
                }
                fontSizeArray.push(nextValue);
            }
            return fontSizeArray.sort(function (a, b) {
                if (a > b) {
                    return -1;
                }
                if (a < b) {
                    return 1;
                }
                return 0;
            });
        },

        /**
        * Merge the displayed tags and font ranges in single array
        * @memberOf widgets/leftPanel/leftPanel
        */
        _mergeTags: function (maxUsedTags, fontSizeArray) {
            var i;

            for (i = 0; i < maxUsedTags.length; i++) {
                maxUsedTags[i].fontSize = fontSizeArray[i];
            }
            return maxUsedTags.sort(function (a, b) {
                if (a.key.toLowerCase() < b.key.toLowerCase()) {
                    return -1;
                }
                if (a.key.toLowerCase() > b.key.toLowerCase()) {
                    return 1;
                }
                return 0;
            });
        }
    });

    declare("LeftPanelCollection", [_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, Deferred], {
        templateString: template,
        nls: nls,
        gallery: null,

        startup: function () {
            var i, j, listSortMenu, groupItems = [];
            dojo.sortBy = dojo.configData.values.sortField;
            dojo.sortOrder = dojo.configData.values.sortOrder;
            listSortMenu = query(".listSortMenu")[0];

            // On load, add selected class to ascending or descending arrow as configured in the configuration file
            for (i = 0; i < listSortMenu.children.length; i++) {
                if (domAttr.get(listSortMenu.children[i], "sortValue") === dojo.configData.values.sortField) {
                    for (j = 0; j < listSortMenu.children[i].children.length; j++) {
                        if (domAttr.get(listSortMenu.children[i].children[j], "sortOrder") === dojo.configData.values.sortOrder) {
                            domClass.remove(query(".esriCTSortMenuListSelected")[0], "esriCTSortMenuListSelected");
                            domClass.add(listSortMenu.children[i].children[j].children[0], "esriCTSortMenuListSelected");
                            break;
                        }
                    }
                    break;
                }
            }
            this._setGroupContent();
            this._expandGroupdescEvent(this.expandGroupDescription, this);
            this._queryGroupItems(null, null, groupItems);
            domAttr.set(this.leftPanelHeader, "innerHTML", dojo.configData.values.applicationName);
            topic.subscribe("createNoDataContainer", lang.hitch(this, this._createNoDataContainer));
            topic.subscribe("queryItemPods", this._queryItemPods);
        },

        /*
        * @memberOf widgets/leftPanel/leftPanel
        * Store the item details in an array
        */
        _queryGroupItems: function (nextQuery, queryString, groupItems) {
            var defObj = new Deferred();

            if ((!nextQuery) && (!queryString)) {
                dojo.queryString = 'group:("' + dojo.configData.values.group + '")';
                topic.publish("queryGroupItem", dojo.queryString, dojo.sortBy, dojo.sortOrder, defObj);
            } else if (!queryString) {
                topic.publish("queryGroupItem", null, null, null, defObj, nextQuery);
            }
            if (queryString) {
                dojo.queryString = queryString;
                topic.publish("queryGroupItem", dojo.queryString, dojo.sortBy, dojo.sortOrder, defObj);
            }

            defObj.then(lang.hitch(this, function (data) {
                var i;
                // Store group items in an array
                if (data.results.length > 0) {
                    for (i = 0; i < data.results.length; i++) {
                        groupItems.push(data.results[i]);
                    }
                    if (data.nextQueryParams.start !== -1) {
                        this._queryGroupItems(data.nextQueryParams, null, groupItems);
                    } else {
                        dojo.groupItems = groupItems;
                        this._setLeftPanelContent(groupItems);
                    }
                } else {
                    if (dojo.queryString) {
                        alert(nls.errorMessages.noPublicItems);
                        topic.publish("hideProgressIndicator");
                        this._setLeftPanelContent([]);
                        this._createNoDataContainer();
                    }
                }
            }), function (err) {
                alert(err.message);
            });
        },

        /**
        * Create the categories and geographies tag cloud container
        * @memberOf widgets/leftPanel/leftPanel
        */
        _setLeftPanelContent: function (results) {
            var uniqueTags, tagsObj, tagCloud, displayCategoryTags, tagContainerHeight;
            // Create tag cloud
            dojo.selectedTags = "";
            dojo.tagCloudArray = [];
            if (dojo.configData.values.showTagCloud) {
                uniqueTags = new CollectUniqueTags();
                tagsObj = uniqueTags.collectTags(results);
                tagCloud = new TagCloudObj();
                // If minimum and maximum font size is not specified in the configuration file, set  minimum and maximum font size to 10 and 18 respectively
                if (!dojo.configData.values.tagCloudFontMinValue && !dojo.configData.values.tagCloudFontMaxValue && dojo.configData.values.tagCloudFontUnits) {
                    dojo.configData.values.tagCloudFontMinValue = 10;
                    dojo.configData.values.tagCloudFontMaxValue = 18;
                    dojo.configData.values.tagCloudFontUnits = "px";
                }
                // If the configured minimum font size is greater than maximum font size, display an error message
                if (dojo.configData.values.tagCloudFontMinValue > dojo.configData.values.tagCloudFontMaxValue) {
                    alert(nls.errorMessages.minfontSizeGreater);
                    return;
                }
                if (tagsObj.groupItemsTagsdata) {
                    domStyle.set(this.tagsCategoriesContent, "display", "block");
                    uniqueTags.setNodeValue(this.tagsCategories, nls.tagHeaderText);

                    displayCategoryTags = tagCloud.generateTagCloud(tagsObj.groupItemsTagsdata);
                    this.displayTagCloud(displayCategoryTags, this.tagsCategoriesCloud, this.tagsCategories.innerHTML);
                }
            }
            // Append left panel to parent container
            this._appendLeftPanel();
            // If showTagCloud is set to true in the configuration file, adjust space in the left panel for rest of the content
            if (dojo.configData.values.showTagCloud) {
                tagContainerHeight = window.innerHeight - (domGeom.position(query(".esriCTCategoriesHeader")[0]).h + domGeom.position(query(".esriCTMenuTab")[0]).h + domGeom.position(this.groupPanel).h + 50) + "px";
                domStyle.set(query(".esriCTPadding")[0], "height", tagContainerHeight);
            }
            this._queryItemPods();
        },

        /**
        * Query the number of items to be displayed in the gallery
        * @memberOf widgets/leftPanel/leftPanel
        */
        _queryItemPods: function (flag) {
            var defObj, queryString;
            defObj = new Deferred();
            queryString = 'group:("' + dojo.configData.values.group + '")';
            /**
            *if searchString exists in the config file, perform a default search with the specified string
            * @memberOf widgets/leftPanel/leftPanel
            */
            if (dojo.configData.values.searchString) {
                queryString += ' AND ' + dojo.configData.values.searchString + ' ';
            }

            /**
            * if searchType exists in the config file, perform a default type search with the specified string
            * @memberOf widgets/leftPanel/leftPanel
            */
            if (dojo.configData.values.searchType) {
                queryString += ' AND ( type:' + dojo.configData.values.searchType + ' )';
            }

            dojo.queryString = queryString;
            dojo.sortBy = dojo.configData.values.sortField;
            topic.publish("queryGroupItem", dojo.queryString, dojo.sortBy, dojo.sortOrder, defObj);
            defObj.then(function (data) {
                topic.publish("showProgressIndicator");
                dojo.nextQuery = data.nextQueryParams;
                if (this.gallery && this.gallery.destroy) {
                    this.gallery.destroy();
                }
                this.gallery = new ItemGallery();
                dojo.results = data.results;
                this.gallery.createItemPods(data.results, flag);
            }, function (err) {
                alert(err.message);
            });
        },

        /**
        * Create the required HTML for generating the tag cloud
        * @memberOf widgets/leftPanel/leftPanel
        */
        displayTagCloud: function (displayTags, node, text) {
            var i, span;

            for (i = 0; i < displayTags.length; i++) {
                span = domConstruct.place(domConstruct.create('h3'), node);
                domClass.add(span, "esriCTTagCloud");
                domStyle.set(span, "fontSize", displayTags[i].fontSize + dojo.configData.values.tagCloudFontUnits);
                if (i !== (displayTags.length - 1)) {
                    domAttr.set(span, "innerHTML", displayTags[i].key + "  ");
                } else {
                    domAttr.set(span, "innerHTML", displayTags[i].key);
                }
                domAttr.set(span, "selectedTagCloud", text);
                domAttr.set(span, "tagCloudValue", displayTags[i].key);
                span.onclick = this._makeSelectedTagHandler();
            }
        },

        /**
        * Creates a handler for a click on a tag
        * @memberOf widgets/leftPanel/leftPanel
        */
        _makeSelectedTagHandler: function () {
            var _self = this;

            return function () {
                var val, index;

                topic.publish("showProgressIndicator");
                if (query(".esriCTNoResults")[0]) {
                    domConstruct.destroy(query(".esriCTNoResults")[0]);
                }
                val = domAttr.get(this, "tagCloudValue");
                if (domClass.contains(this, "esriCTTagCloudHighlight")) {
                    domClass.remove(this, "esriCTTagCloudHighlight");
                    index = array.indexOf(dojo.tagCloudArray, val);
                    if (index > -1) {
                        dojo.tagCloudArray.splice(index, 1);
                    }
                } else {
                    domClass.add(this, "esriCTTagCloudHighlight");
                    dojo.tagCloudArray.push(val);
                }
                topic.publish("hideText");

                if (dojo.selectedTags !== "") {
                    dojo.selectedTags = dojo.tagCloudArray.join('"' + " AND " + '"');
                } else {
                    dojo.selectedTags = val;
                }
                _self._queryRelatedTags(dojo.selectedTags);

                if (query(".esriCTInnerRightPanelDetails")[0]) {
                    domClass.replace(query(".esriCTMenuTabRight")[0], "displayBlockAll", "displayNoneAll");
                    domClass.add(query(".esriCTInnerRightPanelDetails")[0], "displayNoneAll");
                    domClass.remove(query(".esriCTGalleryContent")[0], "displayNoneAll");
                    domClass.remove(query(".esriCTInnerRightPanel")[0], "displayNoneAll");
                    domClass.replace(query(".esriCTApplicationIcon")[0], "esriCTCursorDefault", "esriCTCursorPointer");
                    domClass.replace(query(".esriCTMenuTabLeft")[0], "esriCTCursorDefault", "esriCTCursorPointer");
                }
            };
        },

        /**
        * Executed on the click of a tag cloud and queries to fetch items containing the selected tag cloud
        * @memberOf widgets/leftPanel/leftPanel
        */
        _queryRelatedTags: function (tagName) {
            var defObj = new Deferred(), tagNameArray, i, resultFilter;
            dojo.queryString = 'group:("' + dojo.configData.values.group + '")' + ' AND (tags: ("' + tagName + '"))';
            topic.publish("queryGroupItem", dojo.queryString, dojo.sortBy, dojo.sortOrder, defObj);
            defObj.then(lang.hitch(this, function (data) {
                /**
                * Perform exact match and remove unwanted items from results
                */
                tagNameArray = tagName.split('" AND "');
                if (data.total === 0) {
                    this._createNoDataContainer();
                } else if (tagNameArray.length === 1 && tagNameArray[0] === '') {
                    /**
                    * load all the results
                    */
                    if (query(".esriCTNoResults")[0]) {
                        domConstruct.destroy(query(".esriCTNoResults")[0]);
                    }

                    domClass.replace(query(".esriCTInnerRightPanel")[0], "displayBlockAll", "displayNoneAll");
                    dojo.nextQuery = data.nextQueryParams;
                    dojo.results = data.results;
                    topic.publish("createPods", data.results, true);
                } else {
                    /**
                    * Compare tagName with tags
                    * Check if tag matches with the tags inside data.results.tags
                    * If it does not match then skip it else add the result item to resultFilter array
                    */
                    resultFilter = [];
                    for (i = 0; i < data.results.length; i++) {
                        if (this._searchStringInArray(tagNameArray, data.results[i].tags)) {
                            resultFilter.push(data.results[i]);
                        }
                    }
                    if (resultFilter.length > 0) {
                        if (query(".esriCTNoResults")[0]) {
                            domConstruct.destroy(query(".esriCTNoResults")[0]);
                        }

                        domClass.replace(query(".esriCTInnerRightPanel")[0], "displayBlockAll", "displayNoneAll");
                        dojo.nextQuery = data.nextQueryParams;
                        dojo.results = resultFilter;
                        topic.publish("createPods", resultFilter, true);
                    } else {
                        this._createNoDataContainer();
                    }
                }
            }), function (err) {
                alert(err.message);
                topic.publish("hideProgressIndicator");
            });
        },

        /**
        * Comparing strings
        * @memberOf widgets/leftPanel/leftPanel
        */
        _searchStringInArray: function (tagNameArray, strArray) {
            var i, j, matchCounter;
            for (i = 0, matchCounter = 0; i < tagNameArray.length; i++) {
                for (j = 0; j < strArray.length; j++) {
                    if (strArray[j] === tagNameArray[i]) {
                        matchCounter++;
                        if (matchCounter === tagNameArray.length) {
                            return true;
                        }
                        break;
                    }
                }
            }
            return false;
        },

        /**
        * Create a container with a message when no results are returned for a query
        * @memberOf widgets/leftPanel/leftPanel
        */
        _createNoDataContainer: function () {
            var innerRightPanel = query(".esriCTInnerRightPanel")[0];
            if (innerRightPanel) {
                domClass.replace(innerRightPanel, "displayNoneAll", "displayBlockAll");
            }
            if (query(".esriCTNoResults")[0]) {
                domConstruct.destroy(query(".esriCTNoResults")[0]);
            }
            if (query(".esriCTRightPanel")[0]) {
                domConstruct.create('div', { "class": "esriCTDivClear esriCTNoResults", "innerHTML": nls.noResultsText }, query(".esriCTRightPanel")[0]);
                if (innerRightPanel) {
                    if (domClass.contains(innerRightPanel, "displayNone")) {
                        domClass.replace(query(".esriCTNoResults")[0], "displayNoneAll", "displayBlockAll");
                    } else {
                        domClass.replace(query(".esriCTNoResults")[0], "displayBlockAll", "displayNoneAll");
                    }
                }
            }
            topic.publish("hideProgressIndicator");
        },

        /**
        * Shrinks or expands the group description content on the left panel based on the click event
        * @memberOf widgets/leftPanel/leftPanel
        */
        _expandGroupdescEvent: function (node, _self) {
            on(node, "click", lang.hitch(node, function (evt) {
                var tagContainerHeight, descHeight, height;
                if (this.innerHTML === nls.expandGroupDescText) {
                    domAttr.set(this, "innerHTML", nls.shrinkGroupDescText);
                    descHeight = window.innerHeight / 5;
                    height = window.innerHeight - (domGeom.position(query(".esriCTMenuTab")[0]).h + domGeom.position(query(".esriCTInnerLeftPanelBottom")[0]).h - descHeight) + "px";
                    domStyle.set(query(".esriCTLeftPanelDesc")[0], "maxHeight", height);
                } else {
                    domAttr.set(this, "innerHTML", nls.expandGroupDescText);
                }
                domClass.toggle(_self.groupDesc, "esriCTLeftTextReadLess");
                if (dojo.configData.values.showTagCloud) {
                    if (domClass.contains(query(".esriCTSignIn")[0], "displayNone")) {
                        tagContainerHeight = window.innerHeight - (domGeom.position(query(".sortByLabelMbl")[0]).h + domGeom.position(query(".esriCTCategoriesHeader")[0]).h) + "px";
                        domStyle.set(query(".esriCTPadding")[0], "height", tagContainerHeight);
                    } else {
                        tagContainerHeight = window.innerHeight - (domGeom.position(query(".esriCTCategoriesHeader")[0]).h + domGeom.position(query(".esriCTMenuTab")[0]).h + domGeom.position(query(".esriCTInnerLeftPanelTop")[0]).h + 30) + "px";
                        domStyle.set(query(".esriCTPadding")[0], "height", tagContainerHeight);
                    }
                }
            }));
        },

        /**
        * Sets the required group content in the containers
        * @memberOf widgets/leftPanel/leftPanel
        */
        _setGroupContent: function () {
            var groupPanelHeight;
            if (dojo.configData.groupTitle) {
                this.setNodeText(this.groupName, dojo.configData.groupTitle);
            }
            if (dojo.configData.values.applicationName) {
                this.setNodeText(this.groupDescPanelHeader, dojo.configData.values.applicationName);
            }
            if (dojo.configData.groupDescription) {
                this.setNodeText(this.groupDesc, dojo.configData.groupDescription);
                if (domStyle.get(query(".esriCTSignInIcon")[0], "display") === "none") {
                    groupPanelHeight = window.innerHeight - (domGeom.position(this.groupDescPanelHeader).h + 100) + "px";
                    domStyle.set(this.groupDesc, "height", groupPanelHeight);
                } else {
                    if (query(this.groupDesc).text().length > 400) {
                        domClass.add(this.groupDesc, "esriCTLeftTextReadLess");
                        if (nls.expandGroupDescText) {
                            this.setNodeText(this.expandGroupDescription, nls.expandGroupDescText);
                        }
                    }
                }
            }
        },

        /**
        * Used to set the innerHTML
        * @memberOf widgets/leftPanel/leftPanel
        */
        setNodeText: function (node, htmlString) {
            if (node) {
                domAttr.set(node, "innerHTML", htmlString);
            }
        },

        /**
        * Append the left panel to parent container
        */
        _appendLeftPanel: function () {
            var applicationHeaderDiv = dom.byId("esriCTParentDivContainer");
            if (query(".esriCTGalleryContent", dom.byId("esriCTParentDivContainer"))[0]) {
                domConstruct.destroy(query(".esriCTGalleryContent", dom.byId("esriCTParentDivContainer"))[0]);
            }
            domConstruct.place(this.galleryandPannels, applicationHeaderDiv);
        }
    });
});
