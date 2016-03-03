// Copyright 2015 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the Sample code usage restrictions document for further information.
//
//------------------------------------------------------------------------------

import QtGraphicalEffects 1.0
import QtPositioning 5.3
import QtSensors 5.0
import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0


//------------------------------------------------------------------------------

Item {
    id: _root

    property string featureServiceURL : app.info.propertyValue("featureServiceURL","");
    property var objectIdToEdit
    property string addButtonClicked: "no item"
    property var foundFeatureIds: null
    property int hitFeatureId
    property bool featureAdded
    property bool featureSelected: false
    property var mapPoint
    property var selectedId
    //property alias queriedFeaturesModel: queriedFeaturesModel

    ListModel {
        id: queriedFeaturesModel
    }

    RectHeader {
        id: rectHeader
    }

    //MAP
    Map {
        id: map
        width: parent.width
        height: parent.height - rectHeader.height
        anchors.bottom: parent.bottom
        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: false
        mapPanningByMagnifierEnabled: true
        zoomByPinchingEnabled: true
        extent: envelopeInitalExtent

        //INITIAL EXTENT
        Envelope {
            id: envelopeInitalExtent
            xMax: -13630134.691272736
            yMax: 4554320.7069897875
            xMin: -13647294.804122735
            yMin: 4535211.44991852
            spatialReference: map.spatialReference
        }

        //BASEMAP
        ArcGISTiledMapServiceLayer {
            url: app.info.propertyValue("basemapServiceUrl", "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        }

        //CREATE A FEATURE SERVICE TABLE FROM A FEATURE SERVICE
        GeodatabaseFeatureServiceTable {
            id: featureServiceTable
            url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Wildfire/FeatureServer/0"

            onApplyFeatureEditsStatusChanged: {
                if (applyFeatureEditsStatus === Enums.ApplyEditsStatusCompleted) {
                    console.log("applied feature edits completed");
                }
                if (applyFeatureEditsStatus === Enums.ApplyEditsStatusErrored) {
                    console.log("applied feature edits errored");
                }
                if (applyFeatureEditsStatus === Enums.ApplyEditsStatusInProgress) {
                    console.log("applied feature edits in progress");
                }
                if (applyFeatureEditsStatus === Enums.ApplyEditsStatusReady) {
                    console.log("applied feature edits ready");
                }
            }
        }

        //CREATE A FEATURE LAYER FROM THE FEATURE SERVICE TABLE
        FeatureLayer {
            id: featureLayer
            featureTable: featureServiceTable
            onStatusChanged: {

                if(status === Enums.LayerStatusInitialized) {
                    featureTable.onQueryIdsStatusChanged.connect(function(){
                        if(featureTable.queryIdsStatus === Enums.QueryIdsStatusCompleted) {
                            console.log(featureTable.queryIdsResults[0])

                            // check to see if any features were previously selected

                            // if no feature was located, and no feature previously selected, create new feature
                            if (featureTable.queryIdsResults.length === 0 && featureSelected === false){
                                console.log("if no feature was located, and no feature previously selected, create new feature");
                                featureAdded = true;
                                addFeature(mapPoint);
                                queryFeatures(mapPoint);
                                featureSelected = true;
                            }

                            // if no feature was located, but a feature was previously selected, clear the features
                            else if (featureTable.queryIdsResults.length === 0 && featureSelected === true){
                                console.log("if no feature was located, and a feature was previously selected, clear the features");
                                queriedFeaturesModel.clear();
                                featureSelected = false;
                            }

                            // a current feature(s) is selected, update the query to the newly selected feature
                            else{
                                console.log("a current feature(s) is selected, update the query to the newly selected feature(s)");
                                //getAttributes(featureTable.queryIdsResults, featureTable.feature);
                                getFields(featureTable.queryIdsResults, featureLayer.featureTable);

                                featureSelected = true;
                            }
                        }
                    });
                }
                if(status === Enums.LayerStatusErrored) {
                    console.log("ERROR: Unable to initialize layer", layer.name)
                }
            }
        }

        onMouseClicked: {
            mapPoint = mouse.mapPoint;
            queryFeatures();
        }

        Query {
            id: query
            spatialRelationship: Enums.SpatialRelationshipIntersects
            returnGeometry: true
        }
    }

    AttributeViewer {
        id: rectAttributes
    }

    Component {
        id: featurePicker
        FeatureSelectorButton{}
    }

    FeatureSelector {
        id: rectFeatures
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
    }

    //EXECUTE QUERY FOR FEATURES NEAR MOUSE CLICK
    function queryFeatures(){
        // Hide features rectangle
        rectFeatures.y = parent.height
        queriedFeaturesModel.clear();

        // Inflate query geometry
        query.geometry = mapPoint.queryEnvelope().inflate(20*map.resolution, 20*map.resolution);
        // Query Ids
        featureLayer.featureTable.queryIds(query);

        ////////JUMP TO featureTable.onQueryIdsStatusChanged

        // Clear layer selection
        featureLayer.clearSelection();

        // Display features in list view
        rectAttributes.rBehavior.enabled = true
        rectAttributes.rBehavior.enabled = true
        rectFeatures.rListView.currentIndex = 0
    }

    // POPULATE MODEL FOR BOTH FEATURE SELECTOR AND ATTRIBUTE VIEWER
    function getFields(resultIds, featureTable) {
        var fieldsCount = featureTable.fields.length;

        // loop through each selected feature
        for (var i= 0; i < resultIds.length; i++){
        fieldsArray = [];
            // loop through each field in a feature
            for ( var j = 0; j < fieldsCount; j++ ) {
                var fieldName = featureTable.fields[j].name;
                var fieldAlias = featureTable.fields[j].alias;
                var fieldEditable = featureTable.fields[j].isEditable;
                var fieldType = featureTable.fields[j].fieldTypeString;
                var attrValue = featureTable.feature(resultIds[i]).attributeValue(fieldName);
                if (fieldType !== "esriFieldTypeOID") {
                    fieldsArray.push({
                                         "name": fieldName,
                                         "nameAlias": fieldName,
                                         "originalValue": attrValue,
                                         "formattedValue": valueToText(attrValue, fieldType),
                                         "fieldType": fieldType,
                                         "editable": fieldEditable,
                                         "placeHolderValue": placeHolderValue(fieldType)
                                     });
                }
            }
            var displayValue = (featureTable.feature(resultIds[i]).attributes[displayField]).toString()
            queriedFeaturesModel.append({"displayValue": displayValue, "fields": fieldsArray, "id": resultIds[i]});
        }
    }

    //ADD FEATURE FUNCTION
    function addFeature(mapPoint) {
        if (addButtonClicked == "add item"){
            console.log("x", mapPoint.x);
            var featureJson = {
                geometry: {
                    x: mapPoint.x,
                    y: mapPoint.y,
                    spatialReference: mapPoint.spatialReference
                },
                attributes: {
                    eventtype : "eventtype",
                    eventdate : "district",
                    eventtype: 17
                }
            }
        }
        if (featureServiceTable.featureTableStatus === Enums.FeatureTableStatusInitialized) {
            var newFeature = featureServiceTable.addFeature(featureJson);
        }
    }

    // CONVERT GEODATABASE VALUE TO DISPLAY TEXT
    function valueToText(value, fieldType) {
        if (value == null)
            return "";
        if (fieldType == "esriFieldTypeString")
            return value;
        if (fieldType == "esriFieldTypeInteger" || fieldType == "esriFieldTypeSmallInteger")
            return value.toString();
        if (fieldType == "esriFieldTypeDate")
            return Qt.formatDate(new Date(value), Qt.DefaultLocaleShortDate);
        return value.toString();
    }

    // CONVERT DISPLAY TEXT TO GEODATABASE VALUE
    function textToValue(text, fieldType) {
        if (text == "")
            return null;
        if (fieldType == "esriFieldTypeString")
            return text;
        if (fieldType == "esriFieldTypeInteger" || fieldType == "esriFieldTypeSmallInteger")
            return parseInt(text);
        if (fieldType == "esriFieldTypeDate"){
            var dateString = new Date(text);
            var dateVal = dateString.valueOf();
            console.log("dateVal", dateVal);
            return dateVal;
        }
        return text;
    }

    // CONVERT FIELD TYPE TO PLACEHOLDER VALUE
    function placeHolderValue(fieldType) {
        if (fieldType == "esriFieldTypeString")
            return qsTr("Enter a string");
        if (fieldType == "esriFieldTypeInteger" || fieldType == "esriFieldTypeSmallInteger")
            return qsTr("Enter a small integer");
        if (fieldType == "esriFieldTypeDate")
            return qsTr("Enter a date");
        return "oops";
    }

    Component.onCompleted : {
        addButtonClicked = "add item"
    }
}

//------------------------------------------------------------------------------
