import QtQuick 2.3
import QtQuick.Controls 1.2
import QtPositioning 5.2

import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    property url url: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
    readonly property bool suggestRunning: internal.suggestRequest != null
    readonly property bool findRunning: internal.findRequest != null

    property var suggestions: []

    property alias locationsSpatialReference: locationsSpatialReference
    property var locations: []

    property SpatialReference outputSpatialReference


    QtObject {
        id: internal

        property var suggestRequest: null
        property var findRequest: null
    }

    SpatialReference {
        id: locationsSpatialReference
    }

    //--------------------------------------------------------------------------

    function suggest(text, location, distance) {

        suggestions = [];

        if (internal.suggestRequest) {
            internal.suggestRequest.abort();
        }

        internal.suggestRequest = new XMLHttpRequest();
        //internal.suggestRequest.uuid = AppFramework.createId();
        internal.suggestRequest.onreadystatechange = _suggest_onReadyStateChange;

        var suggestUrl = url + "/suggest?" +
                "text=" + text +
                "&location=" + location.x.toString() + "%2C" + location.y.toString() +
                "&distance=" + distance.toString() +
                "&f=json";

        //console.log("suggest", suggestUrl);
        internal.suggestRequest.open("GET", suggestUrl, true);
        internal.suggestRequest.send();
    }

    function _suggest_onReadyStateChange()
    {
        if (internal.suggestRequest.readyState === internal.suggestRequest.DONE)
        {
            if (internal.suggestRequest.status === 200)
            {
                //console.log("suggestions response", internal.suggestRequest.responseText);
                suggestions = JSON.parse(internal.suggestRequest.responseText).suggestions;
                //console.log("suggestions", JSON.stringify(suggestions, undefined, 2));
            } else {
                //console.log("suggestRequest Status", internal.suggestRequest.status);
                suggestions = [];
            }
        }
    }

    //--------------------------------------------------------------------------

    function suggestCancel() {
        if (internal.suggestRequest) {
            internal.suggestRequest.abort();
            internal.suggestRequest = null;
        }
    }

    //--------------------------------------------------------------------------

    function findSuggestion(index) {
        if (index < 0 || index >= suggestions.length) {
            console.error("findSuggestion: Invalid index", index);
            return false;
        }

        var suggestion = suggestions[index];

        find(suggestion.text, suggestion.magicKey);

        return true;
    }

    //--------------------------------------------------------------------------

    function find(text, magicKey) {
        if (internal.findRequest) {
            internal.findRequest.abort();
        }

        internal.findRequest = new XMLHttpRequest();
        internal.findRequest.onreadystatechange = function()
        {
            if (internal.findRequest.readyState === internal.findRequest.DONE)
            {
                if (internal.findRequest.status === 200)
                {
                    var json = JSON.parse(internal.findRequest.responseText);

                    locationsSpatialReference.json = json.spatialReference;
                    locations = json.locations;
                } else {
                   // locations = [];
                   // console.log("findRequest Status", internal.suggestRequest.status);
                }
            }
        }

        var findUrl = url + "/find?" +
                "text=" + text +
                "&magicKey=" + magicKey +
                "&f=json";

        if (outputSpatialReference) {
            findUrl += "&outSR=" + outputSpatialReference.wkid.toString();
        }

        //console.log(findUrl);
        internal.findRequest.open("GET", findUrl, true);
        internal.findRequest.send();
    }
}
