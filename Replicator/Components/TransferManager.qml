import QtQuick 2.7

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    property var sourcePortal
    property var destPortal

    property string _sourceRootURL: sourcePortal.url
    property string _sourceToken: sourcePortal.token
    property string _sourceItemId

    property string _destRootURL: destPortal.url
    property string _destToken: destPortal.token
    property string _destUsername: destPortal.username
    property string _destItemId

    property var _itemInfoTemplate
    property var _itemThumbnail

    property var requestProgress
    property string _action

    property var errorHandler

    property string loadingStatusString: ""

    /*--------------------------------------------------------------------------*/

    FileFolder{
        id: fileFolder

        path: "~/ArcGIS/AppTransfer/temp"

        Component.onCompleted: {
            makeFolder();
        }
    }

    Component {
        id: networkRequestComponent

        NetworkRequest {
            property var callback
            property var params
            property string action

            followRedirects: true
            ignoreSslErrors: true
            responseType: "json"
            method: "POST"

            onReadyStateChanged: {
                if (readyState == NetworkRequest.DONE){
                    if (errorCode === 0) {
                        callback(response, params);
                    } else {
                        console.log("ERROR"+ errorCode + ": Request Failed");
                        errorHandler();
                    }
                }
            }

            onProgressChanged: {
                requestProgress = (progress * 100).toFixed(0) + "%";
            }

            onError: {
                console.log(errorText + ", " + errorCode);
            }
        }
    }

    onRequestProgressChanged: {
        console.log(_action, requestProgress);
    }

    /*--------------------------------------------------------------------------*/

    function makeNetworkConnection(action, url, obj, method, responseType, path, callback, params) {
        var component = networkRequestComponent;
        var networkRequest = component.createObject(parent);
        networkRequest.url = url;
        networkRequest.callback = callback;
        if(path > "") networkRequest.responsePath = path;
        networkRequest.responseType = responseType;
        networkRequest.params = params;
        _action = getActionName(action);
        networkRequest.send(obj);
    }

    function getActionName(action) {
        var actionName = "";

        switch(action) {
        case 1:
            actionName = strings.action_1;
            break;
        case 2:
            actionName = strings.action_2;
            break;
        case 3:
            actionName = strings.action_3;
            break;
        case 4:
            actionName = strings.action_4;
            break;
        case 5:
            actionName = strings.action_5;
            break;
        }

        return actionName;
    }

    function getItemInfo(itemId, callback) {
        var url = _sourceRootURL + ("/sharing/rest/content/items/%1").arg(itemId);
        var obj = {
            f: "json",
            "token": _sourceToken
        }

        makeNetworkConnection(1, url, obj, "GET", "json", "", callback);
    }

    function downloadData(itemId, callback) {
        if(fileFolder.fileExists(itemId)) fileFolder.removeFile(itemId + ".zip");
        var path = [fileFolder.path, itemId + ".zip"].join("/");

        var url = _sourceRootURL + ("/sharing/rest/content/items/%1/data").arg(itemId);
        var obj = {
            "token": _sourceToken
        }

        makeNetworkConnection(2, url, obj, "GET", "zip", path, callback);
    }

    function downloadThumbnail(itemId, thumbnail, callback) {
        if(fileFolder.fileExists(itemId)) fileFolder.removeFile(itemId);
        var path = [fileFolder.path, itemId].join("/");

        var url = _sourceRootURL + ("/sharing/rest/content/items/%1/info/%2").arg(itemId).arg(thumbnail);
        var obj = {
            "token": _sourceToken
        }

        makeNetworkConnection(3, url, obj, "GET", "image", path, callback);
    }

    function cleanItemInfo(itemInfo) {
        itemInfo.id = undefined;
        itemInfo.name = undefined;
        itemInfo.owner = undefined;
        itemInfo.ownerFolder = undefined;

        console.log(JSON.stringify(itemInfo));

        return itemInfo;
    }

    function prepareItemInfo(itemInfo) {
        var keys = Object.keys(itemInfo);
        keys.forEach(function(key) {
            var value = itemInfo[key];

            if (Array.isArray(value)) {
                itemInfo[key] = value.join(", ");
            }
        });

        return itemInfo;
    }

    function addItem(itemInfo, callback) {
        var url = _destRootURL + "/sharing/rest/content/users/" + _destUsername + "/addItem";
        var obj = prepareItemInfo(cleanItemInfo(itemInfo));
        obj.token = _destToken;
        obj.f = "pjson";

        makeNetworkConnection(4, url, obj, "POST", "json", "", callback);
    }

    function updateItemContent(itemId, itemInfo, callback) {
        var url = _destRootURL + "/sharing/rest/content/users/" + _destUsername + "/items/%1/update".arg(itemId);

        var filePath = [fileFolder.path, itemId + ".zip"].join("/");
        var thumbnailPath = [fileFolder.path, "thumbnail.png"].join("/");

        if(fileFolder.fileExists(itemId+".zip")) fileFolder.removeFile(itemId+".zip");
        if(fileFolder.fileExists("thumbnail.png")) fileFolder.removeFile("thumbnail.png");

        fileFolder.renameFile(_sourceItemId + ".zip", itemId+".zip");
        fileFolder.renameFile(_sourceItemId, "thumbnail.png");


        var obj = prepareItemInfo(cleanItemInfo(itemInfo));
        obj.name = itemId + ".zip";
        obj.id = itemId;
        obj.token = _destToken;
        obj.f = "pjson";
        obj.file = "@"+filePath;
        obj.thumbnail = "@"+thumbnailPath;

        makeNetworkConnection(5, url, obj, "POST", "json", "", callback);
    }

    function transfer(itemId, callback) {
        if(!(itemId > "")) return;

        _sourceItemId = itemId;

        getItemInfo(_sourceItemId, function(sourceItemInfo) {
            _itemInfoTemplate = sourceItemInfo;
            _itemThumbnail = sourceItemInfo.thumbnail;

            downloadData(_sourceItemId, function() {
                downloadThumbnail(_sourceItemId, _itemThumbnail, function(){
                    addItem(_itemInfoTemplate, function(response){
                        _destItemId = response.id;
                        updateItemContent(_destItemId, _itemInfoTemplate, function(){
                            clearAllTempFiles();
                            callback();
                        });
                    })
                })
            })
        })
    }

    function clearAllTempFiles(){
        if(fileFolder.fileExists(_sourceItemId+".zip")) fileFolder.removeFile(_sourceItemId+".zip");
        if(fileFolder.fileExists(_sourceItemId)) fileFolder.removeFile(_sourceItemId);
        if(fileFolder.fileExists(_destItemId+".zip")) fileFolder.removeFile(_destItemId+".zip");
        if(fileFolder.fileExists("thumbnail.png")) fileFolder.removeFile("thumbnail.png");
    }
}
