import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.6
import Esri.ArcGISRuntime.Toolkit.Controls 100.6

import QtPositioning 5.3
import QtSensors 5.3

import "../Controls"
import "../Widgets"
import "../Assets"

MapView{
    id: mapView

    property alias pointGraphicsOverlay: pointGraphicsOverlay
    property alias compass: compass
    readonly property string mmpkFile: "SanFrancisco.mmpk"
    property string currentLocatorTaskId: ""
    property string mmpkName: ""
    property string mmpkTitle: ""
    property LocatorTask currentLocatorTask
    property RouteTask currentRouteTask
    property var currentRouteParams
    property Point clickedPoint
    property var mobileMap
    property var routeStops: []
    property int selectedMapIndex: 0
    property bool currentMapSupoortsRouting: false
    zoomByPinchingEnabled: true
    rotationByPinchingEnabled: true
    wrapAroundMode: Enums.WrapAroundModeEnabledWhenSupported

    ColumnLayout {

        property color btnColor: "#808080"
        property color btnActiveColor: "#000000"

        width: 50 * app.scaleFactor
        height: routeBtn.visible && mapClearBtn.visible? 150 * app.scaleFactor: 100 * app.scaleFactor
        anchors {
            right: parent.right
            rightMargin: 10 * app.scaleFactor
            bottom: parent.bottom
            bottomMargin: 32 * app.scaleFactor
        }

        spacing: 1

        Behavior on anchors.bottomMargin {
            NumberAnimation {duration: 200}
        }

        Behavior on visible {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        MapRoundButton {
            id: routeBtn

            Layout.fillWidth: true
            Layout.preferredHeight: parent.width
            radius: parent.width/2
            visible: currentMapSupoortsRouting && pointsListModel.count > 1
            imageColor: parent.btnColor
            imageSource: sources.directionsIcon
            onClicked: {
                callout.dismiss();
                if(currentRouteTask !== null) {
                    if (currentRouteTask.solveRouteStatus !== Enums.TaskStatusInProgress) {
                        routeGraphicsOverlay.graphics.clear();
                        currentRouteParams.setStops(routeStops);
                        currentRouteTask.solveRoute(currentRouteParams);
                    }
                } else {
                    toastDialog.displayToast(strings.noRouteTaskFound, false);
                }
            }
        }

        MapRoundButton {
            id: mapSelectionBtn

            Layout.fillWidth: true
            Layout.preferredHeight: parent.width
            radius: parent.width/2
            visible: mapsListModel.count > 0 && pointsListModel.count === 0
            imageColor: parent.btnColor
            imageSource: sources.listIcon
            onClicked: {
                mapSelectionDrawer.open();
            }
        }

        MapRoundButton {
            id: mapClearBtn

            Layout.fillWidth: true
            Layout.preferredHeight: parent.width
            radius: parent.width/2
            visible: pointsListModel.count > 0
            imageColor: parent.btnColor
            imageSource: sources.clearIcon
            onClicked: {
                clearResults();
            }
        }

        MapRoundButton {
            id: infoBtn

            Layout.fillWidth: true
            Layout.preferredHeight: parent.width
            radius: parent.width/2
            imageColor: parent.btnColor
            imageSource: sources.infoIcon
            onClicked: {
                infoDrawer.open();
            }
        }
    }


    GraphicsOverlay {
        id: pointGraphicsOverlay
        SimpleRenderer {
            PictureMarkerSymbol{
                id: pictureMarker

                width: 38*app.scaleFactor
                height: 38*app.scaleFactor
                url: sources.pinIcon
            }
        }
    }

    GraphicsOverlay {
        id: routeGraphicsOverlay

        SimpleRenderer {
            SimpleLineSymbol {
                id: simpleLineSymbol

                color: app.primaryColor
                style: Enums.SimpleLineSymbolStyleSolid
                width: 4
            }
        }
        renderingMode: Enums.GraphicsRenderingModeStatic
    }

    onSetViewpointCompleted: {
        pointGraphicsOverlay.visible = true;
    }

    Compass {
        id: compass
    }

    Dialog {
        id: dialog
        anchors.centerIn: parent
        title: strings.noMmpkFound
        standardButtons: Dialog.Ok
    }

    ListModel {
        id: mapsListModel
    }

    ListModel {
        id: pointsListModel
    }

    FileFolder {
        id: mmpkFolder
        url: "../Data/"

        Component.onCompleted: {
            if(mmpkFolder.fileExists(mmpkFile)) {
                loadMmpk();
            } else {
                dialog.open();
            }
        }
    }

    SuggestParameters {
        id: suggestParameters
        maxResults: 10
    }

    GeocodeParameters {
        id: geocodeParameters
        minScore: 75
        maxResults: 1
        resultAttributeNames: ["*"]
    }

    ReverseGeocodeParameters {
        id: reverseGeocodeParams
        maxResults: 1
    }

    GeocodeView{
        id: geocodeView

        anchors.fill: parent
    }

    Drawer {
        id: mapSelectionDrawer

        edge: deviceManager.isSmall? Qt.BottomEdge: Qt.RightEdge
        height: deviceManager.isSmall? parent.height * 0.4: parent.height
        width: deviceManager.isSmall? parent.width: Math.min(parent.width * 0.75, 360 * app.scaleFactor);
        y: statusBarControls.padding
        ColumnLayout {
            anchors.fill: parent
            ToolBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 56 * app.scaleFactor
                Material.elevation: 0
                Material.background: app.primaryColor
                Label {
                    width: parent.width
                    anchors.centerIn: parent
                    text: strings.selectMap + " " + strings.from + " " + mmpkTitle
                    font.pixelSize: 14 * app.scaleFactor
                    font.bold: true
                    horizontalAlignment: Label.AlignHCenter
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ListView {
                    anchors.fill: parent
                    model: mapsListModel
                    clip: true
                    delegate: ClickableListView {
                        width: parent.width
                        height: 56 * app.scaleFactor

                        ColumnLayout {
                            anchors.fill: parent
                            Label {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                horizontalAlignment: Label.AlignHCenter
                                verticalAlignment: Label.AlignVCenter
                                text: title
                            }
                            Label {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 20 * app.scaleFactor
                                horizontalAlignment: Label.AlignHCenter
                                font.pixelSize: 12 * app.scaleFactor
                                color: "#66000000"
                                text: strings.hasRouting
                                visible: hasRouting
                            }
                        }

                        onIsClicked: {
                            mapSelectionDrawer.close();
                            loadMap(index);
                        }
                    }
                }
            }
        }
    }

    Drawer {
        id: infoDrawer

        edge: deviceManager.isSmall? Qt.BottomEdge: Qt.RightEdge
        height: parent.height
        width: deviceManager.isSmall? parent.width: Math.min(parent.width * 0.75, 360 * app.scaleFactor);
        y: statusBarControls.padding
        interactive: false

        ColumnLayout {
            anchors.fill: parent
            ToolBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 56 * app.scaleFactor
                Material.elevation: 0
                Material.background: app.primaryColor
                RowLayout {
                    width: parent.width
                    height: 56 * app.scaleFactor
                    CustomizedToolButton {
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height
                        imageSource: sources.closeWhiteIcon
                        onClicked: {
                            infoDrawer.close();
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: strings.aboutTheApp
                        font.pixelSize: 18 * app.scaleFactor
                        font.bold: true
                        verticalAlignment: Label.AlignVCenter
                    }
                }
            }
            Flickable {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Item {
                    anchors.fill: parent
                    anchors.margins: 16 * app.scaleFactor
                    ColumnLayout {
                        anchors.fill: parent
                        Label {
                            Layout.fillWidth: true
                            text: strings.description
                            color: app.headerTextColor
                        }
                        Label {
                            Layout.fillWidth: true
                            text: qsTr(app.info.description)
                            wrapMode: Label.WordWrap
                            linkColor: app.primaryColor
                            onLinkActivated: {
                                infoDrawer.close();
                                geocodeView.openBrowserView(link);
                            }
                        }
                        Label {
                            visible: licenseInfo.text > ""
                            Layout.fillWidth: true
                            text: strings.accessConstraints
                            color: app.headerTextColor
                        }
                        Label {
                            id: licenseInfo

                            Layout.fillWidth: true
                            text: app.info.itemInfo.licenseInfo
                            wrapMode: Label.WordWrap
                        }

                        Label {
                            Layout.fillWidth: true
                            text: strings.appVersion
                            color: app.headerTextColor
                        }

                        Label {
                            Layout.fillWidth: true
                            text: app.info.version
                            wrapMode: Label.WordWrap
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20 * app.scaleFactor
                        }

                        Label {
                            Layout.fillWidth: true
                            text: strings.about
                            color: app.headerTextColor
                        }

                        Label {
                            Layout.fillWidth: true
                            text: strings.credits
                            wrapMode: Label.WordWrap
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }

    ToastDialog {
        id: toastDialog
        anchors.bottom: parent.bottom
    }

    BusyIndicator {
        id: busyIndicator
        width: 48 * app.scaleFactor
        height: width
        Material.accent: app.primaryColor
        anchors.centerIn: parent
        running: currentLocatorTask !== null && currentRouteTask !== null
                 ? currentLocatorTask.loadStatus === Enums.TaskStatusInProgress || currentRouteTask.solveRouteStatus === Enums.TaskStatusInProgress
                 : false
    }

    Callout {
        id: callout
        calloutData: parent.calloutData
        accessoryButtonHidden: true
        leaderPosition: leaderPositionEnum.Automatic
    }

    onMapChanged: {
        if (mobileMap.maps[selectedMapIndex].transportationNetworks.length > 0) {
            currentRouteTask = ArcGISRuntimeEnvironment.createObject("RouteTask", {transportationNetworkDataset: mobileMap.maps[selectedMapIndex].transportationNetworks[0]});
            currentRouteTask.load();
        } else {
            currentRouteTask = null;
        }
    }

    onMouseClicked: {
        if (currentLocatorTask !== null) {
            clickedPoint = mouse.mapPoint;
            identifyGraphicsOverlayWithMaxResults(pointGraphicsOverlay, mouse.x, mouse.y, 5, false, 2);
        }
    }

    onIdentifyGraphicsOverlayStatusChanged: {
        if (identifyGraphicsOverlayStatus === Enums.TaskStatusCompleted){
            currentLocatorTask.reverseGeocodeWithParameters(clickedPoint, reverseGeocodeParams);
        }
    }

    // connect signals from LocatorTask
    Connections  {
        target: currentLocatorTask

        onGeocodeStatusChanged: {
            if (currentLocatorTask.geocodeStatus === Enums.TaskStatusCompleted) {
                geocodeView.isShowBackground = false;
                parseGeocodeResults(currentLocatorTask.geocodeResults);
            }
        }

        onLoadStatusChanged: {
            if(currentLocatorTask.loadStatus === Enums.LoadStatusLoaded) {
                currentLocatorTask.suggestions.suggestParameters = suggestParameters;
                currentLocatorTask.suggestions.searchText = geocodeView.searchText;
            }
        }
    }

    // connect signals from RouteTask
    Connections {
        target: currentRouteTask

        onLoadStatusChanged: {
            if (currentRouteTask.loadStatus === Enums.LoadStatusLoaded) {
                currentRouteTask.createDefaultParameters();
            }
        }

        onCreateDefaultParametersStatusChanged: {
            if (currentRouteTask.createDefaultParametersStatus === Enums.TaskStatusCompleted)
                currentRouteParams = currentRouteTask.createDefaultParametersResult;
        }

        onSolveRouteStatusChanged: {
            if(currentRouteTask.solveRouteStatus === Enums.TaskStatusCompleted) {
                if(currentRouteTask.solveRouteResult !== null) {
                    var generatedRoute = currentRouteTask.solveRouteResult.routes[0];
                    var routeGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: generatedRoute.routeGeometry});
                    routeGraphicsOverlay.graphics.append(routeGraphic);
                } else {
                    toastDialog.displayToast(strings.noRouteFound, false);
                }
            } else if (currentRouteTask.solveRouteStatus === Enums.TaskStatusErrored) {
                toastDialog.displayToast(strings.errorFindingRoute, false);
            }
        }
    }

    // Function to parse results from locatorTask
    function parseGeocodeResults (geocodeResults) {
        if(geocodeResults.length > 0) {
            if(!currentMapSupoortsRouting) pointGraphicsOverlay.graphics.clear();
            var pinGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: geocodeResults[0].displayLocation});
            pointsListModel.append({"point": geocodeResults[0].displayLocation});
            pointGraphicsOverlay.graphics.append(pinGraphic);
            pinGraphic.attributes.insertAttribute("AddressLabel", geocodeResults[0].label);

            mapView.calloutData.geoElement = pointGraphicsOverlay.graphics.get(pointGraphicsOverlay.graphics.count -1);
            mapView.calloutData.detail = geocodeResults[0].label;
            mapView.calloutData.title = strings.address;
            callout.showCallout();

            var stop = ArcGISRuntimeEnvironment.createObject("Stop", {name: "stop", geometry: geocodeResults[0].displayLocation});
            routeStops.push(stop);
            if(currentMapSupoortsRouting) {
                var textSymbol = ArcGISRuntimeEnvironment.createObject("TextSymbol", {
                                                                           color: app.secondaryColor,
                                                                           backgroundColor: app.primaryColor,
                                                                           text: routeStops.length,
                                                                           size: 18 * scaleFactor,
                                                                           offsetY: 33 * scaleFactor
                                                                       });
                var labelGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: geocodeResults[0].displayLocation, symbol: textSymbol});
                pointGraphicsOverlay.graphics.append(labelGraphic);
            }

        } else {
            toastDialog.displayToast(strings.noLocationFound);
        }
    }

    // Function to display a point on a map
    function showPin(point){
        var pictureMarkerSymbol = ArcGISRuntimeEnvironment.createObject("PictureMarkerSymbol", {width: 40*app.scaleFactor, height: 40*app.scaleFactor, url: "../images/pin.png"});
        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: point});
        pointGraphicsOverlay.graphics.append(graphic);
    }

    // Function to perform address geocoding using user-entered text
    function geocodeAddress() {
        clearResults ();
        if(mapArea.currentLocatorTask !== null) {
            if(currentLocatorTaskId > "" && currentLocatorTask.loadStatus === Enums.LoadStatusLoading) currentLocatorTask.cancelTask(currentLocatorTaskId);
            currentLocatorTaskId = currentLocatorTask.geocodeWithParameters(geocodeView.searchText, geocodeParameters);
        } else {
            dialog.open();
        }
    }

    function geocodeSuggestion(suggestResult) {
        clearResults ();
        if(mapArea.currentLocatorTask !== null) {
            if(currentLocatorTaskId > "" && currentLocatorTask.loadStatus === Enums.LoadStatusLoading) currentLocatorTask.cancelTask(currentLocatorTaskId);
            console.log(suggestResult.label);
            currentLocatorTaskId = currentLocatorTask.geocodeWithSuggestResultAndParameters(suggestResult, geocodeParameters);
        } else {
            dialog.open();
        }
    }

    function clearResults () {
        pointGraphicsOverlay.graphics.clear();
        routeGraphicsOverlay.graphics.clear();
        routeStops = [];
        pointsListModel.clear();
        callout.dismiss();
    }

    // Function to load a map from the mmpk
    function loadMap(index) {
        selectedMapIndex = index;
        mapView.map = mobileMap.maps[index];
        currentMapSupoortsRouting = mobileMap.maps[index].transportationNetworks.length > 0? true: false;
    }

    // Function to load Mmpk
    function loadMmpk() {
        mobileMap = ArcGISRuntimeEnvironment.createObject("MobileMapPackage", { path: mmpkFolder.url + "/" + mmpkFile });
        mobileMap.load();
        mobileMap.loadStatusChanged.connect(function() {
            if (mobileMap.loadStatus === Enums.LoadStatusLoaded) {
                mmpkName = mobileMap.item.name;
                mmpkTitle = mobileMap.item.title;
                if(mobileMap.locatorTask !== null) {
                    currentLocatorTask = mobileMap.locatorTask;
                }

                for(let i = 0; i < mobileMap.maps.length; i++) {
                    if(mobileMap.maps[i] !== null) {
                        if(i === 0) loadMap(i);
                        mapsListModel.append({
                                                 "title": mobileMap.maps[i].item.name,
                                                 "hasRouting": mobileMap.maps[i].transportationNetworks.length > 0? true: false
                                             });
                    }
                }
            }
        });
    }
}



