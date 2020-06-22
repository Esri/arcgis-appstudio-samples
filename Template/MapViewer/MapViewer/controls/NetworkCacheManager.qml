import QtQuick 2.5
import QtQuick.Controls 1.2

import ArcGIS.AppFramework 1.0


Item {
    id: networkCacheManager

    property string subFolder: ""
    property string returnType
    property string referer: ""
    property string userAgent: networkCacheManager.buildUserAgent(app)
    property string storageBasePath: "~/ArcGIS/AppStudio/Cache"
    property string storagePath: subFolder && subFolder>"" ? storageBasePath + "/" + subFolder  + "/": storageBasePath
    property var fileInfo : AppFramework.fileInfo(storagePath);
    property var fileFolder:fileInfo.folder



    Component {
        id: fileFolderComponent
        FileFolder{
            url: networkCacheManager.fileInfo.folder.url
        }
    }

    function flagForDeletion (fname, callback) {
        var flaggedForDeletion = app.settings.value("flaggedForDeletion", "")
        if (flaggedForDeletion) {
            if (flaggedForDeletion.indexOf(fname) === -1) {
                app.settings.setValue("flaggedForDeletion", "%1,%2".arg(flaggedForDeletion).arg(fname))
            }
        } else {
            app.settings.setValue("flaggedForDeletion", fname)
        }
        if (callback) callback()
    }

    function removeFlaggedFiles () {
        var flaggedFiles = app.settings.value("flaggedForDeletion")
        app.settings.setValue("flaggedForDeletion", "")
        if (flaggedFiles) {
            var fileList = flaggedFiles.split(",")
            for (var i=0; i<fileList.length; i++) {
                if (fileFolder.fileExists(fileList[i])) {
                    removeFile(fileList[i])
                }
            }
        }
    }

    function getCacheSizeRecursively (currentSize, folder) {
        // This does 2 levels at the moment.
        if (!currentSize) currentSize = 0
        if (!folder) folder = fileFolderComponent.createObject(null)
        currentSize += getCacheSize(folder)
        var folderNames = folder.folderNames()

        for (var i=0; i<folderNames.length; i++) {
            var subFolder = fileFolderComponent.createObject(null)
            subFolder.url = [folder.url, folderNames[i]].join("/")
            currentSize += getCacheSize(subFolder)
        }

        if (typeof subFolder !== "undefined") subFolder.destroy()
        return currentSize
    }

    function getCacheSize (fileFolder) {
        if (!fileFolder) fileFolder = networkCacheManager.fileInfo.folder
        var filenames = fileFolder.fileNames().toString().split(","),
            size = 0,
            flaggedFiles = app.settings.value("flaggedForDeletion", "").split(",")

        for (var i=0; i<filenames.length; i++) {
            if (flaggedFiles.indexOf(filenames[i]) === -1) {
                size += fileFolder.fileInfo(filenames[i]).size
            }
        }
        return size
    }

    function getFileSize (filename) {
        let fileFolder = fileInfo.folder
        var flaggedFiles = app.settings.value("flaggedForDeletion", "").split(",")
        if (flaggedFiles.indexOf(filename) === -1) {
            return fileFolder.fileInfo(filename).size
        } else {
            return 0
        }
    }

    function hasFile (url, alias) {
        let fileFolder = fileInfo.folder
        if (!(alias > "")) alias = url
        var result = url
        var cacheName = Qt.md5(alias)
        return fileFolder.fileExists(cacheName)
    }

    function cache(url, alias, obj, callback){

        if(!(alias>"")) alias = url;
        var result = url
        var cacheName = Qt.md5(alias)

        //console.log("**** NM:cache :: for  ", url, alias, cacheName)

        if(!fileFolder.fileExists(cacheName)){
            //console.log("**** NM:cache :: no cache, creating new ...");
            var component = networkRequestComponent;
            var networkRequest = component.createObject(parent);

            networkRequest.downloadImage(url, obj , cacheName, fileFolder.path, callback);
        } else{
            var cacheUrl = [fileFolder.url, cacheName].join("/");
            //console.log("####cacheUrl####", cacheUrl);
            result = cacheUrl;
        }

        return result;
    }

    function removeFile (fname) {
        let fileFolder = fileInfo.folder
        var success = fileFolder.removeFile(fname)
        //console.log("###### Removing file ", fname, success)
        if (!success) {
            success = fileFolder.removeFolder(fname, true)
            if (!success) flagForDeletion(fname)
        }
    }

    function clearAllCache(fileFolder, callback){
        if (!fileFolder) fileFolder = networkCacheManager.fileInfo.folder
        var fileNames = fileFolder.fileNames();
        //console.log("**** NM:clearAllCache :: Total files ", names.length)
        for(var i=0; i<fileNames.length; i++){
            removeFile(fileNames[i])
        }
        var folderNames = fileFolder.folderNames()
        for (var j=0; j<folderNames.length; j++) {
            fileFolder.removeFolder(folderNames[j], true)
        }
        if (callback) callback ()
    }

    function isCached(alias){
        let fileFolder = fileInfo.folder
        var name = Qt.md5(alias);
        //console.log("**** NM: isCached : ", alias)
        return fileFolder.fileExists(name);
    }

    function clearCache(alias){
        let fileFolder = fileInfo.folder
        var name = Qt.md5(alias);
        return fileFolder.removeFile(name);
    }

    function deleteCacheName(cacheName){
        let fileFolder = fileInfo.folder
        return fileFolder.removeFile(cacheName);
    }

    function refreshCache(url, alias, callback){
        if(!(alias>"")) alias = url;
        if(isCached(alias)){
            clearCache(alias);
        }
        //console.log("**** NM: url : ", url);
        if(callback) {
            cache(url, alias, callback);
        } else {
            return cache(url,alias);
        }
    }

    function cacheJson(url, obj, alias, callback){
        let fileFolder = fileInfo.folder
        if(!(alias>"")) alias = url;
        var cacheName = Qt.md5(alias)

        //console.log("**** NM:cache :: for  ", url, alias, cacheName)

        if(!fileFolder.fileExists(cacheName)){
            //console.log("**** NM:cache :: no cache, creating new ...");
            var component = networkRequestComponent;
            var networkRequest = component.createObject(parent);
            networkRequest.requestCompleted.connect(networkRequest.destroy)
            let fpath = fileFolder.path

            networkRequest.downloadImage(url, obj, cacheName, fpath, callback);
        } else{
            var cacheUrl = [fileFolder.url, cacheName].join("/");
            //console.log("####cacheUrl####", cacheUrl);
            var result = fileFolder.readTextFile(cacheName);
            callback(0, "");
        }
    }

    function readLocalJson(cacheName){
        let fileFolder = fileInfo.folder
        var result = fileFolder.readTextFile(cacheName);
        return result;
    }

    Component.onCompleted: {

        fileFolder.path = storagePath
        if(!fileFolder.exists){
            fileFolder.makeFolder(storagePath);
        }
        if (!fileFolder.fileExists(".nomedia") && Qt.platform.os === "android") {
            fileFolder.writeFile(".nomedia", "")
        }
        removeFlaggedFiles()
    }

    Component{
        id: networkRequestComponent
        NetworkRequest{
            id: networkRequest

            property string name;
            property var callback;

            signal requestCompleted ()

            responseType: networkCacheManager.returnType
            method:"POST"

            headers.referer: networkCacheManager.referer
            headers.referrer: networkCacheManager.referer
            headers.userAgent: networkCacheManager.userAgent

            onReadyStateChanged: {

                var fileName = name;
                if (readyState === NetworkRequest.DONE ){
                    //console.log("####error####", errorCode, networkRequest.url);
                    if(errorCode != 0){
                        fileFolder.removeFile(networkRequest.name);
                        try {
                            callback(errorCode, errorText);
                        } catch (err) {}
                    } else{
                        //console.log("**** NM: download successful", networkRequest.name, fileName);
                        var json = fileFolder.readJsonFile(networkRequest.name);
                        if(json.error!=null){
                            var code = json.error.code;
                            var message = json.error.message;
                            fileFolder.removeFile(networkRequest.name);
                            callback(code, message);
                        } else{
                            if(callback!=null){
                                callback(0, "");
                            }
                        }
                    }
                    requestCompleted()
                }
            }

            function downloadImage(url, obj, name, fileFolderPath, callback) {
                if (url) {
                    networkRequest.url = url;
                    networkRequest.callback = callback;
                    //console.log("####PATH####", name)
                    networkRequest.name = name;
                    networkRequest.responsePath = [fileFolderPath, name].join("/");
                    networkRequest.send(obj);
                }
            }
        }
    }

    function buildUserAgent(app) {
        var userAgent = "";

        function addProduct(name, version, comments) {
            if (!(name > "")) {
                return;
            }

            if (userAgent > "") {
                userAgent += " ";
            }

            name = name.replace(/\s/g, "");
            userAgent += name;

            if (version > "") {
                userAgent += "/" + version.replace(/\s/g, "");
            }

            if (comments) {
                userAgent += " (";

                for (var i = 2; i < arguments.length; i++) {
                    var comment = arguments[i];

                    if (!(comment > "")) {
                        continue;
                    }

                    if (i > 2) {
                        userAgent += "; "
                    }

                    userAgent += arguments[i];
                }

                userAgent += ")";
            }

            return name;
        }

        function addAppInfo(app) {
            var deployment = app.info.value("deployment");
            if (!deployment || typeof deployment !== 'object') {
                deployment = {};
            }

            var appName = deployment.shortcutName > ""
                    ? deployment.shortcutName
                    : app.info.title;

            var udid = app.settings.value("udid", "");

            if (!(udid > "")) {
                udid = AppFramework.createUuidString(2);
                app.settings.setValue("udid", udid);
            }

            appName = addProduct(appName, app.info.version, Qt.locale().name, AppFramework.currentCpuArchitecture, udid)

            return appName;
        }

        if (app) {
            addAppInfo(app);
        } else {
            addProduct(Qt.application.name, Qt.application.version, Qt.locale().name, AppFramework.currentCpuArchitecture, Qt.application.organization);
        }

        addProduct(Qt.platform.os, AppFramework.osVersion, AppFramework.osDisplayName);
        addProduct("AppFramework", AppFramework.version, "Qt " + AppFramework.qtVersion, AppFramework.buildAbi);
        addProduct(AppFramework.kernelType, AppFramework.kernelVersion);

        // console.log("userAgent:", userAgent);

        return userAgent;
    }
}
