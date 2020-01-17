import QtQuick 2.7

import ArcGIS.AppFramework 1.0

Item {
    property string rootUrl: portalA.url
    property string token: portalA.token
    property string owner: portalA.username

    //===================================================================================

    function makeNetworkConnection(url, obj, callback, method, params) {
        var component = networkRequestComponent;
        var networkRequest = component.createObject(parent);
        networkRequest.url = url;
        networkRequest.callback = callback;
        if(method > "") networkRequest.method = method;
        networkRequest.params = params;
        networkRequest.send(obj);
    }

    Component {
        id: networkRequestComponent

        NetworkRequest {
            property var callback
            property var params

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
                    }
                }
            }

            onError: {
                console.log(errorText + ", " + errorCode);
            }
        }
    }

    //===================================================================================

    function getApps(start, isMyApps, callback){
        var url = rootUrl + "/sharing/rest/search";
        var query = (isMyApps? "owner:%1 ".arg(owner) : "") +"((type:\"Native Application\" AND NOT type:\"Native Application Installer\") OR (tags:\"app\" AND tags:\"qml\" AND type:\"Code Sample\")) AND (access:shared OR access:private OR access:org OR (orgid:%1 AND access:public))".arg(portalA.user.orgId)
        var obj = {
            "start": start,
            "num": "25",
            "sortField": "modified",
            "sortOrder": "desc",
            "q": query,
            "f": "json",
            "token": token
        }

        makeNetworkConnection(url, obj, callback, "GET");
    }
}
