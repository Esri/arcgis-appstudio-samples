import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0

Item {

    function makeNetworkConnection(url, obj, callback, params) {
        var component = networkRequestComponent;
        var networkRequest = component.createObject(parent);
        networkRequest.url = url;
        networkRequest.callback = callback;
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
            method: "GET"

            onReadyStateChanged: {
                if (readyState == NetworkRequest.DONE){
                    if (errorCode === 0) {
                        callback(response, params, errorCode);
                    } else {
                        callback(response, params, errorCode);
                    }
                }
            }

            onError: {
                callback({}, params, -1);
            }
        }
    }
}
