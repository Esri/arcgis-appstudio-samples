/*global define,dojo,alert */
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
    "dojo/text!./templates/sortby.html",
    "dijit/_WidgetBase",
    "dijit/_TemplatedMixin",
    "dijit/_WidgetsInTemplateMixin",
    "dojo/i18n!nls/localizedStrings",
    "dojo/query",
    "dojo/_base/lang",
    "dojo/topic",
    "dojo/Deferred",
    "dojo/dom-class",
    "dojo/dom-construct",
    "dojo/dom-attr",
    "dojo/on"
], function (declare, template, _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, nls, query, lang, topic, Deferred, domClass, domConstruct, domAttr, on) {

    return declare([_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin], {
        templateString: template,
        nls: nls,

        postCreate: function () {
            var listSortMenu, sortMenuListViews, sortMenuListViewsAsc, sortMenuListViewsAscImg, sortMenuListViewsDesc, sortMenuListViewsDescImg,
                sortMenuListDate, sortMenuListDateAsc, sortMenuListDateAscImg, sortMenuListDateDesc, sortMenuListDateDescImg,
                sortMenuListTitle, sortMenuListTitleAsc, sortMenuListTitleAscImg, sortMenuListTitleDesc, sortMenuListTitleDescImg, i, j;
            domAttr.set(this.sortByContainer, "title", nls.title.sortByBtnTitle);
            domAttr.set(this.sortByLabel, "innerHTML", nls.sortByText);

            // Create sort by dropdown menu
            listSortMenu = domConstruct.create('ul', { "class": "listSortMenu esriCTHeaderBackgroundColor esriCTHeaderTextColorAsBorder esriCTHeaderTextColor" }, this.sortMenu);
            sortMenuListViews = domConstruct.create('li', { "class": "list esriCTHeaderTextColorAsBorder", "sortValue": "numViews" }, listSortMenu);

            sortMenuListViewsAsc = domConstruct.create('div', { "class": "esriCTSortAsc", "sortOrder": "asc" }, sortMenuListViews);
            sortMenuListViewsAscImg = domConstruct.create('div', { "class": "esriCTSortAscImg  icon-angle-up", "title": nls.title.ascendingSort }, sortMenuListViewsAsc);
            domConstruct.create('div', { "class": "esriCTSortListText", "innerHTML": nls.sortByViewText, "sortValue": "numViews" }, sortMenuListViews);
            sortMenuListViewsDesc = domConstruct.create('div', { "class": "esriCTSortDesc", "sortOrder": "desc" }, sortMenuListViews);
            sortMenuListViewsDescImg = domConstruct.create('div', { "class": "esriCTSortDescImg icon-angle-down", "title": nls.title.descendingSort }, sortMenuListViewsDesc);

            sortMenuListDate = domConstruct.create('li', { "class": "list esriCTHeaderTextColorAsBorder", "sortValue": "modified" }, listSortMenu);

            sortMenuListDateAsc = domConstruct.create('div', { "class": "esriCTSortAsc", "sortOrder": "asc" }, sortMenuListDate);
            sortMenuListDateAscImg = domConstruct.create('div', { "class": "esriCTSortAscImg  icon-angle-up", "title": nls.title.ascendingSort }, sortMenuListDateAsc);
            domConstruct.create('div', { "class": "esriCTSortListText", "innerHTML": nls.sortByDateText, "sortValue": "modified" }, sortMenuListDate);
            sortMenuListDateDesc = domConstruct.create('div', { "class": "esriCTSortDesc", "sortOrder": "desc" }, sortMenuListDate);
            sortMenuListDateDescImg = domConstruct.create('div', { "class": "esriCTSortDescImg icon-angle-down", "title": nls.title.descendingSort }, sortMenuListDateDesc);

            sortMenuListTitle = domConstruct.create('li', { "class": "list", "sortValue": "title" }, listSortMenu);

            sortMenuListTitleAsc = domConstruct.create('div', { "class": "esriCTSortAsc", "sortOrder": "asc" }, sortMenuListTitle);
            sortMenuListTitleAscImg = domConstruct.create('div', { "class": "esriCTSortAscImg icon-angle-up", "title": nls.title.ascendingSort }, sortMenuListTitleAsc);
            domConstruct.create('div', { "class": "esriCTSortListText", "innerHTML": nls.sortByNameText, "sortValue": "title" }, sortMenuListTitle);
            sortMenuListTitleDesc = domConstruct.create('div', { "class": "esriCTSortDesc", "sortOrder": "desc" }, sortMenuListTitle);
            sortMenuListTitleDescImg = domConstruct.create('div', { "class": "esriCTSortDescImg icon-angle-down", "title": nls.title.descendingSort }, sortMenuListTitleDesc);

            for (i = 0; i < listSortMenu.children.length; i++) {
                if (domAttr.get(listSortMenu.children[i], "sortValue") === dojo.configData.values.sortField) {
                    for (j = 0; j < listSortMenu.children[i].children.length; j++) {
                        if (domAttr.get(listSortMenu.children[i].children[j], "sortOrder") === dojo.configData.values.sortOrder) {
                            domClass.add(listSortMenu.children[i].children[j].children[0], "esriCTSortMenuListSelected");
                            break;
                        }
                    }
                    break;
                }
            }

            // Show or hide the sort by container on click of the sort by tag present in header panel
            this.own(on(this.sortByContainer, "click", lang.hitch(this, function () {
                domClass.toggle(this.sortMenu, "displayNoneAll");
            })));

            // Handle click of ascending arrow of 'views' section from the sort by dropdown menu
            this.own(on(sortMenuListViewsAscImg, "click", lang.hitch(this, function () {
                dojo.sortBy = domAttr.get(sortMenuListViewsAscImg.parentElement.parentElement, "sortValue");
                dojo.sortOrder = domAttr.get(sortMenuListViewsAscImg.parentElement, "sortOrder");
                this._sortPodOrder(sortMenuListViewsAscImg);
            })));

            // Handle click of descending arrow of 'views' section from the sort by dropdown menu
            this.own(on(sortMenuListViewsDescImg, "click", lang.hitch(this, function () {
                dojo.sortBy = domAttr.get(sortMenuListViewsDescImg.parentElement.parentElement, "sortValue");
                dojo.sortOrder = domAttr.get(sortMenuListViewsDescImg.parentElement, "sortOrder");
                this._sortPodOrder(sortMenuListViewsDescImg);
            })));

            // Handle click of ascending arrow of 'date' section from the sort by dropdown menu
            this.own(on(sortMenuListDateAscImg, "click", lang.hitch(this, function () {
                dojo.sortBy = domAttr.get(sortMenuListDateAscImg.parentElement.parentElement, "sortValue");
                dojo.sortOrder = domAttr.get(sortMenuListDateAscImg.parentElement, "sortOrder");
                this._sortPodOrder(sortMenuListDateAscImg);
            })));

            // Handle click of descending arrow of 'date' section from the sort by dropdown menu
            this.own(on(sortMenuListDateDescImg, "click", lang.hitch(this, function () {
                dojo.sortBy = domAttr.get(sortMenuListDateDescImg.parentElement.parentElement, "sortValue");
                dojo.sortOrder = domAttr.get(sortMenuListDateDescImg.parentElement, "sortOrder");
                this._sortPodOrder(sortMenuListDateDescImg);
            })));

            // Handle click of ascending arrow of 'title' section from the sort by dropdown menu
            this.own(on(sortMenuListTitleAscImg, "click", lang.hitch(this, function () {
                dojo.sortBy = domAttr.get(sortMenuListTitleAscImg.parentElement.parentElement, "sortValue");
                dojo.sortOrder = domAttr.get(sortMenuListTitleAscImg.parentElement, "sortOrder");
                this._sortPodOrder(sortMenuListTitleAscImg);
            })));

            // Handle click of descending arrow of 'title' section from the sort by dropdown menu
            this.own(on(sortMenuListTitleDescImg, "click", lang.hitch(this, function () {
                dojo.sortBy = domAttr.get(sortMenuListTitleDescImg.parentElement.parentElement, "sortValue");
                dojo.sortOrder = domAttr.get(sortMenuListTitleDescImg.parentElement, "sortOrder");
                this._sortPodOrder(sortMenuListTitleDescImg);
            })));
            topic.subscribe("sortGallery", lang.hitch(this, this._sortPodOrder));
        },

        /**
        * Highlight the selected sort order image
        * @memberOf widgets/sortby/sortby
        */
        _selectedMenuItem: function (sortMenuListItem) {
            if (sortMenuListItem) {
                domClass.remove(query(".esriCTSortMenuListSelected")[0], "esriCTSortMenuListSelected");
                domClass.add(sortMenuListItem, "esriCTSortMenuListSelected");
            }
        },

        /**
        * Reorganize the gallery according to the selected sort value and sort order
        * @memberOf widgets/sortby/sortby
        */
        _sortPodOrder: function (sortMenuListItem) {
            var defObj = new Deferred(), tagNameArray, i, j, resultFilter;
            this._selectedMenuItem(sortMenuListItem);
            if (dojo.results.length > 0) {
                topic.publish("showProgressIndicator");
                domClass.add(this.sortMenu, "displayNoneAll");
                topic.publish("queryGroupItem", dojo.queryString, dojo.sortBy, dojo.sortOrder, defObj);
                defObj.then(function (data) {
                    if (data.results.length > 0) {
                        tagNameArray = dojo.selectedTags.split('" AND "');
                        if (tagNameArray.length > 0 && tagNameArray[0] !== "") {
                            /**
                            * Compare dojo.selectedTags with tags
                            * Check if tag matches with the tags inside data.results.tags
                            * If it does not match then skip it else add the result item to resultFilter array
                            */
                            resultFilter = [];
                            for (i = 0; i < data.results.length; i++) {
                                for (j = 0; j < data.results[i].tags.length; j++) {
                                    if (data.results[i].tags[j] === tagNameArray[0]) {
                                        resultFilter.push(data.results[i]);
                                    }
                                }
                            }
                            data.results = resultFilter;
                        }
                        dojo.results = data.results;
                        dojo.nextQuery = data.nextQueryParams;
                        topic.publish("createPods", data.results, true);
                    } else {
                        topic.publish("hideProgressIndicator");
                    }
                }, function (err) {
                    alert(err.message);
                    defObj.resolve();
                    topic.publish("hideProgressIndicator");
                });
            }
        }
    });
});
