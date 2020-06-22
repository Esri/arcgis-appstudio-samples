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
import ArcGIS.AppFramework.SecureStorage 1.0

Item {
    id: root

    property bool isRunningInPlayer: true

    Component.onCompleted: {
        if (parent) {
            if (AppFramework.typeOf(parent, true) === "AppLoader") {
                var portal = parent.portal
                if (portal) {
                    //console.log("#### AppStudio Player username: " + portal.username)
                    isRunningInPlayer = true
                }
            } else {
                //console.log("#### Different Player")
                isRunningInPlayer = true
            }
        } else {
            isRunningInPlayer = false
        }
    }

    function hashKey (originalKey) {
        var id = (app.info.itemInfo.id || "") + (isRunningInPlayer ? "" : "1")
        return Qt.md5(originalKey + id)
    }

    function setContent (originalKey, value, storageAPI) {
        if (!storageAPI) storageAPI = SecureStorage
        clearContent(originalKey, storageAPI)

        var key = hashKey(originalKey)

        var maxChars = storageAPI.maximumValueLength;
        var lookupKeys = ""
        var quotient = Math.floor(value.length/maxChars)
        var remainder = value.length % maxChars

        for (var i=0; i < quotient; i++) {
            var lookupKey = "%1%2".arg(key).arg(i)
            var lookupValue = value.slice(i*maxChars,(i+1)*maxChars)

            lookupKeys = lookupKeys.length === 0 ? lookupKey : "%1,%2".arg(lookupKeys).arg(lookupKey)
            storageAPI.setValue(lookupKey, lookupValue)
        }

        if (remainder) {
            lookupKey = "%1%2".arg(key).arg(i+1)
            lookupValue = value.slice((i)*maxChars)

            lookupKeys = lookupKeys.length === 0 ? lookupKey : "%1,%2".arg(lookupKeys).arg(lookupKey)
            storageAPI.setValue(lookupKey, lookupValue)
        }

        app.settings.setValue(key, lookupKeys)
    }

    function getContent (originalKey, storageAPI) {
        if (!storageAPI) storageAPI = SecureStorage
        var key = hashKey(originalKey)

        var lookupKeysString = app.settings.value(key)

        if (!lookupKeysString) return ""

        var lookupKeys = lookupKeysString.split(",")
        var value = ""

        for (var i=0; i<lookupKeys.length; i++) {
            if (lookupKeys[i]) {
                value += storageAPI.value(lookupKeys[i])
            }
        }

        return value
    }

    function clearContent (originalKey, storageAPI) {
        if (!storageAPI) storageAPI = SecureStorage

        var key = hashKey(originalKey)

        var lookupKeysString = app.settings.value(key)
        if (!lookupKeysString) return

        var lookupKeys = lookupKeysString.split(",")

        for (var i=0; i<lookupKeys.length; i++) {
            if (lookupKeys[i]) {
                storageAPI.setValue(lookupKeys[i], "")
            }
        }
        app.settings.setValue(key, "")
    }
}
