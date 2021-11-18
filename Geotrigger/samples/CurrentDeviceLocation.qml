/* Copyright 2020 Esri
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


// You can run your app in Qt Creator by pressing Alt+Shift+R.
// Alternatively, you can run apps through UI using Tools > External > AppStudio > Run.
// AppStudio users frequently use the Ctrl+A and Ctrl+I commands to
// automatically indent the entirety of the .qml file.

import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import QtPositioning 5.12
import QtQuick.Dialogs 1.2

import Esri.ArcGISRuntime 100.12
import Esri.ArcGISRuntime.Toolkit 100.12

import ArcGIS.AppFramework 1.0

Item {

    property var medicalFacilityInRange: []
    property var currentLocation: null
    property var initialLocationLongitude: null
    property var initialLocationLatitude: null
    property bool initializeFeaturesInBuffer: false
    property double geotriggerBufferSize: 200
    property double featureBufferSize: 16093.44
    property int featuresFoundCount: 0
    property bool initializedLocation: false
    property bool initializedMap: false
    property string lastQueryTask: ""

    MapView {
        id: mapView
        anchors.fill: parent

        GraphicsOverlay {
            id: graphicsOverlay
        }

        //Used to rerender featurelayer with medicalFacility logo
        SimpleRenderer {
            id: renderSBLogo
            PictureMarkerSymbol {
                id: medicalFacilityLogo
                url: "../assets/medicalFacility_Logo_2011.png"
                width: 25 * scaleFactor
                height: width
            }
        }

        SelectionProperties {
            id: selectionProperty
            color: "cyan"
        }

        BusyIndicator {
            id: busyIndicator

            anchors.centerIn: parent
            running: true
        }

        Map {
            id: map

            BasemapLightGrayCanvas {}
            //Feature layer with medicalFacility locations data
            FeatureLayer {
                id: medicalFacilityFeature

                //feature for medicalFacilitynts of interest for geotrigger fence parameter
                ServiceFeatureTable {
                    id: medicalFacilityServiceFeatureTable
                    PortalItem {
                        itemId: "103d643c221e40dea643bf7dff13364a"
                    }

                    initLayerId: "0"
                    onQueryFeaturesStatusChanged: {
                        if(queryFeaturesStatus === Enums.TaskStatusCompleted){
                            if(!queryFeaturesResult){
                                errorMsgDialog.visible = true;
                                return;
                            }
                            if (!queryFeaturesResult.iterator.hasNext) {
                                errorMsgDialog.visible = true;
                                return;
                            }

                            // clear any previous selection
                            medicalFacilityFeature.clearSelection();

                            var features = []
                            //get the features from query
                            while (queryFeaturesResult.iterator.hasNext) {
                                features.push(queryFeaturesResult.iterator.next());
                            }

                            //If first initializing geotrigger, get features within buffer and create
                            //a definitionExpression to display only those features.
                            if(!initializeFeaturesInBuffer){

                                featuresFoundCount = features.length;

                                var featuresNames = [];

                                //Add medicalFacility location name field to list used to create a definition expression
                                for(let i = 0; i < features.length; i++){
                                    featuresNames.push(features[i].attributes.attributesJson["objectid"]);
                                }

                                //Create a definitionExpression string to display features found within bfufer
                                var definitionExpression = "";

                                for(let j = 0; j < featuresNames.length; j++){
                                    definitionExpression = definitionExpression + "objectid = \'" + featuresNames[j] + "\'"
                                    //If last element, don't add or
                                    if(j + 1 !== featuresNames.length){
                                        definitionExpression = definitionExpression + " OR ";
                                    }
                                }

                                medicalFacilityFeature.definitionExpression = definitionExpression;
                                initializeFeaturesInBuffer = true;

                                //After setting definitionExpression, start the geotrigger monitor
                                medicalFacilityGeotriggerMonitor.start()
                            } else {

                                //select the features
                                medicalFacilityFeature.selectFeatures(features);
                            }
                        } else if(queryFeaturesStatus === Enums.TaskStatusErrored){
                            console.log("Error " + error.message);
                        }
                    }

                }
            }
        }

        locationDisplay {
            id: userLocation
            autoPanMode: Enums.LocationDisplayAutoPanModeRecenter
            initialZoomScale: 50000
            wanderExtentFactor: 0.85
            positionSource: PositionSource {
                id: posSrc
                updateInterval: 5000
                active: true
                onPositionChanged: {
                    //Get and update currentlocation when position is found/changed
                    var coord = posSrc.position.coordinate;
                    currentLocation = coord;
                    //Set the initial location and call findFeaturesWithinRadius
                    if(!initialLocationLatitude && mapView.spatialReference !== null) {
                        busyIndicator.running = false;
                        initialLocationLatitude = currentLocation.latitude
                        initialLocationLongitude = currentLocation.longitude
                        findFeaturesWithinRadius();
                    }
                    //If there is an initialLocation, check distance from initial location
                    if(initialLocationLatitude) {
                        checkDistanceCovered()
                    }
                }

            }

            dataSource: DefaultLocationDataSource {
                id: defaultLocationDataSource
                Component.onCompleted: {
                    defaultLocationDataSource.start()
                }
            }
            onLocationChanged: {
                //Used to determine location accuracy
                positionAccuracy = userLocation.location.horizontalAccuracy
            }
        }

        QueryParameters {
            id: params
        }

        QueryParameters {
            id: featuresWithinRadiusParameters
        }

        // error message dialog
        MessageDialog {
            id: errorMsgDialog
            visible: false
            text: "No features found."
            onAccepted: {
                visible = false;
            }
        }

        Component.onCompleted: {
            initializedMap = true;
        }
    }

    //Geotriggers for medicalFacility features
    GeotriggerMonitor {
        id: medicalFacilityGeotriggerMonitor

        //Set which location data source to follow
        geotrigger: FenceGeotrigger {
            feed: LocationGeotriggerFeed {
                locationDataSource: defaultLocationDataSource
            }

            ruleType: Enums.FenceRuleTypeEnterOrExit
            //Indicates which features to monitor and distance (in meters)
            //from features to trigger
            fenceParameters: FeatureFenceParameters {
                featureTable: medicalFacilityServiceFeatureTable
                bufferDistance: geotriggerBufferSize
            }

            messageExpression: ArcadeExpression {
                expression: "$fencefeature.objectid";
            }

            name: "medicalFacilityGeotrigger"
        }

        //Provides warnings for issues. Note: Geotrigger fails and logs error
        //before definitionExpression is used.
        onWarningChanged: {
            console.log("Status code: " + status + " - " + warning.additionalMessage)
        }

        onGeotriggerNotification: {
            const medicalFacilityId = geotriggerNotificationInfo.message;
            const index = medicalFacilityInRange.indexOf(medicalFacilityId);

            // Commit feature attributes to memory for later querying and display
            if (!(medicalFacilityId in featuresMap))
                featuresMap[medicalFacilityId] = geotriggerNotificationInfo.fenceGeoElement;

            //Get information about medicalFacility feature and add to map
            if (!(medicalFacilityId in descriptionMap)){
                descriptionMap[medicalFacilityId] = [
                            geotriggerNotificationInfo.fenceGeoElement.attributes.attributeValue("objectid").toString(),
                        ];
                //Add other attributes if they are not null
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "name");
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "amenity");
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "addr_housenumber");
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "addr_street");
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "addr_city");
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "addr_state");
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "addr_province");
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "addr_country");
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "addr_postcode");
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "addr_unit");
                addAttribute(medicalFacilityId, geotriggerNotificationInfo, "building");
            }

            // If entering a fence feature, add it to the UI
            if (geotriggerNotificationInfo.fenceNotificationType === Enums.FenceNotificationTypeEntered && index === -1)
                medicalFacilityInRange[medicalFacilityInRange.length] = medicalFacilityId;

            // If exiting the fence feature, remove it from the UI
            else if (geotriggerNotificationInfo.fenceNotificationType === Enums.FenceNotificationTypeExited)
                medicalFacilityInRange.splice(index, 1);

            medicalFacilityInRangeChanged();

            //Set query parameters for highlighting features
            var paramNames = " "

            //Create query for all features in range
            for(let i = 0; i < medicalFacilityInRange.length; i++){
                if(i === 0) {
                    paramNames = "objectid = \'" + medicalFacilityInRange[i] + "\'"
                } else {
                    paramNames = paramNames + " OR " + "objectid = \'" + medicalFacilityInRange[i] + "\'"
                }
            }

            //Query by name to display
            params.whereClause = paramNames

            //Clear all selection if moving away from all features
            if(medicalFacilityInRange.length === 0){
                medicalFacilityFeature.clearSelection()
            } else {
                //If there was a query task, make sure it is canceled before running another query
                if(lastQueryTask !== "" ){
                    medicalFacilityServiceFeatureTable.cancelTask(lastQueryTask)
                }
                lastQueryTask = medicalFacilityServiceFeatureTable.queryFeatures(params)
            }
        }

        //Checks if attribute is not null, then add to map,
        //otherwise don't add if null
        function addAttribute(medicalFacilityId, geotriggerNotificationInfo, attribute){
            if(geotriggerNotificationInfo.fenceGeoElement.attributes.attributeValue(attribute) !== null){
                descriptionMap[medicalFacilityId][attribute] = (geotriggerNotificationInfo.fenceGeoElement.attributes.attributeValue(attribute).toString())
            } else {
                return false;
            }
        }
    }

    // User interface

    // The featureSelectButtonsColumn displays the current section as well as medicalFacilitynts of interest within 10 meters
    // Buttons are added and removed when a feature fence has been entered or exited.
    Control {
        id: featureSelectButtonsColumn
        anchors.right: parent.right
        padding: 10
        visible: !aboutCurrentDeviceFeaturePane.visible
        background: Rectangle {
            color: "white"
            border.color: "black"
        }
        contentItem: Column {
            id: column
            spacing: 8
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                padding: 5
                text: "Total facilities " + getLocaleAndReturnMeasurementString(featureBufferSize) + ": " + featuresFoundCount
                color: "#3B4E1E"
                font {
                    bold: true
                    pointSize: 12
                }
                wrapMode: Text.WordWrap
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                padding: 5
                text: "Facilities nearby " + getLocaleAndReturnMeasurementString(geotriggerBufferSize) + ": "
                color: "#3B4E1E"
                font {
                    bold: true
                    pointSize: 16
                }
                wrapMode: Text.WordWrap
            }
            Text {
                id: noFacilities
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                padding: 5
                visible: medicalFacilityInRange.length === 0
                text: "There are no facilities nearby"
                color: "#3B4E1E"
                font {
                    bold: true
                    pointSize: 12
                }
                wrapMode: Text.WordWrap
            }
            Repeater {
                id: medicalFacilityRepeater
                model: medicalFacilityInRange
                visible: medicalFacilityInRange.length > 0
                delegate: RoundButton {
                    id: medicalFacilityButton
                    width: parent.width - 10
                    height: 35 * scaleFactor
                    padding: 8
                    Text {
                        id: medicalFacilityButtonText
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width - 15
                        padding: 8
                        text: descriptionMap[modelData]["name"] ? descriptionMap[modelData]["name"] : "N/A"
                        wrapMode: Text.WordWrap
                        font.bold: true
                        color: "white"
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 8
                        font.pixelSize: 12
                    }
                    background: Rectangle {
                        anchors.fill: parent
                        radius: medicalFacilityButton.radius
                        color: "#AC901E"
                    }
                    onClicked: {
                        currentFeatureName = modelData;
                        getFeatureInformation(currentFeatureName);
                        aboutCurrentDeviceFeaturePane.visible = true;
                    }
                }
            }
        }
    }

    //Checks whether attribute is defined or not.
    function notNull(featureName, attribute){
        if(descriptionMap[featureName][attribute] === undefined){
            return ""
        } else {
            return descriptionMap[featureName][attribute]
        }
    }

    //Get UI from FeatureInfoPane with medicalFacility info
    function getFeatureInformation(featureName) {
        aboutCurrentDeviceFeaturePane.featureName = notNull(featureName, "name")
        aboutCurrentDeviceFeaturePane.featureAmenity = notNull(featureName, "amenity")
        aboutCurrentDeviceFeaturePane.featureHouseNumber = notNull(featureName, "addr_housenumber")
        aboutCurrentDeviceFeaturePane.featureStreet = notNull(featureName, "addr_street")
        aboutCurrentDeviceFeaturePane.featureCity = notNull(featureName, "addr_city")
        aboutCurrentDeviceFeaturePane.featureState = notNull(featureName, "addr_state")
        aboutCurrentDeviceFeaturePane.featureProvince = notNull(featureName, "addr_province")
        aboutCurrentDeviceFeaturePane.featureCountry = notNull(featureName, "addr_country")
        aboutCurrentDeviceFeaturePane.featurePostcode = notNull(featureName, "addr_postcode")
        aboutCurrentDeviceFeaturePane.featureUnit = notNull(featureName, "addr_unit")
        aboutCurrentDeviceFeaturePane.featureBuilding = notNull(featureName, "building")
    }

    //First, create a geometry engine buffer and add to query parameters
    //Called only when querying for features within radius
    function findFeaturesWithinRadius(){

        if(initialLocationLatitude !== null && initialLocationLongitude !== null && mapView.spatialReference !== null){

            //Used to determine how to query feature service table
            initializeFeaturesInBuffer = false
            //Create a point at current location and a buffer around it with
            //radius in meters
            var bufferRadius = featureBufferSize;

            //Create point based on initial location and project mapView
            //to have same spatial reference before creating and adding the buffer geometry
            var locationPoint = ArcGISRuntimeEnvironment.createObject("Point", {
                                                                          x: initialLocationLongitude,
                                                                          y: initialLocationLatitude,
                                                                          spatialReference: Factory.SpatialReference.createWgs84()
                                                                      });
            var projectedPoint = GeometryEngine.project(locationPoint, mapView.spatialReference);
            var bufferGeometry = GeometryEngine.buffer(projectedPoint, bufferRadius);

            //Add buffer to query parameters to find intersecting features within buffer radius
            featuresWithinRadiusParameters.geometry = bufferGeometry;
            featuresWithinRadiusParameters.spatialRelationship = Enums.SpatialRelationshipIntersects;
            medicalFacilityServiceFeatureTable.queryFeatures(featuresWithinRadiusParameters)
        }
    }


    //Checks the distance from initial location to current location.
    //If distance is >= half the buffer radius, set new initial location
    //and find all features within buffer radius of new location
    function checkDistanceCovered() {

        if(initialLocationLatitude !== null && currentLocation !== null) {
            //Create point objects and project them to mapView spatial reference
            var startLocation = ArcGISRuntimeEnvironment.createObject("Point", {
                                                                          x: initialLocationLongitude,
                                                                          y: initialLocationLatitude,
                                                                          spatialReference: Factory.SpatialReference.createWgs84()
                                                                      });
            var projectedStartLocation = GeometryEngine.project(startLocation, mapView.spatialReference);
            var endingLocation = ArcGISRuntimeEnvironment.createObject("Point", {
                                                                           x: currentLocation.longitude,
                                                                           y: currentLocation.latitude,
                                                                           spatialReference: Factory.SpatialReference.createWgs84()
                                                                       });
            var projectedEndLocation = GeometryEngine.project(endingLocation, mapView.spatialReference);

            //Get the geodetic distance between 2 points
            var geodeticDistance = GeometryEngine.distanceGeodetic(projectedStartLocation, projectedEndLocation, Enums.LinearUnitIdMeters, Enums.AngularUnitIdDegrees, Enums.GeodeticCurveTypeGeodesic)
            var distanceTraveled = geodeticDistance.distance

            //If distance traveled is 5 miles or more,
            //Set initialLocation to current location and requery features
            if(distanceTraveled >= featureBufferSize/2){
                initialLocationLatitude = currentLocation.latitude;
                initialLocationLongitude = currentLocation.longitude;
                findFeaturesWithinRadius();
            }
        }
    }

    //Takes the meters measurement, returns appropriate string based on metric system
    function getLocaleAndReturnMeasurementString(meters) {
        if(localeMeasurementSystem === Locale.ImperialUSSystem) {
            var feet = meters * 3.28
            if(feet > 5280){
                var miles = feet / 5280
                return "(" + miles.toFixed(0) + " mi)";
            } else {
                return "(" + feet.toFixed(0) + " ft)";
            }
        } else {
            if(meters > 1000){
                var kilometers = meters / 1000
                return "(" + kilometers.toFixed(0) + " km)";
            } else {
                return "(" + meters.toFixed(0) + " m)";
            }
        }
    }
}
