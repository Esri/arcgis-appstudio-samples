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

App {
    id: appWindow
    width: 640
    height: 480

    property string featureServiceURL : appWindow.info.propertyValue("featureServiceURL","");
    property var objectIdToEdit
    property string addButtonClicked: "no item"
    property var foundFeatureIds: null
    property int hitFeatureId
    property double scaleFactor: AppFramework.displayScaleFactor
    property bool featureAdded
    property bool isMobile : Qt.platform.os === "ios" || Qt.platform.os === "android" ? true : false
    property var fieldsArray

    //MAP
    Map {
        id: mainMap
        anchors.fill: parent
        extent: envelopeInitalExtent
        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: false
        mapPanningByMagnifierEnabled: true
        zoomByPinchingEnabled: true

        //INITIAL EXTENT
        Envelope {
            id: envelopeInitalExtent
            xMax: -13630134.691272736
            yMax: 4554320.7069897875
            xMin: -13647294.804122735
            yMin: 4535211.44991852
            spatialReference: mainMap.spatialReference
        }

        //BASEMAP
        ArcGISTiledMapServiceLayer {
            url: appWindow.info.propertyValue("basemapServiceUrl", "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
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

        FeatureLayer {
            id: featureLayer
            featureTable: featureServiceTable
        }

        //ENABLE POSITION ONCE MAP IS CREATED
        onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                positionSource.active = true;
            }
        }

        //CREATE USER POSITION DISPLAY
        positionDisplay {
            id: positionDisplay
            zoomScale: 200000
            mode: Enums.AutoPanModeDefault
            positionSource: PositionSource {
                id: positionSource
            }
        }

        //BUTTON BACKGROUND
        Rectangle {
            anchors {
                fill: controlsColumn
                margins: -10 * scaleFactor
            }
            color: "lightgrey"
            radius: 5 * scaleFactor
            border.color: "black"
            opacity: 0.77
        }

        //BUTTON AREA
        Column {
            id: controlsColumn
            anchors {
                left: mainMap.left
                top: mainMap.top
                margins: 20 * scaleFactor
            }
            spacing: 7

            Button {
                id: showPosition
                text: "Hide my position"
                width: addLocationPoint.width
                enabled: mainMap.status === Enums.MapStatusReady

                onClicked: {
                    if(positionSource.active === true){
                        positionSource.active = false;
                        showPosition.text = "Show my position"
                    }
                    else{
                        positionSource.active = true;
                        positionDisplay.mode = Enums.AutoPanModeDefault
                        showPosition.text = "Hide my position"
                    }
                }
            }

            Button {
                text: "Create feature at my position"
                id: addLocationPoint
                enabled: true

                onClicked: {
                    featureAdded = true;
                    if (positionDisplay.mapPoint.x != 0 && positionDisplay.mapPoint.y != 0){
                        addPoint(positionDisplay.mapPoint.x, positionDisplay.mapPoint.y, mainMap.spatialReference);
                    }
                }
            }
        }

    }

    //EDIT WINDOW
    Rectangle {
        id: formDialog
        anchors.fill: parent
        visible: false

        ColumnLayout {
            anchors.fill: parent

            Rectangle {
                id: formTitle
                Layout.fillWidth: true
                Layout.minimumHeight: titleText.height * 2
                color: appWindow.info.propertyValue("titleBackgroundColor", "darkblue")

                Text {
                    id: titleText
                    anchors.centerIn: parent
                    text: featureAdded ?  "New Feature" : ("Object ID: " + hitFeatureId)
                    color: appWindow.info.propertyValue("titleTextColor", "white")
                    font {
                        pointSize: 22
                    }
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                id: formBody
                Layout.fillHeight: true
                Layout.fillWidth: true

                ScrollView{
                    anchors.fill: parent
                    anchors.margins: 10

                    ListView {
                        id: listView
                        spacing: 10 //* scaleFactor
                        delegate:

                            RowLayout {
                            width: parent.width
                            spacing: 2 //* scaleFactor

                            Label {
                                id: nameLabel
                                text: modelData.name + ": "
                                color: "black"
                                font.pointSize: 10
                                horizontalAlignment: Text.AlignLeft
                            }

                            Rectangle {
                                Layout.fillWidth: true
                            }

                            //FIELD VALUE
                            TextField {
                                id: valueEdit
                                readOnly: !modelData.editable
                                text: valueToText(modelData.currentValue, modelData.fieldType)
                                placeholderText: !modelData.editable ? "" :  {
                                    "esriFieldTypeString": qsTr("Enter a string"),
                                    "esriFieldTypeDate": qsTr("Enter a date"),
                                    "esriFieldTypeInteger": qsTr("Enter an integer"),
                                    "esriFieldTypeSmallInteger": qsTr("Enter a small integer")
                                }[modelData.fieldType]
                                font.pointSize: 10
                                horizontalAlignment: Text.AlignRight
                                Layout.minimumWidth: parent.width * 0.5

                                style: TextFieldStyle {
                                    id: textFieldStyle
                                    textColor: "black"

                                    background: Rectangle {
                                        radius: 2
                                        border.color: "#333"
                                        border.width: 1
                                        color: modelData.editable ? "#ffffff" : "#e2e2e2"
                                    }
                                }

                                onTextChanged: {
                                    if (!modelData.editable || !visible || !activeFocus)
                                        return;
                                    try {
                                        var value = textToValue(text, modelData.fieldType);
                                        fieldsArray[index].currentValue = value;
                                        console.log("INFO: " + modelData.name + " -> " + value);
                                    } catch (err) {
                                        console.log("ERROR");
                                        console.log(err);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: formFooter
                Layout.fillWidth: true
                Layout.preferredHeight: footerButtons.height

                Row {
                    id: footerButtons
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.margins: 5 * scaleFactor
                    spacing: 5 * scaleFactor

                    Button {
                        id: addFeatureBtn
                        text: qsTr("Ok")
                        enabled: AppFramework.network.isOnline

                        onClicked: {
                            var featureToEdit = null;
                            fieldsArray.forEach( function(e) {
                                if (e.currentValue != e.originalValue) {
                                    if (!featureToEdit) {
                                        featureToEdit = featureLayer.featureTable.feature(objectIdToEdit);
                                    }
                                    featureToEdit.setAttributeValue(e.name, e.currentValue);
                                }
                            } );
                            if (featureToEdit) {
                                featureServiceTable.updateFeature(objectIdToEdit, featureToEdit);
                                featureServiceTable.applyFeatureEdits();
                            }
                            formDialog.visible = false;
                        }
                    }

                    Button {
                        id: cancelFeatureBtn
                        text: "Cancel"
                        enabled: AppFramework.network.isOnline

                        onClicked: {
                            if (featureAdded == true)
                                featureServiceTable.deleteFeature(objectIdToEdit);
                            formDialog.visible = false;
                        }
                    }

                    Button {
                        id: deleteFeatureBtn
                        visible: featureAdded ? false : true
                        text: "Delete"
                        enabled: AppFramework.network.isOnline

                        onClicked: {
                            if (featureAdded == false)
                                featureServiceTable.deleteFeature(objectIdToEdit);
                            featureServiceTable.applyFeatureEdits();
                            formDialog.visible=false;
                        }
                    }
                }
            }
        }
    }

    //ADD POINT FUNCTION
    function addPoint(pointX, pointY, pointSR) {
        if (addButtonClicked == "add item"){
            //console.log(pointX+500);
            var featureJson = {
                geometry: {
                    x: pointX,
                    y: pointY,
                    spatialReference: pointSR
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
            dispTable(newFeature);
        }
    }

    //DISPLAY WINDOW
    function dispTable(feature){
        hitFeatureId = feature;
        objectIdToEdit = hitFeatureId;
        getFields(featureLayer);
        formDialog.visible = true;
    }

    //POPULATE EDIT WINDOW
    function getFields(featureLayer) {
        fieldsArray = [ ];
        var fieldsCount = featureLayer.featureTable.fields.length;
        for ( var f = 0; f < fieldsCount; f++ ) {
            var fieldName = featureLayer.featureTable.fields[f].name;
            var fieldEditable = featureLayer.featureTable.fields[f].isEditable;
            var fieldType = featureLayer.featureTable.fields[f].fieldTypeString;
            var attrValue = featureLayer.featureTable.feature(hitFeatureId).attributeValue(fieldName);
            if ( fieldName !== "Shape" && fieldName !== "objectid" ) {
                fieldsArray.push({
                                     name: fieldName,
                                     currentValue: attrValue,
                                     originalValue: attrValue,
                                     fieldType: fieldType,
                                     editable: fieldEditable
                                 });
            }
        }
        listView.model = [ ];
        listView.model = fieldsArray;
    }

    // Convert geodatabase value to display text
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

    // Convert display text to geodatabase value
    function textToValue(text, fieldType) {
        if (text == "")
            return null;
        if (fieldType == "esriFieldTypeString")
            return text;
        if (fieldType == "esriFieldTypeInteger" || fieldType == "esriFieldTypeSmallInteger")
            return parseInt(text);
        if (fieldType == "esriFieldTypeDate")
            return (new Date(text)).valueOf();
        return text;
    }

    Component.onCompleted : {
        addButtonClicked = "add item"
    }
}

//------------------------------------------------------------------------------
