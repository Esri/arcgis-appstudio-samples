import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

import QtPositioning 5.8
import QtSensors 5.3

import "../Widgets"

MapView{
    id: mapView

    property alias pointGraphicsOverlay: pointGraphicsOverlay
    property alias routeGraphicsOverlay: routeGraphicsOverlay
    property alias compass: compass
    property alias geocodeView: geocodeView
    property real mapIconsSize: 24
    property alias map: map
    property PositionSource positionSource: positionSource
    property double lat
    property double lon
    property bool locationObtained: false

    signal placeIsSelected(real index)

    zoomByPinchingEnabled: true
    rotationByPinchingEnabled: true
    wrapAroundMode: Enums.WrapAroundModeEnabledWhenSupported

    onPlaceIsSelected: {
        geocodeView.showSelectedPlaceInfo(index);
    }

    Map{
        id: map

        BasemapTopographic{}
        initUrl: "http://melbournedev.maps.arcgis.com/home/webmap/viewer.html?webmap=c7bde7901f524071a8f56cf424a5a55a"
        onLoadStatusChanged: {
            if (loadStatus === Enums.LoadStatusLoaded) {
                locationDisplay.start();
            }
        }
    }

    locationDisplay {
        positionSource: positionSource
        compass: compass
    }

    ColumnLayout{

        property color btnColor: app.btnColor
        property color btnActiveColor: app.primaryColor

        width: 50*app.scaleFactor
        height: mapView.mapRotation != 0 ? 100 * app.scaleFactor + spacing * 2 : 50 * app.scaleFactor + spacing
        anchors {
            right: parent.right
            rightMargin: 10 * app.scaleFactor
            bottom: parent.bottom
            bottomMargin: deviceManager.isiPhoneXSeries? 72 * app.scaleFactor: 64 * app.scaleFactor
        }
        spacing: 1 * app.scaleFactor
        visible: map.loadStatus === Enums.LoadStatusLoaded &&
                 !geocodeView.isInRouteMode &&
                 !geocodeView.placeInfoDrawerIsOpen

        Behavior on anchors.bottomMargin {
            NumberAnimation {duration: 200}
        }

        Behavior on visible {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        MapRoundButton{
            Layout.fillWidth: true
            Layout.preferredHeight: parent.width
            radius: parent.width/2
            visible: mapView.mapRotation != 0
            imageColor: mapView.mapRotation === 0 ? parent.btnColor : parent.btnActiveColor
            rotation: -mapView.mapRotation
            imageSource: sources.compassIcon
            onClicked: {
                mapView.setViewpointRotation(0);
            }
        }

        MapRoundButton{
            id: locationBtn

            Layout.fillWidth: true
            Layout.preferredHeight: parent.width
            radius: parent.width/2
            checkable: true
            imageColor: locationDisplay.started? parent.btnActiveColor : parent.btnColor
            imageSource: sources.locationIcon
            onClicked: {
                if (!mapView.locationDisplay.started) {
                    mapView.locationDisplay.start();
                    zoomToCurrentLocation();
                    mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeRecenter;
                } else {
                    locationDisplay.stop();
                }
            }
        }
    }

    PositionSource {
        id: positionSource

        property bool isInitial: true

        onPositionChanged: {
            lat = position.coordinate.latitude;
            lon = position.coordinate.longitude;
            if(map.loadStatus === Enums.LoadStatusLoaded && isInitial) {
                isInitial = false;
                stop();
            }
        }

        onIsInitialChanged: {
            if(!isInitial) {
                locationObtained = true;
                geocodeView.geocodeAddress();
                geocodeView.getWeather(lat, lon);
            }
        }
    }

    SelectionProperties {
        id: selectionProperties

        color: app.primaryColor
    }

    GraphicsOverlay {
        id: pointGraphicsOverlay

        renderingMode: Enums.GraphicsRenderingModeDynamic
    }

    GraphicsOverlay {
        id: routeGraphicsOverlay

        SimpleRenderer {
            SimpleLineSymbol {
                id: simpleLineSymbol

                color: colors.tertiaryColor
                style: geocodeView.routeView.selectedRouteMode === 0? Enums.SimpleLineSymbolStyleSolid: Enums.SimpleLineSymbolStyleDashDot
                width: 4
            }
        }
        renderingMode: Enums.GraphicsRenderingModeDynamic
    }

    Compass {
        id: compass

        active: true
    }

    GeocodeView {
        id: geocodeView

        anchors.fill: parent
    }

    onMouseClicked: {
        pointGraphicsOverlay.clearSelection();
        var tolerance = 5,
        returnPopupsOnly = false,
        maximumResults = 1;
        mapView.identifyGraphicsOverlayWithMaxResults(pointGraphicsOverlay, mouse.x, mouse.y, tolerance, returnPopupsOnly, maximumResults);
    }

    onIdentifyGraphicsOverlayStatusChanged: {
        switch (identifyGraphicsOverlayStatus) {
        case Enums.TaskStatusCompleted:
            if (identifyGraphicsOverlayResult.graphics.length) {
                var graphic = identifyGraphicsOverlayResult.graphics[0];
                for (var i = 0; i < pointGraphicsOverlay.graphics.count; i++) {
                    if (graphic.equals(pointGraphicsOverlay.graphics.get(i))) {
                        onGraphicClickHandler(graphic, i);
                        break;
                    }
                }
            }
            break;
        case Enums.TaskStatusErrored:
            break;
        }
    }

    // on click handler for mapView graphics
    function onGraphicClickHandler (graphic, index) {
        pointGraphicsOverlay.clearSelection();
        pointGraphicsOverlay.selectGraphics([graphic]);
        placeIsSelected(index);
    }

    // Function to zoom to current user location
    function zoomToCurrentLocation(){
        var currentPositionPoint = ArcGISRuntimeEnvironment.createObject("Point", {x: lon, y: lat, spatialReference: Factory.SpatialReference.createWgs84()});
        var centerPoint = GeometryEngine.project(currentPositionPoint, mapView.spatialReference);
        var viewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter",{center: centerPoint, targetScale: 10000});
        mapView.setViewpointWithAnimationCurve(viewPointCenter, 2.0,  Enums.AnimationCurveEaseInOutCubic);
    }

    // Function to zoom to a selected point by user. Smaller animation duration than zoomToPoint(point)
    function zoomToSelectedPoint(point){
        var centerPoint = GeometryEngine.project(point, mapView.spatialReference);
        var viewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter",{center: centerPoint, targetScale: 10000});
        mapView.setViewpointWithAnimationCurve(viewPointCenter, 1.0,  Enums.AnimationCurveEaseInOutCubic);
    }

    // Function to display graphic at a point on map depending on place category
    function showPin(point, type, isSmall){
        let size = isSmall? 24: 36;
        var marker = ArcGISRuntimeEnvironment.createObject("PictureMarkerSymbol", {width: size, height: size});
        marker.url =  mapIConsSelector.getMapPlaceIcon(type);
        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: point, symbol: marker});
        pointGraphicsOverlay.graphics.append(graphic);
    }

    function showSelectedGraphic(point, type, index) {
        let marker = ArcGISRuntimeEnvironment.createObject("PictureMarkerSymbol", {width: 36, height: 36});
        marker.url =  mapIConsSelector.getMapPlaceIcon(type);
        let selectedGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: point, symbol: marker});
        pointGraphicsOverlay.graphics.remove(index, 1);
        pointGraphicsOverlay.graphics.insert(index, selectedGraphic);
    }

    function restoreCategoryGraphic(point, type, index) {
        var marker = ArcGISRuntimeEnvironment.createObject("PictureMarkerSymbol", {width: mapIconsSize, height: mapIconsSize});
        marker.url =  mapIConsSelector.getMapPlaceIcon(type);
        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: point, symbol: marker});
        pointGraphicsOverlay.graphics.remove(index, 1);
        pointGraphicsOverlay.graphics.insert(index, graphic);
    }

    // Function to remove currently added graphics from map
    function removeAllGraphics() {
        pointGraphicsOverlay.graphics.remove(0, pointGraphicsOverlay.graphics.count);
    }

    // Function to remove route graphics
    function removeRoute() {
        routeGraphicsOverlay.graphics.remove(0, routeGraphicsOverlay.graphics.count);
    }
}
