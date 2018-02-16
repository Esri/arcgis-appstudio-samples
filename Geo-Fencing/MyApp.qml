/* Copyright 2017 Esri
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

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import QtPositioning 5.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Notifications 1.0
import ArcGIS.AppFramework.Notifications.Local 1.0

import Esri.ArcGISRuntime 100.2
import QtSensors 5.0
import QtMultimedia 5.8
import QtQuick.Controls.Styles 1.4
import ArcGIS.AppFramework.Speech 1.0


import "controls" as Controls

App {
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    property string currentQueryTaskId:""

    property bool inBuilding
    property bool activeDevice: true
    property string navMode: "empty"
    property bool voiceMode: true
    property bool toppanelon: true
    property bool layerpanelon: false
    property string currentlayer: "esribuilding"
    property string currentunit: "mile_hour"
    property Geometry locationregion
    property Geometry lastpoint
    property bool iwannatest: false

    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle{
            anchors.top:header.bottom
            // Map view UI presentation at top

            MapView{
                id: mapView
                anchors.fill: parent
                zoomByPinchingEnabled: true
                rotationByPinchingEnabled: true
                wrapAroundMode: Enums.WrapAroundModeEnabledWhenSupported


                //Busy Indicator
                BusyIndicator {
                    id: loadingicon
                    anchors.centerIn: parent
                    height: 48 * scaleFactor
                    width: height
                    running: true
                    Material.accent:"#8f499c"
                    visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
                }

                Map {
                    id: map
                    initUrl: "http://melbournedev.maps.arcgis.com/sharing/rest/content/items/931afb1deebf4ec09d430641080c82a6"
                    FeatureLayer {
                        id: featureLayer_esribuilding
                        ServiceFeatureTable {
                            id: servicefeaturetable_esribuilding
                            url: "https://services1.arcgis.com/e7dVfn25KpfE6dDd/ArcGIS/rest/services/Esri_Campus_Geofencing3/FeatureServer/0"
                            onQueryFeaturesStatusChanged: {
                                if (queryFeaturesStatus === Enums.TaskStatusCompleted) {
                                    var templength = queryFeaturesResult.iterator.features.length;
                                    if (iwannatest) {
                                        console.log(notification.schedule("alert","the length of intersecting thing is: "+templength, 0.1));
                                        iwannatest=false;
                                    }

                                    if (templength===0){
                                        if (inBuilding==true && navMode!="empty") {
                                            if(activeDevice && voiceMode){
                                                textToSpeech.say("See you next time!")
                                            } else if(activeDevice) {
                                                Vibration.vibrate();
                                            } else {
                                                console.log(notification.schedule("alert","See you next time!", 0.1));
                                            }
                                        }
                                        inBuilding = false;
                                        statuslabel.text = "Outside";
                                    } else {
                                        if (inBuilding==false && navMode!="empty") {
                                            if (activeDevice && voiceMode) {
                                                textToSpeech.say("Welcome to ESRI buildings!")
                                            } else if(activeDevice) {
                                                Vibration.vibrate();
                                            } else {
                                                console.log(notification.schedule("alert","Welcome to ESRI Building!", 0.1));
                                            }
                                        }
                                        inBuilding = true;
                                        statuslabel.text = "Inside";
                                    }
                                }
                            }
                        }
                    }
                    FeatureLayer {
                        id: featureLayer_nationalpark
                        visible: false
                        ServiceFeatureTable {
                            id: servicefeaturetable_nationalpark
                            url: "https://services1.arcgis.com/fBc8EJBxQRMcHlei/arcgis/rest/services/NPS_Park_Boundaries/FeatureServer/0"
                            featureRequestMode: Enums.FeatureRequestModeOnInteractionNoCache
                            onQueryFeaturesStatusChanged: {
                                if (queryFeaturesStatus === Enums.TaskStatusCompleted) {
                                    var templength = queryFeaturesResult.iterator.features.length;
                                    if (templength===0){
                                        if (inBuilding==true && navMode!="empty") {
                                            if(activeDevice && voiceMode){
                                                textToSpeech.say("See you next time!")
                                            } else if(activeDevice) {
                                                Vibration.vibrate();
                                            } else {
                                                console.log(notification.schedule("alert","See you next time!", 0.1));
                                            }
                                        }
                                        inBuilding = false;
                                        statuslabel.text = "Outside";
                                    } else {
                                        if (inBuilding==false && navMode!="empty") {
                                            if (activeDevice && voiceMode) {
                                                textToSpeech.say("Welcome to National Park!")
                                            } else if(activeDevice) {
                                                Vibration.vibrate();
                                            } else {
                                                console.log(notification.schedule("alert","Welcome to National Park!", 0.1));
                                            }
                                        }
                                        inBuilding = true;
                                        statuslabel.text = "Inside";
                                    }
                                }
                            }
                        }
                    }
                    FeatureLayer {
                        id: featureLayer_starbucks
                        visible: false
                        ServiceFeatureTable {
                            id: servicefeaturetable_starbucks
                            url: "https://services1.arcgis.com/e7dVfn25KpfE6dDd/arcgis/rest/services/starbucks10meter/FeatureServer/0"
                            featureRequestMode: Enums.FeatureRequestModeOnInteractionNoCache
                            onQueryFeaturesStatusChanged: {
                                if (queryFeaturesStatus === Enums.TaskStatusCompleted) {
                                    var templength = queryFeaturesResult.iterator.features.length;
                                    if (templength===0){
                                        if (inBuilding==true && navMode!="empty") {
                                            if(activeDevice && voiceMode){
                                                textToSpeech.say("See you next time!")
                                            } else if(activeDevice) {
                                                Vibration.vibrate();
                                            } else {
                                                console.log(notification.schedule("alert","See you next time!", 0.1));
                                            }
                                        }
                                        inBuilding = false;
                                        statuslabel.text = "Outside";
                                    } else {
                                        if (inBuilding==false && navMode!="empty") {
                                            if (activeDevice && voiceMode) {
                                                textToSpeech.say("Welcome to Starbucks!")
                                            } else if(activeDevice) {
                                                Vibration.vibrate();
                                            } else {
                                                console.log(notification.schedule("alert","Welcome to Starbucks!", 0.1));
                                            }
                                        }
                                        inBuilding = true;
                                        statuslabel.text = "Inside";
                                    }
                                }
                            }
                        }
                    }
                }

        //        GraphicsOverlay {
        //            id: graphicsOverlay
        //            visible: true
        //        }

                // Define parameters for the geo-fencing query task.
                QueryParameters {
                    id: queryParameters
                    spatialRelationship: Enums.SpatialRelationshipIntersects
                    returnGeometry: true
                }

                // Remote testing if required
        //        onMouseClicked: {
        //            queryParameters.geometry = screenToLocation(mouse.x,mouse.y);
        //            GeometryEngine.project(queryParameters.geometry,featureLayer.spatialReference);
        //            currentQueryTaskId = servicefeaturetable.queryFeatures(queryParameters);
        //        }
                onMapRotationChanged: {
                    if(mapView.mapRotation!=0 & navMode!="stage3") {
                        navigationbutton.visible=true;
                    } else {
                        navigationbutton.visible = false;
                    }
                }

                locationDisplay {
                    positionSource: positionSource
                    compass: compass
                    showAccuracy: true
                }

                onMouseReleased: {
                    if (navMode=="stage1") {
                        zoomToCurrentLocation(2000);
                    }
                }

                PolygonBuilder {
                    id: polygonBuilder
                    spatialReference: featureLayer_esribuilding.spatialReference
                }
                SimpleFillSymbol {
                    id: nestingGroundSymbol
                    style: Enums.SimpleFillSymbolStyleSolid
                    color: Qt.rgba(0.0, 0.31, 0.0, 0.3)
                }
            }


            Controls.CustomizedPane {
                id: customizedinfopane
                width: Math.min(600*app.scaleFactor, parent.width)
                height: 65*scaleFactor
                anchors.topMargin: 15*scaleFactor
                anchors.bottom:parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                Material.elevation: 2
                padding: 5*scaleFactor
                RowLayout {
                    id: infoBar
                    width: parent.width
                    height: parent.height

                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100*scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0
                        Image {
                            id: speedSource
                            Layout.preferredHeight: 35*scaleFactor
                            Layout.preferredWidth:35*scaleFactor
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: "assets/stop.png"
                            opacity: 0.8
                            mipmap:true
                        }
                        Text {
                            id: speed
                            Layout.preferredHeight: 20*scaleFactor
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            text: "0.00 mi/h"
                            font.pixelSize: 18
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (currentunit == "mile_hour") {
                                        currentunit = "meter_second";
                                    } else {
                                        currentunit = "mile_hour";
                                    }
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillHeight: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle {
                            Layout.preferredHeight: 65*scaleFactor
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            Material.background: "#ffffff"

                            Text {
                                id: statuslabel
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Status"
                                font.bold: true
                                font.pixelSize: 24
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100*scaleFactor
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0
                        ToolButton {
                            Layout.preferredHeight: 35*scaleFactor
                            Layout.preferredWidth:35*scaleFactor
                            anchors.horizontalCenter: parent.horizontalCenter
                            indicator: Image {
                                height: parent.height
                                anchors.centerIn: parent
                                source: voiceMode?"./assets/onvoice.png":"./assets/novoice.png"
                                fillMode: Image.PreserveAspectFit
                                mipmap:true
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if(voiceMode) {
                                            voiceMode = false;
                                            voiceonoff.text = "off"
                                        } else {
                                            voiceMode=true;
                                            voiceonoff.text = "on"
                                        }
                                    }
                                }
                            }
                        }
                        Text {
                            id: voiceonoff
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            text: "on"
                            font.pixelSize: 18
                        }
                    }
                }
                function open() {
                    customizedinfopane.anchors.topMargin = 0;
                    toppanelon = true;
                }
                function close() {
                    customizedinfopane.anchors.topMargin = -65*scaleFactor;
                    toppanelon = false;
                }

                Behavior on anchors.topMargin {
                    NumberAnimation {
                        duration: 250
                    }
                }
            }

            ColumnLayout {
                id: rightcontrolbuttons
                width: 60*scaleFactor
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 12*scaleFactor
                }
                spacing: 1*scaleFactor

                property color normalColor: "#808080"
                property color activeColor: "#6DB5E3"
                Controls.RoundButton {
                    id: navigationbutton
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.width
                    radius: parent.width/2
                    padding: 0
                    visible: false
                    Material.background: "#ffffff"
                    rotation: -mapView.mapRotation
                    contentItem: Image {
                        source: "assets/navigation.png"
                        opacity: 0.8
                        anchors {
                            fill: parent
                            margins: 10*app.scaleFactor
                        }
                        mipmap: true
                    }
                    onClicked: {
                        mapView.setViewpointRotation(0);
                    }
                }


                Controls.RoundButton {
                    id: layerbutton
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.width
                    radius: parent.width/2
                    imageSource: "assets/layer.png"
                    MouseArea {
                        anchors.fill: parent;
                        onClicked: {
                            if (layerpanelon) {
                                layerchoices.close();
                                layerpanelon = false;
                            } else {
                                layerchoices.open();
                                layerpanelon = true
                            }
                        }
                    }
                }

                Controls.RoundButton {
                    id: locationbutton
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.width
                    radius: parent.width/2
                    imageSource: "assets/location.png"
                    onClicked: {
                        if (!mapView.locationDisplay.started) {
                            accuracybox.visible = true;
                            locationbutton.imageColor = "#6DB5E3";
                            zoomToCurrentLocation(2000);
                            mapView.locationDisplay.start();
                            mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeRecenter;
                            navMode = "stage1";
                            customizedinfopane.open();
                        } else if (navMode == "stage1") {
                            mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeNavigation;
                            mapView.enabled = false;
                            navMode = "stage2";
                            locationbutton.imageSource = "assets/nav.png";
                        } else if (navMode == "stage2") {
                            mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeCompassNavigation;
                            navMode = "stage3";
                            navigationbutton.visible=false;
                            locationbutton.imageSource = "assets/compass.png";
                        } else {
                            locationbutton.imageSource = "assets/location.png"
                            mapView.enabled = true;
                            mapView.locationDisplay.stop();
                            locationbutton.imageColor = "#808080";
                            navMode = "empty";
                            accuracybox.visible = false;
                            customizedinfopane.close();
                        }
                    }
                }
            }

            Controls.CustomizedPane {
                id: layerchoices
                width: 0
                height: 400*scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                Material.elevation: 2
                opacity: 0
                ColumnLayout {
                    Layout.fillHeight: true
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5*scaleFactor
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Select a geo-fence layer"
                        font.pixelSize: 18
                        color: "green"
                    }
                    Button {
                        id: esribuildinglayer
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: 50*scaleFactor
                        Material.background: "darkred"
                        Text {
                            text: "ESRI Buildings"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 16
                            color: "white"
                        }
                        onClicked: {
                            featureLayer_esribuilding.visible = true;
                            featureLayer_nationalpark.visible = false;
                            featureLayer_starbucks.visible = false;
                            currentlayer = "esribuilding";
                            layerchoices.close();
                            lastpoint = null;
                            updateStatus(positionSource.position);
                        }
                    }

                    Button {
                        id: nationalparklayer
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: 50*scaleFactor
                        Material.background: "green"
                        Text {
                            text: "National Parks"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color:"white"
                            font.pixelSize: 16
                        }
                        onClicked: {
                            featureLayer_esribuilding.visible = false;
                            featureLayer_nationalpark.visible = true;
                            featureLayer_starbucks.visible = false;
                            currentlayer="nationalpark";
                            layerchoices.close();
                            lastpoint = null;
                            updateStatus(positionSource.position);
                        }
                    }

                    Button {
                        id: starbuckslayer
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        Layout.preferredWidth: parent.width
                        Layout.preferredHeight: 50*scaleFactor
                        Material.background: "orange"
                        Text {
                            text: "Starbucks"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            color:"white"
                            font.pixelSize: 16
                        }
                        onClicked: {
                            featureLayer_esribuilding.visible = false;
                            featureLayer_nationalpark.visible = false;
                            featureLayer_starbucks.visible = true;
                            currentlayer="starbucks";
                            layerchoices.close();
                            lastpoint = null;
                            updateStatus(positionSource.position);
                        }
                    }
                }
                function open() {
                    layerchoices.width = Math.min(600*scaleFactor, parent.width)*0.6;
                    layerchoices.opacity = 1;
                }
                function close() {
                    layerchoices.width = 0;
                    layerchoices.opacity = 0;
                }
                Behavior on width {
                    NumberAnimation {
                        duration: 250
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                    }
                }

            }

            PositionSource{
                id: positionSource
                updateInterval: 1000
                active: true

                onPositionChanged: {
                    updateStatus(position);

                    // update speed and guess the travel mode of current situation
                    if (currentunit=="mile_hour") {
                        speed.text = (mapView.locationDisplay.location.velocity*9/4).toFixed(2)+" mi/h";
                    } else {
                        speed.text = mapView.locationDisplay.location.velocity.toFixed(2)+" m/s";
                    }
                    positionSource.update();
                    if (mapView.locationDisplay.location.velocity == 0) {
                        speedSource.source = "assets/stop.png"
                    } else if (mapView.locationDisplay.location.velocity >= 0 && mapView.locationDisplay.location.velocity<3) {
                        speedSource.source = "assets/walk.png"
                    } else if (mapView.locationDisplay.location.velocity >= 3 && mapView.locationDisplay.location.velocity<6) {
                        speedSource.source = "assets/run.png"
                    } else {
                        speedSource.source = "assets/drive.png"
                    }
                }
            }

            Compass {
                id: compass
            }

            LocalNotification {
                id: notification
            }

            Rectangle {
                id: accuracybox
                width: 65*scaleFactor
                height: 30*scaleFactor
                anchors {
                    top: parent.top
                    right: parent.right
                    rightMargin: 20*scaleFactor
                    topMargin: 85*scaleFactor
                }
                visible: false

                Material.background: "#ffffff"
                color: "green"
                Text {
                    id: accuracyvalue
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "± 0 ft"
                    font.pixelSize: 16
                    color: "white"
                }
            }

            TextToSpeech {
                id: textToSpeech

                property var locales

                Component.onCompleted: {
                    var locales = []
                    for (var i = 0; i < availableLocales.length; i++) {
                        var name = availableLocales[i];
                        var localeInfo = AppFramework.localeInfo(name);
                        locales.push({
                                         name: name,
                                         label: "%1 (%2)".arg(localeInfo.countryName).arg(localeInfo.languageName)
                                     });
                    }

                    textToSpeech.locales = locales;
                }
            }

            Connections{
                target: Qt.application
                onStateChanged: {
                    if(state === Qt.ApplicationActive) {
                        activeDevice = true;
                    } else {
                        activeDevice = false;
                    }
                }
            }


            }

    }


    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }

    function zoomToCurrentLocation(scale){
        positionSource.update();
        loadingicon.visible=false;
        var currentPositionPoint = ArcGISRuntimeEnvironment.createObject("Point", {x: positionSource.position.coordinate.longitude, y: positionSource.position.coordinate.latitude, spatialReference: SpatialReference.createWgs84()});
        var centerPoint = GeometryEngine.project(currentPositionPoint, mapView.spatialReference);
        var viewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter",{center: centerPoint, targetScale: scale});
        mapView.setViewpointWithAnimationCurve(viewPointCenter, 2.0,  Enums.AnimationCurveEaseInOutCubic);
    }

    function updateStatus(position) {
        if (!lastpoint && position.coordinate.latitude) {

            lastpoint = CoordinateFormatter.fromLatitudeLongitude(position.coordinate.latitude+","+position.coordinate.longitude,featureLayer_esribuilding.spatialReference);

            queryParameters.geometry = lastpoint;

            if (currentlayer=="esribuilding") {
                currentQueryTaskId = servicefeaturetable_esribuilding.queryFeatures(queryParameters);
            } else if (currentlayer=="nationalpark") {
                currentQueryTaskId = servicefeaturetable_nationalpark.queryFeatures(queryParameters);
            } else if (currentlayer=="starbucks") {
                currentQueryTaskId = servicefeaturetable_starbucks.queryFeatures(queryParameters);
            }

        }
        if (lastpoint){
            var currentaccuracy = mapView.locationDisplay.location.horizontalAccuracy;
            if (currentaccuracy>20) {
                statuslabel.text="Unknown";
            } else {
                var currentpoint = CoordinateFormatter.fromLatitudeLongitude(position.coordinate.latitude+","+position.coordinate.longitude,featureLayer_esribuilding.spatialReference);
                if (statuslabel.text=="Unknown") {
                    queryParameters.geometry = currentpoint;
                    if (currentlayer=="esribuilding") {
                        currentQueryTaskId = servicefeaturetable_esribuilding.queryFeatures(queryParameters);
                    } else if (currentlayer=="nationalpark") {
                        currentQueryTaskId = servicefeaturetable_nationalpark.queryFeatures(queryParameters);
                    } else if (currentlayer=="starbucks") {
                        currentQueryTaskId = servicefeaturetable_starbucks.queryFeatures(queryParameters);
                    }
                }
                var dist = GeometryEngine.distance(lastpoint, currentpoint);
                if (dist>3){
                    queryParameters.geometry = currentpoint;
                    console.log("dist > 3");
                    lastpoint = CoordinateFormatter.fromLatitudeLongitude(position.coordinate.latitude+","+position.coordinate.longitude,featureLayer_esribuilding.spatialReference);


                    if (currentaccuracy>19.9) {
                        locationregion = uncertaintyPoint(lastpoint.x,lastpoint.y,mapView.locationDisplay.location.horizontalAccuracy);

                        // if want to see the graphic overlay when moving, uncomment this function. This process may slow down the speed.
//                        graphicsOverlay.graphics.append(createGraphic(locationregion, nestingGroundSymbol));

                        queryParameters.geometry = locationregion;
                        iwannatest = true;
                    }


                    if (currentlayer=="esribuilding") {
                        currentQueryTaskId = servicefeaturetable_esribuilding.queryFeatures(queryParameters);
                    } else if (currentlayer=="nationalpark") {
                        currentQueryTaskId = servicefeaturetable_nationalpark.queryFeatures(queryParameters);
                    } else if (currentlayer=="starbucks") {
                        currentQueryTaskId = servicefeaturetable_starbucks.queryFeatures(queryParameters);
                    }

                }
            }




            // update the accuracy of current location
            accuracyvalue.text = "± " + (mapView.locationDisplay.location.horizontalAccuracy*3.28084).toFixed(0) + " ft";
            if (mapView.locationDisplay.location.horizontalAccuracy>20) {
                accuracybox.color="red";
            } else {
                accuracybox.color="green";
            }
        }
    }
    function uncertaintyPoint(x,y,accuracy) {
        console.log("test");
        polygonBuilder.addPointXY(x-accuracy,y-accuracy);
        polygonBuilder.addPointXY(x+accuracy,y-accuracy);
        polygonBuilder.addPointXY(x+accuracy,y+accuracy);
        polygonBuilder.addPointXY(x-accuracy,y+accuracy);
        return polygonBuilder.geometry
    }
    function createGraphic(geometry, symbol) {
        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic");
        graphic.geometry = geometry;
        graphic.symbol = symbol;
        return graphic;
    }

}

