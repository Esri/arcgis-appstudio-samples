/* ******************************************
Copyright 2015 Esri

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.​
******************************************* */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

import "components"
import "components/moment.js" as Moment

Item {
    id: _root
    property var mapPoint
    property alias allFeaturesModel: allFeaturesModel
    property bool featureSelected: false

    ListModel {
        id: allFeaturesModel
    }

    Rectangle {
        id: rectHeader
        width: parent.width
        height: 50*app.scaleFactor
        color: app.headerBarColor
        anchors.top: parent.top

        Text {
            id: txtHeader
            text: app.mapTitle
            color: app.headerTextColor
            font.pointSize: 18*app.scaleFactor
            font.family: app.fontSourceSansProReg.name
            font.bold: true
            anchors.centerIn: parent
        }

        Rectangle {
            id: rectClear
            height: parent.height
            width: 35*app.scaleFactor
            color: "transparent"
            anchors {
                right: parent.right
                rightMargin: 15*app.scaleFactor
            }

            Text {
                id: txtClear
                text: allFeaturesModel.count>0 ? "Clear(" + allFeaturesModel.count + ")" : "Clear"
                color: featureSelected ? app.headerTextColor : "lightgray"
                font.bold: featureSelected
                font.pointSize: 14*app.scaleFactor
                font.family: app.fontSourceSansProReg.name
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Clear selection
                    for (var i = 0; i < listView.model.count; i++) {
                        var layer = listView.model.get(i).layer
                        layer.clearSelection()
                    }
                    // Update bool for feature selected
                    featureSelected = false
                    // Hide features rectangle
                    rectFeatures.y = app.height
                    //remove popup features
                    allFeaturesModel.clear();
                }
            }
        }
    }

    Envelope {
        id: extent
        xMin:  -8574876.742323654
        yMin:  4705251.383377932
        xMax:  -8570676.93264509
        yMax:  4711751.088832853
    }

    Component {
        id: customFeatureLayer
        FeatureLayer {
            property int layerIndex
            property var jsonDef

            onStatusChanged: {
                if(status === Enums.LayerStatusInitialized) {
                    jsonDef.layerId = name
                    map.updateListModel(featureTable.fields, layerIndex)

                    featureTable.onQueryIdsStatusChanged.connect(function(){
                        if(featureTable.queryIdsStatus === Enums.QueryIdsStatusCompleted) {
                            map.getAttributes(featureTable.queryIdsResults, name, featureTable.feature, jsonDef.fields, jsonDef.displayField)
                        }
                    });
                }

                if(status === Enums.LayerStatusErrored) {
                    console.log("ERROR: Unable to initialize layer", layer.name)
                }
            }
        }
    }

    Map {
        id: map

        width: parent.width
        height: parent.height - rectHeader.height
        anchors.bottom: parent.bottom

        wrapAroundEnabled: true
        zoomByPinchingEnabled: true
        extent: extent

        onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                for (var i=0; i < app.queryLayers.length; i++) {
                    var url = app.queryLayers[i].url

                    var featureServiceTable = ArcGISRuntime.createObject("GeodatabaseFeatureServiceTable")
                    featureServiceTable.url = url

                    var layer = customFeatureLayer.createObject(null, {"layerIndex": i, "jsonDef": app.queryLayers[i]})
                    layer.featureTable = featureServiceTable.valid ? featureServiceTable : null

                    // Add layer to the map
                    map.addLayer(layer)
                }
            }
        }

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        function updateListModel (fields, i) {
            // Get list of field names in feature layer
            var layerFieldsList = []
            for (var j = 0; j < fields.length; j++) {
                layerFieldsList.push(fields[j].name.toLowerCase())
            }

            // Get list of field names in model
            var modelFieldNames = []
            for (var k=0; k < app.queryLayers[i].fields.length; k++) {
                modelFieldNames.push(app.queryLayers[i].fields[k].fieldName.toLowerCase())
            }


            // Loop through fields in feature service and check list model for formats/changes
            for (var m=0; m < layerFieldsList.length; m++) {
                // Get field data type
                var dataType = fields[m].fieldType

                // Check for field in list model
                var index = modelFieldNames.indexOf(layerFieldsList[m])
                // Check for fields in the model
                if (index > -1) {
                    // Check if field is hidden
                    if (!app.queryLayers[i].fields[index].isHidden) {
                        // Update isHidden property to false
                        app.queryLayers[i].fields[index].isHidden = false
                    }
                    // Check if field has link
                    if (!app.queryLayers[i].fields[index].isLink) {
                        // Update isLink property to false
                        app.queryLayers[i].fields[index].isLink = false
                    }

                    // Check if field does not have display name
                    if (!app.queryLayers[i].fields[index].displayName) {
                        app.queryLayers[i].fields[index].displayName = fields[m].alias
                    }

                    // Add data type to fieldsListModel
                    app.queryLayers[i].fields[index].dataType = dataType
                }else {
                    // Update isHidden, isLink, and displayName properties
                    app.queryLayers[i].fields.push({"fieldName": fields[m].name, "displayName": fields[m].alias, "dataType": dataType, "isHidden": false, "isLink": false})
                }
            }
        }


        function getAttributes(results, layerName, feature, fieldInfo, displayField) {
            for (var i=0; i < results.length; i++) {
                var fieldValues = []
                for (var j=0; j < fieldInfo.length; j++) {
                    var fieldName = fieldInfo[j].fieldName
                    var displayName = fieldInfo[j].displayName
                    var isHidden = fieldInfo[j].isHidden
                    var isLink = fieldInfo[j].isLink
                    var dataType = fieldInfo[j].dataType

                    // Ignore case for fields
                    for (var key in feature(results[i]).attributes) {
                        if (key.toLowerCase() === fieldName) {
                            fieldName = key
                        }

                        if (key.toLowerCase() === displayField) {
                            displayField = key
                        }
                    }

                    // Get value of field
                    var value = feature(results[i]).attributes[fieldName]

                    // Format value based on format provided in field list model
                    var valueFormat = formatValue(value, fieldInfo[j]).toString()

                    fieldValues.push({"displayName": displayName, "value": valueFormat, "isHidden": isHidden, "isLink": isLink, "dataType": dataType})
                }

                var displayValue = (feature(results[i]).attributes[displayField]).toString()

                var layer = map.layerByName(layerName)

                if (layer) {
                    // Get layer symbol
                    var renderer = layer.renderer
                    var symbol = renderer.featureSymbol(feature)
                    var symbolImage = symbol.symbolImage()

                    // Get layer geometry
                    var geom = feature(results[i]).geometry

                    // Append data to model
                    allFeaturesModel.append({"layer": layer, "displayValue": displayValue, "fields": fieldValues,
                                                "geometry": geom, "id": results[i], "symbolImage": symbolImage})
                } else {
                    console.log("Error! Could not find the layer - ", name)
                }
            }
        }

        function formatValue(value, element) {
            var valueFormat = value

            // Make sure value is not null
            if (valueFormat) {

                // Decimal places
                if ("decimalPlaces" in element) {
                    if (element.decimalPlaces && (element.dataType >= 1 && element.dataType < 5)) {
                        valueFormat = Number(valueFormat).toFixed(element.decimalPlaces)
                    }
                }

                // Thousands separator
                if ("thousandsSeparator" in element) {
                    if (element.thousandsSeparator && (element.dataType >= 1 && element.dataType < 5)) {
                        valueFormat = valueFormat.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1,")
                    }
                }

                // Date
                if ("dateFormat" in element) {
                    if (element.dateFormat && element.dataType === 5) {
                        var d = new Date(valueFormat)
                        //valueFormat = Moment.moment(d).format(element.dateFormat) // UTC
                        valueFormat = Moment.moment.utc(d).format(element.dateFormat) // Local
                    }
                }

                // Prefix
                if ("prefix" in element) {
                    if (element.prefix) {
                        valueFormat = element.prefix + valueFormat
                    }
                }

                // Suffix
                if ("suffix" in element) {
                    if (element.suffix) {
                        valueFormat = valueFormat + element.suffix
                    }
                }

            }else {
                // If value is null, set value to empty string
                valueFormat = ""
            }

            return valueFormat
        }

        onMouseClicked: {
            // Get point clicked on map
            mapPoint = mouse.mapPoint

            // Hide features rectangle
            rectFeatures.y = parent.height

            // Clear list model containing features from last map click
            allFeaturesModel.clear()

            //console.log(map.layerNames)
            for (var i=0; i < app.queryLayers.length; i++) {
                var queryObj = app.queryLayers[i]
                var layerId = queryObj.layerId
                var fieldInfo = queryObj.fields
                var displayField = queryObj.displayField

                var layer = map.layerByName(layerId)


                // Inflate query geometry
                if (layer.geometryType !== Enums.GeometryTypePoint) {
                    query.geometry = mapPoint.queryEnvelope().inflate(map.resolution, map.resolution)
                }else {
                    query.geometry = mapPoint.queryEnvelope().inflate(20*map.resolution, 20*map.resolution)
                }


                // Query Ids
                layer.featureTable.queryIds(query)

                // Clear layer selection
                layer.clearSelection()

            }

            // Update bool for feature selected
            featureSelected = false

            // Display features in list view
            behaviorOnYFeatures.enabled = true
            behaviorOnYAttributes.enabled = true
            listView.currentIndex = 0
        }

        Query {
            id: query
            spatialRelationship: Enums.SpatialRelationshipIntersects
            returnGeometry: true
        }
    }

    Component {
        id: featurePicker

        Item {
            width: listView.width
            height: listView.height

            Rectangle {
                id: rectFeature
                width: parent.width - 20*app.scaleFactor
                height:parent.height - 15*app.scaleFactor
                radius: 3*app.scaleFactor
                anchors.centerIn: parent
                clip: true
                color: "white"
                border.color: "darkgray"


                Rectangle {
                    color: "transparent"
                    width: 35*app.scaleFactor
                    height: 35*app.scaleFactor
                    clip: true
                    anchors {
                        left: parent.left
                        leftMargin: 15*app.scaleFactor
                        verticalCenter: parent.verticalCenter
                    }
                    Image {
                        width: geometry.geometryType > 1 ? parent.width : symbolImage.defaultSize[0]
                        height: geometry.geometryType > 1 ? parent.height : symbolImage.defaultSize[1]
                        //width: parent.width
                        //height: parent.height
                        anchors.centerIn: parent
                        source: symbolImage.url
                        fillMode: Image.PreserveAspectFit
                        clip: true
                    }
                }

                Text {
                    id: txtFeature
                    width: parent.width - 110*app.scaleFactor
                    anchors.centerIn: parent
                    text: displayValue
                    font.pointSize: 14*app.scaleFactor
                    font.family: app.fontSourceSansProReg.name
                    color: app.attributeValueColor
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Rectangle {
        id: rectFeatures
        width: parent.width
        height: 60*app.scaleFactor
        y: parent.height
        color: "lightgray"

        Behavior on y {
            id: behaviorOnYFeatures
            NumberAnimation { duration: 400 }
            enabled: false
        }

        ListView {
            id: listView
            width: parent.width - 40*app.scaleFactor
            height: parent.height
            anchors.centerIn: parent
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            delegate: featurePicker
            model: allFeaturesModel
            currentIndex: -1

            onCurrentItemChanged: {
                // Show features rectangle
                rectFeatures.y = app.height - rectFeatures.height
                // Select first feature in model
                selectFeature()
            }

            onFlickEnded: {
                currentIndex = indexAt(contentX, contentY)
                // Clear features
                for (var i = 0; i < listView.model.count; i++) {
                    var layer = listView.model.get(i).layer
                    layer.clearSelection()
                }

                // Select feature geometry corresponding to current feature in model
                selectFeature()
            }

            function selectFeature() {
                var layer = listView.model.get(currentIndex).layer
                var id = listView.model.get(currentIndex).id
                layer.selectFeature(id)
                featureSelected = true
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    repeater.model = listView.model.get(listView.currentIndex).fields
                    flickableValuesList.contentY = 0
                    rectAttributes.visible = true
                    rectAttributes.y = 0
                }
            }
        }
    }

    Rectangle {
        id: rectAttributes
        width: parent.width
        height: parent.height
        y: parent.height
        color: "white"
        visible: false

        MouseArea{
            anchors.fill: parent
            onClicked: {
                mouse.accepted = false
            }
        }

        Rectangle {
            id: rectAttributeHeader
            width: parent.width
            height: rectHeader.height
            color: app.headerBarColor

            Text {
                id: txtDetails
                height: parent.height
                width: parent.width
                text: "Details"
                color: app.headerTextColor
                font.pointSize: 18*app.scaleFactor
                font.family: app.fontSourceSansProReg.name
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                id: rectMapControl
                height: parent.height
                width: txtMapControl.implicitWidth
                color: "transparent"
                anchors {
                    left: parent.left
                    leftMargin: 15*app.scaleFactor
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    id: txtMapControl
                    text: "Map"
                    color: app.headerTextColor
                    font.pointSize: 16*app.scaleFactor
                    font.family: app.fontSourceSansProReg.name
                    anchors.centerIn: parent

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        rectAttributes.y = app.height
                        flickableValuesList.contentY = 0
                    }
                }
            }
        }

        Flickable {
            id: flickableValuesList
            width: parent.width
            height: parent.height - rectAttributeHeader.height
            contentHeight: col.implicitHeight
            clip: true
            anchors.top: rectAttributeHeader.bottom

            Column {
                id: col
                width: parent.width
                height: parent.height
                spacing: 5*app.scaleFactor
                anchors.top: parent.top

                Repeater {
                    id: repeater

                    Rectangle {
                        id: rectRepeaterItem
                        width: col.width
                        height: Math.max(35*app.scaleFactor, txtDisplayname.implicitHeight, txtValue.implicitHeight)
                        color: "transparent"
                        visible: !isHidden && (dataType > 0 && dataType < 7)
                        anchors {
                            left: col.left
                            right: col.right
                        }

                        Text {
                            id: txtDisplayname
                            width: (parent.width/2) - 5*app.scaleFactor
                            color: app.attributeDisplayNameColor
                            text: displayName
                            font.family: app.fontSourceSansProReg.name
                            font.pointSize: 16*app.scaleFactor
                            wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere
                            horizontalAlignment: Text.AlignLeft
                            anchors {
                                left: parent.left
                                leftMargin: 10*app.scaleFactor
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            id: txtValue
                            width: (parent.width/2) - 5*app.scaleFactor
                            color: app.attributeValueColor
                            text: isLink ? "<a href='" + value + "'>More info</a>" : value
                            font.family: app.fontSourceSansProReg.name
                            font.pointSize: 16*app.scaleFactor
                            wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere
                            horizontalAlignment: Text.AlignRight
                            anchors {
                                right: parent.right
                                rightMargin: 10*app.scaleFactor
                                verticalCenter: parent.verticalCenter
                            }
                            linkColor: "blue"
                            onLinkActivated: {
                                Qt.openUrlExternally(unescape(link));
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1*app.scaleFactor
                            color: app.attributeSeparatorColor
                            anchors.top: parent.bottom
                        }
                    }
                }
            }
        }

        Behavior on y {
            id: behaviorOnYAttributes
            enabled: false
            NumberAnimation { duration: 400 }
        }
    }


    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: false
    }
}

