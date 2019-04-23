import QtQuick 2.9

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    id: root

    property string rootUrl: "";

    property string token: "";

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
                if (readyState == NetworkRequest.DONE) {
                    if (errorCode === 0)
                        callback(response, params, errorCode);
                    else
                        callback(response, params, errorCode);
                }
            }

            onError: {
                callback({}, params, -1);
            }
        }
    }

    function makeNetworkConnection(url, obj, callback, params) {
        var _component = networkRequestComponent;
        var _networkRequest = _component.createObject(parent);
        _networkRequest.url = url;
        _networkRequest.callback = callback;
        _networkRequest.params = params;
        _networkRequest.send(obj);
    }

    function requestWebScenes(q, num, start, sortField, sortOrder, callback) {
        var _url = rootUrl + "/search";

        var _obj = {
            q: q,
            num: num,
            start: start,
            sortField: sortField,
            sortOrder: sortOrder,
            f: "json"
        };

        if (token > "")
            _obj.token = token;

        makeNetworkConnection(_url, _obj, callback);
    }

    function getPortalInfo(callback) {
        var _url = rootUrl + "/portals/self";

        var _obj = {
            f: "json"
        }

        makeNetworkConnection(_url, _obj, callback);
    }

    function requestShortenedUrl(longUrl, callback) {
        var _url = "https://arcg.is/prod/shorten?longUrl=" + longUrl;

        makeXHRRequest(_url, "GET", callback);
    }

    function makeXHRRequest(networkRequestUrl, networkRequestMethod, callback) {
        var _xhr = new XMLHttpRequest();
        var _method = networkRequestMethod;
        var _url = networkRequestUrl;

        _xhr.open(_method, _url, true);
        _xhr.send();

        _xhr.onreadystatechange = function() {
            if (_xhr.readyState === _xhr.DONE && _xhr.status === 200)
                callback(_xhr);
        };
    }
}
