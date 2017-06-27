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
    "dojo/text!./templates/info.html",
    "dijit/_WidgetBase",
    "dijit/_TemplatedMixin",
    "dijit/_WidgetsInTemplateMixin",
    "dojo/i18n!nls/localizedStrings",
    "dojo/query",
    "dojo/dom-class"
], function (declare, lang, on, template, _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, nls, query, domClass) {

    return declare([_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin], {
        templateString: template,
        nls: nls,
        /**
        *@class
        *@name  widgets/info/info
        */
        postCreate: function () {
            this.domNode.title = nls.title.infoBtnTitle;
            this.own(on(this.infoIcon, "click", lang.hitch(this, function () {
                this._slideRightPanel();
            })));
        },

        /**
        * Slide in and out the right panel upon clicking the info icon. Only for smart phone devices.
        * @memberOf widgets/info/info
        */
        _slideRightPanel: function () {
            domClass.add(query(".esriCTInnerLeftPanelBottom")[0], "displayNone");
            if (query(".esriCTMenuTab")[0]) {
                domClass.toggle(query(".esriCTMenuTab")[0], "esriCTShiftLeft");
            }
            if (query(".esriCTGalleryContent")[0]) {
                domClass.toggle(query(".esriCTRightPanel")[0], "esriCTShiftLeft");
            }
            if (query(".esriCTLeftPanel")[0]) {
                domClass.toggle(query(".esriCTLeftPanel")[0], "esriCTShiftLeftPanel");
            }
            if (query(".esriCTSearchIcon")[0]) {
                domClass.toggle(query(".esriCTClearInput")[0], "displayNone");
                domClass.toggle(query(".esriCTSearchIcon")[0], "displayNone");
                domClass.toggle(query(".esriCTSearchItemInput")[0], "displayNone");
            }
            if (domClass.contains(query(".esriCTRightPanel")[0], "esriCTShiftLeft")) {
                domClass.replace(query(".esriCTInnerLeftPanelTop")[0], "displayBlock", "displayNone");
            } else {
                domClass.replace(query(".esriCTInnerLeftPanelTop")[0], "displayNone", "displayBlock");
            }
            if (query(".esriCTMenuTabLeft")[0]) {
                if (domClass.contains(query(".esriCTMenuTabLeft")[0], "displayBlock")) {
                    domClass.replace(query(".esriCTMenuTabLeft")[0], "displayNone", "displayBlock");
                    domClass.replace(query(".esriCTHomeIcon")[0], "displayNone", "displayBlock");
                    domClass.replace(query(".esriCTSignIn")[0], "displayNone", "displayBlock");
                } else {
                    domClass.replace(query(".esriCTMenuTabLeft")[0], "displayBlock", "displayNone");
                    domClass.replace(query(".esriCTHomeIcon")[0], "displayBlock", "displayNone");
                    domClass.replace(query(".esriCTSignIn")[0], "displayBlock", "displayNone");
                }
            }
        }
    });
});
