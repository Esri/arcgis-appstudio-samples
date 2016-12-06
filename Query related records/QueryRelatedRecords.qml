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
//------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {

    id: app
    width: 1000
    height: 640

    property real scaleFactor: AppFramework.displayScaleFactor
    property real formWidth: 10
    property real formMaxWidth: app.width * 0.8
    property bool isLandscape: width > height
    property variant mainData: ""
    property variant toUpdateAttribute: ""
    property variant toUpdatedAttributeValue: ""
    property variant selectedFeatureId: ""
    property bool queryenabled: false

    function queryForRelationships(TableView, TableViewColumn, queryindex){
        var selectedFeature = wellsFeatureServiceTable.feature(selectedFeatureId);
        clearTable(TableView)
        mainData = initTable(TableView, TableViewColumn, wellsFeatureServiceTable.fields, selectedFeature)
        var relationships = wellsFeatureServiceTable.relationships
        var inIDList = [selectedFeatureId]
        relatedQueryParam.objectIds = inIDList
        relatedQueryParam.relationshipId = relationships[queryindex].relationshipId
        relatedQueryParam.returnGeometry = false
        if(relationships[queryindex].relationshipId==0){
            var outFieldsList = ["OBJECTID", "FORMATION" , "SOURCE"];
            relatedQueryParam.outFields = outFieldsList
        }else{
            var outFieldsList = ["OBJECTID", "FIELD_NAME", ];
            relatedQueryParam.outFields = outFieldsList
        }
        relationshipQueryTask.url = wellsFeatureServiceTable.url
        relationshipQueryTask.executeRelationshipQuery(relatedQueryParam)

    }

    function clearTable(TableView){
        while(TableView.columnCount!==0){
            TableView.removeColumn(TableView.columnCount-1)
        }
        TableView.model.clear();
    }

    function initTable(TableView, TableViewColumn, Fields, Feature){
        var fieldslength = Fields.length;
        var counter = 0;
        var jsonString = "{";

        for (var k=0; k<fieldslength; k++){
            var fieldName = Fields[k].name;
            if(fieldName === "OBJECTID" || fieldName === "LEASE_NAME" || fieldName === "WELL_NAME"){
                var component = TableViewColumn;
                if(component.status == Component.Ready){
                    var propertiesObject = JSON.parse("{\"role\":\"" + fieldName + "\",\"title\":\"" + fieldName + "\",\"visible\":true,\"width\":"+150*scaleFactor+"}");
                    var myObject = component.createObject(TableView, propertiesObject);
                    TableView.addColumn(myObject);
                    counter++
                }
                var attributeValue = Feature.attributeValue(fieldName)
                if (counter < 3){
                    jsonString += "\""+ fieldName + "\":\"" + attributeValue + "\", ";
                }
                else{
                    jsonString += "\""+ fieldName + "\":\"" + attributeValue + "\"}";
                }
            }
        }
        var jsonObject = JSON.parse(jsonString);
        return jsonObject
    }

    function addRelFields(TableView, TableViewColumn, Fields){
        var fieldslength = Fields.length;
        for (var k=0; k<fieldslength; k++){
            var fieldName = "REL_"+Fields[k];
            var component = TableViewColumn;
            if(component.status == Component.Ready){
                var propertiesObject = JSON.parse("{\"role\":\"" + fieldName + "\",\"title\":\"" + fieldName + "\",\"visible\":true,\"width\":"+150*scaleFactor+"}");
                var myObject = component.createObject(TableView, propertiesObject);
                TableView.addColumn(myObject);
            }
        }
    }

    function populateRelFields(TableView, MainData, RelData){
        var temp = JSON.stringify(MainData);
        temp = temp.substring(0, temp.length-1)+", ";

        for(var m=0; m<RelData.attributeNames.length; m++){
            var fieldName = "REL_"+RelData.attributeNames[m];
            var value = RelData.attributes[RelData.attributeNames[m]]
            if(m == RelData.attributeNames.length-1){
                temp += "\""+ fieldName + "\":\"" + value + "\"}";
            }else{
                temp += "\""+ fieldName + "\":\"" + value + "\", ";
            }
        }
        var jsonObject = JSON.parse(temp);
        TableView.model.append(jsonObject);
    }

    function updateField(TableView, ListModel, text, styleData){
        var topstable;
        for(var n=0; n<TableView.columnCount; n++){
            if(TableView.getColumn(n).title == "REL_FORMATION"){
                topstable = true
            }
        }

        var fieldName = TableView.getColumn(styleData.column).title
        if(fieldName.substring(0, 4)=== "REL_"){
            var relid = ListModel.get(TableView.currentRow).REL_OBJECTID
            if(topstable){
                fieldName = TableView.getColumn(styleData.column).title
                toUpdateAttribute = fieldName.substring(4, fieldName.length);
                toUpdatedAttributeValue = text;
                featureQuery.where = "OBJECTID = "+relid
                topsFeatureServiceTable.queryServiceFeatures(featureQuery)
            }
            else{
                var relid = ListModel.get(TableView.currentRow).REL_OBJECTID
                var rfeat = fieldsFeatureServiceTable.feature(relid)
                fieldName = fieldName.substring(4, fieldName.length);
                rfeat.setAttributeValue(fieldName, text)
                fieldsFeatureServiceTable.updateFeature(relid, rfeat)
                fieldsFeatureServiceTable.applyFeatureEdits()
            }
        }
        else{
            var id = ListModel.get(TableView.currentRow).OBJECTID
            var feat = wellsFeatureServiceTable.feature(id)
            fieldName = TableView.getColumn(styleData.column).title
            feat.setAttributeValue(fieldName, text)
            wellsFeatureServiceTable.updateFeature(id,feat)
            wellsFeatureServiceTable.applyFeatureEdits()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5

        GridLayout {
            id: grid
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: app.isLandscape ? children.length : 1
            rows: app.isLandscape ? 1 : children.length

            SpatialReference{
                id: sr
                wkid: 4267
            }

            ContentBlock {
                id: mapBlock

                Envelope{
                    id: initialExtent
                    xMin:-98.647319
                    yMin:38.362661
                    xMax: -98.564871
                    yMax: 38.417745
                    spatialReference: sr
                }

                Rectangle {
                    color: "lightgrey"
                    opacity: 1
                    anchors {
                        fill: map
                        margins: -10 * scaleFactor
                    }
                }

                Map {
                    id: map
                    anchors {
                        fill: parent
                        margins: 5 * scaleFactor
                    }

                    focus: true

                    onStatusChanged:{
                        if(status==Enums.MapStatusReady)
                            extent = initialExtent;
                    }

                    ArcGISTiledMapServiceLayer {
                        url: "http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer"
                    }

                    FeatureLayer {
                        id: fieldsFeatureLayer
                        featureTable: fieldsFeatureServiceTable
                        selectionColor: "green"
                    }

                    FeatureLayer {
                        id: wellsFeatureLayer
                        featureTable: wellsFeatureServiceTable
                        selectionColor: "cyan"

                        function hitTestFeatures(x,y) {
                            var tolerance = Qt.platform.os === "ios" || Qt.platform.os === "android" ? 10 : 1;
                            var featureIds = wellsFeatureLayer.findFeatures(x, y, tolerance*scaleFactor, 1);
                            if(!featureIds.length==0){
                                clearTable(tableView1)
                                clearTable(tableView2)
                                selectedFeatureId = featureIds[0]
                                var selectedFeature = wellsFeatureServiceTable.feature(selectedFeatureId)
                                selectFeature(selectedFeatureId)
                                queryenabled = true
                            }
                        }
                    }

                    onMouseClicked: {
                        wellsFeatureLayer.clearSelection()
                        queryenabled = false
                        wellsFeatureLayer.hitTestFeatures(mouse.x, mouse.y)

                    }

                }

                Text{
                    font.pointSize: 50
                    id: saved
                    text: "SAVED"
                    opacity: 0

                    SequentialAnimation{
                        id: saveFlash;
                        OpacityAnimator{
                            target: saved;
                            from: 0;
                            to: 1;
                            duration: 1000
                        }
                        OpacityAnimator{
                            target: saved;
                            from: 1;
                            to: 0;
                            duration: 1000
                        }
                    }
                }

                Rectangle {
                    color: "lightgrey"
                    radius: 5
                    border.color: "black"
                    opacity: 0.77
                    anchors {
                        fill: controlsColumn
                        margins: -10 * scaleFactor
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: (mouse.accepted = true)
                    }
                }

                Column {
                    id: controlsColumn
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        margins: 20 * scaleFactor
                    }
                    spacing: 10 * scaleFactor

                    Text {
                        text: qsTr("Click on a point, then click on either Query Button.")
                    }

                    Text {
                        text: qsTr("First Query Button finds feature to table relates.")
                    }
                    Text {
                        text: qsTr("Second Query Button finds feature to feature relates.")
                    }
                    Text {
                        text: qsTr("Press enter to save Edits.")
                    }
                }
            }

            GridLayout{
                Layout.fillHeight: true
                Layout.fillWidth: true
                columns: app.isLandscape ? 1 : children.length
                rows: app.isLandscape ? children.length : 1

                ContentBlock {
                    id: tableBlock1

                    ListModel{
                        id: listModel1
                    }

                    Rectangle{
                        id: tableArea1
                        anchors.fill: parent

                        Text{
                            id: tablename1
                            text: qsTr("Feature to Table Relationship")
                            font.pixelSize: 15
                            height: 20
                        }

                        TableView{
                            id: tableView1
                            model: listModel1
                            style: TableViewStyle {
                                textColor: "black"
                            }
                            anchors{
                                top: parent.top
                                right: parent.right
                                left: parent.left
                                bottom: parent.bottom
                                topMargin: 20
                            }

                            itemDelegate: TextInput{
                                text: styleData.value
                                onAccepted: {
                                    updateField(tableView1, listModel1, text, styleData)
                                }
                            }
                        }
                    }

                    Component {
                        id: tableViewColumn1
                        TableViewColumn {
                            width: 70
                        }
                    }

                    Rectangle {
                        anchors {
                            fill: controlsColumn2
                            margins: -10
                        }
                        color: "lightgrey"
                        opacity: 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: (mouse.accepted = true)
                        }
                    }

                    Column {
                        id: controlsColumn2
                        anchors {
                            right: parent.right
                            bottom: parent.bottom
                            bottomMargin: 50
                            rightMargin: 20
                        }
                        spacing: 1

                        Button{
                            id: firstRel
                            text: qsTr("Query")
                            enabled: queryenabled
                            onClicked: {
                                queryForRelationships(tableView1, tableViewColumn1, 0)
                            }
                        }
                    }
                }

                ContentBlock{
                    id: tableBlock2

                    ListModel{
                        id: listModel2
                    }

                    Rectangle{
                        id: tableArea2
                        anchors.fill: parent

                        Text{
                            id: tablename2
                            text: qsTr("Feature to Feature Relationship")
                            font.pixelSize: 15
                            height: 20
                        }

                        TableView{
                            id: tableView2
                            model: listModel2
                            style: TableViewStyle {
                                textColor: "black"
                            }
                            anchors{
                                top: parent.top
                                right: parent.right
                                left: parent.left
                                bottom: parent.bottom
                                topMargin: 20
                            }

                            itemDelegate: TextInput{
                                text: styleData.value
                                onAccepted: {
                                    updateField(tableView2, listModel2, text, styleData)
                                }
                            }
                        }
                    }

                    Component {
                        id: tableViewColumn2
                        TableViewColumn {
                            width: 70
                        }
                    }

                    Rectangle {
                        anchors {
                            fill: controlsColumn3
                            margins: -10
                        }
                        color: "lightgrey"
                        opacity: 0

                        MouseArea {
                            anchors.fill: parent
                            onClicked: (mouse.accepted = true)
                        }
                    }

                    Column {
                        id: controlsColumn3
                        anchors {
                            right: parent.right
                            bottom: parent.bottom
                            bottomMargin: 50
                            rightMargin: 20
                        }
                        spacing: 1
                        Button{
                            id: secondRel
                            text: qsTr("Query")
                            enabled: queryenabled
                            onClicked: {
                                queryForRelationships(tableView2, tableViewColumn2, 1)
                            }
                        }
                    }
                }
            }
        }
    }

    GeodatabaseFeatureServiceTable{
        id: wellsFeatureServiceTable
        url: "http://services.arcgis.com/Wl7Y1m92PbjtJs5n/arcgis/rest/services/KSPetro/FeatureServer/0"

        onApplyFeatureEditsErrorsChanged: {

        }

        onApplyFeatureEditsStatusChanged: {
            saveFlash.start()
        }
    }

    GeodatabaseFeatureServiceTable{
        id: fieldsFeatureServiceTable
        url: "http://services.arcgis.com/Wl7Y1m92PbjtJs5n/arcgis/rest/services/KSPetro/FeatureServer/1"

        onApplyFeatureEditsErrorsChanged: {

        }

        onApplyFeatureEditsStatusChanged: {
            saveFlash.start()
        }
    }

    GeodatabaseFeatureServiceTable{
        id: topsFeatureServiceTable
        url: "http://services.arcgis.com/Wl7Y1m92PbjtJs5n/arcgis/rest/services/KSPetro/FeatureServer/2"

        onQueryServiceFeaturesResultChanged: {
            var feat = queryServiceFeaturesResult.iterator.next();
            var id = feat.uniqueId
            feat.setAttributeValue(toUpdateAttribute,toUpdatedAttributeValue )
            topsFeatureServiceTable.updateFeature(id,feat)
            topsFeatureServiceTable.applyFeatureEdits()
        }

        onApplyFeatureEditsErrorsChanged: {

        }

        onApplyFeatureEditsStatusChanged: {
            saveFlash.start()
        }
    }

    QueryTask{
        id: relationshipQueryTask
        onRelationshipQueryErrorChanged: {

        }
        onRelationshipQueryTaskStatusChanged: {

        }
        onRelationshipQueryResultChanged: {
            if(relationshipQueryTaskStatus == Enums.RelationshipQueryTaskStatusCompleted){
                var graphics = relationshipQueryResult.relatedRecordGroups[0].graphics;
                if(graphics[0].attributeNames.length==3){
                    addRelFields(tableView1, tableViewColumn1, graphics[0].attributeNames)
                    for(var l=0; l<graphics.length; l++){
                        populateRelFields(tableView1, mainData, graphics[l])
                    }
                }else if(graphics[0].attributeNames.length==2){
                    addRelFields(tableView2, tableViewColumn2, graphics[0].attributeNames)
                    for(var l=0; l<graphics.length; l++){
                        populateRelFields(tableView2, mainData, graphics[l])
                    }
                }
            }else{

            }
        }
    }

    QueryRelatedRecordsParameters{
        id: relatedQueryParam
    }

    Query{
        id: featureQuery
    }
}
