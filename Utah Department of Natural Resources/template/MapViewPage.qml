import QtQuick 2.2
import QtQuick.Controls 1.1
import QtPositioning 5.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "Helper.js" as Helper


Item {
    id: mapView

    property Portal portal
    property alias mapFolder: mapFolder
    property PositionSource positionSource
    property Envelope initialExtent
    property alias map: myMap
    property alias webMap: myMap

    property real zoomScale: 10000
    property real ornamentsMinimumOpacity: 0.85

    signal exit()

    //--------------------------------------------------------------------------

    function loadWebMap(itemId) {
        mapFolder.path = mapsFolder.filePath(itemId);
        mapFolder.makeFolder();

        myMap.webMapId = itemId;

        map.positionDisplay.positionSource = mapView.positionSource;
    }

    //--------------------------------------------------------------------------

    function showPopup(mouse) {
        var mapPoint = mouse.mapPoint;
        console.log("Popup", mapPoint.x, mapPoint.y);

        var myMapPosition;

        if (map.positionDisplay.positionSource && map.positionDisplay.positionSource.active) {
            var position = map.positionDisplay.positionSource.position;

            myPosition.valid = position.longitudeValid && position.latitudeValid;
            myPosition.x = position.coordinate.longitude;
            myPosition.y = position.coordinate.latitude;

            myMapPosition = myPosition.project(map.spatialReference);
        }

        identifyPanel.setLocation(mouse, myMapPosition);
    }

    Point {
        id: myPosition

        property bool valid : false

        spatialReference: SpatialReference {
            wkid: 4326
        }
    }

    //--------------------------------------------------------------------------

    FileFolder {
        id: mapFolder
    }

    //--------------------------------------------------------------------------

    GraphicsLayer {
        id: resultsLayer

        property var currentId

        visible: searchPanel.visible || identifyPanel.visible
        name: "_results_"
        //        renderer: SimpleRenderer {
        //            symbol: PictureMarkerSymbol {
        //                image: "images/pin_center_circle_red.png"
        //            }
        //        }

        function clearCurrent() {
            if (currentId) {
                removeGraphic(currentId);
                currentId = 0;
            }
        }

        function setCurrent(graphic) {
            clearCurrent();

            if (!graphic) {
                console.log("setCurrent to null");
                return;
            }

            if (!graphic.geometry) {
                console.log("setCurrent null geometry");
                return;
            }

            //console.log("setCurrent geometry type", graphic.geometry.geometryType, graphic.geometry.geometryTypeString);

            switch (graphic.geometry.geometryType) {
            case Enums.GeometryTypePoint:
            case Enums.GeometryTypeMultiPoint:
                graphic.symbol = resultMarkerSymbol;
                break;

            case Enums.GeometryTypeLine:
            case Enums.GeometryTypePolyline:
                graphic.symbol = resultLineSymbol;
                break;

            case Enums.GeometryTypeEnvelope:
            case Enums.GeometryTypePolygon:
                graphic.symbol = resultFillSymbol;
                break;

            default:
                console.log("Unhandled geometry type", graphic.geometry.geometryType, graphic.geometry.geometryTypeString);
                break;
            }

            currentId = addGraphic(graphic);
            selectGraphic(currentId);
        }
    }

    PictureMarkerSymbol {
        id: identifyMarkerSymbol
        property url swatchImage: "images/pin_circle_red.png"
        image: "images/pin_center_circle_red.png"
    }

    PictureMarkerSymbol {
        id: resultMarkerSymbol
        image: "images/pin_center_star_grey.png"
    }

    SimpleLineSymbol {
        id: resultLineSymbol
        color: "transparent"
        width: 2
    }

    SimpleFillSymbol {
        id: resultFillSymbol
        color: "transparent"
    }

    //--------------------------------------------------------------------------

    GraphicsLayer {
        id: droppedPinsLayer
        name: "droppedPins"
        renderer: SimpleRenderer {
            symbol: PictureMarkerSymbol {
                id: droppedPinsMarkerSymbol
                image: "images/pin_center_star_orange.png"
            }
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: map

        onStatusChanged: {
            if (map.status === Enums.MapStatusReady) {
                initialExtent = webMap.defaultExtent.project(map.spatialReference);

                //console.log("webMap extent", JSON.stringify(webMap.extent.json, undefined, 2), "initial extent", JSON.stringify(initialExtent.json, undefined, 2));

                map.zoomTo(initialExtent);
                //map.fullExtent = map.extent; // TODO bug in API
                //map.extent = initialExtent;
                map.addLayer(resultsLayer);
                map.addLayer(droppedPinsLayer);

                if (mapView.positionSource.position.latitudeValid &&
                        mapView.positionSource.position.longitudeValid) {
                    //point4326.x = mapView.positionSource.position.coordinate.longitude;
                    //point4326.y = mapView.positionSource.position.coordinate.latitude;
                    //map.panTo(point4326.project(map.spatialReference));
                    map.positionDisplay.mode = app.info.propertyValue("positionDisplayMode", 1);
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    WebMap {
        id: myMap

        property alias identify: _identify
        property alias search: _search

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: footer.top
        }

        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: true
        mapPanningByMagnifierEnabled: true

        portal: mapView.portal
        fileFolder: mapFolder

        onMouseClicked: {
            showPopup(mouse);//.mapPoint);
        }

        WebMapSearch {
            id: _search

            webMap: parent
        }

        WebMapIdentify {
            id: _identify

            webMap: parent
            defaultTolerance: app.identifyTolerance
        }
    }

    //--------------------------------------------------------------------------

    Item {
        anchors.fill: myMap

        Rectangle {
            id: banner

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            height: 60 * AppFramework.displayScaleFactor
            color: "#e04c4c4c"

            Row {
                id: leftButtons

                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    margins: 5
                }

                spacing: 2

                ImageButton {
                    id: exitButton

                    height: parent.height
                    width: height
                    visible: false

                    source: "images/left2.png"
                    hoverColor: app.hoverColor
                    pressedColor: app.pressedColor

                    onClicked: {
                        exit();
                    }
                }

                ImageButton {
                    id: actionsButton

                    height: parent.height
                    width: height
                    visible: true

                    source: "images/actions.png"
                    hoverColor: app.hoverColor
                    pressedColor: app.pressedColor
                    checkedColor: app.selectedColor

                    onClicked: {
                        checked = !checked;
                    }
                }
            }

            Row {
                id: rightButtons

                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    margins: 5
                }

                spacing: 2

                ImageButton {
                    id: searchButton

                    height: parent.height
                    width: height
                    visible: webMap.search.canSearch// && !mapView.searchVisible

                    source: "images/search.png"
                    hoverColor: app.hoverColor
                    pressedColor: app.pressedColor
                    checkedColor: app.selectedColor

                    onClicked: {
                        toggleSearch();
                    }
                }
            }

            Text {
                id: titleText

                anchors {
                    left: leftButtons.right
                    right: rightButtons.left
                    rightMargin: 4
                    verticalCenter: parent.verticalCenter
                }

                text: webMap.itemInfo.title
                elide: Text.ElideRight

                font {
                    pixelSize: parent.height * 0.4
                }
                fontSizeMode: Text.HorizontalFit
                color: "#f7f8f8"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            /*
            SearchField {
                id: searchField

                width: searchVisible ? titleText.width + 2 : 0
                visible: width > 0

                anchors {
                    right: titleText.right
                    top: parent.top
                    topMargin: 10
                    bottom: parent.bottom
                    bottomMargin: 10
                }

                webMapSearch: webMap.search

                Behavior on width {
                    SmoothedAnimation {
                        duration: 200
                    }
                }

                onVisibleChanged: {
                    if (visible) {
                        forceActiveFocus();
                    }
                }

                onTextChanged: {
                    searchResultsView.currentIndex = -1;
                }

                onCleared: {
                    searchResultsView.currentIndex = -1;
                }
            }
*/
        }

        //----------------------------------------------------------------------

        Item {
            anchors {
                left: parent.left
                right: parent.right
                top: banner.bottom
                bottom: parent.bottom
            }

            NorthArrow {
                anchors {
                    right: parent.right
                    rightMargin: 10
                    top: parent.top
                    topMargin: 10
                }

                map: myMap
                visible: myMap.mapRotation != 0
                fader.minumumOpacity: ornamentsMinimumOpacity
            }
            /*
            ScaleBar {
                anchors {
                    left: parent.left
                    leftMargin: 10
                    bottom: parent.bottom
                    bottomMargin: 25
                }

                map: myMap
                visible: false
            }
*/
            ZoomButtons {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 10
                }

                map: myMap
                homeExtent: initialExtent
                fader.minumumOpacity: ornamentsMinimumOpacity
            }
        }


        //----------------------------------------------------------------------

        ActionsPanel {
            id: actionsPanel

            webMap: myMap
            show: actionsButton.checked

            onVisibleChanged: {
                if (visible) {
                    hidePanels(this);
                    //                    identifyPanel.clear();
                    //                    hideSearch();
                }
            }
        }

        //----------------------------------------------------------------------

        LegendPanel {
            id: legendPanel

            map: webMap

            onVisibleChanged: {
                if (visible) {
                    hidePanels(this);
                }
            }
        }

        //----------------------------------------------------------------------

        BookmarksPanel {
            id: bookmarksPanel

            webMap: myMap

            onVisibleChanged: {
                if (visible) {
                    hidePanels(this);
                }
            }
        }

        //--------------------------------------------------------------------------

        IdentifyPanel {
            id: identifyPanel

            webMapIdentify: webMap.identify
            popupModel: webMap.identify.popupModel

            onVisibleChanged: {
                if (visible) {
                    hidePanels(this);
                    //                    hideSearch();
                    //                    actionsPanel.hide();
                }
            }
        }

        //----------------------------------------------------------------------

        SearchPanel {
            id: searchPanel

            fullScreen: app.compactLayout || landscape && app.width * app.sidePanelRatio < app.sidePanelWidth
            landscape: (app.width > app.height) || app.width > app.sidePanelWidth * 2

            leftEdge: parent.left
            rightEdge: parent.right
            topEdge: banner.bottom
            bottomEdge: parent.bottom
            lockRight: false
            lockBottom: false

            webMapSearch: webMap.search
            show: false //!app.compactLayout && mapView.searchVisible //searchField.visible

            function clear() {
                webMap.search.clear();
                resultsView.currentIndex = -1;
            }

            onVisibleChanged: {
                if (visible) {
                    hidePanels(this);
                    //                    identifyPanel.clear();
                    //                    actionsPanel.hide();
                }
            }
        }
    }

    Component {
        id: searchPage

        SearchView {
            readonly property bool isSearch: true

            webMapSearch: webMap.search
            fullScreen: true
            popupsStackView: stackView
            color: "#f7f8f8"

            Component.onCompleted: {
                forceFocus();
            }
        }
    }

    function showSearch() {
        searchButton.checked = true;

        if (app.compactLayout || app.height <= compactThreshold) {
            stackView.push(searchPage);
        } else {
            searchPanel.show = true;
        }
    }

    function hideSearch() {
        searchButton.checked = false;

        if (searchPanel.show) {
            searchPanel.show = false;
        } else if (stackView.currentItem.isSearch) {
            stackView.pop(stackView.initialItem);
        }
    }

    function toggleSearch() {
        if (searchButton.checked) {
            hideSearch();
        } else {
            showSearch();
        }
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: footer

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        visible: false
        height: visible ? 60 * AppFramework.displayScaleFactor : 0
        color: "#f7f8f8" //#9095aa"

        Behavior on height {
            SmoothedAnimation {
                duration: 200
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 1
            color: "darkgrey"
        }

        Row {
            id: footerRowLeft

            anchors {
                left: parent.left
                leftMargin: 5
                verticalCenter: parent.verticalCenter
            }

            height: 50 * AppFramework.displayScaleFactor
        }

        Row {
            id: footerRowRight

            anchors {
                right: parent.right
                rightMargin: 5
                verticalCenter: parent.verticalCenter
            }

            layoutDirection: Qt.RightToLeft

            height: footerRowLeft.height
        }
    }

    //--------------------------------------------------------------------------

    function clearPins() {
        droppedPinsLayer.removeAllGraphics();
    }

    function dropPin(x, y) {
        resultsLayer.addGraphic({
                                    geometry: {
                                        x: x,
                                        y: y
                                    }
                                });
    }

    //--------------------------------------------------------------------------

    function hidePanels(excludePanel) {
        if (identifyPanel !== excludePanel) {
            identifyPanel.clear();
        }

        if (searchPanel !== excludePanel) {
            hideSearch();
        }

        if (legendPanel !== excludePanel) {
            legendPanel.hide();
        }

        if (actionsPanel !== excludePanel) {
            actionsPanel.hide();
        }

        if (bookmarksPanel !== excludePanel) {
            bookmarksPanel.hide();
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: mapAboutPage

        MapAboutPage {
            stackView: app.stackView
        }
    }

    //--------------------------------------------------------------------------

    NoNetwork {
    }

    //--------------------------------------------------------------------------
}
