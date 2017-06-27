/*global define,dojo,dojoConfig */
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
    "dojo/dom",
    "dojo/text!./templates/appHeaderTemplate.html",
    "dijit/_WidgetBase",
    "dijit/_TemplatedMixin",
    "dijit/_WidgetsInTemplateMixin",
    "dojo/query",
    "dojo/on",
    "dojo/i18n!nls/localizedStrings",
    "dojo/dom-class",
    "dojo/topic"

], function (declare, domConstruct, lang, domAttr, dom, template, _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, query, on, nls, domClass, topic) {

    return declare([_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin], {
        templateString: template,
        nls: nls,

        /**
        * create header panel
        *
        * @param {string} dojo.configData.values.applicationName Application name specified in configuration file
        *
        * @class
        * @name widgets/appHeader/appHeader
        */
        postCreate: function () {
            topic.subscribe("showProgressIndicator", lang.hitch(this, this.showProgressIndicator));
            topic.subscribe("hideProgressIndicator", lang.hitch(this, this.hideProgressIndicator));
            /**
            * add applicationHeaderParentContainer to div for header panel and append to esriCTParentDivContainer container
            *
            * applicationHeaderParentContainer container for application header
            * @member {div} applicationHeaderParentContainer
            * @private
            * @memberOf widgets/appHeader/appHeader
            */
            var applicationHeaderDiv = dom.byId("esriCTParentDivContainer");
            domConstruct.place(this.applicationHeaderParentContainer, applicationHeaderDiv);
            /**
            * set browser header and application header to application name
            *
            * applicationHeaderName container for application name
            * @member {div} applicationHeaderName
            * @private
            * @memberOf widgets/appHeader/appHeader
            */
            document.title = dojo.configData.values.applicationName;
            domAttr.set(this.applicationHeaderName, "innerHTML", dojo.configData.values.applicationName);
        },

        /**
        * append widgets to header panel
        * @param {object} widgets Contain widgets to be displayed in header panel
        * @memberOf widgets/appHeader/appHeader
        */
        loadHeaderWidgets: function (widgets) {
            var i;

            /**
            * applicationHeaderWidgetsContainer container for header panel widgets
            * @member {div} applicationHeaderWidgetsContainer
            * @private
            * @memberOf widgets/appHeader/appHeader
            */
            for (i in widgets) {
                if (widgets.hasOwnProperty(i) && widgets[i].domNode) {
                    domConstruct.place(widgets[i].domNode, this.applicationHeaderWidgetsContainer);
                }
            }
        },

        /**
        * show loading indicator
        * @memberOf widgets/appHeader/appHeader
        */
        showProgressIndicator: function () {
            domClass.replace(this.divLoadingIndicator, "displayBlockAll", "displayNoneAll");
        },

        /**
        * hide loading indicator
        * @memberOf widgets/appHeader/appHeader
        */
        hideProgressIndicator: function () {
            domClass.replace(this.divLoadingIndicator, "displayNoneAll", "displayBlockAll");
        }
    });
});
