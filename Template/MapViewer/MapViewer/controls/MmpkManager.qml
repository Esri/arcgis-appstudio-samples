import QtQuick 2.5
import QtQuick.Controls 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0


Item {
    id: mmpkManager
    property string itemId: ""
    property string itemName: itemId > "" ? "%1.mmpk".arg(itemId) : ""
    property string token: ""
    property string rootUrl: "http://www.arcgis.com/sharing/rest/content/items/"
    property url fileUrl: [fileFolder.url, itemName].join("/")
    property string subFolder: "MapViewer"
    property int loadStatus: -1 //unknow = -1, loaded = 0, loading = 1, failed to load = 2
    property bool offlineMapExist: hasOfflineMap()
    property real size: fileFolder.fileInfo(itemName).size

    property string errorText: ""

   property var fileFolder:fileInfo.folder
    property string storageBasePath: "~/ArcGIS/AppStudio/Cache"
    property string storagePath: subFolder && subFolder>"" ? storageBasePath + "/" + subFolder : storageBasePath
    property var fileInfo : AppFramework.fileInfo(storagePath);

    Component.onCompleted: {

        fileFolder.path = storagePath
        if(!fileFolder.exists){
            fileFolder.makeFolder(storagePath);
        }
        if (!fileFolder.fileExists(".nomedia") && Qt.platform.os === "android") {
            fileFolder.writeFile(".nomedia", "")
        }

        hasOfflineMap();
    }

    function downloadOfflineMap(callback){
        mmpkManager.errorText = ""
        if(itemId>""){
            Platform.stayAwake = true
            var component = typeNetworkRequestComponent;
            var networkRequest = component.createObject(parent);
            var url = rootUrl+itemId+"?f=json&token="+token;
            networkRequest.checkType(url, callback);
        }

    }

    function updateOfflineMap(callback){
        if(offlineMapExist){
            downloadOfflineMap(callback);
        }
    }

    function hasOfflineMap(){

        offlineMapExist = fileInfo.folder.fileExists(itemName)
        getSize()
        return offlineMapExist;
    }

    function deleteOfflineMap(callback){

        if(fileFolder.fileExists("~"+itemName))fileFolder.removeFile("~"+itemName);
        if(fileFolder.fileExists(itemName))fileFolder.removeFile(itemName);
        hasOfflineMap();
        if (callback) callback()
    }

    Component{
        id: typeNetworkRequestComponent
        NetworkRequest{
            id: typeNetworkRequest

            property var callback

            method: "GET"
            ignoreSslErrors: true

            onErrorTextChanged: mmpkManager.errorText = errorText

            onReadyStateChanged: {
                if (readyState === NetworkRequest.DONE ){

                    if(errorCode != 0){
                        loadStatus = 2;
                        //console.log(errorCode, errorText);
                    } else {
                        //console.log("Type Response", responseText)
                        var root = JSON.parse(responseText);
                        if(root.type == "Mobile Map Package"){
                            loadStatus = 1;
                            var component = networkRequestComponent;
                            var networkRequest = component.createObject(parent);
                            var url = rootUrl+itemId+"/data?token="+token;

                            var path = [fileFolder.path, "~"+itemName].join("/");

                            networkRequest.downloadFile("~"+itemName, url, path, typeNetworkRequest.callback);
                        } else {
                            loadStatus = 2;
                        }
                    }
                    if (callback) callback ()
                }                
            }
            onError:{
                Platform.stayAwake=false
            }

            function checkType(url, callback){
                typeNetworkRequest.url = url;
                typeNetworkRequest.callback = callback;
                typeNetworkRequest.send();
                loadStatus = 1;
            }
        }
    }

    Component{
        id: networkRequestComponent
        NetworkRequest{
            id: networkRequest

            property var name;
            property var callback;

            method: "GET"
            ignoreSslErrors: true

            onErrorTextChanged: mmpkManager.errorText = errorText

            onReadyStateChanged: {
                if (readyState === NetworkRequest.DONE ){

                    if(errorCode != 0){

                        fileFolder.removeFile(networkRequest.name);
                        loadStatus = 2;
                        //console.log(errorCode, errorText);
                    } else {
                        loadStatus = 0;
                        if(hasOfflineMap()) fileFolder.removeFile(itemName);
                        fileFolder.renameFile(name, itemName);

                        hasOfflineMap();

                        if (callback) {
                            callback();
                        }
                    }
                }
            }

            function downloadFile(name, url, path, callback){
                networkRequest.name = name;
                networkRequest.url = url;
                networkRequest.responsePath = path;
                networkRequest.callback = callback;
                networkRequest.send();
                loadStatus = 1;
            }
        }
    }

    function getSize () {
        size = fileFolder.fileInfo(itemName).size
    }
}
