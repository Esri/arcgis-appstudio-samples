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
    "dojo/text!./templates/layout.html",
    "dijit/_WidgetBase",
    "dijit/_TemplatedMixin",
    "dijit/_WidgetsInTemplateMixin",
    "dojo/i18n!nls/localizedStrings",
    "dojo/_base/lang",
    "dojo/dom-class",
    "dojo/topic",
    "dojo/dom-attr",
    "dojo/on"
], function (declare, template, _WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin, nls, lang, domClass, topic, domAttr, on) {

    return declare([_WidgetBase, _TemplatedMixin, _WidgetsInTemplateMixin], {
        templateString: template,
        nls: nls,

        postCreate: function () {
            /**
            * gets executed on the click of the layout button in the header panel. It switches the layout from list view to grid view and vice versa.
            * @memberOf widgets/layout/layout
            */
            this.domNode.title = nls.title.layoutBtnTitle;
            domAttr.set(this.layoutLabel, "innerHTML", nls.layoutText);
            if (dojo.configData.values.defaultLayout.toLowerCase() === "list") {
                domClass.add(this.layoutTitle, "icon-grid");
            } else {
                domClass.add(this.layoutTitle, "icon-list");
            }
            this.own(on(this.toggleLayout, "click", lang.hitch(this, function () {
                topic.publish("showProgressIndicator");
                if (!dojo.gridView) {
                    dojo.gridView = true;
                    domAttr.set(this.layoutTitle, "title", nls.listViewTitle);
                    domClass.replace(this.layoutTitle, "icon-list", "icon-grid");
                } else {
                    dojo.gridView = false;
                    domAttr.set(this.layoutTitle, "title", nls.gridViewTitle);
                    domClass.replace(this.layoutTitle, "icon-grid", "icon-list");
                }
                topic.publish("createPods", dojo.results, true);
                topic.publish("hideProgressIndicator");
            })));
        }
    });
});
