/* Copyright 2019 Esri
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
import QtQuick 2.7

import ArcGIS.AppFramework 1.0

import Esri.ArcGISRuntime 100.7

//TODO: creating a portal item isn't the best option. Continue with json

Item {
    id: root

    property string portalUrl: "http://www.arcgis.com" //NB: This is reset in the method findItems()
    property var findItemsResults: []
    property bool isBusy: false
    property bool isOnline: Networking.isOnline
    property string token: ""
    property string referer: ""
    property string subFolder: "MapViewer"
    property string onlineFolder: "onlinecache"
    property string offlineFolder: "offlinecache"
     property string offlineMapAreaFolder: "mapareas"

    signal updateModel

    signal requestSuccess(var results, int errorCode, string errorMsg)
    signal requestError(int errorCode, string errorMsg)

    onRequestSuccess: {
        var resultsArray = []
        for (var i=0; i<results.length; i++) {
            var portalItem = results[i]

            if (!portalItem.url) portalItem.url = "%1/sharing/rest/content/items/%2".arg(portal.url).arg(portalItem.id)
            portalItem.url = portalItem.url + "?token=%1".arg(root.token)
            portalItem.token = root.token
            portalItem.thumbnailUrl = onlineCacheManager.cache(root.getThumbnailUrl(portalUrl, portalItem, root.token), "", {"token": token}, null)
            if (isOnline) {
                resultsArray.push(portalItem)
            } else if (portalItem.type === "Mobile Map Package") {
                mmpkManager.itemId = portalItem.id
                if (mmpkManager.hasOfflineMap()) {
                    resultsArray.push(portalItem)
                }
            }
        }

        resultsArray.forEach(function(element) {
            var obj = findItemsResults.filter(item => item.id === element.id)
            if(obj.length === 0)
            findItemsResults.push(element);
          });
        root.isBusy = false
        updateModel()
    }

    onRequestError: {
        root.isBusy = false
    }

    MmpkManager {
        id: mmpkManager

        rootUrl: "%1/sharing/rest/content/items/".arg(portalUrl)
        subFolder: offlineCacheManager.subFolder
    }

    NetworkCacheManager {
        id: onlineCacheManager

        referer: root.referer
        subFolder: [root.subFolder, onlineFolder].join("/")
    }

    NetworkCacheManager {
        id: offlineCacheManager

        referer: root.referer
        subFolder: [root.subFolder, offlineFolder].join("/")
    }
    function clearResults()
    {
        findItemsResults = []
    }

    function findItems (portalUrl, queryParameters, token) {
        root.isBusy = true
        var paramsObj = {
            //"token": token,
            "sortField": queryParameters.sortField,
            "sortOrder": queryParameters.sortOrder === 0 ? "asc" : "desc",
            "num": queryParameters.limit,
            "f": "pjson",
            "q": constructQuery (queryParameters.searchString,
                                 queryParameters.types)
        }
        var urlSuffix = constructUrlSuffix (paramsObj)
        root.portalUrl = portalUrl      
        if (token)
            root.token = token
        else
            root.token = ""
        var url = "%1/sharing/rest/search?%2".arg(root.portalUrl).arg(urlSuffix)

        if (isOnline) {
            onlineCacheManager.clearAllCache()//Cache(url)
        }
        var obj = {"token": root.token}
        search (url, obj)
    }

    //-------------------------------------------------------------------------------
    property string url
    property var obj

    function search (url, obj) {
        root.isBusy = true
        root.url = url
        root.obj = obj

        onlineCacheManager.cacheJson(url, obj, null, function (errorCode, errorMsg) {
            if (errorCode === 0) {
                var cacheName = Qt.md5(url),
                    temp = onlineCacheManager.readLocalJson(cacheName)
                    if (temp) {
                        var results = JSON.parse(temp)["results"]
                        requestSuccess(results, errorCode, errorMsg)
                    } else {
                        requestError(errorCode, errorMsg)
                    }
            } else {
                requestError(errorCode, errorMsg)
            }
        })
    }

    function refresh () {
        updateModel()


    }

    //-------------------------------------------------------------------------------

    function constructUrlSuffix (obj) {
        var urlSuffix = ""
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
                if (obj[key]) {
                    urlSuffix += "%1=%2&".arg(key).arg(obj[key])
                }
            }
        }
        return urlSuffix.slice(0, -1)
    }

    function constructQuery (searchString, itemTypes) {

        var query = '-type:"Tile Package" -type:"Web Mapping Application" ' +
                    '-type:"Map Service" -type:"Map Template" -type:"Type Map Package"' +
                    ' type:Maps AND type:'

        for (var i=0; i<itemTypes.length; i++) {
            if (i !== 0) query += ' OR type:'
            switch (itemTypes[i]) {
            case Enums.PortalItemTypeMobileMapPackage:
                query += '"Mobile Map Package"'
                break
            case Enums.PortalItemTypeWebMap:
                query += '"Web Map"'
                break
            }
        }

        if (searchString) query += " %1".arg(searchString)

        return query
    }

    function getThumbnailUrl (portalUrl, portalItem, token) {
        try {
            if (portalItem.thumbnailUrl) return portalItem.thumbnailUrl
        } catch (err) {}

        var imgName = portalItem.thumbnail
        if (!imgName) {
            return ""
        }
        var urlFormat = "%1/sharing/rest/content/items/%2/info/%3%4",
                prefix = ""
        if (token) {
            //prefix = "?token=%1".arg(token) // Ignoring the token. Letting NetworkCacheManager handle it
        }
        return urlFormat.arg(portalUrl).arg(portalItem.id).arg(imgName).arg(prefix)
    }
}
