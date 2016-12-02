/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.5

import ArcGIS.AppFramework 1.0

HockeyApp {

    property App app: parent
    property FileFolder fileFolder: FileFolder{ path: app.folder.path + "/AppMetrics" }
    property string releaseType
    property var ids
    property string configFile: "appmetrics.json"

    //--------------------------------------------------------------------------

    enabled: AppFramework.network.isOnline

    sdkVersion: "AppStudio (%1):%2".arg(Qt.platform.os).arg(AppFramework.version)
    osName: AppFramework.osDisplayName
    osVersion: AppFramework.osVersion

    appVersion: app.info.version
    appId: "" // lookupId(os, releaseType, "appId", "")
    appPackageId: "" // lookupId(os, releaseType, "packageId", "")

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        if (!(deviceId > "")) {
            deviceId = readUdid();
        }

        readConfig();
        appId = lookupId(os, releaseType, "appId", "");
        appPackageId = lookupId(os, releaseType, "packageId", "");
    }

    //--------------------------------------------------------------------------

    createUuid: function() {
        return AppFramework.createUuidString(2);
    }

    //--------------------------------------------------------------------------

    function readUdid() {
        var udid = app.settings.value("udid", "");
        if (!(udid > "")) {
            udid = AppFramework.createUuidString(2);
            app.settings.setValue("udid", udid);

            console.log("App UDID generated:", udid);
        }

        return udid;
    }

    //--------------------------------------------------------------------------

    function readConfig() {
        if (!fileFolder.fileExists(configFile)) {
            console.warn("Config file not found:", configFile);
            return;
        }

        var config = fileFolder.readJsonFile(configFile);

        if (debug) {
            console.log("AppMetrics config:", JSON.stringify(config, undefined, 2));
        }

        if (!(token > "") && config.token > "") {
            token = config.token;
        }

        if (!ids && config.ids) {
            ids = config.ids;
            console.log(JSON.stringify(config.ids));
        }
    }

    //--------------------------------------------------------------------------

    function lookupId(os, releaseType, name, defaultValue) {
        //console.log("os:", os, "releaseType:", releaseType, "data:", JSON.stringify(ids[releaseType][os]));

        if (!ids) {
            console.error("Undefined ids");
            return defaultValue;
        }

        if (releaseType > "") {
            return ((ids[releaseType] || {})[os] || {})[name] || defaultValue;
        } else {
            return (ids[os] || {})[name] || defaultValue;
        }
    }

    //--------------------------------------------------------------------------
}
