import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.1
import QtQml 2.2
import Qt.labs.settings 1.0

import ArcGIS.AppFramework 1.0


Item {

    id: root
    property string trackingId : ""
    property string clientId: ""
    property string appVersion: ""
    property string apiVersion: AppFramework.version
    property string appName: ""
    property int appWidth : 0
    property int appHeight : 0
    property int screenOrientation: Screen.orientation
    property real pixelDensity: Screen.logicalPixelDensity
    property int scaleFactor : AppFramework.displayScaleFactor
    property string os: Qt.platform.os
    property string osVersion: AppFramework.osVersion
    property string network: AppFramework.network.defaultConfiguration.name || ""
    property string positionSources: AppFramework.device.availablePositionSources.toString()
    property string locale : Qt.locale().name

    anchors.fill: parent

    property string uuid : ""

    Settings {
        id: settings
        property string uuid
    }

    Component.onCompleted: {
        settings.synchronize();
        console.log("####", settings.uuid);
        if(!settings.uuid) {
            settings.uuid = AppFramework.createId()
        }
        clientId = settings.uuid;
        console.log("######", clientId)


    }

    NetworkRequest {
        id: networkRequest
        //url: "http://52.5.49.28:8080/" + trackingId
        url: "http://appstudio.arcgis.com/analytics/" + trackingId
        method: "POST"
        ignoreSslErrors: true
        responseType: "json"

        onError: {
            console.log("#### ERROR #####")
            console.log(errorCode, errorText);
        }

        onReadyStateChanged: {
            if ( readyState === NetworkRequest.DONE ) {
                console.log("#### DONE #####")
                console.log(responseText);
                console.log(JSON.stringify(response, undefined, 2));
            }
        }


    }

    function ready() {

        var data = {};
        data.name = trackingId

        appWidth = root.width
        appHeight = root.height

        data.columns = ["apiVersion","version","width","height","uuid","displayScaleFactor","title","pixelDensity","screenOrientation","os","osVersion","locale","network","positionSources"]
        data.points = [[apiVersion,appVersion,appWidth,appHeight,clientId,scaleFactor,appName,pixelDensity,screenOrientation,os,osVersion,locale,network,positionSources]];

        //_sendData([data]);

        var data2 = {
            "apiVersion" : apiVersion,
            "version":appVersion,
            "width":appWidth,
            "height":appHeight,
            "uuid":clientId,
            "displayScaleFactor":scaleFactor,
            "title":appName,
            "pixelDensity":pixelDensity,
            "screenOrientation":screenOrientation,
            "os":os,
            "osVersion":osVersion,
            "sslVersion": AppFramework.sslLibraryVersion,
            "locale":locale,
            "network":network,
            "positionSources":positionSources,
            "ip": AppFramework.network.addresses && AppFramework.network.addresses.length > 0? AppFramework.network.addresses[0].address : "",
            "player": AppFramework.player ? true : false
        };

        console.log(JSON.stringify(data2))

        networkRequest.send(data2);

    }

    function _sendData(data){

        if(!AppFramework.network.isOnline) {
            console.log("App is offline, cannot send analytics!");
            return false;
        }

        if(trackingId=="" || clientId == ""){
            console.log("!!! Tracker not initialized");
            return false;
        }

        //console.log(data);

        var request = new XMLHttpRequest()
        request.onreadystatechange = function() {
            if (request.readyState == 4) {
                var response = request.responseText
                console.log(JSON.stringify(request.getAllResponseHeaders()));
                console.log("!!! Tracking " + JSON.stringify(request.status));
                console.log(JSON.stringify(request.statusText))
                console.log(request.responseText);
                console.log(JSON.stringify(data));
                //console.log("!!! Tracking "+data+" !!! " + response); //usually is a GIF
            }
        }

        //var url = "http://52.4.29.41:8086/db/appstats/" + trackingId + "?u=stats&p=stats"
        var url = "http://52.4.29.41:8086/db/appstats/series?u=stats&p=stats";
        //console.log(url);

        console.log(JSON.stringify(data,null,2));

        request.open("POST", url, true);
        request.send(JSON.stringify(data));
        return true;
    }

}
