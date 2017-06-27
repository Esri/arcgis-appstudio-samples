/*global define,dojo,alert,dojoConfig,LeftPanelCollection */
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
    "dijit/_WidgetBase",
    "esri/arcgis/Portal",
    "dojo/topic",
    "dojo/_base/lang",
    "dojo/Deferred",
    "dojo/i18n!nls/localizedStrings",
    "dojo/query",
    "dojo/on",
    "dojo/dom",
    "dojo/dom-attr",
    "dojo/dom-class",
    "dojo/dom-style",
    "dojo/dom-geometry",
    "dojo/dom-construct",
    "esri/request",
    "esri/arcgis/utils",
    "esri/urlUtils",
    "esri/IdentityManager",
    "esri/arcgis/OAuthInfo",
    "widgets/leftPanel/leftPanel",
    "dojo/domReady!"
], function (declare, _WidgetBase, portal, topic, lang, Deferred, nls, query, on, dom, domAttr, domClass, domStyle, domGeom, domConstruct, esriRequest, arcgisUtils, urlUtils, IdentityManager, ArcGISOAuthInfo) {

    return declare([_WidgetBase], {
        nls: nls,

        postCreate: function () {
            topic.subscribe("portalSignIn", lang.hitch(this, this.portalSignIn));
            topic.subscribe("onSignIn", lang.hitch(this, this.onSignIn));
            topic.subscribe("queryGroupItem", dojo.hitch(this, this.queryGroupForItems));
            topic.subscribe("queryItemInfo", dojo.hitch(this, this.queryItemInfo));
            this._initializeApplication();
        },

        /**
        * check access type of the group and initialize portal
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        initializePortal: function () {
            var def = new Deferred();
            this.createPortal().then(lang.hitch(this, function () {
                dojo.locatorURL = this._portal.helperServices.geocode[0].url;
                dojo.configData.values.geometryService = this._portal.helperServices.geometry.url;
                dojo.privateBaseMapGroup = true;
                dojo.BaseMapGroupQuery = this._portal.basemapGalleryGroupQuery;
                // check if 'suggest' property is available for geocoder services
                if (this._portal.helperServices.geocode[0].suggest) {
                    dojo.enableGeocodeSuggest = this._portal.helperServices.geocode[0].suggest;
                } else {
                    dojo.enableGeocodeSuggest = true;
                }
                esriRequest({
                    // group rest URL
                    url: dojo.configData.values.portalURL + '/sharing/rest/community/groups?q=' + dojo.configData.values.group,
                    content: {
                        'f': 'json'
                    },
                    callbackParamName: 'callback',
                    load: lang.hitch(this, function (response) {
                        // to check access type of the group
                        if (response.results.length > 0) {
                            // executed if group is public
                            this.isPrivateGroup = false;
                            dojo.privateBaseMapGroup = true;
                            this.queryGroup().then(lang.hitch(this, function () {
                                var leftPanelObj = new LeftPanelCollection();
                                leftPanelObj.startup();
                            }));
                        } else {
                            // executed if group is private
                            this.isPrivateGroup = true;
                            dojo.privateBaseMapGroup = false;
                            this._setApplicationHeaderIcon();
                            var leftPanelObj = new LeftPanelCollection();
                            leftPanelObj.startup();
                        }
                        def.resolve();
                    }),
                    error: function (response) {
                        alert(response.message);
                        topic.publish("hideProgressIndicator");
                        def.resolve();
                    }
                });
            }));
            return def;
        },

        _initializeApplication: function () {
            var appLocation, instance;
            // Check to see if the app is hosted or a portal. If the app is hosted or a portal set the
            // sharing url and the proxy. Otherwise use the sharing url set it to arcgis.com.
            // We know app is hosted (or portal) if it has /apps/ or /home/ in the url.
            appLocation = location.pathname.indexOf("/apps/");
            if (appLocation === -1) {
                appLocation = location.pathname.indexOf("/home/");
            }
            // app is hosted and no sharing url is defined so let's figure it out.
            if (appLocation !== -1) {
                // hosted or portal
                instance = location.pathname.substr(0, appLocation); //get the portal instance name
                dojo.configData.values.portalURL = location.protocol + "//" + location.host + instance;
            }
            arcgisUtils.arcgisUrl = dojo.configData.values.portalURL + "/sharing/rest/content/items";
        },

        /**
        * fetch app id settings if appid is configured in the config file
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        fetchAppIdSettings: function () {
            var def = new Deferred(), settings, info, appSettings;
            settings = urlUtils.urlToObject(window.location.href);
            lang.mixin(dojo.configData.values, settings.query);
            if (dojo.configData.values.appid) {
                //If there's an oauth appid specified register it
                if (dojo.configData.values.oauthappid) {
                    info = new ArcGISOAuthInfo({
                        appId: dojo.configData.values.oauthappid,
                        portalUrl: dojo.configData.values.portalURL,
                        popup: false
                    });
                    IdentityManager.registerOAuthInfos([info]);
                }

                domStyle.set(dom.byId("esriCTParentDivContainer"), "display", "none");
                arcgisUtils.getItem(dojo.configData.values.appid).then(lang.hitch(this, function (response) {
                    /**
                    * check for false value strings
                    */
                    if (response.itemData && response.itemData.values) {
                        appSettings = this.setFalseValues(response.itemData.values);
                    }
                    domStyle.set(dom.byId("esriCTParentDivContainer"), "display", "block");
                    if (IdentityManager.credentials[0]) {
                        dojo.configData.values.token = IdentityManager.credentials[0].token;
                    }

                    // check sign-in status
                    var signedIn = IdentityManager.checkSignInStatus(dojo.configData.values.portalURL + "/sharing");
                    // resolve regardless of signed in or not.
                    signedIn.promise.always(lang.hitch(this, function (res) {
                        // set other config options (except portalURL) from app id
                        dojo.configPrev = lang.clone(dojo.configData.values);
                        var portalURL = dojo.configData.values.portalURL;
                        lang.mixin(dojo.configData.values, appSettings);
                        dojo.configData.values.portalURL = portalURL;
                        def.resolve(res);
                    }));
                    /**
                    * on error
                    */
                }), function (error) {
                    alert(error.message);
                    def.resolve();
                });
            } else {
                def.resolve();
            }
            return def;
        },

        /**
        * set false values
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        setFalseValues: function (obj) {
            var key;

            /**
            * for each key
            */
            for (key in obj) {
                /**
                * if not a prototype
                */
                if (obj.hasOwnProperty(key)) {
                    /**
                    * if is a false value string
                    */
                    if (typeof obj[key] === 'string' && (obj[key].toLowerCase() === 'false' || obj[key].toLowerCase() === 'null' || obj[key].toLowerCase() === 'undefined')) {
                        // set to false bool type
                        obj[key] = false;
                    }
                }
            }
            /**
            * return object
            * @param {object} obj
            */
            return obj;
        },

        /**
        * initialize the portal object
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        createPortal: function () {
            var def = new Deferred();
            /**
            * create portal
            */
            this._portal = new portal.Portal(dojo.configData.values.portalURL);
            /**
            * portal loaded
            */
            this.own(on(this._portal, "load", function (response) {
                def.resolve();
            }));
            return def;
        },

        /**
        * set group content like group title, description, etc.
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        setGroupContent: function (groupInfo) {
            /**
            * set group id
            */
            if (!dojo.configData.values.group) {
                dojo.configData.values.group = groupInfo.id;
            }
            /**
            * Set group logo image
            */
            if (!dojo.configData.values.applicationIcon) {
                dojo.configData.groupIcon = groupInfo.thumbnailUrl;
            }
            /**
            * Set group title
            */
            if (!dojo.configData.groupTitle) {
                dojo.configData.groupTitle = groupInfo.title || "";
            }
            /**
            * Set group description
            */
            if (!dojo.configData.groupDescription) {
                dojo.configData.groupDescription = groupInfo.description || "";
            }
            this._setApplicationHeaderIcon();
        },

        /**
        * Set Application Header Icon
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        _setApplicationHeaderIcon: function () {
            var appIcon;
            if (query(".esriCTApplicationIcon")[0]) {
                if (dojo.configData.values.applicationIcon) {
                    if (dojo.configData.values.applicationIcon.indexOf("http") === 0) {
                        domAttr.set(query(".esriCTApplicationIcon")[0], "src", dojo.configData.values.applicationIcon);
                    } else {
                        if (dojo.configData.values.applicationIcon.indexOf("/") === 0) {
                            domAttr.set(query(".esriCTApplicationIcon")[0], "src", dojoConfig.baseURL + dojo.configData.values.applicationIcon);
                        } else {
                            domAttr.set(query(".esriCTApplicationIcon")[0], "src", dojoConfig.baseURL + "/" + dojo.configData.values.applicationIcon);
                        }
                    }
                } else if (dojo.configData.groupIcon) {
                    domAttr.set(query(".esriCTApplicationIcon")[0], "src", dojo.configData.groupIcon);
                } else {
                    domAttr.set(query(".esriCTApplicationIcon")[0], "src", dojoConfig.baseURL + "/themes/images/defaultLogo.png");
                }
                appIcon = domAttr.get(query(".esriCTApplicationIcon")[0], "src");
                this.own(on(query(".esriCTApplicationIcon")[0], "click", lang.hitch(this, function () {
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
                })));
            }
            this._loadIcons("shortcut icon", dojo.configData.values.applicationFavicon);
            this._loadIcons("apple-touch-icon-precomposed", appIcon);
            this._loadIcons("apple-touch-icon", appIcon);
        },

        /**
        * load Application shortcut icons
        * @param {object} icon type
        * @param {object} icon path
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        _loadIcons: function (rel, iconPath) {
            var icon = domConstruct.create("link");
            icon.rel = rel;
            icon.type = "image/x-icon";
            if (iconPath.indexOf("http") === 0) {
                icon.href = iconPath;
            } else {
                icon.href = dojoConfig.baseURL + iconPath;
            }
            document.getElementsByTagName('head')[0].appendChild(icon);
        },

        /**
        * query arcgis group info
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        queryGroup: function (obj) {
            var def = new Deferred();

            /**
            * first, request the group to see if it's public or private
            */
            esriRequest({
                // group rest URL
                url: dojo.configData.values.portalURL + '/sharing/rest/community/groups/' + dojo.configData.values.group,
                content: {
                    'f': 'json'
                },
                callbackParamName: 'callback',
                load: lang.hitch(this, function () {
                    var q, params;

                    // query group
                    q = 'id:"' + dojo.configData.values.group + '"';
                    params = {
                        q: q,
                        token: dojo.configData.values.token,
                        f: 'json'
                    };
                    this._portal.queryGroups(params).then(lang.hitch(this, function (data) {
                        if (data) {
                            // fetch basemap group query for private items
                            dojo.privateBaseMapGroup = true;
                            if (data.results.length > 0) {
                                dojo.BaseMapGroupQuery = data.results[0].portal.basemapGalleryGroupQuery;
                                this.setGroupContent(data.results[0]);
                            }
                            dojo.configData.values.baseMapLayers = null;
                            def.resolve();
                        } else {
                            def.resolve();
                        }
                    }));
                }),
                error: function (response) {
                    alert(response.message);
                    topic.publish("hideProgressIndicator");
                    def.resolve();
                }
            });
            return def;
        },

        /**
        * query group to fetch group items
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        queryGroupForItems: function (queryString, sortfields, sortorder, deferedObj, nextQuery) {
            var params;
            if (!nextQuery) {
                params = {
                    q: queryString + '-type:\"Code Attachment\"',
                    num: 100, //should be in number format ex: 100
                    sortField: sortfields, //should be in string format
                    sortOrder: sortorder //should be in string format
                };
            } else {
                params = nextQuery;
            }

            this._portal.queryItems(params).then(function (data) {
                deferedObj.resolve(data);
            });
            return deferedObj;
        },

        /**
        * query to fetch item details
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        queryItemInfo: function (itemUrl, defObj) {
            esriRequest({
                url: itemUrl,
                callbackParamName: "callback",
                timeout: 20000,
                load: function (data) {
                    defObj.resolve(data);
                },
                error: function (e) {
                    if (e.httpCode === 498) {
                        defObj.resolve();
                        topic.publish("hideProgressIndicator");
                        // destroying credentials to invoke sign in dialog on timeout
                        IdentityManager.destroyCredentials();
                        topic.publish("portalSignIn", null, true);
                    } else {
                        defObj.resolve();
                        alert(e.message);
                        topic.publish("hideProgressIndicator");
                    }
                }
            });
            return defObj;
        },

        /**
        * override sign-in container text
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        setSignInContainerText: function () {
            setTimeout(function () {
                if (query(".dijitDialogTitle")[0]) {
                    query(".dijitDialogTitle")[0].innerHTML = nls.signInText;
                }
                if (query(".dijitDialogPaneContentArea")[0]) {
                    query(".dijitDialogPaneContentArea")[0].childNodes[0].innerHTML = "";
                    domStyle.set(query(".dijitDialogPaneContentArea")[0].childNodes[1], "height", "0px");
                }
                if (query(".esriIdSubmit")[0]) {
                    on(query(".esriIdSubmit")[0], "click", lang.hitch(this, function () {
                        if (lang.trim(query(".dijitInputInner")[0].value) === "" && lang.trim(query(".dijitInputInner")[1].value) === "") {
                            domAttr.set(query(".esriErrorMsg")[0], "innerHTML", nls.errorMessages.emptyUsernamePassword);
                            domStyle.set(query(".esriErrorMsg")[0], "display", "block");
                        }
                    }));
                }
            }, 1000);
        },

        /**
        * performs sign in or sign out operation
        * @memberOf widgets/searchAGOLGroupItems/searchAGOLGroupItems
        */
        portalSignIn: function (def, flag) {
            if (!def) {
                def = new Deferred();
            }
            if (query(".signin")[0]) {
                if (query(".signin")[0].innerHTML === nls.signInText) {
                    this._portal = new portal.Portal(dojo.configData.values.portalURL);
                    on(this._portal, "load", lang.hitch(this, function () {
                        this.onSignIn(def, flag);
                    }));
                } else {
                    this._portal.signOut().then(lang.hitch(this, function () {
                        this._portal = new portal.Portal(dojo.configData.values.portalURL);
                        on(this._portal, "load", lang.hitch(this, function () {
                            if (dojo.configData.values.token) {
                                dojo.configData.values.token = null;
                            }
                            topic.publish("showProgressIndicator");
                            IdentityManager.destroyCredentials();
                            if (this.isPrivateGroup) {
                                dojo.configData.groupTitle = null;
                                dojo.configData.groupDescription = null;
                                dojo.configData.groupIcon = null;
                                this._setApplicationHeaderIcon();
                            }

                            dojo.privateBaseMapGroup = false;
                            dojo.configData.values.baseMapLayers = null;
                            domAttr.set(query(".signin")[0], "innerHTML", nls.signInText);
                            domClass.replace(query(".esriCTSignInIcon")[0], "icon-login", "icon-logout");
                            if (dojo.configPrev) {
                                dojo.configData.values = dojo.configPrev;
                            }
                            if (dojo.configData.values.appid) {
                                this.fetchAppIdSettings().then(lang.hitch(this, function (response) {
                                    this.initializePortal();
                                }));
                            } else {
                                if (flag) {
                                    this.portalSignIn(def, true);
                                } else {
                                    /**
                                    * query to check if the group has any public items to be displayed on sign out
                                    */
                                    def.resolve();
                                    topic.publish("hideProgressIndicator");
                                }
                            }
                        }));
                    }));
                }
            }
            topic.publish("setDefaultTextboxValue");
            if (domGeom.position(query(".esriCTAutoSuggest")[0]).h > 0) {
                domClass.replace(query(".esriCTAutoSuggest")[0], "displayNoneAll", "displayBlockAll");
            }
            this.setSignInContainerText();
            return def;
        },

        onSignIn: function (def, flag) {
            this._portal.signIn().then(lang.hitch(this, function (loggedInUser) {
                if (document.activeElement) {
                    document.activeElement.blur();
                }
                domAttr.set(query(".esriCTSignIn")[0], "title", nls.title.signOutBtnTitle);
                topic.publish("showProgressIndicator");
                if (loggedInUser) {
                    if (!dojo.configData.values.token) {
                        dojo.configData.values.token = loggedInUser.credential.token;
                    }
                    if (flag) {
                        this.queryGroup().then(lang.hitch(this, function () {
                            domClass.add(query(".esriCTMenuTabRight")[0], "displayBlockAll");
                            if (query(".esriCTInnerRightPanelDetails")[0]) {
                                domClass.add(query(".esriCTInnerRightPanelDetails")[0], "displayNoneAll");
                            }
                            if (query(".esriCTGalleryContent")[0]) {
                                domClass.remove(query(".esriCTGalleryContent")[0], "displayNoneAll");
                            }
                            if (query(".esriCTInnerRightPanel")[0]) {
                                domClass.remove(query(".esriCTInnerRightPanel")[0], "displayNoneAll");
                            }
                            domClass.remove(query(".esriCTApplicationIcon")[0], "esriCTCursorPointer");
                            domClass.remove(query(".esriCTMenuTabLeft")[0], "esriCTCursorPointer");
                            topic.publish("queryItemPods");
                        }));
                    } else {
                        this.queryGroup().then(lang.hitch(this, function () {
                            var leftPanelObj = new LeftPanelCollection();
                            leftPanelObj.startup();
                        }));
                    }
                    domAttr.set(query(".signin")[0], "innerHTML", nls.signOutText);
                    domClass.replace(query(".esriCTSignInIcon")[0], "icon-logout", "icon-login");
                    if (def) {
                        def.resolve();
                    }
                }
            }), function (e) {
                if (e.httpCode === 403) {
                    alert(nls.errorMessages.notMemberOfOrg);
                    IdentityManager.destroyCredentials();
                }
            });
        }
    });
});

