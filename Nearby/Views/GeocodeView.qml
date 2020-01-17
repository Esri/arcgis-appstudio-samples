import QtQuick 2.9
import QtQuick.Controls 2.5 as NewControls
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.WebView 1.0
import Esri.ArcGISRuntime 100.5

import "../Widgets"
import "../Controls"

Item {
    id: geocodeView

    property var currentPoint
    property int compassDegree: 0
    property bool isShowBackground: false
    property string currentLocatorTaskId: ""
    property alias resultListModel: resultListModel
    property alias placeListDrawer: placeListDrawer
    property alias searchView: searchView
    property alias browserView: browserView
    property alias statusBarControl: statusBarControl
    property alias routeView: routeView
    property bool isInListMode: false//true
    property bool isInRouteMode: false
    property bool weatherObtained: false
    property bool initialSearch: true
    property real currentIndex: -1
    property var allPoints: []
    readonly property bool placeInfoDrawerIsOpen: placeListDrawer.opened
    readonly property string weatherIconSourceUrl: "http://openweathermap.org/img/w/"
    anchors.fill: parent

    ListModel{
        id: resultListModel
    }

    Rectangle{
        id: background

        anchors.fill: parent
        color: colors.lighGreyBackgroundColor
        opacity: isShowBackground? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    ColumnLayout{
        id: columnLayout

        anchors.fill: parent
        spacing: 0
        NewControls.ToolBar {
            id:header

            property double searchBarControlsOpacity: 0.6

            Material.background: app.toolbarColor
            Material.elevation: 4
            Layout.preferredHeight: 56 * app.scaleFactor
            Layout.fillWidth: true

            RowLayout {
                height: parent.height
                width: parent.width
                anchors.centerIn: parent
                spacing: 0

                NewControls.Label {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: 16 * app.scaleFactor
                    text: resultListModel.count > 0
                          ? (searchView.currentSearchCategory !== ""
                             ? resultListModel.count + " " + searchView.currentSearchCategoryLowercase + " " +strings.nearMe
                             : resultListModel.count + " " + strings.nearByPlacesLowercase)
                          : strings.nearByPlaces
                    color: app.secondaryColor
                    font.bold: true
                    elide: NewControls.Label.ElideMiddle
                    verticalAlignment: NewControls.Label.AlignVCenter
                }

                CustomizedToolButton {
                    id: searchBtn

                    imageSource: sources.searchIcon
                    onClicked: {
                        searchView.open();
                        isShowBackground = false;
                    }
                }

                CustomizedToolButton {
                    id: mapBtn

                    imageSource: isInListMode && appManager.isSmall? sources.mapIcon: sources.listIcon
                    onClicked: {
                        if(appManager.isSmall) {
                            if(isInListMode) {
                                isShowBackground = false;
                                isInListMode = false;
                            } else {
                                isInListMode = true;
                                isShowBackground = true;
                            }
                        } else {
                            placeListDrawer.open();
                        }
                    }
                }

                CustomizedToolButton {
                    id: sortBtn

                    imageSource: sources.sortIcon
                    onClicked: {
                        filtersDrawer.open();
                    }
                }

                CustomizedToolButton {
                    id: infoBtn

                    imageSource: sources.infoIcon
                    onClicked: {
                        infoDrawer.open();
                    }
                }
            }
        }

        // View shows on small devices
        CustomizedPane {
            id: searchResultsListviewContainer

            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: isInListMode && appManager.isSmall
            rightPadding: 16 * app.scaleFactor
            topPadding: 0
            bottomPadding: 0
            leftPadding: 0

            Item {
                height: parent.height
                width: Math.min(600*app.scaleFactor, parent.width)
                anchors.centerIn: parent
                visible: mapView.locationObtained && resultListModel.count === 0 && locatorTask.geocodeStatus !== Enums.TaskStatusInProgress

                NewControls.Label {
                    id: noPlaceFoundText

                    width: parent.width
                    anchors.top: parent.top
                    anchors.topMargin: 16 * app.scaleFactor
                    text: searchView.currentSearchCategory !== ""? strings.no + " " + searchView.currentSearchCategoryLowercase + " " + strings.found: strings.noPlacesFound
                    color: colors.textColor
                    font.pixelSize: 14 * app.scaleFactor
                    opacity: 0.9
                    verticalAlignment: NewControls.Label.AlignVCenter
                    horizontalAlignment: NewControls.Label.AlignHCenter
                }
            }

            ListView{
                id: searchResultListView

                height: parent.height
                width: Math.min(600 * app.scaleFactor, parent.width)
                rightMargin: 16
                anchors.centerIn: parent
                clip: true
                model: resultListModel
                spacing: 0

                footer: Item {
                    height: 56 * app.scaleFactor
                }

                delegate: Item {
                    width: parent.width
                    height: 50 * app.scaleFactor

                    Item {
                        anchors.fill: parent

                        Item{
                            width: parent.height
                            height: parent.height
                            anchors.left: parent.left

                            Image{
                                id: categoryIcon

                                width: parent.width * 0.40
                                height: width
                                anchors.top: parent.top
                                anchors.topMargin: parent.width*0.3
                                anchors.horizontalCenter: parent.horizontalCenter
                                source:  mapIConsSelector.getListPlaceIcon(type)
                                mipmap: true
                                opacity: 0.4
                            }
                        }

                        NewControls.Label{
                            id: titleLabel

                            width: parent.width
                            height: parent.height * 0.45
                            anchors.top: parent.top
                            anchors.topMargin: parent.height * 0.10
                            padding: 0
                            font.pixelSize: 13 * app.scaleFactor
                            verticalAlignment: NewControls.Label.AlignVCenter
                            elide: NewControls.Label.ElideRight
                            clip: true
                            leftPadding: 55 * app.scaleFactor
                            rightPadding: 55 * app.scaleFactor
                            text: name
                            opacity: 0.9
                        }

                        NewControls.Label{
                            width: parent.width
                            height: parent.height * 0.4
                            anchors.top: titleLabel.bottom
                            verticalAlignment: NewControls.Label.AlignTop
                            elide: NewControls.Label.ElideRight
                            clip: true
                            font.pixelSize: titleLabel.font.pixelSize * 0.85
                            padding: 0
                            leftPadding: 55 * app.scaleFactor
                            rightPadding: 55 * app.scaleFactor
                            text: address
                            opacity: 0.6
                        }

                        Item{
                            width: parent.height
                            height: parent.height
                            anchors.right: parent.right


                            Image{
                                id: icon

                                width: parent.width*0.40
                                height: width
                                anchors.top: parent.top
                                anchors.topMargin: parent.width*0.15
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: sources.navigationIcon
                                mipmap: true
                                rotation: degrees-compassDegree
                                opacity: 0.4
                            }

                            NewControls.Label{
                                width: parent.width
                                height: parent.height*0.30
                                anchors.top: icon.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                horizontalAlignment: NewControls.Label.AlignHCenter
                                text: distanceText
                                font.pixelSize: titleLabel.font.pixelSize*0.85
                                opacity: 0.4
                            }
                        }

                        Ink{
                            anchors.fill: parent
                            onClicked: {
                                Qt.inputMethod.hide();
                                isInListMode = false;
                                isShowBackground = false;
                                showSelectedPlaceInfo(index);
                            }
                        }

                        Rectangle{
                            width: parent.width - 50 * app.scaleFactor
                            height: 1
                            color: "#19000000"
                            visible: index != resultListModel.count - 1
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                    }
                }
            }
        }

        Item {
            id: geoCodeViewBody
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: appManager.isLarge? true: !isInListMode

            Item {
                id: weatherWidget

                height: 28 * app.scaleFactor
                width: 52 * app.scaleFactor
                anchors {
                    right: parent.right
                    rightMargin: 10 * app.scaleFactor
                    bottom: parent.bottom
                    bottomMargin: deviceManager.isiPhoneXSeries? 36 * app.scaleFactor: 24 * app.scaleFactor
                }
                Material.elevation: 4 * app.scaleFactor
                //y: ((geoCodeViewBody.height - geoCodeViewBody.y)) - (Math.round((placeInfoView.height * placeInfoView.position)))
                visible: weatherObtained && !geocodeView.placeInfoDrawerIsOpen
                Rectangle {
                    anchors.fill: parent
                    color: app.secondaryColor
                    radius: 4 * app.scaleFactor
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 2 * app.scaleFactor
                        spacing: 0
                        Image {
                            id: weatherIcon
                            Layout.preferredHeight: 24 * app.scaleFactor
                            Layout.preferredWidth: 24 * app.scaleFactor
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                        }
                        NewControls.Label {
                            id: tempLabel
                            horizontalAlignment: NewControls.Label.AlignVCenter
                            font.pixelSize: 14 * app.scaleFactor
                        }
                    }
                }

                Behavior on visible {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    }
    StatusBarControls {
        id: statusBarControl
    }

    FiltersView {
        id: filtersDrawer

        height: parent.height
        width: Math.min(240 * app.scaleFactor, parent.width * 0.75)
        y: statusBarControl.padding
    }

    AboutView {
        id: infoDrawer

        edge: Qt.RightEdge
        height: parent.height
        width: appManager.isSmall? parent.width: Math.min(parent.width * 0.75, 360 * app.scaleFactor);
        y: statusBarControl.padding
    }

    PlaceListView {
        id: placeListDrawer

        width: appManager.isSmall? parent.width: Math.min(app.width - 48 * app.scaleFactor, 316 * app.scaleFactor)
        height: appManager.isSmall? 172 * app.scaleFactor: parent.height - 56 * app.scaleFactor

        y: statusBarControl.padding + header.height
        Material.elevation: 2 * app.scaleFactor
        edge: appManager.isSmall? Qt.BottomEdge: Qt.LeftEdge
        closePolicy: Popup.CloseOnEscape
        modal: false
        interactive: true
        dim: false
        background: Rectangle {
            color: appManager.isSmall? "transparent" : colors.secondaryColor
        }
    }

    GeocodeParameters {
        id: geocodeParameters

        minScore: 85
        maxResults: 10
        resultAttributeNames: ["*"]
        categories: ["Food", "Hotel", "Cinema", "Library", "Hospital", "Gas Station", "Bank", "Shops and Service"]
    }

    LocatorTask {
        id: locatorTask

        url: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
        suggestions.suggestParameters: SuggestParameters{
            maxResults: 10
        }
        suggestions.searchText: searchView.searchTextField.text

        onLoadStatusChanged: {
            if (loadStatus === Enums.LoadStatusLoading) {
                mapView.zoomToCurrentLocation();
            }
        }

        onGeocodeStatusChanged: {
            if (geocodeStatus === Enums.TaskStatusCompleted) {
                placeListDrawer.resultListView.currentIndex = -1;
                mapView.zoomToCurrentLocation();
                allPoints = [];
                busyIndicator.running = false;
                parseResults(geocodeResults);
            }
        }
    }

    RouteView {
        id: routeView

        anchors.fill: parent
    }

    SearchView {
        id: searchView

        anchors.fill: parent
        visible: false
    }

    ToastMessage {
        id: toastMessage

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        isTall: app.deviceManager.isiPhone
    }

    NewControls.BusyIndicator {
        id: busyIndicator

        height: app.busyIndicatorXY
        width: height
        Material.accent: app.primaryColor
        running: locatorTask.geocodeStatus === Enums.TaskStatusInProgress
                 || map.loadStatus === Enums.LoadStatusLoading
                 || initialSearch
        anchors.centerIn: parent
    }

    OfflineMask {
        anchors.fill: parent
        visible: !deviceManager.isOnline
    }

    LocationPermissionsView {
        anchors.fill: parent
        visible: !deviceManager.hasLocationAccess
    }

    BrowserView {
        id: browserView
        anchors.fill: parent
        primaryColor: app.toolbarColor
        foregroundColor: app.secondaryColor
    }

    NetworkManager {
        id: networkManager
    }

    // Timer to get weather every two minutes
    Timer {
        id: weatherTimer
        interval: 120000
        running: false
        repeat: true
        onTriggered: if(!placeListDrawer.opened)
                         geoCodeView.getWeather(mapView.lat, mapView.lon);
    }

    // Function to parse geocode results
    function parseResults (geocodeResults) {
        initialSearch = false;
        if(geocodeResults.length > 0) {
            for(var i in geocodeResults) {
                var e = geocodeResults[i];
                var point = e.displayLocation;
                point = GeometryEngine.project(point, mapView.spatialReference);
                var pointJson = JSON.stringify(point.json);
                var distance = GeometryEngine.distance(point, currentPoint);
                var distanceInMile = (distance/1609.34);
                distanceInMile = distanceInMile<10? distanceInMile.toFixed(2):distanceInMile.toFixed(0);
                var distanceInFeet = (distance/0.3048).toFixed(0);
                var distanceText = "";
                if(distanceInMile<1000)distanceText = distanceInFeet < 528 ? distanceInFeet+qsTr(" ft") : distanceInMile+qsTr(" mi");
                var name = e.label;
                var address = ((e.attributes.Place_addr).split(","))[0];
                var phone = e.attributes.Phone;
                var url = e.attributes.URL;
                var type = e.attributes.Type;
                var linearUnit  = ArcGISRuntimeEnvironment.createObject("LinearUnit", {linearUnitId: Enums.LinearUnitIdMillimeters});
                var angularUnit = ArcGISRuntimeEnvironment.createObject("AngularUnit", {angularUnitId: Enums.AngularUnitIdDegrees});
                var results = GeometryEngine.distanceGeodetic(currentPoint, point, linearUnit, angularUnit, Enums.GeodeticCurveTypeGeodesic)
                var degrees = results.azimuth1;

                allPoints.push(point);
                resultListModel.append({
                                           "name": name,
                                           "distanceText": distanceText,
                                           "distanceInFeet": distanceInFeet,
                                           "address": address,
                                           "geometryJson": pointJson,
                                           "degrees": degrees,
                                           "phone": phone,
                                           "url": url,
                                           "type": type,
                                           "point": point,
                                           "lat": e.displayLocation.y,
                                           "lon": e.displayLocation.x
                                       });
                mapView.showPin(point, type, true);
            }
            sortByDistance ();
            var extent = GeometryEngine.combineExtentsOfGeometries(allPoints);
            mapView.setViewpointGeometryAndPadding(extent, 300);
            placeListDrawer.resultListView.currentIndex = 0;
            if(appManager.isSmall) {
                if(!isInListMode) showSelectedPlaceInfo(placeListDrawer.resultListView.currentIndex);
            } else {
                placeListDrawer.open();
            }
        } else {
            let currentDistance = (app.deviceManager.localeInfoNameIsEn_US? Math.round(app.searchDistance /app.milesToMeters): Math.round(app.searchDistance /app.kiloMetersToMeters));
            let measurement = app.deviceManager.localeInfoNameIsEn_US? (currentDistance === 1? "mile": "miles"): "km";

            if(appManager.isSmall && !isInListMode) {
                if(searchView.currentSearchCategory === "") {
                    toastMessage.displayToast(strings.noPlacesFoundWithin + " " + currentDistance + " " + measurement, false);
                } else {
                    toastMessage.displayToast(strings.no + " " + searchView.currentSearchCategoryLowercase + " " + strings.found + " " + strings.within  + " " + currentDistance + " " + measurement, false);
                }
            } else {
                toastMessage.displayToast(strings.no + " " + searchView.currentSearchCategoryLowercase + " " + strings.found + " " + strings.within  + " " + currentDistance + " " + measurement, false);
            }
        }
    }

    // Function to load selected place's info
    function loadSelectedPlace(index) {
        if(currentIndex !== -1 && currentIndex !== index)
            mapView.restoreCategoryGraphic(resultListModel.get(currentIndex).point, resultListModel.get(currentIndex).type, currentIndex);
        mapView.zoomToSelectedPoint(resultListModel.get(index).point);
        currentIndex = index;
        mapView.showSelectedGraphic(resultListModel.get(index).point, resultListModel.get(currentIndex).type, index);
    }

    // Function to display selected place on map
    function showSelectedPlaceInfo(index) {
        placeListDrawer.resultListView.currentIndex = index;
        loadSelectedPlace(index);
        placeListDrawer.open();
    }

    // Function to set search radius per set distance
    function setSearchAreaBuffer() {
        let userPoint = ArcGISRuntimeEnvironment.createObject("Point", {
                                                                  x: mapView.lon,
                                                                  y: mapView.lat,
                                                                  spatialReference: SpatialReference.createWgs84()});
        if (mapView.spatialReference !== undefined) {
            currentPoint = GeometryEngine.project(userPoint, mapView.spatialReference);
            geocodeParameters.preferredSearchLocation = currentPoint;
            locatorTask.suggestions.suggestParameters.preferredSearchLocation = currentPoint;
            let buffer = GeometryEngine.buffer(currentPoint, app.searchDistance);
            locatorTask.suggestions.suggestParameters.searchArea = buffer;
            geocodeParameters.searchArea = buffer;
            return;
        }
    }

    // Function to perform address geocode
    function geocodeAddress() {
        if(app.isOnline) {
            if(mapView.locationObtained) {
                busyIndicator.running = true;
                setSearchAreaBuffer();
                if(currentLocatorTaskId > "" && locatorTask.loadStatus === Enums.LoadStatusLoading) locatorTask.cancelTask(currentLocatorTaskId);
                currentLocatorTaskId = locatorTask.geocodeWithParameters(searchView.searchTextField.text, geocodeParameters);
            } else {
                toastMessage.displayToast("Location is off", false);
            }
        }
    }

    // Function to re-add places from current search after route
    function redrawFoundPlaces() {
        mapView.removeRoute();
        mapView.removeAllGraphics();
        for(var i = 0; i < resultListModel.count; i++) {
            mapView.showPin(resultListModel.get(i).point, resultListModel.get(i).type, true);
        }
        var extent = GeometryEngine.combineExtentsOfGeometries(allPoints);
        mapView.setViewpointGeometryAndPadding(extent, 900);
    }

    function clearResults () {
        resultListModel.clear();
        mapView.removeAllGraphics();
    }

    // Function to sort places by distance
    function sortByDistance () {
        let indexes = [...Array(resultListModel.count).keys()];
        indexes.sort((a, b) => compareDistance(resultListModel.get(a), resultListModel.get(b)));
        let sorted = 0;
        while (sorted < indexes.length && sorted === indexes[sorted]) sorted++;
        if (sorted === indexes.length) return;
        for(let i = sorted; i < indexes.length; i++) {
            resultListModel.move(indexes[i], resultListModel.count - 1, 1);
            resultListModel.insert(indexes[i], {});
        }
        resultListModel.remove(sorted, indexes.length - sorted);
    }

    function compareDistance(a, b) {
        return a.distanceInFeet - b.distanceInFeet;
    }

    // Function to get location's weather
    function getWeather (lat, lon) {
        if(app.isOnline) {
            var url = "https://api.openweathermap.org/data/2.5/weather";
            var obj = {
                "appid": "a37293039a6c321e3c82cace2406e7ca",
                "lat": lat,
                "lon": lon
            }
            var params = {};

            networkManager.makeNetworkConnection(url, obj, function(response) {
                if(response.main && (response.weather && response.weather.length > 0)) {
                    tempLabel.text = Math.round(kelvinToFahr(response.main.temp)) + "°";
                    weatherIcon.source = weatherIconSourceUrl + response.weather[0].icon + ".png";
                    weatherObtained = true;
                    if(!weatherTimer.running) weatherTimer.start();
                } else {
                    weatherObtained = false;
                    if(!weatherTimer.running) weatherTimer.start();
                }
            }, params);
        } else {
            weatherObtained = false;
        }
    }

    function kelvinToFahr(kelvin) {
        return (9/5) * (kelvin - 273) + 32;
    }
}
