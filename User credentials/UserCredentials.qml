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
import QtQuick.Controls 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0


App {
    id: app
    width: 800
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor
    property string serviceURL: "http://serverapps10.esri.com/ArcGIS/rest/services/MontgomeryEdit/FeatureServer"
    property string baseMapURL: "http://serverapps10.esri.com/ArcGIS/rest/services/Montgomery/MapServer"
    property string summary: ""
    property real tableID

    UserCredentials {
        id: userCredentials
        userName: userName.text
        password: password.text
    }

    ServiceInfoTask {
        id: serviceInfoTask
        url: serviceURL

        credentials: userCredentials

        onFeatureServiceInfoStatusChanged: {
            if (featureServiceInfoStatus == Enums.FeatureServiceInfoStatusCompleted){
                serviceInfoTaskText.text = "Successfully connected to the Service info task"

                userCredText.text = " " + userCredentials.token;
                userCredText.text += "\n\r " + userCredentials.tokenExpiry;

                featureLayer.initialize();
            }
            else if (featureServiceInfoStatus == Enums.FeatureServiceInfoStatusErrored){
                serviceInfoTaskText.text = " > ERROR for serviceInfoTask";
                serviceInfoTaskText.text += "\n\r " + featureServiceInfoError.code;
                serviceInfoTaskText.text += "\n\r " + featureServiceInfoError.message;
            }
        }
    }

    FeatureLayer {
        id: featureLayer

        featureTable: geodatabaseFeatureServiceTable.valid ? geodatabaseFeatureServiceTable : null

        enableLabels: true

        onStatusChanged: {
            if(status == Enums.LayerStatusInitialized) {
                featureLayerText.text = " Feature layer complete";
                featureLayerText.text += "\n\r Table Name: " + featureTable.tableName;
                featureLayerText.text += "\n\r " + featureTable.fields.length + " fields"
                featureLayerText.text += "\n\r Editable?: " + geodatabaseFeatureServiceTable.isEditable;
                featureLayerText.text += "\n\r Has attachments: " + geodatabaseFeatureServiceTable.hasAttachments;

                map.addLayer(featureLayer);
                console.log("length", extent.xMin)

            }

            if(status == Enums.LayerStatusErrored) {
                console.log("Layer create error: ", error)
            }
        }
    }

    GeodatabaseFeatureServiceTable {
        id: geodatabaseFeatureServiceTable

        url: serviceURL + "/0"

        onApplyFeatureEditsStatusChanged: {

            if (applyFeatureEditsStatus === Enums.ApplyEditsStatusCompleted) {
                var newID = lookupObjectId(tableID);
                summary += newID;
            }
            else if (applyFeatureEditsStatus === Enums.ApplyEditsStatusErrored) {
                summary = applyFeatureEditsErrors.error
                summaryText.color = "red";
                addButton.enabled = false;
            }
        }
    }

    /*-------------------------------------------------------------------------
    UI
    -------------------------------------------------------------------------*/

    Map {
        id: map
        anchors.fill: parent

        ArcGISDynamicMapServiceLayer {
            url: baseMapURL
        }

        onLayerCountChanged: {
            if (layerCount > 1) {
                mapText.text += " Layer count: " + map.layerCount;
                mapText.text += "\n\r Layer names: " + map.layerNames;
                visButton.visible = !visButton.visible
            }
        }
    }

    Rectangle {
        anchors {
            fill: resultsColumn
            margins: -10 * scaleFactor
        }
        color: "lightgrey"
        radius: 5 * scaleFactor
        border.color: "black"
        opacity: 0.77

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse.accepted = true)
        }
    }

    Column {

        id: resultsColumn

        anchors {
            top: parent.top
            left: parent.left
            margins: 15
        }

        spacing: 5
        Text {
            text: "<b>Secured Feature Service:</b>"
            width: parent.width
        }
        TextField {
            text: serviceURL
            width: parent.width
            onTextChanged: serviceURL = text
        }
        Text {
            text: "<b>Enter User Credentials:</b>"
            width: parent.width
        }
        Row {
            spacing: 5
            TextField {
                id: userName
                placeholderText: "enter your username"
                text: "user1"
            }
            TextField {
                id: password
                placeholderText: "enter your password"
                echoMode: TextInput.Password
                text: "pass.word1"
            }
            Button {
                id: signIn
                text: "SIGN IN"
                visible: userCredText.text === ""
                enabled: userName.text > "" && password.text > ""
                onClicked: serviceInfoTask.fetchFeatureServiceInfo()
            }
        }
        Text {
            text:"<b>User:</b>\n" + userCredentials.userName
        }
        Text {
            id: userCredText
            width: parent.width
            wrapMode: Text.WrapAnywhere

        }
        Text {
            text:"<b>Service Task:</b>"
        }
        Text {
            id: serviceInfoTaskText
        }
        Text {
            text:"<b>Feature Layer:</b>"
        }
        Text {
            id: featureLayerText
        }
        Text {
            text:"<b>Map Info:</b>"
        }
        Text {
            id: mapText
        }
        Button {
            id: visButton
            text: visible ? "Basemap off" : "Basemap on"
            visible: false
            onClicked: {
                map.layerByIndex(0).visible = !map.layerByIndex(0).visible
            }
        }
        Button {
            id: addButton
            text: "Add point and sync"

            onClicked: {
                var point = ArcGISRuntime.createObject("Point");
                point.spatialReference = ArcGISRuntime.createObject("SpatialReference", {"json":{"wkid": featureLayer.spatialReference.wkid}});
                point.x = random(503000, 511000);
                point.y = random(678300, 687000);

                summary = "X: " + point.x + ", Y: " + point.y + ", ID: ";

                var featureToEdit = ArcGISRuntime.createObject("GeodatabaseFeature");
                featureToEdit.geometry = point;
                featureToEdit.setAttributeValue("Name", userCredentials.userName);
                featureToEdit.setAttributeValue("Tracking_Number", random(607, 2105));

                tableID = geodatabaseFeatureServiceTable.addFeature(featureToEdit);

                geodatabaseFeatureServiceTable.applyFeatureEdits();
            }

            function random(min, max){
                return Math.floor(Math.random() * (max - min)) + min;
            }
        }
        Text {
            id: summaryText
            text: summary
        }
    }
}

