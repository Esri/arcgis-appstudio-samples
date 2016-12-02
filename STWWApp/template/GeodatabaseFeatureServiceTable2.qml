import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "LocalStorage.js" as LocalStorage

GeodatabaseFeatureServiceTable {
    function fieldArray() {
        var array = [];
        for (var i = 0; i < fields.length; i++) {
             array.push(fields[i]);
        }
        for (var i = 0; i < featureTypes.length; i++) {
             //array.push(featureTypes[i]);
            //array.push(featureTypes[i].domains);
            array.push( { "name": featureTypes[i].domains[0] });
        }
        return array;
    }

    function lookupField(name) {
        return fieldArray().filter(function(e) { return e.name == name; })[0];
    }

}
