import QtQuick 2.9
import QtQuick.Controls 2.5 as NewControls
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

import QtPositioning 5.3
import QtSensors 5.3

import "../Assets"
import "../Widgets"
import "../Controls"

Item {
    id: routeView

    property bool isInRouteMode: false
    property string distance: ""
    property string name: ""
    property real time: 0
    property var routeParameters: null
    property Point point: null
    property real selectedRouteMode

    onIsInRouteModeChanged: {

    }

    CustomHeader {
        id:header

        property double searchBarControlsOpacity: 0.6
        height: 56 * app.scaleFactor
        width: parent.width
        stateVisible: isInRouteMode
        visible: stateVisible

        RowLayout {
            width: parent.width - 16 * app.scaleFactor
            height: 56 * app.scaleFactor
            anchors.centerIn: parent

            CustomizedToolButton {
                id: closeBtn

                Layout.alignment: Qt.AlignVCenter
                imageSource: sources.closeBlackIcon
                onClicked: {
                    closeRouting();
                }
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: 8

                NewControls.Label {
                    id: directionText

                    Layout.fillWidth: true
                    font.pixelSize: 12 * app.scaleFactor
                    text: strings.directionsTo
                    verticalAlignment: NewControls.Label.AlignVCenter
                    elide: NewControls.Label.ElideRight
                }

                NewControls.Label {
                    Layout.fillWidth: true
                    font.pixelSize: 14 * app.scaleFactor
                    text: name
                    font.bold: true
                    verticalAlignment: NewControls.Label.AlignVCenter
                    elide: NewControls.Label.ElideRight
                }
            }
        }
    }

    MapRoundButton{
        height: 50 * app.scaleFactor
        width: 50 * app.scaleFactor
        anchors {
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 24 * app.scaleFactor
            rightMargin: 10 * app.scaleFactor
        }
        radius: height/2
        visible: isInRouteMode && directionsModel.count > 0 && !directionsDrawer.opened
        imageColor: app.btnColor
        imageSource: sources.directionsBlackIcon
        onClicked: {
            directionsDrawer.open();
        }
    }

    NewControls.Drawer {
        id: directionsDrawer

        property bool isMaximized: false
        height: appManager.isSmall? header.height: parent.height
        width: appManager.isSmall? parent.width: 392 * app.scaleFactor
        y: statusBarControl.padding + (deviceManager.isiPad?  64 * app.scaleFactor: 0)
        edge: appManager.isSmall? Qt.BottomEdge: Qt.LeftEdge
        modal: false
        interactive: opened
        closePolicy: NewControls.Drawer.NoAutoClose
        Material.elevation: 0

        contentItem: ColumnLayout {
            anchors.fill: parent

            CustomHeader {
                id: drawerHeader

                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 56 * app.scaleFactor
                Material.elevation: appManager.isSmall? 2: 0
                RowLayout {
                    id: headerContent

                    width: Math.min(600*app.scaleFactor, parent.width) - 16 * app.scaleFactor
                    height: 56 * app.scaleFactor
                    anchors.centerIn: parent
                    spacing: 0

                    CustomizedToolButton {
                        Layout.alignment: Qt.AlignVCenter
                        imageSource: directionsDrawer.isMaximized? sources.arrowDownIcon: sources.arrowUpIcon
                        overlayColor: app.secondaryColor
                        visible: appManager.isSmall
                        onClicked: {
                            if(directionsDrawer.isMaximized) {
                                minimizeDirectionsDrawer();
                            } else {
                                maximizeDirectionsDrawer();
                            }
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.margins: 8

                        ColumnLayout {
                            spacing: 0

                            Text {
                                text: time > ""? timePrettyPrint(time): ""
                                Layout.fillWidth: true
                                font.bold: true
                                font.pixelSize: 18 * app.scaleFactor
                                color: app.secondaryColor
                            }

                            RowLayout {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                Text {
                                    text: distance + " mi ·"
                                    font.pixelSize: 13 * app.scaleFactor
                                    color: app.secondaryColor
                                }

                                Text {
                                    text: getArrivalTime(time) + " ETA"
                                    font.pixelSize: 13 * app.scaleFactor
                                    color: app.secondaryColor
                                }
                            }
                        }
                    }
                    CustomizedToolButton {
                        Layout.alignment: Qt.AlignRight
                        overlayColor: selectedRouteMode === 0? colors.primaryColor: colors.lightGrey
                        imageSource: sources.walkIcon
                        onClicked: {
                            setToWalkMode();
                            getRoute();
                        }
                    }

                    CustomizedToolButton {
                        Layout.alignment: Qt.AlignRight
                        overlayColor: selectedRouteMode === 1? colors.primaryColor: colors.lightGrey
                        imageSource: sources.driveIcon
                        onClicked: {
                            setToDriveMode();
                            getRoute();
                        }
                    }
                }

                Rectangle {
                    anchors.top: headerContent.bottom
                    width: parent.width
                    height: deviceManager.isiPhoneXSeries && !directionsDrawer.isMaximized? 28 * app.scaleFactor: 0
                    color: colors.toolbarColor
                }
            }
            ListView {
                id: directionsListView

                Layout.fillHeight: true
                Layout.preferredWidth: Math.min(600*app.scaleFactor, parent.width) - 16 * app.scaleFactor
                Layout.alignment: Qt.AlignHCenter
                clip: true
                model: directionsModel
                spacing: 0
                delegate: Item {
                    width: parent.width
                    height: 50 * app.scaleFactor

                    Item {
                        anchors.fill: parent

                        Item{
                            width: parent.height
                            height: parent.height
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            Image{
                                anchors.fill: parent
                                anchors.margins: parent.width*0.30
                                anchors.centerIn: parent
                                source: iconSelector.getRouteIcon(direction)
                                mipmap: true
                                opacity: 0.4
                            }
                        }

                        NewControls.Label{
                            anchors.fill: parent
                            verticalAlignment: NewControls.Label.AlignVCenter
                            clip: true
                            font.pixelSize: 13*app.scaleFactor
                            leftPadding: 50*app.scaleFactor
                            rightPadding: 40*app.scaleFactor
                            wrapMode: NewControls.Label.WordWrap
                            text: direction
                            opacity: 0.9
                        }

                        Rectangle{
                            width: parent.width-50*app.scaleFactor
                            height: 1
                            color: "#19000000"
                            visible: index != directionsModel.count - 1
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                    }
                }
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
        onClosed: {
            minimizeDirectionsDrawer();
        }
    }

    NewControls.BusyIndicator {
        id: busyIndicator

        height: app.busyIndicatorXY
        width: height
        Material.accent: app.primaryColor
        running: routeTask.solveRouteStatus === Enums.TaskStatusInProgress
        anchors.centerIn: parent
    }

    // List model to containing current directions
    ListModel {
        id: directionsModel
    }

    OAuthClientInfo {
        id: clientInfo

        clientId: "<<YOU CLIENT ID GOES HERE>>"
        clientSecret: "<<YOUR CLIENT SECRET GOES HERE>>"
        oAuthMode: Enums.OAuthModeApp
    }

    Credential {
        id: cred

        oAuthClientInfo: clientInfo
    }

    // Route Task
    RouteTask {
        id: routeTask

        url:"http://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World"
        credential: cred

        // Request default parameters once the task is loaded
        onLoadStatusChanged: {
            if (loadStatus === Enums.LoadStatusLoaded) {
                routeTask.createDefaultParameters();
            }
        }

        // Store the resulting route parameters
        onCreateDefaultParametersStatusChanged: {
            if (createDefaultParametersStatus === Enums.TaskStatusCompleted) {
                routeParameters = createDefaultParametersResult;
                setToDriveMode();
            }
        }

        onSolveRouteStatusChanged: {
            if (solveRouteStatus === Enums.TaskStatusCompleted) {
                // Add the route graphic once the solve completes
                if(solveRouteResult !== null) displayRoute(solveRouteResult.routes[0]);
            }
        }
    }

    ToastMessage {
        id: toastMessage

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        isTall: app.deviceManager.isiPhone
    }

    Sources {
        id: sources
    }

    Strings {
        id: strings
    }

    MapIConsSelector {
        id: iconSelector
    }

    NewControls.Dialog {
        id: messageDialog
        title: strings.missingCredentials
        closePolicy: NewControls.Popup.NoAutoClose
        anchors.centerIn: parent
        onAccepted: {
            closeRouting();
        }
        footer: Rectangle {
            implicitWidth: 48 * app.scaleFactor
            implicitHeight: 48 * app.scaleFactor
            anchors.margins: 16 * app.scaleFactor

            Ink {
                anchors.fill: parent
                NewControls.Label {
                    anchors.fill: parent
                    text: strings.ok
                    font.bold: true
                    verticalAlignment: NewControls.Label.AlignVCenter
                    horizontalAlignment: NewControls.Label.AlignHCenter
                    color: colors.primaryColor
                }
                onClicked: messageDialog.accept();
            }
        }
    }

    Component.onCompleted: {
        routeTask.load();
    }

    function setToWalkMode() {
        selectedRouteMode = 1;
        routeParameters.travelMode.type = "WALK";
        routeParameters.travelMode.impedanceAttributeName = "WalkTime";
        routeParameters.travelMode.timeAttributeName = "WalkTime";
    }

    function setToDriveMode() {
        selectedRouteMode = 0;
        routeParameters.travelMode.type = "AUTOMOBILE";
        routeParameters.travelMode.impedanceAttributeName = "TravelTime";
        routeParameters.travelMode.timeAttributeName = "TravelTime";
    }

    // Function to display route on map
    function displayRoute(route) {
        mapView.removeAllGraphics();
        var routeGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: route.routeGeometry});
        mapView.routeGraphicsOverlay.graphics.append(routeGraphic);

        mapView.showPin(route.stops[1].geometry, "", false);
        time = route.totalTime;
        distance = (route.totalLength / app.milesToMeters).toFixed(2);

        for(var i = 0; i < route.directionManeuvers.count; i++) {
            directionsModel.append({"direction": route.directionManeuvers.get(i).directionText});
        }

        var extent = GeometryEngine.combineExtentsOfGeometries([route.stops[0].geometry, route.stops[1].geometry, mapView.routeGraphicsOverlay.graphics.get(0).geometry]);
        mapView.setViewpointGeometryAndPadding(extent, 100);
        toastMessage.reset();
        directionsDrawer.open();
    }

    function getRoute() {
        /********** REMOVE SECTION AFTER ADDING CLIENTID AND CLIENTSECRET ON LINE 293 ***************/
        messageDialog.open();
        return;
        /********************************************************************************************/
        if(deviceManager.isOnline) {
            directionsDrawer.close();
            minimizeDirectionsDrawer();
            toastMessage.displayToast(strings.gettingRoute, true);
            directionsModel.clear();
            mapView.removeRoute();
            time = "";
            distance = "";
            mapView.locationDisplay.start();
            var currentUserPoint = ArcGISRuntimeEnvironment.createObject("Point", {
                                                                             x: mapView.lon,
                                                                             y: mapView.lat,
                                                                             spatialReference: SpatialReference.createWgs84()
                                                                         });

            var start = ArcGISRuntimeEnvironment.createObject("Stop", {geometry: currentUserPoint, name: "Origin"});
            var end = ArcGISRuntimeEnvironment.createObject("Stop", {geometry: point, name: name});
            routeParameters.returnDirections = true;
            routeParameters.returnRoutes = true;
            routeParameters.returnStops = true;
            routeParameters.setStops([start, end]);

            // solve the route with the parameters
            routeTask.solveRoute(routeParameters);
        }
    }



    // function to close routing view
    function closeRouting() {
        if(routeTask.solveRouteStatus === Enums.TaskStatusInProgress) {
            toastMessage.reset();
            routeTask.cancelTask();
        }
        directionsDrawer.close();
        directionsDrawer.close();
        minimizeDirectionsDrawer();
        hide();
        directionsModel.clear();
        name = "";
        distance = "";
        time = "";
        setToDriveMode();
        geocodeView.isInRouteMode = false;
        geocodeView.redrawFoundPlaces();
    }

    // Function to get arrival time
    function getArrivalTime(time) {
        var timeNow = new Date();
        var arrivalTime = timeNow.getTime() + (time * 60000);
        var finalTime = new Date(arrivalTime);
        return (finalTime.getHours() < 10? "0" + finalTime.getHours(): finalTime.getHours())  + ":" + (finalTime.getMinutes() < 10? "0" + finalTime.getMinutes(): finalTime.getMinutes()) + " " + (finalTime.getHours() < 12? "AM": "PM");
    }

    // Function for time pretty print
    function timePrettyPrint(time) {
        var hours = Math.floor(time / 60);
        var minutes = Math.floor(time - (hours * 60));
        var seconds = Math.round((time - (minutes + hours * 60)) * 60);
        return (hours >0?hours + " hr ": "") + (minutes > 0? minutes + " min ":"") + (seconds >0? seconds + " sec ": "");
    }

    function peekDirectionsDrawer() {
        directionsDrawer.open();
    }

    function minimizeDirectionsDrawer() {
        if(appManager.isSmall) {
            directionsDrawer.height = deviceManager.isiPhoneXSeries? 72 * app.scaleFactor: 56 * app.scaleFactor;
        }
        directionsDrawer.isMaximized = false;
    }

    function maximizeDirectionsDrawer() {
        if(appManager.isSmall) {
            directionsDrawer.height =  deviceManager.isiPhoneXSeries? directionsDrawer.parent.height - 40 * app.scaleFactor: directionsDrawer.parent.height;
        }
        directionsDrawer.isMaximized = true;
    }

    function show() {
        routeView.isInRouteMode = true;
    }

    function hide() {
        routeView.isInRouteMode = false;
    }
}
