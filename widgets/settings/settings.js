/*global define,dojo */
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
    "dojo/on",
    "dojo/text!./templates/settings.html",
    "dojo/dom-attr",
    "dijit/_WidgetBase",
    "dijit/_TemplatedMixin",
    "dijit/_WidgetsInTemplateMixin",
    "dojo/i18n!nls/localizedStrings",
    "dojo/query",
    "dojo/dom-class",
    "dojo/topic",
    "dojo/dom-construct",
    "dojo/dom-geometry"

], function (declare, lang, on, template, domAttr, _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, nls, query, domClass, topic, domConstruct, domGeom) {

    return declare([_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin], {
        templateString: template,
        flag: null,
        nls: nls,
        postCreate: function () {
            this.domNode.title = nls.title.settingsBtnTitle;
            this.own(on(this.settingsIcon, "click", lang.hitch(this, function () {
                if (query(".esriCTSortByContainer")[0].children.length <= 0) {
                    var sortByTitle, sortMenu, listSortMenu, viewMbl, dateMbl, titleMbl, i, j, sortMenuListViewsAsc, sortMenuListViewsDesc, sortMenuListDateAsc,
                        sortMenuListDateDesc, sortMenuListTitleAsc, sortMenuListTitleDesc;
                    sortByTitle = domConstruct.create('div', { "class": "esriCTSortByTitle" }, query(".esriCTSortByContainer")[0]);
                    domConstruct.create('div', { "class": "esriCTSortHeader", "innerHTML": nls.sortByText }, sortByTitle);
                    sortMenu = domConstruct.create('div', { "class": "esriCTSortMenu" }, sortByTitle);
                    listSortMenu = domConstruct.create('ul', {}, sortMenu);
                    viewMbl = domConstruct.create('li', { "class": "sortByViewMbl", "sortValue": "numViews" }, listSortMenu);

                    sortMenuListViewsAsc = domConstruct.create('div', { "class": "esriCTSortAsc", "sortOrder": "asc" }, viewMbl);
                    domConstruct.create('div', { "class": "esriCTSortAscImgMbl" }, sortMenuListViewsAsc);
                    domConstruct.create('div', { "class": "esriCTSortListText", "innerHTML": nls.sortByViewText, "sortValue": "numViews" }, viewMbl);
                    sortMenuListViewsDesc = domConstruct.create('div', { "class": "esriCTSortDesc", "sortOrder": "desc" }, viewMbl);
                    domConstruct.create('div', { "class": "esriCTSortDescImgMbl" }, sortMenuListViewsDesc);

                    dateMbl = domConstruct.create('li', { "class": "sortByDateMbl", "sortValue": "modified" }, listSortMenu);

                    sortMenuListDateAsc = domConstruct.create('div', { "class": "esriCTSortAsc", "sortOrder": "asc" }, dateMbl);
                    domConstruct.create('div', { "class": "esriCTSortAscImgMbl" }, sortMenuListDateAsc);
                    domConstruct.create('div', { "class": "esriCTSortListText", "innerHTML": nls.sortByDateText, "sortValue": "modified" }, dateMbl);
                    sortMenuListDateDesc = domConstruct.create('div', { "class": "esriCTSortDesc", "sortOrder": "desc" }, dateMbl);
                    domConstruct.create('div', { "class": "esriCTSortDescImgMbl" }, sortMenuListDateDesc);

                    titleMbl = domConstruct.create('li', { "class": "sortByNameMbl", "sortValue": "title" }, listSortMenu);

                    sortMenuListTitleAsc = domConstruct.create('div', { "class": "esriCTSortAsc", "sortOrder": "asc" }, titleMbl);
                    domConstruct.create('div', { "class": "esriCTSortAscImgMbl" }, sortMenuListTitleAsc);
                    domConstruct.create('div', { "class": "esriCTSortListText", "innerHTML": nls.sortByNameText, "sortValue": "title" }, titleMbl);
                    sortMenuListTitleDesc = domConstruct.create('div', { "class": "esriCTSortDesc", "sortOrder": "desc" }, titleMbl);
                    domConstruct.create('div', { "class": "esriCTSortDescImgMbl" }, sortMenuListTitleDesc);

                    for (i = 0; i < listSortMenu.childNodes.length; i++) {
                        if (domAttr.get(listSortMenu.childNodes[i], "sortValue") === dojo.sortBy) {
                            for (j = 0; j < listSortMenu.childNodes[i].childNodes.length; j++) {
                                if (domAttr.get(listSortMenu.childNodes[i].childNodes[j], "sortOrder") === dojo.sortOrder) {
                                    domClass.add(listSortMenu.childNodes[i].childNodes[j], "esriCTListSelected");
                                    break;
                                }
                            }
                            break;
                        }
                    }

                    // Handle mobile click of ascending arrow of 'views' section from the sort by dropdown menu
                    this.own(on(sortMenuListViewsAsc, "click", lang.hitch(this, function (evt) {
                        this._setSelectedSorting(sortMenuListViewsAsc);
                    })));
                    // Handle click of descending arrow of 'views' section from the sort by dropdown menu
                    this.own(on(sortMenuListViewsDesc, "click", lang.hitch(this, function (evt) {
                        this._setSelectedSorting(sortMenuListViewsDesc);
                    })));

                    // Handle click of ascending arrow of 'date' section from the sort by dropdown menu
                    this.own(on(sortMenuListDateAsc, "click", lang.hitch(this, function (evt) {
                        this._setSelectedSorting(sortMenuListDateAsc);
                    })));
                    // Handle click of descending arrow of 'date' section from the sort by dropdown menu
                    this.own(on(sortMenuListDateDesc, "click", lang.hitch(this, function (evt) {
                        this._setSelectedSorting(sortMenuListDateDesc);
                    })));

                    // Handle click of ascending arrow of 'title' section from the sort by dropdown menu
                    this.own(on(sortMenuListTitleAsc, "click", lang.hitch(this, function (evt) {
                        this._setSelectedSorting(sortMenuListTitleAsc);

                    })));
                    // Handle click of descending arrow of 'title' section from the sort by dropdown menu
                    this.own(on(sortMenuListTitleDesc, "click", lang.hitch(this, function (evt) {
                        this._setSelectedSorting(sortMenuListTitleDesc);
                    })));
                } else {
                    domConstruct.empty(query(".esriCTSortByContainer")[0]);
                }
                this._slideLeftPanel();
            })));
        },

      /**
      * set the clicked node value for sorting. Only for smart phone devices.
      */
        _setSelectedSorting: function (selectedNode) {
            domClass.remove(query(".esriCTListSelected")[0], "esriCTListSelected");
            domClass.add(selectedNode, "esriCTListSelected");
            dojo.sortBy = domAttr.get(selectedNode.parentElement, "sortValue");
            dojo.sortOrder = domAttr.get(selectedNode, "sortOrder");
            topic.publish("sortGallery");
        },

        /**
        * Slide in and out the left panel upon clicking the settings icon. Only for smart phone devices.
        */
        _slideLeftPanel: function () {
            query(".esriCTInnerLeftPanelBottom")[0].style.height = dojo.window.getBox().h + "px";
            if (query(".esriCTMenuTab")[0]) {
                domClass.toggle(query(".esriCTMenuTab")[0], "esriCTShiftRight");
            }
            if (query(".esriCTInnerLeftPanelTop")[0]) {
                domClass.toggle(query(".esriCTInnerLeftPanelTop")[0], "esriCTShiftRight");
            }
            if (query(".esriCTInnerLeftPanelBottom")[0]) {
                domClass.remove(query(".esriCTInnerLeftPanelBottom")[0], "displayNone");
                domClass.toggle(query(".esriCTInnerLeftPanelBottom")[0], "esriCTInnerLeftPanelBottomShift");
            }
            if (query(".esriCTSearchIcon")[0]) {
                domClass.toggle(query(".esriCTSearchIcon")[0], "displayNone");
                domClass.toggle(query(".esriCTSearchItemInput")[0], "displayNone");
                domClass.toggle(query(".esriCTClearInput")[0], "displayNone");
            }
            if (query(".esriCTInfoIcon")[0]) {
                domClass.toggle(query(".esriCTInfoIcon")[0], "displayNone");
            }
            if (query(".esriCTSearch")[0]) {
                domClass.toggle(query(".esriCTSearch")[0], "displayNone");
            }
            if (query(".esriCTRightPanel")[0]) {
                domClass.toggle(query(".esriCTRightPanel")[0], "esriCTShiftRight");
                domClass.toggle(query(".esriCTRightPanel")[0], "esriCTShiftRightPanel");
            }

            if (query(".esriCTMenuTabLeft")[0]) {
                if (domClass.contains(query(".esriCTMenuTabLeft")[0], "displayBlock")) {
                    domClass.replace(query(".esriCTMenuTabLeft")[0], "displayNone", "displayBlock");
                    domClass.replace(query(".esriCTHomeIcon")[0], "displayNone", "displayBlock");

                    if (query(".esriCTSignIn")[0]) {
                        domClass.replace(query(".esriCTSignIn")[0], "displayNone", "displayBlock");
                    }
                    domClass.add(query(".esriCTInnerRightPanel")[0], "displayNone");
                    if (query(".esriCTNoResults")[0]) {
                        if (domClass.contains(query(".esriCTNoResults")[0], "displayBlockAll")) {
                            domClass.replace(query(".esriCTNoResults")[0], "displayNoneAll", "displayBlockAll");
                        }
                    }
                    if (dojo.configData.values.showTagCloud) {
                        query(".esriCTPadding")[0].style.height = window.innerHeight - (domGeom.position(query(".sortByLabelMbl")[0]).h + domGeom.position(query(".esriCTCategoriesHeader")[0]).h + 40) + "px";
                    }
                    if (domClass.contains(query(".esriCTItemSearch")[0], "displayBlockAll")) {
                        this.flag = true;
                        domClass.replace(query(".esriCTItemSearch")[0], "displayNoneAll", "displayBlockAll");
                    }
                } else {
                    domClass.replace(query(".esriCTMenuTabLeft")[0], "displayBlock", "displayNone");
                    domClass.replace(query(".esriCTHomeIcon")[0], "displayBlock", "displayNone");
                    if (query(".esriCTSignIn")[0]) {
                        domClass.replace(query(".esriCTSignIn")[0], "displayBlock", "displayNone");
                    }
                    domClass.remove(query(".esriCTInnerRightPanel")[0], "displayNone");
                    if (query(".esriCTNoResults")[0]) {
                        if (domClass.contains(query(".esriCTNoResults")[0], "displayNoneAll")) {
                            domClass.replace(query(".esriCTNoResults")[0], "displayBlockAll", "displayNoneAll");
                        }
                    }
                    if (this.flag) {
                        domClass.replace(query(".esriCTItemSearch")[0], "displayBlockAll", "displayNoneAll");
                        this.flag = false;
                    }
                }
            }
        }
    });
});
