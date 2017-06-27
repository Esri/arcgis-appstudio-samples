/*global require,dojo,alert,dojoConfig */
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
require([
    "coreLibrary/widgetLoader",
    "application/appIncludes",
    "esri/config",
    "esri/request",
    "esri/urlUtils",
    "dojo/domReady!"
], function (WidgetLoader, appIncludesConfig, esriConfig, esriRequest, urlUtils) {

    try {

        /**
        * load application configuration settings from configuration file
        * create an object of widget loader class
        */

        var url = dojoConfig.baseURL + "/config.js";
        esriRequest({
            url: url,
            handleAs: "json",
            load: function (jsondata) {
                dojo.configData = jsondata;
                dojo.appConfigData = appIncludesConfig;
                var applicationWidgetLoader = new WidgetLoader();
                applicationWidgetLoader.startup();

                // Use the proxy for the portal if the proxy URL is provided
                if (dojo.configData.values.proxyUrl) {
                    urlUtils.addProxyRule({
                        urlPrefix: dojo.configData.values.portalURL,
                        proxyUrl: dojo.configData.values.proxyUrl
                    });
                }
            },
            error: function (err) {
                alert(err.message);
            }
        });
    } catch (ex) {
        alert(ex.message);
    }
});
