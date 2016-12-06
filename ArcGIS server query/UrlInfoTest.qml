/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.3
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

import ArcGIS.AppFramework 1.0

App {
    id: app
    width: 800
    height: 750

    property var jsonQuery: ({"f":"pjson"})
    property var massagedArray: []

    UrlInfo {
        id: urlConstruct
        //query: urlText.text + massagedArray
    }

    Rectangle {
        anchors.fill: parent
        color: "#E1F0FB"
    }

    ColumnLayout {
        id: cl
        spacing: 3
        anchors {
            fill: parent
            margins: 5
        }

        TextField {
            id: urlText
            Layout.fillWidth: true
            text: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/Wildfire/FeatureServer/0/query"
            onTextChanged: urlConstruct.fromUserInput(text)
        }

        GridLayout {
            Layout.fillHeight: true
            columns: 2
            Text {
                text:"Where:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["where"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Obect Ids:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["objectIds"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Time:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["time"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Input geometry:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["geometry"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Geometry Type:"
            }
            ComboBox {
                model:["Envelope","Point","Polyline","Polygon","Multipoint"]
                onCurrentIndexChanged: {
                    jsonQuery["geometryType"] = currentText.toString();
                    console.log(currentText)
                }

                Component.onCompleted: jsonQuery["geometryType"] = ""

            }
            Text {
                text:"Input Spatial Reference:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["inSR"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text: "Spatial Relationship:"
            }
            ComboBox {
                model: ["Intersects","Contains","Crosses","Envelope Intersects", "Index Intersects", "Overlaps", "Touches", "Within", "Relation"]
                onCurrentIndexChanged: {
                    console.log(currentText)
                    jsonQuery["spatialRel"] = currentText.toString();
                }
                Component.onCompleted: jsonQuery["spatialRel"] = ""
            }

            Text {
                text:"Relation:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["relationParam"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Out Fields:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["outFields"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Return Geometry:"
            }
            Row {
                spacing: 5
                ExclusiveGroup {
                    id:returnGeometry
                }

                RadioButton {
                    text: "True"
                    checked: true
                    exclusiveGroup: returnGeometry
                    onCheckedChanged: {
                        jsonQuery["returnGeometry"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                    Component.onCompleted:{
                        jsonQuery["returnGeometry"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                }
                RadioButton {
                    text: "False"
                    exclusiveGroup: returnGeometry
                }
            }

            Text {
                text:"Max Allowable Offset:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["maxAllowableOffset"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Geometry Precision:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["where"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }

            Text {
                text:"Output Spatial Reference:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["outSR"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Geodatabase Version Name:"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["gdbVersion"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Return Distinct Values::"
            }
            Row {
                spacing: 5
                ExclusiveGroup {
                    id:returnDistinct
                }

                RadioButton {
                    text: "True"
                    exclusiveGroup: returnDistinct
                    onCheckedChanged: {
                        jsonQuery["returnDistinctValues"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                    Component.onCompleted:{
                        jsonQuery["returnDistinctValues"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                }
                RadioButton {
                    text: "False"
                    checked: true
                    exclusiveGroup: returnDistinct

                }
            }
            Text {
                text:"Return IDs Only::"
            }
            Row {
                spacing: 5
                ExclusiveGroup {
                    id:returnIds
                }

                RadioButton {
                    text: "True"
                    exclusiveGroup: returnIds
                    onCheckedChanged: {
                        jsonQuery["returnIdsOnly"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                    Component.onCompleted:{
                        jsonQuery["returnIdsOnly"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }

                }
                RadioButton {
                    text: "False"
                    checked: true
                    exclusiveGroup: returnIds

                }
            }
            Text {
                text:"Return Count Only::"
            }
            Row {
                spacing: 5
                ExclusiveGroup {
                    id:returnCount
                }

                RadioButton {
                    text: "True"
                    exclusiveGroup: returnCount
                    onCheckedChanged: {
                        jsonQuery["returnCountOnly"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                    Component.onCompleted:{
                        jsonQuery["returnCountOnly"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                }
                RadioButton {
                    text: "False"
                    checked: true
                    exclusiveGroup: returnCount

                }
            }
            Text {
                text:"Order By Fields::"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["orderByFields"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Group By Fields (ForStatistics)::"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["groupByFieldsForStatistics"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"Output Statistics::"
            }
            TextField{
                Layout.fillWidth: true
                onTextChanged: {
                    console.log(text)
                    jsonQuery["outStatistics"] = text.toString();
                    console.log(JSON.stringify(jsonQuery))
                }
            }
            Text {
                text:"ReturnZ:"
            }
            Row {
                spacing: 5
                ExclusiveGroup {
                    id:returnZ
                }

                RadioButton {
                    text: "True"
                    exclusiveGroup: returnZ
                    onCheckedChanged: {
                        jsonQuery["returnZ"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                    Component.onCompleted:{
                        jsonQuery["returnZ"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                }
                RadioButton {
                    text: "False"
                    checked: true
                    exclusiveGroup: returnZ

                }
            }
            Text {
                text:"ReturnM:"
            }
            Row {
                spacing: 5
                ExclusiveGroup {
                    id:returnM
                }

                RadioButton {
                    text: "True"
                    exclusiveGroup: returnM
                    onCheckedChanged: {
                        jsonQuery["returnM"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                    Component.onCompleted:{
                        jsonQuery["returnM"] = checked.toString()
                        console.log(JSON.stringify(jsonQuery))
                    }
                }
                RadioButton {
                    text: "False"
                    checked: true
                    exclusiveGroup: returnM

                }
            }
        }

        Button {
            text: qsTr("Query (GET)")
            onClicked: {
                var str = JSON.stringify(jsonQuery);
                var sub = str.substring(1, str.length-1);
                for ( var i in jsonQuery ){
                    massagedArray.push(i + "=" + encodeURIComponent(jsonQuery[i]))
                }

                urlConstruct.query = massagedArray.join("&")
                address = (urlConstruct.scheme + "://" + urlConstruct.host + urlConstruct.path + "?" + urlConstruct.query).toString();

                console.log("fff",address);

                networkRequest.url = address
                networkRequest.send()

            }
        }
    }

    property string address

    NetworkRequest {
        id: networkRequest

        responseType: "json"

        onReadyStateChanged: {
            if (readyState == NetworkRequest.DONE){
                txtResponse.text = JSON.stringify(response, undefined, 2);
                resultPanel.visible = true;
            }
        }
    }


    Rectangle {
        id: resultPanel
        anchors.fill: parent
        color: "#E5E6E7"
        opacity: 0.9
        z: 10
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.margins: 20
            opacity: 1
            color: "#EFEEEF"
            TextArea {
                id: txtResponse
                anchors {
                    left: parent.left
                    right: parent.right
                    top: closeButton.bottom
                    bottom: parent.bottom
                    margins: 10
                }

                clip: true

            }
            Button {
                id: closeButton
                anchors.right: parent.right

                text: qsTr("Close")
                onClicked: resultPanel.visible = false
            }
        }
    }
}

