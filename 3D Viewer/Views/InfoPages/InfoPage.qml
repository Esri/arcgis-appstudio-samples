import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import Esri.ArcGISRuntime 100.5

import "../../Widgets" as Widgets

Page {
    id: infoPage

    Material.background: colors.view_background

    property string sceneUrl: ""
    property string sceneTitle: ""
    property string viewMode: ""
    property string sceneInfoText: ""
    property string coordinatesText: ""
    property string shortUrl: ""

    property bool isLocationDisplayed: false
    property bool isPageLoading: false

    property var initialViewpointCamera

    signal closed()

    Connections {
        target: locationManager

        onPositionChanged: {
            var _coordinateString = "%1 %2".arg(locationManager.coordinate.latitude).arg(locationManager.coordinate.longitude);

            var _point = CoordinateFormatter.fromLatitudeLongitude(_coordinateString, SpatialReference.createWgs84());

            var _location = {
                x: _point.x,
                y: _point.y,
                z: locationManager.coordinate.altitude + 500
            }

            var _rotation = {
                heading: sceneView.currentViewpointCamera.heading,
                pitch: 0,
                roll: sceneView.currentViewpointCamera.roll
            }

            manipulateCamera(_rotation, _location);

            displayLocation(_location);
        }
    }

    Item {
        anchors.fill: parent

        SceneView {
            id: sceneView

            anchors.fill: parent
            attributionTextVisible: false

            GraphicsOverlay {
                LayerSceneProperties {
                    surfacePlacement: Enums.SurfacePlacementDraped
                }

                Graphic {
                    id: locationGraphic

                    symbol: locationSymbol

                    visible: isLocationDisplayed
                }

                SimpleMarkerSymbol {
                    id: locationSymbol

                    color: colors.blue
                    size: 12
                    style: Enums.SimpleMarkerSymbolStyleCircle

                    SimpleLineSymbol {
                        width: 1
                        color: colors.black
                    }
                }
            }

            onViewpointChanged: {
                updateSceneView();
            }

            onMousePressed: {
                resetCameraController();
            }

            Component.onCompleted: {
                viewMode = Qt.binding(function() { return sceneView.currentViewpointCamera.pitch < 0.1 ? "3D" : "2D"; })
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40 * constants.scaleFactor

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Widgets.RoundedButton {
                        Layout.preferredWidth: 40 * constants.scaleFactor
                        Layout.fillHeight: true

                        color: isLocationDisplayed ? colors.blue : colors.view_background

                        source: images.location_icon
                        iconColor: colors.white

                        isEnabled: locationManager.valid

                        onClicked: {
                            resetCameraController();

                            if (isLocationDisplayed) {
                                locationManager.stop();

                                isLocationDisplayed = false;
                            } else {
                                locationManager.start();

                                if (!appManager.isWindows && !appManager.ismacOS && !appManager.isLinux && !appManager.hasLocationPermission())
                                    displayNoLocationDialog();
                                else
                                    isLocationDisplayed = true;
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16 * constants.scaleFactor
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40 * constants.scaleFactor

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Widgets.RoundedButton {
                        Layout.preferredWidth: 40 * constants.scaleFactor
                        Layout.fillHeight: true

                        color: colors.view_background

                        source: images.home_icon
                        iconColor: colors.white

                        onClicked: {
                            if (isLocationDisplayed) {
                                locationManager.stop();

                                isLocationDisplayed = false;
                            }

                            resetCameraController();

                            if (typeof initialViewpointCamera !== "undefined")
                                arcGISRuntimeHelper.setCamera(sceneView, initialViewpointCamera);
                        }
                    }

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16 * constants.scaleFactor
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40 * constants.scaleFactor

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Widgets.TouchGestureArea {
                        Layout.preferredWidth: 40 * constants.scaleFactor
                        Layout.fillHeight: true
                        color: colors.view_background
                        radius: this.width / 2

                        isEnabled: viewMode > ""

                        Label {
                            id: icon

                            anchors.centerIn: parent

                            height: 24 * constants.scaleFactor

                            text: viewMode === "2D" ? "2D" : "3D"
                            clip: true
                            elide: Text.ElideRight

                            font.family: fonts.avenirNextDemi
                            font.pixelSize: 14 * constants.scaleFactor
                            color: colors.white
                        }

                        onClicked: {
                            if (isLocationDisplayed) {
                                locationManager.stop();

                                isLocationDisplayed = false;
                            }

                            resetCameraController();

                            switchViewMode();
                        }
                    }

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16 * constants.scaleFactor
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40 * constants.scaleFactor

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Widgets.RoundedButton {
                        Layout.preferredWidth: 40 * constants.scaleFactor
                        Layout.fillHeight: true

                        color: colors.view_background

                        source: images.rotation_icon
                        iconColor: colors.white

                        isEnabled: viewMode === "2D"

                        onClicked: {
                            if (isLocationDisplayed) {
                                locationManager.stop();

                                isLocationDisplayed = false;
                            }

                            applyRotation();
                        }
                    }

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16 * constants.scaleFactor
            }


            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40 * constants.scaleFactor

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Widgets.RoundedButton {
                        Layout.preferredWidth: 40 * constants.scaleFactor
                        Layout.fillHeight: true

                        color: colors.view_background

                        source: images.compass_icon
                        iconRotation: sceneView.currentViewpointCamera.heading
                        iconSize: 32 * constants.scaleFactor

                        onClicked: {
                            if (isLocationDisplayed) {
                                locationManager.stop();

                                isLocationDisplayed = false;
                            }

                            resetCameraController();

                            rotateToNorth();
                        }
                    }

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40 * constants.scaleFactor

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: this.visible ? 16 * constants.scaleFactor : 0
                        visible: sceneInfoText > ""

                        Behavior on Layout.preferredHeight {
                            NumberAnimation { duration: constants.normalDuration }
                        }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 0

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            Item {
                                Layout.preferredWidth: coordinateLabel.width
                                Layout.fillHeight: true

                                Widgets.TouchGestureArea {
                                    anchors.fill: parent
                                    color: colors.black
                                    opacity: 0.38

                                    onClicked: {
                                        copy(coordinatesText);
                                    }
                                }

                                Label {
                                    id: coordinateLabel

                                    width: this.implicitWidth
                                    height: parent.height

                                    text: sceneInfoText
                                    clip: true
                                    elide: Text.ElideRight

                                    font.family: fonts.avenirNextRegular
                                    font.pixelSize: 12 * constants.scaleFactor
                                    color: colors.white

                                    horizontalAlignment: Label.AlignHCenter
                                    verticalAlignment: Label.AlignVCenter

                                    leftPadding: 8 * constants.scaleFactor
                                    rightPadding: 8 * constants.scaleFactor
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        width: parent.width
        height: 56 * constants.scaleFactor

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            anchors.fill: parent
            color: colors.black
            opacity: 0.38
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.preferredWidth: 8 * constants.scaleFactor
                Layout.fillHeight: true
            }

            Item {
                Layout.preferredWidth: 40 * constants.scaleFactor
                Layout.fillHeight: true

                Widgets.RoundedButton {
                    width: 40 * constants.scaleFactor
                    height: this.width
                    anchors.centerIn: parent

                    color: colors.transparent

                    source: images.close_icon
                    iconColor: colors.white

                    onClicked: {
                        closed();
                    }
                }
            }

            Item {
                Layout.preferredWidth: 8 * constants.scaleFactor
                Layout.fillHeight: true
            }

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true

                text: sceneTitle
                clip: true
                elide: Text.ElideRight

                font.family: fonts.avenirNextDemi
                font.pixelSize: 20 * constants.scaleFactor
                color: colors.white

                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter
            }

            Item {
                Layout.preferredWidth: 8 * constants.scaleFactor
                Layout.fillHeight: true
            }

            Item {
                Layout.preferredWidth: 40 * constants.scaleFactor
                Layout.fillHeight: true

                Widgets.RoundedButton {
                    width: 40 * constants.scaleFactor
                    height: this.width
                    anchors.centerIn: parent

                    color: colors.transparent

                    source: images.book_marks_icon
                    iconColor: colors.white

                    onClicked: {
                        bookMarkSlideMenu.open();
                    }
                }
            }

            Item {
                Layout.preferredWidth: 8 * constants.scaleFactor
                Layout.fillHeight: true
            }

            Item {
                Layout.preferredWidth: 40 * constants.scaleFactor
                Layout.fillHeight: true
                visible: !appManager.isWindows

                Widgets.RoundedButton {
                    width: 40 * constants.scaleFactor
                    height: this.width
                    anchors.centerIn: parent

                    color: colors.transparent

                    source: images.more_option_icon
                    iconColor: colors.white

                    isEnabled: shortUrl > ""

                    onClicked: {
                        openShareSheet();
                    }
                }
            }

            Item {
                Layout.preferredWidth: 8 * constants.scaleFactor
                Layout.fillHeight: true
                visible: !appManager.isWindows
            }
        }

        Widgets.LinearGadientLoadingBar {
            width: parent.width
            height: 4 * constants.scaleFactor

            anchors.left: parent.left
            anchors.top: parent.top

            visible: sceneView.drawStatus === Enums.DrawStatusInProgress

            Behavior on visible {
                NumberAnimation { duration: constants.normalDuration }
            }
        }
    }

    BookMarkSlideMenu{
        id: bookMarkSlideMenu

        width: 0.78 * parent.width
        height: parent.height

        onClicked: {
            resetCameraController();

            var _camera = arcGISRuntimeHelper.createCamera(viewpoint.camera, sceneView.spatialReference.wkid);
            arcGISRuntimeHelper.setCamera(sceneView, _camera);

            close();
        }
    }

    GlobeCameraController {
        id: globeCameraController
    }

    Timer {
        id: rotationTimer

        interval: 100
        repeat: false
        running: false

        onTriggered: {
            sceneView.cameraController.moveCamera(0, -360, 0, 120);
        }
    }

    Component.onCompleted: {
        initial();
    }

    function initial() {
        isPageLoading = true;

        createScene();
        getShortenedUrl(sceneUrl, function() {
            isPageLoading = false;
        });
    }

    function createScene() {
        var _scene = ArcGISRuntimeEnvironment.createObject(
                    "Scene", {
                        initUrl: sceneUrl
                    });

        _scene.onLoadStatusChanged.connect(function() {
            if (_scene.loadStatus === 0) {
                initialViewpointCamera = sceneView.scene.initialViewpoint.camera;

                getBookMarks();
            }
        });

        _scene.onLoadErrorChanged.connect(function() {
            displayErrorDialog(_scene.loadError.additionalMessage);
        })

        sceneView.scene = _scene;
    }

    function displayLocation(location) {
        // no z value
        locationGraphic.geometry = ArcGISRuntimeEnvironment.createObject(
                    "Point", {
                        x: location.x,
                        y: location.y,
                        SpatialReference: SpatialReference.createWgs84()
                    })
    }

    function getBookMarks() {
        var _unsupportedJson = sceneView.scene.unsupportedJson;

        var _presentation = {};

        if (_unsupportedJson.hasOwnProperty("presentation")) {
            _presentation = _unsupportedJson.presentation;

            if (_presentation.hasOwnProperty("slides")) {
                var _slides = _presentation.slides;

                _slides.forEach(function(slide) {
                    var _itemTitle = {};
                    var _itemViewpoint = {};
                    var _itemThumbnail = {};

                    if (slide.hasOwnProperty("title"))
                        _itemTitle = slide.title;

                    if (slide.hasOwnProperty("viewpoint"))
                        _itemViewpoint = slide.viewpoint;

                    if (slide.hasOwnProperty("thumbnail"))
                        _itemThumbnail = slide.thumbnail;

                    var _obj = {
                        itemTitle: _itemTitle,
                        itemThumbnail: _itemThumbnail,
                        itemViewpoint: _itemViewpoint
                    }

                    bookMarkSlideMenu.gridView.model.append(_obj);
                })
            }
        }
    }

    function openShareSheet() {
        AppFramework.clipboard.share(AppFramework.urlInfo(shortUrl).url);
    }

    function getShortenedUrl(url, process) {
        var _promise = new Promise(function(resolve, reject) {
            networkManager.requestShortenedUrl(url, function(response) {
                try {
                    if (!infoPage)
                        return;

                    var _json = JSON.parse(response.responseText);

                    if (_json.hasOwnProperty("data"))
                        shortUrl = _json.data.url;
                    else
                        shortUrl = url;

                    resolve();
                } catch (e) {
                    reject("Error in InfoPage requestShortenedUrl(): " + e);
                }
            })
        })

        _promise.then(function() {
            process();
        }).catch(function(e) {
            console.error(e);
        })
    }

    function manipulateCamera(rotation, location) {
        var _location = ArcGISRuntimeEnvironment.createObject(
                    "Point", {
                        x: location.x,
                        y: location.y,
                        z: location.z,
                        SpatialReference: SpatialReference.createWgs84()
                    })

        var _camera = ArcGISRuntimeEnvironment.createObject(
                    "Camera", {
                        heading: rotation.heading,
                        pitch: rotation.pitch,
                        roll: rotation.roll,
                        location: _location
                    });

        arcGISRuntimeHelper.setCamera(sceneView, _camera);
    }

    function rotateToNorth() {
        var _camera = sceneView.currentViewpointCamera;

        var _rotation = {
            heading: 0,
            pitch: _camera.pitch,
            roll: _camera.roll
        }

        arcGISRuntimeHelper.cameraRotateTo(sceneView, _rotation);
    }

    function switchViewMode() {
        var _camera = sceneView.currentViewpointCamera;
        var _point = sceneView.currentViewpointCenter.center;
        var _deltaRotation = {};

        if (viewMode === "2D") {
            _deltaRotation = {
                heading: 0,
                pitch: -_camera.pitch,
                roll: 0
            }
        } else {
            _deltaRotation = {
                heading: 0,
                pitch: 45,
                roll: 0
            }
        }

        arcGISRuntimeHelper.cameraRotateAround(sceneView, _point, _deltaRotation);
    }

    function applyRotation() {
        var _center = sceneView.currentViewpointCenter.center;
        var _camera = sceneView.currentViewpointCamera;

        var orbitLocationCameraController = ArcGISRuntimeEnvironment.createObject(
                    "OrbitLocationCameraController",
                    {
                        cameraHeadingOffset: _camera.heading,
                        cameraPitchOffset: _camera.pitch,
                        targetLocation: _center,
                        initialCameraLocation: _camera.location
                    })

        sceneView.cameraController = orbitLocationCameraController;

        rotationTimer.start();
    }

    function updateSceneView() {
        if (!sceneView.currentViewpointCenter || !sceneView.currentViewpointCamera)
            return;

        updateSceneInfo();
    }

    function updateSceneInfo() {
        var _cameraLocation = GeometryEngine.project(sceneView.currentViewpointCamera.location, SpatialReference.createWebMercator());
        var _distanceText = "";

        if (_cameraLocation.z > 1000)
            _distanceText = "%1 km".arg(arcGISRuntimeHelper.convertUnit(_cameraLocation.z, "km"));
        else
            _distanceText = "%1 m".arg(arcGISRuntimeHelper.convertUnit(_cameraLocation.z, "m"));

        coordinatesText = arcGISRuntimeHelper.changePointToLatitudeLongitude(sceneView.currentViewpointCenter.center, Enums.LatitudeLongitudeFormatDegreesMinutesSeconds, 3, "DMS");

        sceneInfoText = "Camera: %1  ".arg(_distanceText) + coordinatesText;
    }

    function copy(text) {
        if (AppFramework.clipboard.copy(text))
            toastMessage.show(strings.clipboard_copy);
    }

    function displayNoLocationDialog() {
        dialog.display(strings.dialog_no_location_permission_title,
                       strings.dialog_no_location_permission_description,
                       strings.okay,
                       "",
                       colors.white,
                       colors.white,
                       function() {
                           dialog.close();
                       },
                       function() {});
    }

    function displayErrorDialog(message) {
        dialog.display(strings.error,
                       message,
                       strings.okay,
                       "",
                       colors.white,
                       colors.white,
                       function() {
                           stackView.pop();

                           dialog.close();
                       },
                       function() {});
    }

    function resetCameraController() {
        sceneView.cameraController = globeCameraController;
    }

    function resetSceneView() {
        sceneView.scene = null;
    }
}
