import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework.Platform 1.0

import Esri.ArcGISRuntime 100.7

import "../controls" as Controls

Controls.PopupPage {
    id: searchPage

    property MapView mapView

    property string kUseMapExtent: qsTr("Use map extent")
    property string kWithinExtent: qsTr("Within Map Extent")
    property string kOutsideExtent: qsTr("Outside Map Extent")

    property var searchTabs: {
       var tabs = []
       if (locatorTask) tabs.push(app.tabNames.kPlaces)
       if ((featureSearchProperties.supportsSearch && featureSearchProperties.layerProperties.length > 0) || mapView.mmpk.loadStatus === Enums.LoadStatusLoaded) tabs.push(app.tabNames.kFeatures)
       return tabs
    }
    property int transitionDuration: 200
    property real pageExtent: 0
    property real base: searchPage.height
    property string transitionProperty: "y"
    property string currentPlaceSearchText: ""
    property string currentFeatureSearchText: ""
    property alias sizeState: screenSizeState.name
    property bool hasLocationPermission: app.hasLocationPermission

    signal geocodeSearchCompleted ()
    signal featureSearchCompleted ()

    property var lyrNames:{
    var searchLayers = []
        return searchLayers
    }

    onFeatureSearchCompleted: {
        featuresModel.sortByStringAttribute("layerName")
        if (swipeView.currentItem.item.objectName === "searchFeaturesView") {
            var count = featuresModel.count
            displayFeatureResultsCount(count)
        }
    }

    onGeocodeSearchCompleted: {
        withinExtent.sortByNumberAttribute("numericalDistance", "desc")
        outsideExtent.sortByNumberAttribute("numericalDistance", "desc")
        geocodeModel.appendModelData(withinExtent)
        geocodeModel.appendModelData(outsideExtent)
        if (swipeView.currentItem.item.objectName === "searchPlacesView") {
            var count = geocodeModel.count
            displayPlaceResultsCount(count)
        }
    }

    Item {
        id: screenSizeState

        property string name: state

        states: [
            State {
                name: "LARGE"
                when: app.isLarge

                PropertyChanges {
                    target: searchPage
                    pageExtent: height
                    margins: 0.5 * app.defaultMargin
                    leftMargin: app.isIphoneX && app.isLandscape ? app.widthOffset + app.defaultMargin : 0.5 * app.defaultMargin
                    bottomMargin: 1.5 * app.defaultMargin
                    height: parent ? parent.height - topMargin - bottomMargin : 0
                    width: 0.33 * parent.width
                }
            }
        ]
    }
    y: sizeState === "" ? 0 : height
    height: app.height
    width: parent ? parent.width : 0

    enter: Transition {
        NumberAnimation {
            id: bottomUp_MoveIn

            property: searchPage.transitionProperty
            duration: searchPage.transitionDuration
            from: searchPage.base
            to: searchPage.pageExtent
            easing.type: Easing.InOutQuad
        }
    }

    exit: Transition {
        NumberAnimation {
            id: topDown_MoveOut

            property: searchPage.transitionProperty
            duration: searchPage.transitionDuration
            from: searchPage.pageExtent
            to: searchPage.base
            easing.type: Easing.InOutQuad
        }
    }

    property alias tabBar: tabBar
    contentItem: Controls.BasePage {
        anchors.fill: parent
        Material.background: "transparent"

        header: ToolBar {
            id: searchBar

            property real tabBarHeight: 0.8 * app.headerHeight
            property real searchBoxHeight: app.headerHeight
            Material.background: app.primaryColor
            Material.foreground: app.subTitleTextColor
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            height: searchBoxHeight + tabBarHeight + app.defaultMargin

            Rectangle {
                anchors {
                    fill: parent
                    margins: 0.5 * app.defaultMargin
                }
                radius: app.units(2)
                //color: app.backgroundColor

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Pane {
                        Material.background: "transparent"
                        Layout.preferredHeight: searchBar.tabBarHeight
                        Layout.preferredWidth: parent.width
                        Layout.topMargin: 0.5 * app.defaultMargin
                        leftPadding: app.defaultMargin
                        rightPadding: app.defaultMargin
                        topPadding: 0
                        bottomPadding: 0

                        TabBar {
                            id: tabBar
                            width: parent.width
                            height: searchBar.tabBarHeight
                            currentIndex: swipeView.currentIndex
                            padding: 0

                            Repeater {
                                id: tabView

                                model: searchPage.searchTabs

                                TabButton {
                                    id: tabButton
                                    contentItem: Controls.BaseText {
                                        text: modelData
                                        color: tabButton.checked ? app.primaryColor : app.subTitleTextColor
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                    }
                                    padding: 0
                                    implicitWidth: Math.max(app.units(64), tabView.width/tabView.model.count)
                                    implicitHeight: 0.8 * parent.height

                                    Keys.onReleased: {
                                        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape){
                                            event.accepted = true
                                            backButtonPressed ()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        spacing: 0

                        Controls.Icon {
                            imageSource: "../images/back.png"
                            maskColor: app.subTitleTextColor

                            onClicked: {
                                searchPage.close()
                            }
                        }

                        Controls.CustomTextField {
                            id: textField

                            Material.accent: app.baseTextColor
                            Material.foreground: app.subTitleTextColor
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.leftMargin: app.baseUnit
                            Layout.rightMargin: app.baseUnit
                            properties.placeholderText: qsTr("Search")
                            properties.focusReason: Qt.PopupFocusReason
                            properties.color: app.baseTextColor
                            properties.font.pointSize: app.baseFontSize

                            onAccepted: {
                                searchPage.search(textField.properties.text)
                            }

                            onBackButtonPressed: {
                                app.backButtonPressed()
                            }

                            Connections {
                                target: textField.properties

                                onDisplayTextChanged: {
                                    geocodeModel.clearAll()
                                    if (!textField.properties.displayText) {
                                        currentPlaceSearchText = ""
                                        featuresModel.clearAll()
                                        currentFeatureSearchText = ""
                                        swipeView.currentItem.item.reset()
                                        searchBusyIndicator.visible = false
                                        if (Qt.platform.os === "android") app.focus = true
                                    }
                                    if (locatorTask.suggestions) {
                                        locatorTask.suggestions.searchText = textField.properties.displayText
                                    }
                                }
                            }

                            onCloseButtonClicked: {
                                textField.properties.text = ""
                            }
                        }
                    }
                }
            }
        }

        contentItem: SwipeView {
            id: swipeView

            property QtObject currentView
            property QtObject itemModel
            property QtObject itemDelegate
            property string sectionProperty

            currentIndex: tabBar.currentIndex
            interactive: false
            clip: true

            anchors {
                top: searchBar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: sizeState === "" ? app.heightOffset : 0
            }

            Repeater {
                model: tabView.model.length

                Loader {
                    active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                    visible: SwipeView.isCurrentItem

                    sourceComponent: swipeView.currentView
                }
            }

            onCurrentIndexChanged: {
                switch (tabView.model[currentIndex]) {
                case app.tabNames.kFeatures:
                    mapView.hidePin(function () {
                        swipeView.currentView = searchFeaturesView
                        if (featuresModel.count) {
                            displayFeatureResultsCount(featuresModel.count)
                        }
                        if (currentFeatureSearchText !== currentPlaceSearchText) {
                            performFeatureSearch(currentPlaceSearchText)
                        } else if (featuresModel.currentIndex >= 0) {
                            swipeView.currentItem.item.searchResultSelected(featuresModel.features[featuresModel.currentIndex], featuresModel.currentIndex, false)
                        }
                    })
                    break
                case app.tabNames.kPlaces:
                    mapView.identifyProperties.clearHighlight(function () {
                        swipeView.currentView = searchPlacesView
                        if (geocodeModel.count) {
                            displayFeatureResultsCount(geocodeModel.count)
                        }
                        if (currentFeatureSearchText !== currentPlaceSearchText) {
                            searchPlaces(currentFeatureSearchText)
                        } else if (geocodeModel.currentIndex >= 0) {
                            swipeView.currentItem.item.searchResultSelected(geocodeModel.features[geocodeModel.currentIndex], geocodeModel.currentIndex, false)
                        }
                    })
                    break
                }
            }
        }
    }

    Component {
        id: searchPlacesView

        SearchPlacesView {
            searching: searchBusyIndicator.visible
            listView.model: geocodeModel
            suggestionsModel: locatorTask ? locatorTask.suggestions : ListModel

            onSearchResultSelected: {
                searchBusyIndicator.visible = false
                var extent = feature.extent
                if (closeSearchPageOnSelection) {
                    searchPage.close()
                }
                //mapView.setViewpointGeometry(extent)
                mapView.zoomToPoint(feature.displayLocation)
                mapView.showPin(feature.displayLocation)
            }

            onSearchSuggestionSelected: {
                textField.properties.text = suggestion
                searchPage.search(textField.properties.text)
            }
        }
    }

    Component {
        id: searchFeaturesView

        SearchFeaturesView {
            searching: searchBusyIndicator.visible
            listView.model: featuresModel
            defaultSearchViewTitleText: featureSearchProperties.hintText
            onSearchResultSelected: {
                searchBusyIndicator.visible = false
                var extent = feature.geometry
                if (closeSearchPageOnSelection) {
                    searchPage.close()
                }

                if (feature.geometry.geometryType === Enums.GeometryTypePoint){


                    mapView.setViewpointCenter(feature.geometry)
                    mapView.zoomToPoint(feature.geometry)
                }else{
                    var mapViewPadding = app.isLarge ? 280 : 150;
                    mapView.setViewpointGeometryAndPadding(feature.geometry, mapViewPadding)
                }

                mapView.identifyProperties.clearHighlight(function () {
                    mapView.identifyProperties.features = [feature]
                    mapView.identifyProperties.highlightFeature(0)
                })
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            mapView.isIdentifyTool = false
            if (featuresModel.features.length && tabView.model[tabBar.currentIndex] === app.tabNames.kFeatures) {
                swipeView.currentItem.item.searchResultSelected(featuresModel.features[featuresModel.currentIndex], featuresModel.currentIndex, false)
            } else if (geocodeModel.features.length && tabView.model[tabBar.currentIndex] === app.tabNames.kPlaces) {
                swipeView.currentItem.item.searchResultSelected(geocodeModel.features[geocodeModel.currentIndex], geocodeModel.currentIndex, false)
            }
            textField.focus = true
            if(hasLocationPermission)
                devicePositionSource.active = true


        } else {
            if (sizeState !== "") {
                if(!mapView.isIdentifyTool)
                {
                mapView.identifyProperties.clearHighlight()
                mapView.hidePin()
                }
            }
         if(!hasLocationPermission)
            devicePositionSource.active = false
            searchBusyIndicator.visible = false
        }
    }

    Controls.CustomListModel {
        id: featuresModel

        property var features: []
        property int currentIndex: -1

        function clearAll () {
            currentIndex = -1
            features = []
            clear()
            mapView.identifyProperties.clearHighlight()
        }
    }

    Controls.CustomListModel {
        id: geocodeModel

        property var features: []
        property int currentIndex: -1

        function clearAll () {
            currentIndex = -1
            features = []
            clear()
            withinExtent.clear()
            outsideExtent.clear()
            mapView.hidePin()
        }

        function appendModelData (model) {
            for (var i=0; i<model.count; i++) {
                append(model.get(i))
            }
        }
    }

    Controls.CustomListModel {
        id: withinExtent
    }

    Controls.CustomListModel {
        id: outsideExtent
    }

    QueryParameters {
        id: featureParameters

        maxFeatures: 10
    }

    GeocodeParameters {
        id: geocodeParameters

        maxResults: 25
        forStorage: false
        minScore: 90
        preferredSearchLocation: mapView.center
        outputSpatialReference: mapView.map.spatialReference
        outputLanguageCode: Qt.locale().name
        resultAttributeNames: ["Place_addr"]
    }

    Connections {
        target: locatorTask

        onGeocodeStatusChanged: {
            searchBusyIndicator.visible = true
            if (locatorTask.geocodeStatus === Enums.TaskStatusCompleted && mapView.map) {
                if (locatorTask.geocodeResults.length > 0) {
                    var deviceLocation = CoordinateFormatter.fromLatitudeLongitude("%1 %2".arg(devicePositionSource.position.coordinate.latitude).arg(devicePositionSource.position.coordinate.longitude), mapView.spatialReference)
                    //var deviceLocation = CoordinateFormatter.fromLatitudeLongitude("%1 %2".arg(32).arg(118), mapView.spatialReference)
                    for (var i=0; i<locatorTask.geocodeResults.length; i++) {
                        if (locatorTask.geocodeResults[i].label > "") {
                            var distance = GeometryEngine.distance(deviceLocation, locatorTask.geocodeResults[i].displayLocation),
                                distanceInMiles = (distance/1609.34) < 100 ?  "%1 mi".arg((distance/1609.34).toPrecision(3)) : "100+ mi",
                                distanceInKm = (distance/1000.0) < 100 ? "%1 km".arg((distance/1000.0).toPrecision(3)) : "100+ km",
                                distanceLabel = Qt.locale().measurementSystem === Locale.MetricSystem ? distanceInKm : distanceInMiles,
                                initialMapExtent = GeometryEngine.project(mapView.map.initialViewpoint.extent, mapView.map.spatialReference),
                                resultExtent = GeometryEngine.contains(initialMapExtent, locatorTask.geocodeResults[i].displayLocation) ? kWithinExtent : kOutsideExtent,
                                linearUnit  = ArcGISRuntimeEnvironment.createObject("LinearUnit", {linearUnitId: Enums.LinearUnitIdMillimeters}),
                                angularUnit = ArcGISRuntimeEnvironment.createObject("AngularUnit", {angularUnitId: Enums.AngularUnitIdDegrees}),
                                geodeticInfo = GeometryEngine.distanceGeodetic(deviceLocation, locatorTask.geocodeResults[i].displayLocation, linearUnit, angularUnit, Enums.GeodeticCurveTypeGeodesic),
                                results = {
                                    "score": locatorTask.geocodeResults[i].score,
                                    "extent": locatorTask.geocodeResults[i].extent,
                                    "resultExtent": resultExtent,
                                    "place_label": locatorTask.geocodeResults[i].label,
                                    "place_addr": locatorTask.geocodeResults[i].attributes.Place_addr,
                                    "showInView": false,
                                    "initialIndex": i,
                                    "hasNavigationInfo": deviceLocation ? true : false,
                                    "numericalDistance": distance,
                                    "distance": distanceLabel,
                                    "degrees": geodeticInfo.azimuth1
                                }

                            geocodeModel.features.push(locatorTask.geocodeResults[i])

                            if (resultExtent === kWithinExtent) {
                                withinExtent.append(results)
                            } else {
                                outsideExtent.append(results)
                            }
                        }
                        //console.log(GeometryEngine.contains(initialMapExtent, geocodeResults[i].displayLocation), JSON.stringify(initialMapExtent.json),  geocodeResults[i].displayLocation.x, geocodeResults[i].displayLocation.y)
                    }
                }
                geocodeSearchCompleted ()
                searchBusyIndicator.visible = false
            }
        }
    }

    property alias textField: textField
    property LocatorTask locatorTask: mapView.mmpk.locatorTask ? mapView.mmpk.locatorTask : app.isOnline ? onlineLocatorTask : null
    LocatorTask {
        id: onlineLocatorTask

        url: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"

        suggestions.suggestParameters: SuggestParameters {
            maxResults: 10
            preferredSearchLocation: mapView.currentCenter()
        }
    }

    QtObject {
        id: featureSearchProperties

        property bool supportsSearch: false
        property var layerProperties: []
        property string hintText: qsTr("Search for features")
        property bool ready: {
            try {
                return (mapView.map.loadStatus === Enums.LoadStatusLoaded) && layerProperties.length
            } catch (err) {
                return false
            }
        }

        onReadyChanged: {
            if (ready) {
                hintText = getHintText()
            }
        }

        function getHintText () {
            var hint = qsTr("Search for features")
            if (supportsSearch) {
                hint = qsTr("Search for")
                for (var i=0; i<layerProperties.length; i++) {
                    var layer = getLayerInfoById(layerProperties[i].id)
                    hint += qsTr(" %1 in %2").arg(layerProperties[i].field.name).arg(layer.name)
                    if (i !== layerProperties.length - 1) {
                        hint += ", "
                    }
                }
            }
            return hint
        }
    }

    Connections {
        target: mapView.map
        onLoadStatusChanged: {
            if (mapView.map) {
                switch (mapView.map.loadStatus) {
                case Enums.LoadStatusLoaded:
                    try {
                        featureSearchProperties.supportsSearch = mapView.map.json.applicationProperties.viewing.search.enabled
                        featureSearchProperties.layerProperties = mapView.map.json.applicationProperties.viewing.search.layers || []
                    } catch (err) {

                    }
                    break
                }
            }
        }
    }

    BusyIndicator {
        id: searchBusyIndicator

        visible: false
        Material.primary: app.primaryColor
        Material.accent: app.accentColor
        width: app.iconSize
        height: app.iconSize
        anchors.centerIn: parent
    }

    function getLayerInfoById (id) {
        //var layerList = mapView.map.operationalLayers
        var layerList = mapView.contentListModel
        for (var i=0; i<layerList.count; i++) {
            var layer = layerList.get(i)
            if (!layer) continue
            if (layer.layerId === id) {
                return layer
            }
        }
    }

    function getLayerById (id) {
        var layerList = mapView.map.operationalLayers
        for (var i=0; i<layerList.count; i++) {
            var layer = layerList.get(i)
            if (!layer) continue
            if (layer.layerId === id) {
                return layer
            }
        }
    }

    function searchPlaces (txt) {
        currentPlaceSearchText = txt
        //console.log("SEARCHING PLACES FOR ", txt)
        geocodeParameters.preferredSearchLocation = mapView.currentCenter()
        locatorTask.geocodeWithParameters(txt, geocodeParameters)
    }

    function searchOfflineMapFeatures (txt) {
        currentFeatureSearchText = txt

        searchBusyIndicator.visible = true
        featuresModel.clearAll()
        let  isSearching = false;

        for (var i=0; i<mapView.map.operationalLayers.count; i++) {
            var layer = mapView.map.operationalLayers.get(i),
                serviceTable = layer.featureTable

            if (typeof serviceTable === "undefined") {
                continue
            }
            let fields = []

            for (var key in serviceTable.fields) {
                var searchFieldName = serviceTable.fields[key].name
                fields.push(searchFieldName)

            }
            lyrNames.push(layer.name)
            isSearching=true
            queryServiceTable_mmpk(serviceTable, layer.name, fields, false, txt)

        }

            if(!isSearching)
                featureSearchCompleted()
    }



    function searchFeatures (txt) {
        currentFeatureSearchText = txt
        //console.log("SEARCHING FEATURES FOR ", txt)

        searchBusyIndicator.visible = true
        featuresModel.clearAll()
        for (var i=0; i<featureSearchProperties.layerProperties.length; i++) {
            var layerProperties = featureSearchProperties.layerProperties[i],
                id = layerProperties.id,
                searchFieldName = layerProperties.field.name,
                isExactMatch = layerProperties.field.exactMatch,
                layer = searchPage.getLayerById(id),
                layerServiceTable = layer.featureTable

            if (typeof layerServiceTable === "undefined") {
                continue
            }

            queryServiceTable(layerServiceTable, layer.name, searchFieldName, isExactMatch, txt)
        }
    }

    function queryServiceTable_mmpk (serviceTable, layerName, fields, isExactMatch, txt) {
        serviceTable.queryFeaturesStatusChanged.connect (function () {
            if (serviceTable.queryFeaturesStatus === Enums.TaskStatusCompleted) {

                    if(lyrNames.includes(layerName))
                    {
                        if (serviceTable.queryFeaturesResult) {

                            serviceTable.queryFeaturesResult.iterator.reset()
                            var ids=[]
                       let iterator = serviceTable.queryFeaturesResult.iterator;
                            while(iterator.hasNext){

                        let feature = iterator.next()

                         let  oid = feature.attributes.attributeValue("ObjectId")
                             if(!ids.includes(oid))
                             {
                             featuresModel.append({
                                                      "layerName": layerName,
                                                      "search_attr": feature.attributes.attributeValue("ObjectId"),
                                                      "extent": feature.geometry,
                                                      "showInView": false,
                                                      "initialIndex": featuresModel.features.length,
                                                      "hasNavigationInfo": false
                                                  })
                             featuresModel.features.push(feature)
                                 ids.push(oid)
                             }
                    }
                    searchBusyIndicator.visible = false
                    featureSearchCompleted()
                }
                   let searchlyrs = lyrNames.filter(name => name !== layerName)
                   lyrNames = searchlyrs
            }
                }
        })

        let whereClause = ""
         if (isExactMatch) {
             featureParameters.whereClause = "LOWER(%1) = LOWER('%2')".arg(searchFieldName).arg(txt)
         } else {

             fields.forEach(function(fieldname){
                let where = "(LOWER(%1) IS NOT NULL AND LOWER(%1) LIKE LOWER('%%2%'))".arg(fieldname).arg(txt)

                 if(whereClause)
                     whereClause += " OR " + where
                 else
                     whereClause = where

             }
             )

              featureParameters.whereClause = whereClause



        }

        serviceTable.queryFeatures(featureParameters)
    }

    function queryServiceTable (serviceTable, layerName, searchFieldName, isExactMatch, txt) {
        serviceTable.queryFeaturesStatusChanged.connect (function () {
            if (serviceTable.queryFeaturesStatus === Enums.TaskStatusCompleted) {
                if (serviceTable.queryFeaturesResult) {
                    while (serviceTable.queryFeaturesResult.iterator.hasNext) {
                        var feature = serviceTable.queryFeaturesResult.iterator.next(),
                                attributeNames = feature.attributes.attributeNames

                        for (var j=0; j<attributeNames.length; j++) {
                            if (attributeNames[j] === searchFieldName)
                                featuresModel.append({
                                                         "layerName": layerName,
                                                         "search_attr": feature.attributes.attributeValue(attributeNames[j]),
                                                         "extent": feature.geometry,
                                                         "showInView": false,
                                                         "initialIndex": featuresModel.features.length,
                                                         "hasNavigationInfo": false
                                                     })
                            featuresModel.features.push(feature)
                        }
                    }
                    searchBusyIndicator.visible = false
                    featureSearchCompleted()
                }
            }
        })

        if (isExactMatch) {
            featureParameters.whereClause = "LOWER(%1) = LOWER('%2')".arg(searchFieldName).arg(txt)
        } else {
            featureParameters.whereClause = "LOWER(%1) LIKE LOWER('%%2%')".arg(searchFieldName).arg(txt)
        }

        serviceTable.queryFeatures(featureParameters)
    }

    function performFeatureSearch (txt) {
        if (mapView.mmpk.loadStatus === Enums.LoadStatusLoaded) {
            searchOfflineMapFeatures(txt)
        } else {
            searchFeatures(txt)
        }
    }

    function search (txt) {
        switch (searchPage.searchTabs[swipeView.currentIndex]) {
        case app.tabNames.kPlaces:
            geocodeModel.clearAll()
            searchPlaces(txt)
            break
        case app.tabNames.kFeatures:
            performFeatureSearch(txt)
            break
        }
    }

    function displayFeatureResultsCount (count) {
        if (count) {
            if (count === 1) {
                swipeView.currentItem.item.searchViewTitleText = "%1 %2".arg(count).arg(qsTr("result found for features"))
            } else {
                swipeView.currentItem.item.searchViewTitleText = "%1 %2".arg(count).arg(qsTr("results found for features"))
            }
        } else {
            swipeView.currentItem.item.searchViewTitleText = qsTr("No results found for features")
        }
    }

    function displayPlaceResultsCount (count) {
        if (count) {
            if (count === 1) {
                swipeView.currentItem.item.searchViewTitleText = "%1 %2".arg(count).arg(qsTr("result found for places"))
            } else {
                swipeView.currentItem.item.searchViewTitleText = "%1 %2".arg(count).arg(qsTr("results found for places"))
            }
        } else {
            swipeView.currentItem.item.searchViewTitleText = qsTr("No results found for places")
        }
    }
}
