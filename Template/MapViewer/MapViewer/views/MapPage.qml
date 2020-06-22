/* Copyright 2019 Esri
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
import QtSensors 5.3
import QtPositioning 5.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import Esri.ArcGISRuntime 100.7

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0

import "../controls" as Controls

Controls.BasePage {
    id: mapPage

    property var portalItem
    property var mapProperties: Object
    property var portalItem_main
    property var mapProperties_main: Object

    readonly property string kDrawPath: qsTr("Tap on the map to draw a path.")
    readonly property string kDrawArea: qsTr("Tap on the map to draw an area.")
    readonly property string kClear: qsTr("CLEAR")
    readonly property string kDistance: qsTr("Distance")
    readonly property string kArea: qsTr("Area")
    readonly property string kMeasure: qsTr("Measure")

    property bool showMeasureTool: false
    property string captureType: "line"
    property var attachqueryno:0
    signal getAttachmentCompleted()
    property bool isAttachmentPresent:false
    property bool isGetAttachmentRunning:false
    property var mapAreasModel:ListModel{}
    property Geodatabase offlineGdb:null
    property var mapAreaslst:[]
    property var  offlineSyncTask:null
    property var offlinemapSyncJob:null
    property var existingmapareas:null
    property var updatesAvailable:false
    property bool hasMapArea:false
    property bool showUpdatesAvailable:false
    property bool isMapAreaOpened:false
    property var mapAreaGraphicsArray:[]
    property bool updateMapArea:false
    property bool comingFromMapArea:false
    property var mapAreasCount:0

    signal mapSyncCompleted(string title)




    Component.onCompleted: {
        more.updateMenuItemsContent();
    }



    onGetAttachmentCompleted: {

        identifyBtn.populateTabHeaders()
        isGetAttachmentRunning = false
    }

    Item {
        id: screenSizeState

        states: [
            State {
                name: "SMALL"
                when: !isLarge
            }
        ]

        onStateChanged: {
            more.updateMenuItemsContent()
        }
    }

    header: ToolBar {
        id: mapPageHeader

        height: app.headerHeight

        RowLayout {
            anchors {
                fill: parent
                rightMargin: app.isLandscape ? app.widthOffset: 0
                leftMargin: app.isLandscape ? app.widthOffset: 0
            }


            Controls.Icon {
                id: menuIcon
                iconSize: 6 * app.baseUnit

                //visible: !panelPage.fullView
                imageSource: mapProperties.isMapArea && portalItem_main?"../images/back.png":"../images/menu.png"

                onClicked: {
                    if(!portalItem_main)
                    {
                        //if(!mapProperties.isMapArea)
                        sideMenu.toggle()
                    }
                    else
                    {
                        comingFromMapArea = true
                        // hasMapArea = true
                        portalItem = portalItem_main
                        mapProperties = mapProperties_main
                        hasMapArea = true
                        portalItem_main = null
                        mapProperties_main = null


                        //stackView.pop()
                        //load the previous map with map area

                    }
                }
            }

            //            Controls.Icon {
            //                id: backIcon

            //                visible: panelPage.fullView
            //                imageSource: "../images/back.png"

            //                onClicked: {
            //                    panelPage.panelContent.state = "PREVIOUS_VIEW"
            //                }
            //            }


            Label{
                text:app.kMapArea
                visible:mapProperties.isMapArea !== undefined  && portalItem_main ? mapProperties.isMapArea:false
                elide: Text.ElideRight
                Layout.preferredWidth: 80 * app.scaleFactor
                font.bold: true
            }

            Controls.SpaceFiller {
            }

            RowLayout {
                id: mapTools

                visible: mapView.map ? (mapView.map.loadStatus === Enums.LoadStatusLoaded) : false
                Layout.fillHeight: true
                Layout.fillWidth: true



                Controls.Icon {
                    id: searchIcon
                    visible:(mmpk.loadStatus !== Enums.LoadStatusLoaded && mapProperties.isMapArea === undefined) || (mapProperties.isMapArea !== undefined && mapProperties.isMapArea === false)


                    imageSource: "../images/search.png"
                    checkable: true

                    onCheckedChanged: {
                        if (checked) {
                            searchPage.open()
                            toolBarBtns.uncheckAll()
                        } else {
                            searchPage.close()
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        visible: showMeasureTool
                        onClicked: {
                            parent.checked = true
                        }
                    }
                }

                ButtonGroup {
                    id: toolBarBtns

                    property string previouslyChecked

                    buttons: btns.children

                    function uncheckAll (callback) {
                        if (showMeasureTool) {
                            if (callback) callback()
                            return
                        }
                        uncheckButtons()
                        previouslyChecked = ""

                        if (panelPage.visible) {
                            if (callback) panelPage.onClosed.connect(callback)
                            panelPage.close()
                        } else if (searchPage.visible && callback) {
                            searchPage.onClosed.connect(callback)
                            searchPage.close()
                        } else if (callback) {
                            callback()
                        }

                        //if (callback) {
                        //    searchPage.onClosed.disconnect(callback)
                        //    panelPage.onClosed.disconnect(callback)
                        //}
                    }

                    function uncheckButtons () {
                        for (var i=0; i<buttons.length; i++) {
                            if (buttons[i].checked) {
                                buttons[i].checked = false
                            }
                        }
                    }

                    onClicked: {
                        if (button.objectName === previouslyChecked) {
                            uncheckAll(null)
                        }
                        previouslyChecked = button.objectName
                    }
                }

                RowLayout {
                    id: btns

                    Controls.Icon {
                        id: infoIcon

                        objectName: "info"
                        imageSource: "../images/info.png"
                        checkable: true

                        onCheckedChanged: {
                            if (checked) {
                                panelPage.hideDetailsView()
                                panelPage.headerTabNames = [app.tabNames.kInfo, app.tabNames.kLegend, app.tabNames.kContent]
                                panelPage.title = qsTr("Map details")
                                if(mapProperties.title && mapProperties.title > "")
                                {
                                    panelPage.mapTitle = mapProperties.title
                                }
                                if(mapProperties.owner && mapProperties.owner > "")
                                {
                                    panelPage.owner = mapProperties.owner
                                }
                                if(mapProperties.modifiedDate && mapProperties.modifiedDate > "")
                                {
                                    panelPage.modifiedDate = mapProperties.modifiedDate
                                }


                                panelPage.showPageCount = false
                                panelPage.show()
                            } else {
                                panelPage.hide()
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            visible: showMeasureTool
                            onClicked: {
                                parent.checked = true
                            }
                        }
                    }

                    Controls.Icon {
                        id: measureToolIcon

                        property bool previouslyCheckedByClicking: false

                        objectName: "measure"
                        imageSource: "../images/measure.png"
                        checkable: true
                        onCheckedChanged: {
                            if (checked) {
                                panelPage.hideDetailsView()
                                showMeasureTool = true
                                previouslyCheckedByClicking = false

                            } else {
                                showMeasureTool = false
                            }
                        }
                        onClicked: {
                            if (previouslyCheckedByClicking && toolBarBtns.previouslyChecked === measureToolIcon.objectName) {
                                checked = false
                            }
                            previouslyCheckedByClicking = checked
                        }
                        MouseArea {
                            anchors.fill: parent
                            visible: showMeasureTool && (lineGraphics.hasData() || areaGraphics.hasData())
                            onClicked: {
                                parent.checked = false
                            }
                        }
                    }

                    Controls.Icon {
                        id: offlineMapsIcon

                        objectName: "offlineMaps"
                        visible: offlineMaps.count > 1
                        imageSource: "../images/layers.png"
                        checkable: true

                        onCheckedChanged: {
                            if (checked) {
                                panelPage.headerTabNames = [app.tabNames.kOfflineMaps]
                                panelPage.title = qsTr("Offline Maps")
                                panelPage.showPageCount = false
                                panelPage.showFeaturesView()
                                panelPage.show()
                            } else {
                                panelPage.hide()
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            visible: showMeasureTool
                            onClicked: {
                                parent.checked = true
                            }
                        }
                    }

                    Controls.Icon {
                        id: basemapsIcon

                        objectName: "basemap"
                        imageSource: "../images/basemaps.png"
                        visible: (mmpk.loadStatus !== Enums.LoadStatusLoaded && mapProperties.isMapArea === undefined) || (mapProperties.isMapArea !== undefined && mapProperties.isMapArea === false)
                        checkable: mmpk.loadStatus !== Enums.LoadStatusLoaded

                        onCheckedChanged: {
                            if (checked) {
                                panelPage.headerTabNames = [app.tabNames.kBasemaps]
                                panelPage.title = qsTr("Basemaps")
                                panelPage.showPageCount = false
                                panelPage.showFeaturesView()
                                panelPage.show()
                            } else {
                                panelPage.hide()
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            visible: showMeasureTool
                            onClicked: {
                                parent.checked = true

                            }
                        }
                    }

                    Controls.Icon {
                        id: bookmarksIcon
                        visible:(mmpk.loadStatus !== Enums.LoadStatusLoaded && mapProperties.isMapArea === undefined) || (mapProperties.isMapArea !== undefined && mapProperties.isMapArea === false)


                        objectName: "bookmark"
                        imageSource: "../images/book.png"
                        checkable:true

                        onCheckedChanged: {
                            if (checked) {
                                panelPage.headerTabNames = [app.tabNames.kBookmarks]
                                panelPage.title = qsTr("Bookmarks")
                                panelPage.showPageCount = false
                                panelPage.showFeaturesView()
                                panelPage.show()
                            } else {
                                panelPage.hide()
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            visible:false //showMeasureTool
                            onClicked: {
                                parent.checked = true

                            }
                        }
                    }
                    Controls.Icon {
                        id: mapareasSyncIcon
                        visible:app.isOnline?(mapProperties.isMapArea?mapProperties.isMapArea:false):false

                        objectName: "updatesAvailable"
                        imageSource: "../images/available-updates-24.png"

                        MouseArea {
                            anchors.fill: parent
                            visible:true
                            onClicked: {

                                app.messageDialog.standardButtons = Dialog.Yes | Dialog.No
                                app.messageDialog.show("", qsTr("Do you want to update  %1?").arg(portalItem.title))
                                app.messageDialog.connectToAccepted(function () {
                                    mapareasbusyIndicator.visible = true
                                    checkForUpdates()
                                    //applyUpdates()
                                })



                            }
                        }
                        enabled: !mapareasbusyIndicator.visible
                        BusyIndicator {
                            id: mapareasbusyIndicator

                            visible: false

                            Material.primary: "white"//app.primaryColor
                            Material.accent: "white"//app.accentColor
                            width: app.iconSize
                            height: app.iconSize
                            anchors.centerIn: parent
                        }
                    }


                    Controls.Icon {
                        id: mapareasIcon
                        visible:mapPage.hasMapArea
                        //imageWidth: 16
                        //imageHeight: 16

                        objectName: "mapareas"
                        imageSource: "../images/download_mapArea.png"
                        checkable: true

                        onCheckedChanged: {
                            if (checked) {
                                panelPage.headerTabNames = [app.tabNames.kMapAreas]
                                panelPage.title = qsTr("Map Areas")
                                panelPage.showPageCount = false
                                panelPage.showFeaturesView()
                                panelPage.show()

                                offlineMapTask.loadUnloadedMapAreas()
                                drawMapAreas()
                            } else {
                                panelPage.hide()
                                polygonGraphicsOverlay.graphics.clear()
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            visible:true
                            onClicked: {
                                parent.checked = !parent.checked

                            }
                        }
                    }

                    Controls.Icon {
                        id: moreIcon

                        objectName: "more"
                        imageSource: "../images/more.png"
                        checkable: true
                        onCheckedChanged: {
                            if (checked) {
                                toolBarBtns.uncheckAll()
                                more.open()
                            } else {
                                more.close()
                                panelPage.hide()
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            visible: showMeasureTool
                            onClicked: {
                                parent.checked = true
                            }
                        }
                    }

                    Controls.Icon {
                        id: identifyBtn

                        visible: false // just a placeholder button
                        objectName: "identify"
                        checkable: true
                        onCheckedChanged: {
                            if (checked) {
                                if(!isGetAttachmentRunning)
                                    checkIfAttachmentPresent(0)

                            } else {
                                panelPage.hide()
                            }
                            identifyProperties.clearHighlight()
                        }

                        function checkForMedia()
                        {
                            var isMediaPresent = false
                            for(var p=0;p<mapView.identifyProperties.popupDefinitions.length;p++)
                            {
                                var mk = mapView.identifyProperties.popupDefinitions[p].media
                                if(Object.keys(mk).length > 0)
                                {
                                    isMediaPresent = true

                                    break;
                                }

                            }
                            return isMediaPresent
                        }

                        function checkRelatedRecords()
                        {
                            var relatedRecordsPresent = false

                            for(var k=0;k<mapView.identifyProperties.popupManagers.length;k++)
                            {
                                if(!relatedRecordsPresent && mapView.identifyProperties.relatedFeatures[k] && mapView.identifyProperties.relatedFeatures[k].length > 0)
                                {

                                    relatedRecordsPresent = true

                                    break;
                                }

                            }
                            return relatedRecordsPresent
                        }



                        function checkIfAttachmentPresent(featurecount)
                        {

                            isGetAttachmentRunning = true
                            var attachmentListModel = mapView.identifyProperties.features[featurecount].attachments;
                            if(attachmentListModel){
                                attachmentListModel.fetchAttachmentsStatusChanged.connect(function() {
                                    if(attachmentListModel.fetchAttachmentsStatus === Enums.TaskStatusCompleted){
                                        attachqueryno +=1
                                        //console.log("fetchAttachmentsStatus - Loaded");
                                        //console.log(attachmentListModel.count);
                                        if(attachmentListModel.count > 0)
                                        {
                                            isAttachmentPresent = true
                                            getAttachmentCompleted()
                                        }
                                        if(attachqueryno <  mapView.identifyProperties.features.length)
                                        {
                                            if (!isAttachmentPresent)
                                                checkIfAttachmentPresent(featurecount + 1)
                                        }
                                        else
                                            getAttachmentCompleted()


                                    }
                                }

                                )

                            }
                        }



                        function populateTabHeaders()
                        {
                            var tabString = app.tabNames.kFeatures
                            if(isAttachmentPresent)
                                tabString = tabString + "," + app.tabNames.kAttachments

                            var relatedRecordsPresent = checkRelatedRecords()
                            if(relatedRecordsPresent)
                                tabString = tabString + "," + app.tabNames.kRelatedRecords
                            //check for media
                            var isMediaPresent = checkForMedia()
                            if(isMediaPresent)
                                tabString = tabString + "," + app.tabNames.kMedia

                            panelPage.headerTabNames = tabString.split(",")
                            panelPage.showPageCount = true
                            panelPage.pageCount = mapView.identifyProperties.popupManagers.length
                            panelPage.showFeaturesView()
                            panelPage.show()
                        }




                    }
                }
            }

            Controls.PopupMenu {
                id: more

                property string kRefresh: qsTr("Refresh")

                defaultMargin: app.defaultMargin
                backgroundColor: "#FFFFFF"
                highlightColor: Qt.darker(app.backgroundColor, 1.1)
                textColor: app.baseTextColor
                primaryColor: app.primaryColor

                Connections {
                    target: screenSizeState

                    onStateChanged: {
                        more.updateMenuItemsContent()
                    }
                }

                menuItems: [
                    {"itemLabel": more.titleCase(app.tabNames.kMapUnits)},
                    {"itemLabel": qsTr("Graticules")},
                    //{"itemLabel": more.titleCase(kMeasure)}
                    //{"itemLabel": more.kRefresh},
                    //{"itemLabel": qsTr("Sketch")}
                ]

                Material.primary: app.primaryColor
                Material.background: backgroundColor

                height: app.units(160)

                x: parent.width - width - app.baseUnit
                y: 0 + app.baseUnit

                onMenuItemSelected: {
                    switch (itemLabel) {
                    case more.titleCase(app.tabNames.kMapUnits):
                        panelPage.headerTabNames = [app.tabNames.kMapUnits]
                        panelPage.title = qsTr("Map Units")
                        panelPage.showPageCount = false
                        panelPage.show()
                        measureToolIcon.checked = false
                        break
                    case qsTr("Graticules"):
                        panelPage.headerTabNames = [app.tabNames.kGraticules]
                        panelPage.title = qsTr("Graticules")
                        panelPage.showPageCount = false
                        panelPage.show()
                        break
                    case more.titleCase(app.tabNames.kBookmarks):
                        bookmarksIcon.checked = !bookmarksIcon.checked
                        break
                    case more.titleCase(kMeasure):
                        measureToolIcon.checked = !showMeasureTool
                        break
                    case more.kRefresh:
                        break
                    }
                }

                onVisibleChanged: {
                    if (!visible) {
                        if (!panelPage.visible) {
                            toolBarBtns.uncheckAll()
                        } else {
                        }
                    } else {
                        updateMenuItemsContent()
                        if (searchPage.opened) searchPage.close()
                    }
                }

                function updateMenuItemsContent () {
                    if (screenSizeState.state === "SMALL") {
                        if (mapView.map.bookmarks.count) {
                            more.appendUniqueItemToMenuList({"itemLabel": more.titleCase(kMeasure)})
                            more.removeItemFromMenuList({"itemLabel": more.titleCase(app.tabNames.kBookmarks)})
                            if(mapProperties.isMapArea && mapProperties.isMapArea === false)
                                bookmarksIcon.visible = true
                            measureToolIcon.visible = false
                        } else {
                            more.appendUniqueItemToMenuList({"itemLabel": more.titleCase(app.tabNames.kBookmarks)})
                            more.removeItemFromMenuList({"itemLabel": more.titleCase(kMeasure)})
                            bookmarksIcon.visible = false
                            measureToolIcon.visible = true
                        }
                    } else {
                        more.removeItemFromMenuList({"itemLabel": more.titleCase(kMeasure)})
                        more.removeItemFromMenuList({"itemLabel": more.titleCase(app.tabNames.kBookmarks)})
                        if(mapProperties.isMapArea && mapProperties.isMapArea === false)
                            bookmarksIcon.visible = true
                        measureToolIcon.visible = true
                    }
                    more.updateMenu()
                }

                function titleCase(str) {
                    return str.toLowerCase().split(" ").map(function(word) {
                        return (word.charAt(0).toUpperCase() + word.slice(1));
                    }).join(" ");
                }
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 100
            }
        }
    }

    contentItem: Rectangle {
        id: pageView

        Material.background: app.backgroundColor
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }


        PanelPage {
            id: panelPage

            property real extentFraction: 0.6

            mapView: mapView

            pageExtent: (1-extentFraction) * pageView.height

            onVisibleChanged: {
                if (!visible) {
                    if (!more.visible) {
                        toolBarBtns.uncheckAll()
                    } else {
                    }
                } else {
                    app.forceActiveFocus()
                    searchPage.close()
                }
            }

            onFullViewChanged: {
                if (measurePanel.state !== 'MEASURE_MODE') {
                    if (fullView && !isLargeScreen) {
                        mapPage.header.y = - app.headerHeight
                    } else {
                        mapPage.header.y = 0
                    }
                }
            }
        }

        MenuPage {
            id: sideMenu



            fallbackBannerImage: "../images/default-thumbnail.png"

            title: portalItem ? mapPage.portalItem.title : ""
            modified: portalItem ? mapPage.portalItem.modified : ""
            bannerImage: getThumbnailUrl()




            onMenuItemSelected: {
                switch (itemLabel) {
                case app.kBack:
                case app.kBackToGallery:


                    toolBarBtns.uncheckAll(mapPage.previous)
                    if (locationBtn.checked) locationBtn.clicked()
                    break
                }
            }

            Component.onCompleted: {
                if (app.showBackToGalleryButton) {
                    sideMenu.insertItemToMenuList(0, { "iconImage": "../images/back.png", "itemLabel": app.kBackToGallery, "control": "" })
                }
                removeItemsFromMenuListByAttribute ("itemLabel", kSignIn)
                removeItemsFromMenuListByAttribute ("itemLabel", kSignOut)
                removeItemsFromMenuListByAttribute("itemLabel", kClearCache)

                title = portalItem ? mapPage.portalItem.title : ""
                modified = portalItem ? mapPage.portalItem.modified : ""
                bannerImage = getThumbnailUrl()
            }

            function getThumbnailUrl () {
                try {
                    var url = portalItem ? mapPage.portalItem.thumbnailUrl.toString() : ""
                    if (url.startsWith("http") && portalItem ? portalItem.type === "Mobile Map Package" : false) url = offlineCache.cache(url, '', {}, null)
                    return url > "" ? url : fallbackBannerImage
                } catch (err) {
                    return fallbackBannerImage
                }
            }
        }

        SearchPage {
            id: searchPage

            mapView: mapView

            onVisibleChanged: {
                var hasPermission = Permission.checkPermission(Permission.PermissionTypeLocationWhenInUse) === Permission.PermissionResultGranted
                app.hasLocationPermission = hasPermission
                if (!visible) {
                    if (sizeState === "") { mapPage.header.y = 0 }
                    searchIcon.checked = false
                } else {
                    if (sizeState === "") { mapPage.header.y = - app.headerHeight }
                    measureToolIcon.checked = false
                }
            }

            onSizeStateChanged: {
                if (sizeState === "" && measurePanel.state !== 'MEASURE_MODE') {
                    if (!visible) {
                        mapPage.header.y = 0
                    } else {
                        mapPage.header.y = - app.headerHeight
                    }
                }
            }
        }

        MapView {
            id: mapView

            property var tasksInProgress: []
            property ListModel contentsModel_copy: ListModel {}
            property ListModel contentsModel: ListModel {}
            property ListModel contentListModel: ListModel {}
            property ListModel mapunitsListModel: ListModel {}
            property ListModel gridListModel: ListModel{}
            property ListModel unOrderedLegendInfos: Controls.CustomListModel {}
            property ListModel orderedLegendInfos: Controls.CustomListModel {} // model used in view
            property int noSwatchRequested:0
            property int noSwatchReceived:0
            property var scale:mapView.mapScale
            property int noOfFeaturesRequestReceived:0
            property int noOfFeaturesRequested:0
            property var featureTableRequestReceived:[]
            property bool isIdentifyTool:false



            property int mapReadyCount: 0
            property real initialMapRotation: 0
            property alias compass: compass
            property Point center


            property int legendProcessingCountLimit: 250

            property QtObject layersWithErrorMessages: QtObject {
                id: layersWithErrorMessages

                property var layers: []
                property var messagesRequiringLogin: [
                    "Unable to generate token.",
                    "Token Required"
                ]
                property real count: layers.length

                function clear () {
                    layers = []
                }

                function append (item) {
                    layers.push(item)
                    count += 1
                }

                onLayersChanged: {
                    count = layers.length
                }

                onCountChanged: {
                    if (count) {
                        handleErrors()
                    }
                }

                function handleErrors () {
                    for (var i=0; i<count; i++) {
                        var layerContent = layers[i]

                        if (!layerContent.verified) {

                            if (layerContent.layer.loadError) {
                                if (messagesRequiringLogin.indexOf(layerContent.layer.loadError.message) !== -1) {

                                    // Commented out because this is handled by the singleton AuthenticationManager
                                    // Mark as verified and let AuthenticationManager handle it

                                    //loginDialog.show(qsTr("Authentication required to acceess the layer %1").arg(layerContent.layer.name))
                                    //loginDialog.onAccepted.connect(function () {
                                    //    layerContent.verified = true
                                    //    return handleErrors()
                                    //})
                                    //loginDialog.onRejected.connect(function () {
                                    //    layerContent.verified = true
                                    //    return handleErrors()
                                    //})

                                    layerContent.verified = true // verified by AuthenticationManager in loginDialog
                                    return handleErrors()
                                } else if (!app.messageDialog.visible) {
                                    var title = layerContent.layer.loadError.message
                                    var message = layerContent.layer.loadError.additionalMessage
                                    if (!title || !message) {
                                        message = message ? message : title
                                        title = ""
                                    }
                                    app.messageDialog.show (title, message)
                                    app.messageDialog.connectToAccepted(function () {
                                        layerContent.verified = true
                                        return layersWithErrorMessages.handleErrors()
                                    })
                                }
                            }
                        }
                    }
                    //console.log(layers[0].layer, layers[0].verified)
                }
            }

            property QtObject identifyProperties: QtObject {
                id: identifyProperties

                property int popupManagersCount: popupManagers.length
                property int popupDefinitionsCount: popupDefinitions.length
                property int featuresCount: features.length
                property int fieldsCount: fields.length

                property var popupManagers: []
                property var popupDefinitions: []
                property var features: []
                property var fields: []
                property var temporal: []
                property var relatedFeatures:[]

                function reset () {
                    identifyProperties.clearHighlight()
                    popupManagers = []
                    popupDefinitions = []
                    features = []
                    fields = []
                    mapView.noOfFeaturesRequested = 0
                    mapView.noOfFeaturesRequestReceived = 0
                    mapView.featureTableRequestReceived = []

                    computeCounts()
                }

                function computeCounts () {
                    popupManagersCount = popupManagers.length
                    popupDefinitionsCount = popupDefinitions.length
                    featuresCount = features.length
                    fieldsCount = fields.length
                }

                function showInMap(featuregeometry,zoom)
                {
                    clearHighlight()

                    if (featuregeometry.geometryType === Enums.GeometryTypePoint) {
                        var simpleMarker = ArcGISRuntimeEnvironment.createObject("SimpleMarkerSymbol",
                                                                                 {color: "cyan", size: app.units(10),
                                                                                     style: Enums.SimpleMarkerSymbolStyleCircle}),
                        graphic = ArcGISRuntimeEnvironment.createObject("Graphic",
                                                                        {symbol: simpleMarker, geometry: featuregeometry})
                        pointGraphicsOverlay.graphics.append(graphic)
                        //mapView.setViewpointGeometryAndPadding(pointGraphicsOverlay.extent, app.units(2))
                        if (zoom) {
                            mapView.zoomToPoint(pointGraphicsOverlay.extent.center)
                        }
                        temporal.push(simpleMarker, graphic)
                    } else if (featuregeometry.geometryType === Enums.GeometryTypePolygon) {
                        simpleFillSymbol.color = "transparent"
                        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic",
                                                                            {symbol: simpleFillSymbol, geometry: featuregeometry})
                        polygonGraphicsOverlay.graphics.append(graphic)
                        //mapView.setViewpointGeometryAndPadding(polygonGraphicsOverlay.extent, app.units(100))
                        if (zoom) {
                            mapView.zoomToExtent(polygonGraphicsOverlay.extent)
                        }
                        temporal.push(graphic)
                    } else {
                        simpleFillSymbol.color = "cyan"
                        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic",
                                                                            {symbol: simpleLineSymbol, geometry: featuregeometry})
                        lineGraphicsOverlay.graphics.append(graphic)
                        //mapView.setViewpointGeometryAndPadding(lineGraphicsOverlay.extent, app.units(100))
                        if (zoom) {
                            mapView.zoomToExtent(lineGraphicsOverlay.extent)
                        }
                        temporal.push(graphic)
                    }

                }

                function highlightFeature (index, zoom) {
                    if (!zoom) zoom = false
                    if (!features.length) return

                    var feature = features[index]
                    clearHighlight()
                    showInMap(feature.geometry,zoom)


                }

                function clearHighlight (callback) {
                    if (!callback) callback = function () {}
                    pointGraphicsOverlay.graphics.clear()
                    polygonGraphicsOverlay.graphics.clear()
                    lineGraphicsOverlay.graphics.clear()
                    for (var i=0; i<temporal.length; i++) {
                        if (temporal[i]) {
                            temporal[i].destroy()
                        }
                    }
                    temporal = []
                    callback()
                }
            }

            property QtObject mapInfo: QtObject {
                id: mapInfo

                property string title: ""
                property string snippet: ""
                property string description: ""
            }

            onMapReadyCountChanged: {
                if (mapReadyCount === 1) {
                    initialMapRotation = mapRotation
                }
            }




            onMapScaleChanged:{
                if(!elapsedTimer.running)
                    elapsedTimer.start()

            }

            backgroundGrid: BackgroundGrid {
                gridLineWidth: 1
                gridLineColor: "#22000000"
            }

            Map {
                id:myWebmap
                initUrl: mapPage.portalItem.type === "Web Map" ? mapPage.portalItem.url : ""

                onLoadStatusChanged: {
                    mapView.processLoadStatusChange()
                    if(mapPage.portalItem.type === "Web Map")
                    {
                        checkExistingAreas()
                        var taskid = offlineMapTask.preplannedMapAreas();
                    }
                }

                function checkExistingAreas()
                {
                    var fileName = "mapareasinfos.json"
                    var fileContent = null

                    if (offlineMapAreaCache.fileFolder.fileExists(fileName)) {
                        fileContent = offlineMapAreaCache.fileFolder.readJsonFile(fileName)

                        var results = fileContent.results
                        existingmapareas = results.filter(item => item.mapid === mapPage.portalItem.id)
                    }
                }

                onLoadErrorChanged: {
                    mapView.processLoadErrorChange()
                }
            }

            rotationByPinchingEnabled: true
            zoomByPinchingEnabled: true
            wrapAroundMode: Enums.WrapAroundModeEnabledWhenSupported
            anchors.fill: parent

            ColumnLayout {
                id: mapControls

                property real radius: 0.5 * app.mapControlIconSize

                height: 3 * width
                width: mapControls.radius + app.defaultMargin
                anchors {
                    top: undoRedoDraw.bottom
                    right: parent.right
                    margins: app.defaultMargin
                    rightMargin: app.isLandscape ? app.widthOffset +  app.defaultMargin : app.defaultMargin
                }

                RoundButton {
                    radius: mapControls.radius
                    opacity: mapView.mapRotation ? 1 : 0
                    rotation: mapView.mapRotation
                    Material.background: "transparent"//"#FFFFFF"
                    Layout.preferredWidth: 2 * mapControls.radius
                    Layout.preferredHeight: Layout.preferredWidth
                    contentItem: Image {
                        id: compassImg
                        source: "../images/compass.png"
                        anchors {
                            fill: parent
                            margins: 0.4 * parent.padding
                        }
                        mipmap: true
                    }
                    onClicked: {
                        mapView.setViewpointRotation(mapView.initialMapRotation)
                    }
                }

                RoundButton {
                    radius: mapControls.radius
                    Material.background: "#FFFFFF"
                    Layout.preferredWidth: 2 * mapControls.radius
                    Layout.preferredHeight: Layout.preferredWidth
                    contentItem: Image {
                        id: homeImg
                        source: "../images/home.png"
                        width: mapControls.radius
                        height: mapControls.radius
                        mipmap: true
                    }
                    ColorOverlay{
                        anchors.fill: homeImg
                        source: homeImg
                        color: "#4c4c4c"
                    }
                    onClicked: {
                        mapView.setViewpointWithAnimationCurve(mapView.map.initialViewpoint, 2.0, Enums.AnimationCurveEaseInOutCubic)
                        //toolBarBtns.uncheckAll()
                    }
                }

                RoundButton {
                    id: locationBtn

                    radius: mapControls.radius
                    Material.background: "#FFFFFF"
                    Layout.preferredWidth: 2 * mapControls.radius
                    Layout.preferredHeight: Layout.preferredWidth
                    checkable: true

                    contentItem: Image {
                        id: locationImg
                        source: "../images/location.png"
                        width: mapControls.radius
                        height: mapControls.radius
                        mipmap: true
                    }
                    ColorOverlay{
                        anchors.fill: locationImg
                        source: locationImg
                        color: devicePositionSource.active && locationBtn.checked ? "steelBlue" : "#4c4c4c"
                    }
                    onClicked: {

                        if(!((Qt.platform.os === "ios") || (Qt.platform.os == "android")))

                            mapView.zoomToLocation()
                        else
                        {
                            if (Permission.checkPermission(Permission.PermissionTypeLocationWhenInUse) === Permission.PermissionResultGranted)
                            {

                                mapView.zoomToLocation()

                            }
                            else
                            {

                                permissionDialog.permission = PermissionDialog.PermissionDialogTypeLocationWhenInUse;
                                permissionDialog.open()

                            }
                        }




                    }
                }
            }

            function zoomToLocation()
            {
                if (!mapView.locationDisplay.started) {

                    mapView.locationDisplay.start()
                    mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeRecenter
                }
                else {
                    mapView.locationDisplay.stop()
                }
            }

            PermissionDialog {
                id:permissionDialog
                openSettingsWhenDenied: true

                onRejected:{


                }
                onAccepted:{

                }


            }

            locationDisplay {
                positionSource: PositionSource {
                    id: devicePositionSource
                }
                compass: Compass {
                    id: compass
                }
                //autoPanMode: Enums.LocationDisplayAutoPanModeRecenter
            }

            SimpleFillSymbol {
                id: simpleFillSymbol
                color: "transparent"
                style: Enums.SimpleFillSymbolStyleSolid

                SimpleLineSymbol {
                    style: Enums.SimpleLineSymbolStyleSolid
                    color: "cyan"
                    width: app.units(2)
                }
            }
            SimpleFillSymbol {
                id: simpleMapAreaFillSymbol
                color: "transparent"
                style: Enums.SimpleFillSymbolStyleSolid

                SimpleLineSymbol {
                    style: Enums.SimpleLineSymbolStyleSolid
                    color: "brown"
                    width: app.units(2)
                }
            }

            SimpleLineSymbol {
                id: simpleLineSymbol

                style: Enums.SimpleLineSymbolStyleSolid
                color: "cyan"
                width: app.units(2)
            }

            GraphicsOverlay{
                id: polygonGraphicsOverlay
            }

            GraphicsOverlay{
                id: pointGraphicsOverlay
            }

            GraphicsOverlay {
                id: lineGraphicsOverlay
            }

            GraphicsOverlay {
                id: placeSearchResult
                SimpleRenderer {
                    PictureMarkerSymbol{
                        width: app.units(32)
                        height: app.units(32)
                        url: "../images/pin.png"
                    }
                }
            }

            Timer{
                id:elapsedTimer
                interval:500
                repeat:true
                onTriggered:mapView.isZooming()
            }


            function isZooming()
            {
                if(mapView.mapScale !== scale)
                    scale = mapView.mapScale
                else
                {
                    elapsedTimer.stop()
                    sortLegendContentByLyrIndex()

                }

                //scale = mapView.mapScale

                //sortLegendContentByLyrIndex()
            }

            function updateContentListModel(layer, checked)
            {
                for(var k=0;k<mapView.contentListModel.count;k++)
                {
                    var item = mapView.contentListModel.get(k)
                    if(item.name === layer.name)
                    {
                        mapView.contentListModel.set(k,{"checkBox":checked})
                        break;
                    }
                }
            }

            function processLoadStatusChange () {
                switch (mapView.map.loadStatus) {
                case Enums.LoadStatusLoaded:
                    mapView.updateLayers()
                    mapView.updateMapInfo()
                    mapView.mapReadyCount += 1
                    if (app.isLarge && app.isLandscape && mapView.mapReadyCount <= 1) {
                        infoIcon.checked = true
                    }
                    if (mapView.map) {
                        var mapExtent = ArcGISRuntimeEnvironment.createObject("EnvelopeBuilder", { geometry: mapView.map.initialViewpoint.extent })
                        mapView.center = mapExtent.center
                    }

                    if (mmpk.locatorTask) {
                        mmpk.locatorTask.onLoadStatusChanged.connect(function () {
                            if (mmpk.locatorTask.loadStatus === Enums.LoadStatusLoaded) {
                                if (mmpk.locatorTask.suggestions) {
                                    mmpk.locatorTask.suggestions.suggestParameters = ArcGISRuntimeEnvironment.createObject("SuggestParameters", { maxResults: 10, preferredSearchLocation: mapView.center })
                                }
                            }
                        })
                        mmpk.locatorTask.load()
                    }
                    measurePanel.setUnitByScale(mapView.mapScale)
                    more.updateMenuItemsContent()
                    break
                }
            }

            function processLoadErrorChange () {
                app.messageDialog.connectToAccepted(function () {
                    if (mapView) {
                        if (mapView.map.loadStatus !== Enums.loadStatusLoaded) {
                            previous()
                        }
                    }
                })
                var title = mapView.map.loadError.message
                var message = mapView.map.loadError.additionalMessage
                if (!title || !message) {
                    message = message ? message : title
                    title = ""
                }
                app.messageDialog.show (title, message)
            }

            /*
              This sorting functionality is new in version 4.1. Since the layers can load in any order
              we need to sort the layers based on the order they are added to the map.
              In addition we need to  also sort the legend based on legend index.


              */

            function sortAndAddLegendForLayer(layer1,isSublayer,rootLayerName){
                var legendArray = []
                for(var k=0;k<unOrderedLegendInfos.count;k++)
                {
                    var item = unOrderedLegendInfos.get(k)
                    if(isSublayer)
                    {
                        if(layer1.sublayerId)
                        {
                            if (item.layerName === layer1.name && parseInt(item.layerIndex) === parseInt(layer1.sublayerId))
                            {
                                legendArray.push(item)
                            }
                        }
                        else
                        {
                            if ((item.layerName === layer1.name) && (item.rootLayerName === rootLayerName))
                            {
                                legendArray.push(item)
                            }
                        }
                    }
                    else
                    {
                        if (item.layerName === layer1.name)
                        {
                            legendArray.push(item)
                        }
                    }
                }
                legendArray.sort((a, b) => (a.legendIndex > b.legendIndex) ? 1 : -1)
                legendArray.forEach(function(element){
                    orderedLegendInfos.append(element)
                })

            }

            function updateLegendInfos () {
                // sortLegendInfosByLyrIndex()

                /*if (mapView.map.legendInfos.count > mapView.legendProcessingCountLimit) return mapView.map.legendInfos
                mapView.orderedLegendInfos.clear()
                for (var i=mapView.map.operationalLayers.count; i--;) {
                    var lyr = mapView.map.operationalLayers.get(i)
                    if (!lyr.visible || !lyr.showInLegend) continue
                    var other = null
                    for (var j=0; j<lyr.legendInfos.count; j++) {
                        var ol = lyr.legendInfos.get(j)
                        var ul = mapView.unOrderedLegendInfos.getItemByAttributes({"name": ol.name, "layerIndex": i})
                        if (["Other", "other"].indexOf(ol.name) !== -1) {
                            other = ul
                            continue
                        }
                        if (ul) mapView.orderedLegendInfos.addIfUnique(ul, "uid")
                    }
                    if (other) mapView.orderedLegendInfos.addIfUnique(other, "uid")
                }
                return mapView.orderedLegendInfos*/
            }


            /* This function is modified in version 4.1 as sometimes the grouped layers can take some time to load
              This was causing the legend to show sometimes in random order.

              */

            function updateLayers () {
                mapView.contentListModel.clear()
                mapView.layersWithErrorMessages.clear()
                mapView.procLayers()
                /*mapView.procLayers(null, function () {
                    if (mapView.map.legendInfos.count <= mapView.legendProcessingCountLimit) {
                        mapView.fetchAllLegendInfos()
                    }
                })*/
            }

            function fetchAllLegendInfos () {
                mapView.unOrderedLegendInfos.clear()
                for (var i=mapView.map.operationalLayers.count; i--;) {
                    var lyr = mapView.map.operationalLayers.get(i)
                    mapView.fetchLegendInfos(lyr, i)
                }
            }

            function fetchLegendInfos (lyr,layerIndex,rootLayerName,rootLayerIndex) {
                lyr.legendInfos.fetchLegendInfosStatusChanged.connect(function () {
                    switch (lyr.legendInfos.fetchLegendInfosStatus) {
                    case Enums.TaskStatusCompleted:
                        fetchLayerLegends(lyr, layerIndex,rootLayerName,rootLayerIndex)
                    }
                })
                lyr.legendInfos.fetchLegendInfos(true)
            }

            function fetchLayerLegends (lyr, layerIndex,rootLayerName,rootLayerIndex) {
                for (var i=0; i<lyr.legendInfos.count; i++) {
                    if(lyr.sublayerId)
                        layerIndex = lyr.sublayerId
                    mapView.noSwatchRequested ++
                    createSwatchImage(lyr.legendInfos.get(i), lyr.name, i, layerIndex,rootLayerName,rootLayerIndex)
                }
            }

            /*
              This function is modified in  version 4.1 to sort the legend after we get the image.

              */
            function createSwatchImage(legend, layerName, legendIndex, layerIndex,rootLayerName,rootLayerIndex) {

                var sym = legend.symbol
                sym.swatchImageChanged.connect(function () {
                    if (sym.swatchImage) {
                        var uid = ""
                        if(layerName !== rootLayerName)
                            uid = rootLayerName + "_" + layerName + "_" + layerIndex + "_" + legendIndex
                        else
                            uid = layerName + "_" + legendIndex
                        //console.log("uid of symbol" + uid)
                        mapView.unOrderedLegendInfos.addIfUnique(
                                    {
                                        "uid": uid,
                                        "legendIndex": legendIndex,
                                        "layerIndex": parseInt(layerIndex),
                                        "layerName": layerName,
                                        "name": legend.name,
                                        "symbolUrl": sym.swatchImage.toString(),
                                        "rootLayerName":rootLayerName,
                                        "rootLayerIndex":rootLayerIndex,

                                        "displayName":rootLayerName?"<b>"+ rootLayerName + "</b>" + "<br/>" +  layerName:layerName

                                    }, "uid")
                        mapView.noSwatchReceived++



                    }
                })
                sym.createSwatch()
            }

            function zoomToPoint (point, scale) {
                if (!scale) scale = 10000
                var centerPoint = GeometryEngine.project(point, mapView.spatialReference)
                var viewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter", {center: centerPoint, targetScale: scale})
                mapView.setViewpointWithAnimationCurve(viewPointCenter, 0.0, Enums.AnimationCurveEaseInOutCubic)
            }

            function zoomToExtent (extent) {
                var json = extent.json
                json.ymax = extent.yMax + 1000.0
                json.xmax = extent.xMax + 1000.0
                json.ymin = extent.yMin - 1000.0
                json.xmin = extent.xMin - 1000.0
                var envelope = ArcGISRuntimeEnvironment.createObject("Envelope", {json: json})
                var viewPointExtent = ArcGISRuntimeEnvironment.createObject("ViewpointExtent", {extent: envelope})
                mapView.setViewpointWithAnimationCurve(viewPointExtent, 0.0, Enums.AnimationCurveEaseInOutCubic)
            }

            function showPin (point) {
                hidePin(function () {
                    var pictureMarkerSymbol = ArcGISRuntimeEnvironment.createObject("PictureMarkerSymbol", {width: app.units(32), height: app.units(32), url: "../images/pin.png"})
                    var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: point})
                    placeSearchResult.visible = true
                    placeSearchResult.graphics.insert(0, graphic)
                })
            }

            function hidePin (callback) {
                placeSearchResult.visible = false
                placeSearchResult.graphics.remove(0, 1)
                if (callback) callback()
            }

            //-------------------------MEASURE TOOL-------------------------------------------------------------

            property color measureSymbolColor: measurePanel.colorObject ? measurePanel.colorObject.colorName : "#F89927"
            property color measureSymbolColorAlpha: measurePanel.showFillColor ? (measurePanel.colorObject ? measurePanel.colorObject.alpha : "#59F89927") : "transparent"

            GraphicsOverlay {
                id: labels

                visible: measurePanel.showSegmentLength && lineGraphics.visible
                labelsEnabled: true

                onComponentCompleted: {
                    var textSymbol = ArcGISRuntimeEnvironment.createObject("TextSymbol", {size: app.baseFontSize, backgroundColor: app.backgroundColor, color: app.baseTextColor})
                    var textSymbolJSON = textSymbol.json
                    var pointLabelDefinitionJSON = {"labelExpressionInfo" : {"expression" : "$feature.length"}, "labelPlacement": "esriServerLinePlacementAboveAlong", "symbol": textSymbolJSON}
                    var pointLabelDefinition = ArcGISRuntimeEnvironment.createObject("LabelDefinition", {json: pointLabelDefinitionJSON})
                    labelDefinitions.append(pointLabelDefinition)
                }
            }

            GraphicsOverlay {
                id: lineGraphics

                property bool isUndoable: done.length > 0
                property bool isRedoable: unDone.length > 0

                // list of points
                property var done: []
                property var unDone: []

                function hasData () {
                    return done.length || unDone.length
                }

                function add (item, clearHistory) {
                    done.push(item)
                    if (clearHistory) unDone = []
                    recount()
                }

                function remove () {
                    unDone.push(done.pop())
                    recount()
                }

                function reset () {
                    done = []
                    unDone = []
                    recount()
                }

                function recount () {
                    isUndoable = done.length > 0
                    isRedoable = unDone.length > 0
                }

                visible: captureType === "line" && (measureToolIcon.checked || measurePanel.state !== "MEASURE_MODE")
            }

            GraphicsOverlay{
                id: areaGraphics

                property bool isUndoable: done.length > 0
                property bool isRedoable: unDone.length > 0

                // list of points
                property var done: []
                property var unDone: []

                function hasData () {
                    return done.length || unDone.length
                }

                function add (item, clearHistory) {
                    done.push(item)
                    if (clearHistory) unDone = []
                    recount()
                }

                function remove () {
                    unDone.push(done.pop())
                    recount()
                }

                function reset () {
                    done = []
                    unDone = []
                    recount()
                }

                function recount () {
                    isUndoable = done.length > 0
                    isRedoable = unDone.length > 0
                }

                visible: captureType === "area" && (measureToolIcon.checked || measurePanel.state !== "MEASURE_MODE")
            }

            PolylineBuilder {
                id: polylineBuilder
                spatialReference: mapView.spatialReference
            }

            PolygonBuilder {
                id: polygonBuilder
                spatialReference: mapView.spatialReference
            }

            SimpleFillSymbol {
                id: fillSymbol
                color: mapView.measureSymbolColorAlpha
                style: Enums.SimpleFillSymbolStyleSolid

                SimpleLineSymbol {
                    style: Enums.SimpleLineSymbolStyleSolid
                    color: mapView.measureSymbolColor
                    width: app.units(4)
                }
            }

            SimpleLineSymbol {
                id: lineSymbol
                color: mapView.measureSymbolColor
                style: Enums.SimpleLineSymbolStyleSolid
                width: app.units(4)
            }

            SimpleMarkerSymbol {
                id: measurePointSymbol
                color: mapView.measureSymbolColor
                style: Enums.SimpleMarkerSymbolStyleCircle
                size: 8
            }

            SimpleMarkerSymbol {
                id: primaryColorSymbol
                color: mapView.measureSymbolColor
                style: Enums.SimpleMarkerSymbolStyleCircle
                size: 12
                outline: SimpleLineSymbol {
                    style: Enums.SimpleLineSymbolStyleSolid
                    color: "#FFFFFF"
                    width: app.units(2)
                }
            }

            function redoGraphic () {
                var point
                if (captureType === "line" && lineGraphics.isRedoable) {
                    point = lineGraphics.unDone.pop()
                    addPointToPolyline(point, false)
                    drawPoint(point, lineGraphics)
                    lineGraphics.recount()
                } else if (captureType === "area" && areaGraphics.isRedoable) {
                    point = areaGraphics.unDone.pop()
                    addPointToPolygon(point, false)
                    drawPoint(point, areaGraphics)
                    areaGraphics.recount()
                }
            }

            function undoPolyline(graphicOverlay){
                var polylinePart = polylineBuilder.parts.part(0);
                polylinePart.removePoint(polylinePart.pointCount-1, 1);
                var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {symbol: lineSymbol, geometry: polylineBuilder.geometry, zIndex: 1});
                graphicOverlay.graphics.remove(0, 1);
                graphicOverlay.graphics.insert(0, graphic);

                var previousPoint = graphicOverlay.graphics.get(graphicOverlay.graphics.count-3);
                var previousGeometry = previousPoint.geometry;
                var newPointGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {symbol: primaryColorSymbol, geometry: previousGeometry, zIndex: 3});
                graphicOverlay.graphics.remove(graphicOverlay.graphics.count-1,1);
                graphicOverlay.graphics.remove(graphicOverlay.graphics.count-1,1);
                graphicOverlay.graphics.append(newPointGraphic);

                graphicOverlay.remove()
                labels.graphics.remove(labels.graphics.count - 1)
                measurePanel.value = mapView.getDetailValue();
            }

            function undoPolygon(graphicOverlay){
                var polygonPart = polygonBuilder.parts.part(0);
                polygonPart.removePoint(polygonPart.pointCount-1, 1);
                var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {symbol: fillSymbol, geometry: polygonBuilder.geometry, zIndex: 1});
                graphicOverlay.graphics.remove(0, 1);
                graphicOverlay.graphics.insert(0, graphic);

                var previousPoint = graphicOverlay.graphics.get(graphicOverlay.graphics.count-3);
                var previousGeometry = previousPoint.geometry;
                var newPointGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {symbol: primaryColorSymbol, geometry: previousGeometry, zIndex: 3});
                graphicOverlay.graphics.remove(graphicOverlay.graphics.count-1,1);
                graphicOverlay.graphics.remove(graphicOverlay.graphics.count-1,1);
                graphicOverlay.graphics.append(newPointGraphic);

                graphicOverlay.remove()
                measurePanel.value = mapView.getDetailValue();
            }

            function resetMeasureTool () {
                polylineBuilder.parts.removeAll()
                lineGraphics.graphics.clear()
                lineGraphics.reset()
                labels.graphics.clear()
                polygonBuilder.parts.removeAll()
                areaGraphics.graphics.clear()
                areaGraphics.reset()
                measurePanel.value = 0
            }

            function clearGraphics(){
                labels.graphics.clear()
                if (captureType === "line") {
                    polylineBuilder.parts.removeAll();
                    lineGraphics.graphics.clear();
                    lineGraphics.reset()
                } else if (captureType === "area") {
                    polygonBuilder.parts.removeAll();
                    areaGraphics.graphics.clear()
                    areaGraphics.reset()
                }
                if (measurePanel.value === 0) {
                    measurePanel.mUnit.updateDistance()
                    measurePanel.mUnit.updateArea()
                } else {
                    measurePanel.value = 0;
                }
            }

            function draw (mouse) {
                if (captureType === "line"){
                    addPointToPolyline(mapView.screenToLocation(mouse.x, mouse.y), true);
                    drawPoint(mapView.screenToLocation(mouse.x, mouse.y), lineGraphics);
                } else if(captureType === "area") {
                    addPointToPolygon(mapView.screenToLocation(mouse.x, mouse.y), true);
                    drawPoint(mapView.screenToLocation(mouse.x, mouse.y), areaGraphics);
                }
            }

            function getMidPoint (p1, p2) {
                var x1 = p1.x
                var y1 = p1.y
                var x2 = p2.x
                var y2 = p2.y
                var Xmid = (x1+x2)/2
                var Ymid = (y1+y2)/2
                return ArcGISRuntimeEnvironment.createObject("Point", {x:Xmid, y:Ymid, spatialReference:mapView.spatialReference})
            }

            function addPointToPolyline (point, clearHistory) {
                lineGraphics.add(point, clearHistory)
                if(polylineBuilder.parts.empty || polylineBuilder.empty) {
                    var part = ArcGISRuntimeEnvironment.createObject("Part");
                    part.spatialReference = mapView.spatialReference;
                    var pCollection = ArcGISRuntimeEnvironment.createObject("PartCollection");
                    pCollection.spatialReference = mapView.spatialReference;
                    pCollection.addPart(part);
                    polylineBuilder.parts = pCollection;
                }
                point = GeometryEngine.project(point, polylineBuilder.spatialReference);

                //devicePositionSource.active = false
                var polylinePart = polylineBuilder.parts.part(0);

                if (polylinePart.pointCount) {
                    var p1 = polylinePart.point(polylinePart.pointCount-1)
                    var midPoint = getMidPoint (point, p1)
                    var simpleMarker = ArcGISRuntimeEnvironment.createObject("SimpleMarkerSymbol", {color: "transparent", size: 1, style: Enums.SimpleMarkerSymbolStyleCircle});
                    var labelGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: midPoint, symbol:simpleMarker, zIndex: 1})
                    var length = getDistance(p1, point)
                    labelGraphic.attributes.attributesJson = {"length": measurePanel.convert(length), "meters": length, "id": labels.graphics.count}
                    labels.graphics.append(labelGraphic)
                }

                polylinePart.addPoint(point);
                var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {symbol: lineSymbol, geometry: polylineBuilder.geometry, zIndex: 1});
                lineGraphics.graphics.remove(0, 1);
                lineGraphics.graphics.insert(0, graphic);

                measurePanel.value = mapView.getDetailValue();
            }

            function updateSegmentLengths () {
                labels.graphics.clear()
                for (var i=1; i<lineGraphics.done.length; i++) {
                    var p1 = lineGraphics.done[i-1]
                    var p2 = lineGraphics.done[i]
                    var length = getDistance(p1, p2)
                    var midPoint = getMidPoint(p1, p2)
                    var simpleMarker = ArcGISRuntimeEnvironment.createObject("SimpleMarkerSymbol", {color: "transparent", size: 1, style: Enums.SimpleMarkerSymbolStyleCircle});
                    var labelGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: midPoint, symbol:simpleMarker, zIndex: 1})
                    labelGraphic.attributes.attributesJson = {"length": measurePanel.convert(length), "meters": length, "id": labels.graphics.count}
                    labels.graphics.append(labelGraphic)
                }
            }

            function getDistance (p1, p2) {
                var results = GeometryEngine.distanceGeodetic(p1, p2, Enums.LinearUnitIdMeters, Enums.AngularUnitIdDegrees, Enums.GeodeticCurveTypeGeodesic)
                return results.distance
            }

            function drawPoint(point, graphicOverlay){
                var oldPointGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {symbol: measurePointSymbol, geometry: point, zIndex: 2});
                var newPointGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {symbol: primaryColorSymbol, geometry: point, zIndex: 3});
                var graphicsCount = graphicOverlay.graphics.count;
                if(graphicsCount>=3)graphicOverlay.graphics.remove(graphicsCount-1, 1);
                graphicOverlay.graphics.append(oldPointGraphic);
                graphicOverlay.graphics.append(newPointGraphic);
            }

            function addPointToPolygon(point, clearHistory){
                areaGraphics.add(point, clearHistory)
                if(polygonBuilder.parts.empty) {
                    var part = ArcGISRuntimeEnvironment.createObject("Part");
                    part.spatialReference = mapView.spatialReference;
                    var pCollection = ArcGISRuntimeEnvironment.createObject("PartCollection");
                    pCollection.spatialReference = mapView.spatialReference;
                    pCollection.addPart(part);
                    polygonBuilder.parts = pCollection;
                }

                //devicePositionSource.active = false
                point = GeometryEngine.project(point, polygonBuilder.spatialReference);

                var polygonPart = polygonBuilder.parts.part(0);

                polygonPart.addPoint(point);
                var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {symbol: fillSymbol, geometry: polygonBuilder.geometry, zIndex: 1});
                areaGraphics.graphics.remove(0, 1);
                areaGraphics.graphics.insert(0, graphic);

                measurePanel.value = mapView.getDetailValue();
            }

            function getDetailValue () {
                if (!mapView.map) return "";
                var center = (mapView.currentViewpointCenter && mapView.currentViewpointCenter && mapView.map.loadStatus === Enums.LoadStatusLoaded) ?
                            CoordinateFormatter.toLatitudeLongitude(mapView.currentViewpointCenter.center, Enums.LatitudeLongitudeFormatDecimalDegrees, 3)
                          : "";//qsTr("No Location Available.");
                if(captureType === "line"){
                    try { return polylineBuilder.geometry? Math.abs(GeometryEngine.lengthGeodetic(polylineBuilder.geometry, Enums.LinearUnitIdMeters, Enums.GeodeticCurveTypeGeodesic)):0;
                    } catch (err) {}
                } else if(captureType === "area"){
                    try { return polygonBuilder.geometry? Math.abs(GeometryEngine.areaGeodetic(polygonBuilder.geometry, Enums.AreaUnitIdSquareMeters, Enums.GeodeticCurveTypeGeodesic)):0;
                    } catch (err) {}
                }
                return 0//center + ""
            }

            Controls.Tooltip {
                id: mapunitsLabel

                visible: false
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    margins: app.baseUnit
                }
            }

            Controls.Tooltip {
                id: measureToolTip

                visible: measureToolIcon.checked && (captureType === "line" && lineGraphics.graphics.count === 0 || captureType === "area" && areaGraphics.graphics.count === 0)
                text: captureType === "line" ? kDrawPath : kDrawArea
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    margins: app.baseUnit
                }
            }

            Pane {
                id: undoRedoDraw

                visible: measureToolIcon.checked && !measureToolTip.visible
                padding: 0
                leftPadding: app.defaultMargin
                rightPadding: app.defaultMargin
                width: 2*app.iconSize + clearText.contentWidth + 2*app.defaultMargin
                height: (2/3) * app.headerHeight
                Material.elevation: 4
                Material.background: "#FFFFFF"
                anchors {
                    right: parent.right
                    top: parent.top
                    topMargin: app.baseUnit
                    rightMargin: app.defaultMargin
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Controls.BaseText {
                        id: clearText
                        text: kClear
                        Layout.rightMargin: app.defaultMargin
                        verticalAlignment: Text.AlignVCenter
                        Layout.maximumWidth: (2/5) * parent.width
                        //Controls.Debug{}
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                mapView.clearGraphics()
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: parent.height - 2*app.baseUnit
                        Layout.preferredWidth: app.units(2)
                        color: app.backgroundColor
                    }

                    Controls.Icon {
                        //Controls.Debug{}
                        imageSource: "../images/undo.png"
                        Layout.leftMargin: app.baseUnit
                        maskColor: {
                            if (captureType === "line") {
                                return lineGraphics.isUndoable ? app.darkIconMask : Qt.lighter(app.darkIconMask, 2.5)
                            } else if (captureType === "area") {
                                return areaGraphics.isUndoable ? app.darkIconMask : Qt.lighter(app.darkIconMask, 2.5)
                            }
                        }
                        imageWidth: 0.7 * iconSize
                        imageHeight: 0.7 * iconSize
                        iconSize: 0.8 * app.iconSize-undoRedoDraw.topPadding-undoRedoDraw.bottomPadding
                        onClicked: {
                            if (captureType === "line" && lineGraphics.isUndoable) {
                                mapView.undoPolyline(lineGraphics)
                            } else if (captureType === "area" && areaGraphics.isUndoable) {
                                mapView.undoPolygon(areaGraphics)
                            }
                        }
                    }

                    Controls.Icon {
                        //Controls.Debug{}
                        imageSource: "../images/redo.png"
                        maskColor: {
                            if (captureType === "line") {
                                return lineGraphics.isRedoable ? app.darkIconMask : Qt.lighter(app.darkIconMask, 2.5)
                            } else if (captureType === "area") {
                                return areaGraphics.isRedoable ? app.darkIconMask : Qt.lighter(app.darkIconMask, 2.5)
                            }
                        }
                        imageWidth: 0.7 * iconSize
                        imageHeight: 0.7 * iconSize
                        iconSize: 0.8 * app.iconSize-undoRedoDraw.topPadding-undoRedoDraw.bottomPadding
                        onClicked: {
                            mapView.redoGraphic()
                        }
                    }
                }
            }

            RoundButton {
                id: identifyModeSwitch

                visible: (measureToolIcon.checked || measurePanel.isIdentifyMode) && (lineGraphics.hasData() || areaGraphics.hasData()) && !measureToast.visible
                radius: mapControls.radius
                Material.background: "#FFFFFF"
                width: 2 * mapControls.radius
                height: width
                anchors {
                    right: parent.right
                    bottom: locationAccuracy.visible ? locationAccuracy.top : parent.bottom
                    bottomMargin: locationAccuracy.visible ? measurePanel.defaultMargin : measurePanel.defaultHeight + app.defaultMargin
                    rightMargin: app.isLandscape ? app.widthOffset +  app.defaultMargin : app.defaultMargin
                }
                contentItem: Image {

                    id: identifyModeImg
                    source: "../images/rotate.png"
                    width: mapControls.radius
                    height: mapControls.radius
                    mipmap: true
                }
                ColorOverlay{
                    anchors.fill: identifyModeImg
                    source: identifyModeImg
                    color: "#4c4c4c"
                }
                onClicked: {
                    if (measurePanel.isIdentifyMode) {
                        measureToolIcon.checked = true
                        measureToast.show(qsTr("Switched to measure mode."), parent.height-measureToast.height-measurePanel.height+app.baseUnit, 1500)
                    } else {
                        measurePanel.isIdentifyMode = !measurePanel.isIdentifyMode
                        measureToast.show(qsTr("Switched to identify mode."), parent.height-measureToast.height-measurePanel.height-app.baseUnit, 1500)
                    }
                }
            }

            //-------------------------------------------------------------------------------------------------------

            Pane {
                id: locationAccuracy

                property string distanceUnit: Qt.locale().measurementSystem === Locale.MetricSystem ? "m" : "ft"
                property real accuracy: Qt.locale().measurementSystem === Locale.MetricSystem ? devicePositionSource.position.horizontalAccuracy : 3.28084 * devicePositionSource.position.horizontalAccuracy
                property real threshold: Qt.locale().measurementSystem === Locale.MetricSystem ? (50/3.28084) : 50

                visible: devicePositionSource.active && devicePositionSource.position.horizontalAccuracyValid && locationBtn.checked

                padding: 0
                Material.elevation: app.baseElevation + 2
                width: accuracyLabel.contentWidth + app.defaultMargin/2
                height: accuracyLabel.height
                background: Rectangle {
                    radius: app.units(1)
                    color: locationAccuracy.accuracy <= locationAccuracy.threshold ? "green" : "red"
                }
                anchors {
                    bottom: !app.isLarge && measurePanel.visible ? measurePanel.top : parent.bottom
                    right: parent.right
                    rightMargin: app.defaultMargin + app.widthOffset
                    bottomMargin: app.defaultMargin + app.heightOffset + app.baseUnit
                }

                Controls.BaseText {
                    id: accuracyLabel

                    anchors.centerIn: parent
                    height: contentHeight
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: "#FFFFFF"
                    text: "±%L1 %L2".arg(locationAccuracy.accuracy.toFixed(1)).arg(locationAccuracy.distanceUnit)
                    fontSizeMode: Text.HorizontalFit
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    onClicked: {
                        mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeRecenter
                    }
                }
            }

            //-------------------------------------------------------------------------------------------------------

            RadioButton {
                id: screenShotThumbnail

                property real aspectRatio: 96/80

                Material.elevation: app.baseElevation + 2
                visible: measurePanel.state === "MEASURE_MODE" && screenShotsView.screenShots.count
                height: app.units(88)
                width: Math.max(height*aspectRatio, app.units(96))
                anchors {
                    left: parent.left
                    bottom: measurePanel.top
                    margins: app.defaultMargin
                    leftMargin: app.isLandscape ? app.widthOffset +  app.defaultMargin : app.defaultMargin
                }

                indicator: Rectangle {
                    anchors.fill: parent
                    color: app.darkIconMask
                    Image {
                        anchors {
                            fill: parent
                            margins: 1
                        }
                        opacity: 0.8
                        fillMode: Image.PreserveAspectFit
                        source: {
                            var idx = screenShotsView.listView.currentIndex > -1 ? screenShotsView.listView.currentIndex : 0
                            var item = screenShotsView.screenShots.get(idx)
                            return screenShotsView.screenShots.count && item ? item.url : ""
                        }
                    }
                    Controls.SubtitleText {
                        id: screenShotCount

                        background: Rectangle {
                            anchors.centerIn: parent
                            width: height
                            radius: height/2
                            color: "#000000"
                            opacity: 0.4
                        }

                        visible: screenShotsView.screenShots.count
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        anchors.centerIn: parent
                        text: screenShotsView.screenShots.count
                        font.bold: true
                        color: "#FFFFFF"
                    }
                }

                onCheckedChanged: {
                    if (checked) {
                        screenShotsView.open()
                    } else {
                        screenShotsView.close()
                    }
                }

                Component.onCompleted: {
                    aspectRatio = mapView.width/mapView.height
                }
            }

            ScreenShotsView {
                id: screenShotsView

                mapView: mapView
                onClosed: {
                    screenShotThumbnail.checked = false
                }

                onScreenShotTaken: {
                    measureToast.show(qsTr("Screenshot captured."), parent.height-measureToast.height-measurePanel.height, 1500)
                }
            }

            MeasurePanel {
                id: measurePanel

                onCameraClicked: {
                    screenShotsView.takeScreenShot()
                }

                onIsIdentifyModeChanged: {
                    if (isIdentifyMode) {
                        measureToolIcon.checked = false
                    }
                }

                z: parent.z + 2
                states: [
                    State {
                        when: showMeasureTool && !measurePanel.isIdentifyMode
                        name: "MEASURE_MODE"

                        PropertyChanges {
                            target: mapPageHeader
                            y: -app.headerHeight
                        }

                        PropertyChanges {
                            target: undoRedoDraw
                            anchors.topMargin: app.defaultMargin
                        }

                        PropertyChanges {
                            target: measureToolTip
                            anchors.topMargin: app.defaultMargin
                        }

                        PropertyChanges {
                            target: placeSearchResult
                            visible: false
                        }
                    }
                ]

                onCopiedToClipboard: {
                    measureToast.show(qsTr("Copied to clipboard"), parent.height-measureToast.height-measurePanel.height)
                }

                onMeasurementUnitChanged: {
                    mapView.updateSegmentLengths()
                }
            }

            Controls.ToastDialog {
                id: measureToast
                z: parent.z + 1
            }

            //------------------------------------------------------------------------------------------

            property MobileMapPackage mmpk: MobileMapPackage {
                id: mmpk

                signal mmpkLoaded ()

                onLoadStatusChanged: {
                    if (loadStatus === Enums.LoadStatusLoaded) {
                        loadMmpkMapInMapView (0)
                        for (var i=0; i<maps.length; i++) {
                            offlineMaps.append ({
                                                    "name": maps[i].item.title,
                                                    "isChecked": i === 0
                                                })
                        }
                    }
                }

                function loadMmpkMapInMapView (idx) {
                    if (!idx) idx = 0
                    var map = mmpk.maps[idx]
                    map.loadStatusChanged.connect(function () {
                        mapView.processLoadStatusChange()
                    })
                    map.loadErrorChanged.connect(function () {
                        mapView.processLoadErrorChange()
                    })
                    mapView.map = map
                }

                function loadMmpk (path, idx) {
                    mmpk.path = path
                    mmpk.load()
                }
            }

            property alias offlineMaps: offlineMaps
            ListModel {
                id: offlineMaps
            }

            onViewpointChanged: {
                updateMapUnitsModel()
                updateGridModel()
            }

            onMousePressed: {
                if (app.showMapUnits &&
                        mapView.map.loadStatus === Enums.LoadStatusLoaded &&
                        !measureToolIcon.checked) {
                    mapunitsLabel.visible = true
                }
            }

            onMouseReleased: {
                mapunitsLabel.visible = false
            }

            onMouseClicked: {
                if (mapView.map.loadStatus === Enums.LoadStatusLoaded) {
                    if (measureToolIcon.checked && measurePanel.state === "MEASURE_MODE") {
                        draw(mouse)
                    } else {
                        isIdentifyTool=true
                        identifyFeatures (mouse.x, mouse.y)
                    }
                }
            }

            onIdentifyLayersStatusChanged: {
                switch (identifyLayersStatus) {
                case Enums.TaskStatusCompleted:
                    if (mapView.identifyLayersResults.length) {
                        mapView.identifyProperties.reset()
                        populateIdentifyProperties(mapView.identifyLayersResults)
                    }
                    break
                }
            }

            function cancelAllTasks () {
                for (var i=0; i<mapView.tasksInProgress.length; i++) {
                    mapView.cancelTask(mapView.tasksInProgress[i])
                }
                mapView.tasksInProgress = []
            }

            function populateIdentifyProperties (identifyLayerResults) {

                isAttachmentPresent = false
                attachqueryno = 0

                for (var i=0; i<identifyLayerResults.length; i++) {
                    var identifyLayerResult = identifyLayerResults[i],
                    hasSubLayerResults = false
                    try {
                        hasSubLayerResults = identifyLayerResult.sublayerResults &&
                                identifyLayerResult.sublayerResults.length
                    } catch (err) {}

                    if (hasSubLayerResults) {
                        //console.log("HAS SUBLAYER RESULTS", identifyLayerResult.sublayerResults.length)
                        populateIdentifyProperties(identifyLayerResult.sublayerResults)
                    } else {
                        var popupDefinition = identifyLayerResult.layerContent.popupDefinition
                        if (popupDefinition) {
                            for (var j=0; j<identifyLayerResult.geoElements.length; j++) {

                                var feature = identifyLayerResult.geoElements[j],
                                popUp = ArcGISRuntimeEnvironment.createObject("Popup", {initGeoElement: feature, initPopupDefinition: popupDefinition}),
                                popupManager = ArcGISRuntimeEnvironment.createObject("PopupManager", {popup: popUp})
                                popupManager.objectName = identifyLayerResult.layerContent.name
                                mapView.identifyProperties.popupManagers.push(popupManager)


                                mapView.identifyProperties.popupDefinitions.push(popupDefinition)
                                mapView.identifyProperties.fields.push(popupDefinition.fields)

                                mapView.identifyProperties.features.push(feature)
                                populateRelatedRecords(feature)
                            }
                        }
                        else
                        {
                            for (var jk=0; jk<identifyLayerResult.geoElements.length; jk++) {

                                var feature1 = identifyLayerResult.geoElements[jk]
                                var popupDefinition1 = ArcGISRuntimeEnvironment.createObject("PopupDefinition", {initGeoElement: feature1})
                                var popUp1 = ArcGISRuntimeEnvironment.createObject("Popup", {initGeoElement: feature, initPopupDefinition: popupDefinition1})
                                var popupManager1 = ArcGISRuntimeEnvironment.createObject("PopupManager", {popup: popUp1})
                                popupManager1.objectName = identifyLayerResult.layerContent.name
                                mapView.identifyProperties.popupManagers.push(popupManager1)


                                mapView.identifyProperties.popupDefinitions.push(popupDefinition1)
                                mapView.identifyProperties.fields.push(popupDefinition1.fields)

                                mapView.identifyProperties.features.push(feature1)
                                populateRelatedRecords(feature1)
                            }
                        }
                    }
                }


            }

            function populateRelatedRecords(feature)
            {
                var _relatedRecs = {}
                var selectedTable = feature.featureTable
                noOfFeaturesRequested += 1
                mapView.identifyProperties.relatedFeatures = []

                if(selectedTable.queryRelatedFeaturesStatusChanged)
                {

                    selectedTable.queryRelatedFeaturesStatusChanged.connect(function(){
                        if (selectedTable.queryRelatedFeaturesStatus === Enums.TaskStatusCompleted && noOfFeaturesRequestReceived < noOfFeaturesRequested)
                        {

                            noOfFeaturesRequestReceived += 1

                            var relatedFeatureQueryResultList = selectedTable.queryRelatedFeaturesResults
                            var relatedFeaturesList = []
                            for (var i=0;i < relatedFeatureQueryResultList.length; i++)
                            {
                                var iter = relatedFeatureQueryResultList[i].iterator

                                for(var k = 0; k < iter.features.length;k++)
                                {

                                    if(iter.features[k].featureTable)
                                    {


                                        var serviceLayerName =  iter.features[k].featureTable.layerInfo.serviceLayerName
                                        var displayFieldName = iter.features[k].featureTable.layerInfo.displayFieldName ? iter.features[k].featureTable.layerInfo.displayFieldName : "OBJECTID"

                                        var featureElement = {}
                                        featureElement["serviceLayerName"] = serviceLayerName
                                        featureElement["fields"] = []
                                        featureElement["displayFieldName"] = ""
                                        featureElement["geometry"] = iter.features[k].geometry



                                        var featurefields = []
                                        iter.features[k].attributes.attributeNames.forEach(function(attributeName){
                                            var fieldVal = iter.features[k].attributes.attributeValue(attributeName)
                                            var fieldobj = {}

                                            fieldobj["FieldName"] = attributeName
                                            if(fieldVal)
                                                fieldobj["FieldValue"] = fieldVal.toString()
                                            else
                                                fieldobj["FieldValue"] = ""
                                            if(attributeName.toUpperCase() === displayFieldName.toUpperCase())
                                            {
                                                if(fieldVal)
                                                    featureElement["displayFieldName"] = fieldVal.toString()
                                                else
                                                {
                                                    fieldVal = iter.features[k].attributes.attributeValue("OBJECTID")

                                                    featureElement["displayFieldName"] = fieldVal.toString()
                                                }

                                            }



                                            featureElement["fields"].push(fieldobj)
                                        }
                                        )


                                        relatedFeaturesList.push(featureElement)
                                    }



                                }
                            }


                            mapView.identifyProperties.relatedFeatures.push(relatedFeaturesList)
                            if(identifyBtn.checked)
                                identifyBtn.checkIfAttachmentPresent(0)



                            if(noOfFeaturesRequestReceived === noOfFeaturesRequested)
                            {
                                identifyProperties.computeCounts()
                                showIdentifyPanel()
                                //console.log("no of features:" + mapView.identifyProperties.features.length)
                                if (mapView.identifyProperties.features.length) mapView.identifyProperties.highlightFeature(0, false)
                            }
                        }
                    }
                    )

                    selectedTable.queryRelatedFeatures(feature)

                }
                else
                {
                    if(identifyBtn.checked)
                        identifyBtn.populateTabHeaders()



                    identifyProperties.computeCounts()
                    showIdentifyPanel()
                    //console.log("no of features:" + mapView.identifyProperties.features.length)
                    if (mapView.identifyProperties.features.length) mapView.identifyProperties.highlightFeature(0, false)

                }

            }


            function showIdentifyPanel () {
                if (mapView.identifyProperties.popupManagers.length) {
                    identifyBtn.checked = true

                    identifyBtn.checkIfAttachmentPresent(0)
                }
            }

            function identifyFeatures (x, y, tolerance, returnPopupsOnly, maxResults) {
                if (typeof tolerance === "undefined") tolerance = 10
                if (typeof returnPopupsOnly === "undefined") returnPopupsOnly = false
                if (typeof maxResults === "undefined") maxResults = 10
                var id = mapView.identifyLayersWithMaxResults(x, y, tolerance, returnPopupsOnly, maxResults)
                mapView.tasksInProgress.push(id)
            }

            function updateMapInfo () {
                if (!mapView.map) return
                if (mapView.map.item) {
                    if (mapView.map.item.title) {
                        mapView.mapInfo.title = mapView.map.item.title
                    }
                    if (mapView.map.item.snippet) {
                        mapView.mapInfo.snippet = mapView.map.item.snippet
                    }
                    if (mapView.map.item.description) {
                        mapView.mapInfo.description = mapView.map.item.description
                    }
                }
            }

            function procLayers (layers, callback) {
                if (!layers) layers = mapView.map.operationalLayers
                //console.log("no of layers " + layers.count)
                var count = layers.count || layers.length
                var rootlyrindx = -1

                for (var i=count; i--;) {
                    try {
                        var   layer = mapView.map.operationalLayers.get(i)
                    } catch (err) {
                        layer = layers[i]
                    }
                    if (!layer)
                    {
                        continue
                    }
                    rootlyrindx = i
                    addLayerToContentAndFetchLegend(layer,rootlyrindx)

                }

            }

            function processSubLayers(layer,subLayers,rootLayerName,rootlyrindx)
            {
                if(layer.subLayerContents.length > 0)
                {
                    for(var x=layer.subLayerContents.length;x--;){

                        var sublyr = layer.subLayerContents[x]
                        if(sublyr)
                        {

                            if(sublyr !== null)
                            {
                                if(sublyr.subLayerContents && sublyr.subLayerContents.length > 0)
                                {
                                    for(var ks = sublyr.subLayerContents.length; ks--;)
                                    {

                                        processSubLayers(sublyr.subLayerContents[ks],subLayers,rootLayerName,rootlyrindx)
                                    }
                                }
                                else{
                                    var lyrname = sublyr.name
                                    subLayers.push(lyrname)
                                    mapView.fetchLegendInfos(sublyr, x,layer.name,rootLayerName,rootlyrindx)
                                }
                            }

                        }

                    }
                }
                else
                {
                    subLayers.push(layer.name)
                    mapView.fetchLegendInfos(layer, layer.sublayerId,rootLayerName,rootlyrindx)


                }
                return subLayers
            }

            /*
              if it is a group layer then the rootlyrindx is the index of the group layer
              If it is not a group layer then the rootlayerName is empty and the rootLyrIndex
              is same as the layer index

              */
            function addLayerToContentAndFetchLegend(layer,rootlyrindx)
            {

                var subLayers = []


                if(layer.loadStatus === Enums.LoadStatusLoaded)
                {

                    if(layer.subLayerContents.length > 0)
                    {
                        for(var x=layer.subLayerContents.length;x--;){
                            var sublyr = layer.subLayerContents[x]
                            if(sublyr)
                            {
                                if(sublyr.subLayerContents && sublyr.subLayerContents.length > 0)
                                {
                                    for(var ks = sublyr.subLayerContents.length; ks--;)
                                    {
                                        subLayers = processSubLayers(layer,subLayers,layer.name,rootlyrindx)

                                    }
                                }
                                else{
                                    var lyrname = sublyr.name
                                    subLayers.push(lyrname)
                                    mapView.fetchLegendInfos(sublyr, x,layer.name,rootlyrindx)
                                }

                            }

                        }


                    }
                    else
                    {
                        mapView.fetchLegendInfos(layer, rootlyrindx,"",rootlyrindx)
                    }
                    addToContentList(layer,subLayers)

                }
                else
                {
                    loadLayerAndPopulateLegend(layer,rootlyrindx)
                }
            }

            /*
            This is added in version 4.1
            AS mentioned earlier sometimes the layer can take time in loading. So we need to wait
            until the layer is loaded to get the legend. This was causing the legend not to show for some layers
            in earlier version.

         */
            function loadLayerAndPopulateLegend(layer,lyrindex)
            {
                var subLayers = []
                layer.onLoadStatusChanged.connect(function () {
                    if(layer.loadStatus === Enums.LoadStatusLoaded){
                        if(layer.subLayerContents.length > 0)
                        {
                            for(var indx in layer.subLayerContents){
                                if(layer.subLayerContents[indx] !== null)
                                {
                                    if(layer.subLayerContents[indx].subLayerContents && layer.subLayerContents[indx].subLayerContents.length > 0)
                                    {
                                        for(var ks = layer.subLayerContents[indx].subLayerContents.length; ks--;)
                                        {
                                            subLayers = processSubLayers(layer.subLayerContents[indx].subLayerContents[ks],subLayers,layer.name,lyrindex)
                                        }
                                    }
                                    else
                                    {
                                        var lyrname = layer.subLayerContents[indx].name
                                        subLayers.push(lyrname)
                                        var sublyr = layer.subLayerContents[indx]

                                        mapView.fetchLegendInfos(sublyr, indx,layer.name,lyrindex)
                                    }
                                }

                            }
                        }
                        else
                        {
                            mapView.fetchLegendInfos(layer, lyrindex,"",lyrindex)
                        }
                        addToContentList(layer,subLayers,true)
                    }

                })
            }

            /*
              This is modified in version 4.1 to resolve the bug in earlier version
              where some of the layers were duplicated in the content.

              */

            function addToContentList(layer,sublayers)
            {

                var sublayersString = sublayers.join(',')

                if(!find(mapView.contentListModel,layer.name))
                {
                    var isGroupLayer = sublayers.length > 0?true:false

                    var isVisibleAtScale = isGroupLayer?sublayers.length > 0?true:false:layer.isVisibleAtScale(mapView.mapScale)
                    mapView.contentListModel.append({
                                                        "checkBox": layer.visible,
                                                        "name": layer.name,
                                                        "layerId": layer.layerId,
                                                        "sublayers":sublayersString,
                                                        "isVisibleAtScale":isVisibleAtScale,
                                                        "isGroupLayer":isGroupLayer
                                                    })




                    //sort the list when all the layers has been added to the contentlist
                    if(mapView.map.operationalLayers.count === mapView.contentListModel.count)
                        sortLegendContentByLyrIndex()
                }
            }


            function processSubLayerLegend(layer,subLayers,rootLayer)

            {
                if(layer.subLayerContents.length > 0)
                {
                    for(var x=0; x<layer.subLayerContents.length;x++){
                        var sublyr = layer.subLayerContents[x]
                        if(sublyr)
                        {

                            if(sublyr !== null)
                            {
                                if(sublyr.subLayerContents && sublyr.subLayerContents.length > 0)
                                {
                                    for(var ks = 0;ks<sublyr.subLayerContents.length; ks++)
                                    {
                                        processSubLayers(sublyr.subLayerContents[ks],subLayers,rootLayer.Name,rootLayer.index)
                                    }
                                }
                                else{
                                    var lyrname = sublyr.name

                                    var issublyrVisible = sublyr.isVisibleAtScale(mapView.mapScale)

                                    if(issublyrVisible && layer.visible && layer.showInLegend && rootLayer.visible)
                                    {
                                        subLayers.push(lyrname)

                                        sortAndAddLegendForLayer(sublyr,true,layer.name)
                                    }

                                }
                            }

                        }

                    }
                }
                else
                {
                    var issublyrVisible1 = layer.isVisibleAtScale(mapView.mapScale)


                    if(issublyrVisible1 && layer.visible && layer.showInLegend && rootLayer.visible)

                    {
                        subLayers.push(layer.name)
                        sortAndAddLegendForLayer(layer,true,rootLayer.Name)
                    }


                }
                return subLayers
            }

            function sortContent()
            {

            }


            function getItemFromContentsModel(item)
            {
                for(var i=0;i<contentsModel.count;i++)
                {
                    var item2= contentsModel.get(i)
                    if(item.name === item2.name)
                    {

                        item.checkBox = item2.checkBox
                        break;
                    }
                }
                return item
            }

            function populateLegend(layer,item)
            {
                if(layer){
                    if(layer.subLayerContents.length > 0)
                    {
                        var newSubLyrs = []

                        //isGroupLyr=true
                        //the index is reversed in FeatureCollection vs FeatureLayer.
                        for(var newindx = layer.subLayerContents.length;newindx--;){
                            var indx
                            var sublyr
                            if(layer.objectType === "FeatureCollectionLayer")
                            {
                                indx = newindx
                            }
                            else
                                indx = layer.subLayerContents.length - (newindx + 1)

                            sublyr = layer.subLayerContents[layer.subLayerContents.length - (indx + 1)]

                            sublyr = layer.subLayerContents[indx]
                            if(sublyr !== null)
                            {
                                if(layer.subLayerContents[indx].subLayerContents && layer.subLayerContents[indx].subLayerContents.length > 0)
                                {
                                    for(var ks= 0;ks< sublyr.subLayerContents.length;ks++)
                                    {


                                        newSubLyrs = processSubLayerLegend(layer.subLayerContents[indx].subLayerContents[ks],newSubLyrs,layer)

                                    }
                                }
                                else{

                                    var issublyrVisible = sublyr.isVisibleAtScale(mapView.mapScale)
                                    var lyrname = layer.subLayerContents[indx].name
                                    if(issublyrVisible && layer.visible && layer.showInLegend)
                                    {
                                        newSubLyrs.push(lyrname)

                                        sortAndAddLegendForLayer(sublyr,true,layer.name)
                                    }
                                }
                            }
                        }

                        if(newSubLyrs.length > 0)
                        {
                            var sublayersString = newSubLyrs.join(',')

                            if(sublayersString.length > 1)
                            {
                                item.sublayers = sublayersString

                                updateContentsModel(item)
                            }

                        }
                        else
                        {
                            item.sublayers = ""
                            updateContentsModel(item)
                        }

                    }
                    else{
                        sortAndAddLegendForLayer(layer,false)
                        updateContentsModel(item)
                    }
                    sortLegendInfosByLyrIndex()

                }
            }

            /*
              This is also added new in version 4.1 so that the content
              is also sorted. It resolves the issue in earlier version where the
              layers were  sometimes  not sorted

              */

            function sortLegendContentByLyrIndex()
            {
                mapView.orderedLegendInfos.clear()
                var layers = mapView.map.operationalLayers
                //loop through the operational layers and update the subLayers based on their visibility
                //Some layers  may have scale dependency. So we need to check the visibility
                //of the layers/sublayers based on the mapscale and prepare the legend accordingly

                for (var k=layers.count; k--;)
                {
                    var layer = layers.get(k)
                    var isGroupLyr = false
                    if(layer){
                        if(layer.loadStatus === Enums.LoadStatusLoaded)
                        {
                            for(var i=0;i<contentListModel.count;i++)
                            {
                                var item = contentListModel.get(i)
                                item = getItemFromContentsModel(item)

                                if(item.name === layer.name){

                                    var newSubLyrs = []

                                    if(layer.subLayerContents.length > 0)
                                    {
                                        isGroupLyr=true
                                        //the index is reversed in FeatureCollection vs FeatureLayer.
                                        for(var newindx = layer.subLayerContents.length;newindx--;){
                                            var indx
                                            var sublyr
                                            if(layer.objectType === "FeatureCollectionLayer")
                                            {
                                                indx = newindx
                                            }
                                            else
                                                indx = layer.subLayerContents.length - (newindx + 1)

                                            sublyr = layer.subLayerContents[layer.subLayerContents.length - (indx + 1)]

                                            sublyr = layer.subLayerContents[indx]
                                            if(sublyr !== null)
                                            {
                                                if(layer.subLayerContents[indx].subLayerContents && layer.subLayerContents[indx].subLayerContents.length > 0)
                                                {
                                                    for(var ks= 0;ks< sublyr.subLayerContents.length;ks++)
                                                    {

                                                        newSubLyrs = processSubLayerLegend(layer.subLayerContents[indx].subLayerContents[ks],newSubLyrs,layer)

                                                    }
                                                }
                                                else{

                                                    var issublyrVisible = sublyr.isVisibleAtScale(mapView.mapScale)
                                                    var lyrname = layer.subLayerContents[indx].name
                                                    if(issublyrVisible && layer.visible && layer.showInLegend)
                                                    {
                                                        newSubLyrs.push(lyrname)

                                                        sortAndAddLegendForLayer(sublyr,true,layer.name)
                                                    }
                                                }
                                            }
                                        }

                                    }
                                    else
                                    {

                                        if (layer.visible && layer.showInLegend && layer.isVisibleAtScale(mapView.mapScale))
                                            sortAndAddLegendForLayer(layer,false)
                                    }


                                    if (isGroupLyr)
                                    {
                                        if(newSubLyrs.length > 0)
                                        {
                                            var sublayersString = newSubLyrs.join(',')
                                            item.sublayers = sublayersString
                                            if(sublayersString.length > 1)
                                            {
                                                item.isVisibleAtScale = true
                                                updateContentsModel(item)
                                            }
                                            else
                                            {
                                                if(layer.isVisibleAtScale(mapView.mapScale))
                                                    item.isVisibleAtScale = true
                                                else
                                                    item.isVisibleAtScale = false
                                                updateContentsModel(item)
                                            }
                                        }
                                        else
                                        {
                                            item.sublayers = ""
                                            if(layer.isVisibleAtScale(mapView.mapScale))
                                                item.isVisibleAtScale = true
                                            else
                                                item.isVisibleAtScale = false

                                            updateContentsModel(item)
                                        }
                                    }

                                    else
                                    {
                                        // if (layer.visible && layer.showInLegend && layer.isVisibleAtScale(mapView.mapScale))
                                        if (layer.isVisibleAtScale(mapView.mapScale))
                                        {
                                            item.sublayers = ""
                                            item.isVisibleAtScale = true
                                            updateContentsModel(item)
                                        }
                                        else
                                        {
                                            item.isVisibleAtScale = false
                                            updateContentsModel(item)
                                        }

                                    }

                                    break;
                                }
                            }
                        }
                    }
                }

            }

            function getExisting(contentsModel,layerName)
            {
                for (var i=0;i<contentsModel.count;i ++)
                {
                    var lyr = contentsModel.get(i)
                    if(lyr.name === layerName)
                        return true
                }
                return false

            }

            function sortLegendContent()
            {
                var oplayers = mapView.map.operationalLayers

                for (var k=oplayers.count; k--;)
                {
                    var layer = mapView.map.operationalLayers.get(k)

                    if(layer)
                    {
                        if(layer.loadStatus === Enums.LoadStatusLoaded)
                        {

                            var name = layer.name
                            //get the layer from contents model
                            for(var k1=0;k1<mapView.contentsModel_copy.count;k1++)
                            {
                                var item =  mapView.contentsModel_copy.get(k1)
                                if(item.name === layer.name)
                                {
                                    var isPresent = getExisting(contentsModel,layer.name)
                                    if(!isPresent)
                                        contentsModel.append(item)
                                    break;
                                }


                            }
                        }
                    }
                }

            }


            function updateContentsModel(item)
            {

                contentsModel_copy.clear()
                for(var k=0;k<mapView.contentsModel.count;k++)
                {
                    contentsModel_copy.append(mapView.contentsModel.get(k))
                }
                mapView.contentsModel.clear()

                var updated = false
                var itemindx = -1
                for(var k2=0;k2<contentsModel_copy.count;k2++)
                {

                    var element = contentsModel_copy.get(k2)
                    if(element.name === item.name)
                    {
                        itemindx = k2
                        var sublayers = item.sublayers
                        contentsModel_copy.set(k2,{"sublayers":sublayers})
                        contentsModel_copy.set(k2,{"isVisibleAtScale":item.isVisibleAtScale})
                        contentsModel_copy.set(k2,{"checkBox":item.checkBox})
                        updated = true
                        break;
                    }
                }

                if(!updated)
                {
                    contentsModel_copy.append(item)

                }

                sortLegendContent()

            }


            function sortLegendInfosByLyrIndex()
            {
                orderedLegendInfos.clear()
                var oplayers = mapView.map.operationalLayers

                for (var k=oplayers.count; k--;)
                {
                    var layer = oplayers.get(k)

                    if(layer.loadStatus === Enums.LoadStatusLoaded)
                    {
                        //for each layer check if it is a group layer
                        if(mapView.map.operationalLayers.get(k).subLayerContents.length > 0)
                        {
                            //if it is a grouplayer sort the sublayers first based on layer index

                            for(var indx = mapView.map.operationalLayers.get(k).subLayerContents.length;indx--;)
                            {
                                //Then for each sublayer sort the legend based on legend index and add to a listmodel
                                var sublayer =  mapView.map.operationalLayers.get(k).subLayerContents[indx]
                                if(sublayer)
                                {
                                    if (layer.visible && layer.showInLegend && sublayer.isVisibleAtScale(mapView.mapScale))
                                        sortAndAddLegendForLayer(sublayer,true,layer.name)
                                }
                            }
                        }
                        else
                        {
                            //if it is not a group layer sort the legend based on legend index and add to a listmodel
                            if (layer.visible && layer.showInLegend)
                                sortAndAddLegendForLayer(layer,false)
                        }
                    }

                }

            }


            function find(model,layername)
            {
                for(var i=0;i<model.count;i++)
                {
                    var item = model.get(i)
                    if(item.name === layername)
                        return true
                }
                return false
            }

            function updateMapUnitsModel () {
                if (!mapView.currentViewpointCenter.center) return
                var isEmpty = mapView.mapunitsListModel.count === 0,
                DD = CoordinateFormatter.toLatitudeLongitude(mapView.currentViewpointCenter.center, Enums.LatitudeLongitudeFormatDecimalDegrees, 3),
                DM = CoordinateFormatter.toLatitudeLongitude(mapView.currentViewpointCenter.center, Enums.LatitudeLongitudeFormatDegreesDecimalMinutes, 3),
                DMS = CoordinateFormatter.toLatitudeLongitude(mapView.currentViewpointCenter.center, Enums.LatitudeLongitudeFormatDegreesMinutesSeconds, 3),
                MGRS = CoordinateFormatter.toMgrs(mapView.currentViewpointCenter.center, Enums.MgrsConversionModeAutomatic, 3, true),
                mapUnitsObjects = [
                            { "name": "%1 (wkid: %2, %3)".arg(qsTr("Default")).arg(mapView.spatialReference.wkid).arg(getUnitNameFromWkText(mapView.spatialReference.wkText)),
                                "value": "%1 %2".arg(mapView.currentViewpointCenter.center.y.toFixed(4)).arg(mapView.currentViewpointCenter.center.x.toFixed(4)),
                                "isChecked": false,
                            },
                            { "name": "DD",
                                "value": parseDecimalCoordinate(DD),
                                "isChecked": false,
                            },
                            { "name": "DM",
                                "value": parseDecimalCoordinate(DM),
                                "isChecked": true,
                            },
                            { "name": "DMS",
                                "value": parseDecimalCoordinate(DMS),
                                "isChecked": false,
                            },
                            { "name": "MGRS",
                                "value": MGRS,
                                "isChecked": false,
                            }
                        ]

                for (var i=0; i<mapUnitsObjects.length; i++) {
                    if (isEmpty) {
                        mapView.mapunitsListModel.append(mapUnitsObjects[i])
                    } else {
                        for (var key in mapUnitsObjects[i]) {
                            if (mapUnitsObjects[i].hasOwnProperty(key) && key !== "isChecked") {
                                mapView.mapunitsListModel.setProperty(i, key, mapUnitsObjects[i][key])
                            }
                        }
                    }
                    var currentItem = mapView.mapunitsListModel.get(i)
                    if (currentItem.isChecked) {
                        mapunitsLabel.text = currentItem.value
                    }
                }
            }

            function updateGridModel () {
                var isEmpty = mapView.gridListModel.count === 0,
                gridObjects = [
                            { "name": "None ",
                                "value": "",

                                "isChecked": true,
                            },
                            { "name": "Lat/Long Grid",
                                "value": "",
                                "gridObject" : "LatitudeLongitudeGrid",
                                "isChecked": false,
                            },
                            { "name": "UTM Grid",
                                "value": "",
                                "gridObject" :"UTMGrid",
                                "isChecked": false,
                            },
                            { "name": "USNG Grid",
                                "value": "",
                                "gridObject" : "USNGGrid",
                                "isChecked": false,
                            },

                            { "name": "MGRS Grid",
                                "value": "",
                                "gridObject": "MGRSGrid",
                                "isChecked": false,
                            }
                        ]

                for (var i=0; i<gridObjects.length; i++) {
                    if (isEmpty) {
                        mapView.gridListModel.append(gridObjects[i])
                    } else {
                        for (var key in gridObjects[i]) {
                            if (gridObjects[i].hasOwnProperty(key) && key !== "isChecked") {
                                mapView.gridListModel.setProperty(i, key, gridObjects[i][key])
                            }
                        }
                    }
                    var currentItem = mapView.gridListModel.get(i)
                    if (currentItem.isChecked) {
                        mapView.grid = ArcGISRuntimeEnvironment.createObject(currentItem.gridObject, {labelPosition: Enums.GridLabelPositionAllSides})
                    }
                }
            }

            function getUnitNameFromWkText (wkText) {
                var unit
                try {
                    unit = JSON.parse("[" + wkText.split("UNIT")[2])[0][0].split(",")
                } catch (err) {
                    unit = wkText
                }
                return unit[0]
            }

            function parseDecimalCoordinate (coord) {
                switch (coord.split(" ").length) {
                case (2):
                    return parseDD (coord)
                case (4):
                    return parseDM (coord)
                case (6):
                    return parseDMS (coord)
                default:
                    return coord
                }
            }

            function replaceDirectionStrings (originalText, replacement) {
                var directions = ["N", "S", "E", "W"]
                for (var i=0; i<directions.length; i++) {
                    originalText = originalText.replace(directions[i],
                                                        "%1 %2".arg(replacement).arg(directions[i]))
                }
                return originalText
            }

            function parseDD (DD) {
                var DDSplit = DD.split(" ")
                DD = "%1  %2".arg(DDSplit[0]).arg(DDSplit[1])
                return replaceDirectionStrings(DD, "°")
            }

            function parseDM (DM) {
                var DMSplit = DM.split(" ")
                DM = "%1° %2  %3° %4".arg(DMSplit[0]).arg(DMSplit[1]).arg(DMSplit[2]).arg(DMSplit[3])
                return replaceDirectionStrings(DM, "'")
            }

            function parseDMS (DMS) {
                var DMSSplit = DMS.split(" ")
                DMS = "%1° %2' %3  %4° %5' %6".arg(DMSSplit[0]).arg(DMSSplit[1]).arg(DMSSplit[2]).arg(DMSSplit[3]).arg(DMSSplit[4]).arg(DMSSplit[5])
                return replaceDirectionStrings(DMS, "''")
            }

            function currentCenter () {
                var x = app.width/2
                var y = (app.height - app.headerHeight)/2
                return screenToLocation(x, y)
            }
        }

        OfflineMapTask {
            id: offlineMapTask
            onlineMap: myWebmap
            onLoadErrorChanged: {
                //console.log("loadError:" + loadError)
            }

            onLoadStatusChanged:{
                if (loadStatus == Enums.LoadStatusLoaded){
                    // console.log("offline map task "+ loadStatus)

                }
            }
            function getDate(timestamp)
            {
                var date = new Date(timestamp);
                var jsDateValues = [
                            date.getMonth()+1,
                            date.getDate(),
                            date.getFullYear()
                        ]
                return jsDateValues.join("/")
            }

            function loadUnloadedMapAreas()
            {
                if(mapAreasCount !== mapAreasModel.count)
                {
                    //check for the unloaded maparea
                    for(var j=0;j< mapAreasCount; j++)
                    {
                        let mapArea = offlineMapTask.preplannedMapAreaList.get(j);
                        var id = mapArea.portalItem.itemId
                        if(!isMapAreaPresentInModel(id))
                        {
                            loadMapArea(mapArea)
                        }
                    }
                    drawMapAreas()
                }
            }

            function isMapAreaPresentInModel(id)
            {
                for(var p=0;p < mapAreasModel.count;p++)
                {
                    var mapAreaObj = mapAreasModel.get(p)
                    var portalItem = mapAreaObj.portalItem
                    if(portalItem.itemId === id)
                        return true
                }
                return false
            }


            function loadMapArea(mapArea)
            {
                var token = null
                var url = ""
                if(securedPortal)
                    token = securedPortal.credential.token
                mapArea.loadStatusChanged.connect(function () {
                    if (mapArea.loadStatus !== Enums.LoadStatusLoaded)
                        return;

                    var  mapAreaPolygon = null;
                    var mapAreaGeometry = mapArea.areaOfInterest;
                    if (mapAreaGeometry.geometryType === Enums.GeometryTypeEnvelope)
                        mapAreaPolygon = GeometryEngine.buffer(mapAreaGeometry, 0);
                    else
                        mapAreaPolygon = mapAreaGeometry;

                    const graphic = ArcGISRuntimeEnvironment.createObject("Graphic", { symbol: simpleMapAreaFillSymbol,geometry: mapAreaPolygon });

                    mapAreaGraphicsArray.push(graphic)


                    //
                    //var _maparea = mapArea//offlineMapTask.preplannedMapAreaList.get(i)

                    var _size = 0
                    var _title = ""

                    mapArea.contentItemsStatusChanged.connect(function(){
                        if(mapArea.contentItemsStatus === Enums.TaskStatusCompleted)
                        {

                            for(let j = 0;j < mapArea.contentItemsResult.count;j++){
                                var content_data = mapArea.contentItemsResult.get(j)
                                _size += parseInt(content_data.size)


                            }
                            if(_size < 1024)
                                _size = _size + " Bytes"
                            else
                                _size = getFileSize(_size)

                            var _portalItem = mapArea.portalItem
                            var _areaOfInterest = mapArea.areaOfInterest
                            var _mapAreaItemId = _portalItem.itemId
                            var mapareajson = _portalItem.json
                            var _thumbnailpath = mapareajson.thumbnail

                            var _modifiedDate = ""
                            if(mapareajson.modified !== null)
                            {
                                _modifiedDate = getDate(mapareajson.modified)
                            }

                            var _createdDate = getDate(mapareajson.created)
                            var _owner = mapareajson.owner


                            var _isdownloaded = false
                            if(existingmapareas)
                            {
                                var _existingrecs = existingmapareas.filter(item => item.id === _mapAreaItemId)
                                if(_existingrecs.length > 0)
                                    _isdownloaded=true
                            }

                            var _title = mapareajson.title
                            if(token)
                            {
                                var prefix = "?token="+ token
                                url =  app.portalUrl + ("/sharing/rest/content/items/%1/info/%2%3").arg(_mapAreaItemId).arg(_thumbnailpath).arg(prefix);
                            }
                            else
                                url = app.portalUrl + ("/sharing/rest/content/items/%1/info/%2").arg(_mapAreaItemId).arg(_thumbnailpath)

                            if(!isMapAreaPresentInModel(mapArea.portalItem.itemId))
                            {
                                mapAreasModel.append({"mapArea":mapArea,"portalItem":_portalItem,"thumbnailImg":_thumbnailpath,"thumbnailurl":url,"title":_title,"areaOfInterest":_areaOfInterest,"size":_size,"createdDate":_createdDate,"modifiedDate":_modifiedDate,"isPresent":_isdownloaded,"owner":_owner,"isDownloading":false,"isSelected":false})
                                mapAreaslst.push({"mapArea":mapArea,"portalItem":_portalItem,"thumbnailImg":_thumbnailpath,"thumbnailurl":url,"title":_title,"areaOfInterest":_areaOfInterest,"size":_size,"createdDate":_createdDate,"modifiedDate":_modifiedDate,"isPresent":_isdownloaded,"owner":_owner})
                            }



                        }
                    }
                    )
                    var content = mapArea.contentItems()


                });
                mapArea.load();
            }

            function loadMapAreaFromId(id)
            {
                for(var k=0; k<offlineMapTask.preplannedMapAreaList.count; k++)
                {
                    let mapArea = offlineMapTask.preplannedMapAreaList.get(k);
                    var _portalItem = _maparea.portalItem
                    if(_portalItem.itemId === id)
                    {
                        loadMapArea(mapArea)
                    }

                }




            }


            function loadMapAreaFromIndex(index)
            {


                var i = index

                let mapArea = offlineMapTask.preplannedMapAreaList.get(i);
                loadMapArea(mapArea)

            }



            onPreplannedMapAreasStatusChanged: {
                if(preplannedMapAreasStatus === Enums.TaskStatusCompleted)
                {
                    var token = null
                    var url = ""
                    mapAreaGraphicsArray = []
                    var areasModel = offlineMapTask.preplannedMapAreaList;
                    if(securedPortal)
                        token = securedPortal.credential.token
                    for(let i = 0;i< offlineMapTask.preplannedMapAreaList.count;i++){
                        loadMapAreaFromIndex(i)


                    }

                    mapAreasCount = offlineMapTask.preplannedMapAreaList.count

                    if(offlineMapTask.preplannedMapAreaList.count > 0)
                    {
                        mapPage.hasMapArea = true

                        var item = app.mapsWithMapAreas.filter(id => id === mapPage.portalItem.id)
                        if(item.length === 0)
                            app.mapsWithMapAreas.push(mapPage.portalItem.id)
                    }
                    else
                        mapPage.hasMapArea = false



                }




            }

        }

        function getOfflineMaps() {

            //get the downloaded mapareas for mapPage.portalItem.id
            var fileName = "mapareasinfos.json"
            var fileContent = null
            var mapAreaFolder = offlineMapAreaCache.fileFolder.path
            if (mapAreaFolder.fileExists(fileName)) {
                fileContent = mapAreaFolder.readJsonFile(fileName)
            }
            var results = fileContent.results
            existingmapareas = results.filter(item => item.mapid === mapPage.portalItem.id)


            var taskid = offlineMapTask.preplannedMapAreas();


        }



    }

    onShowMeasureToolChanged: {
        if (!showMeasureTool && measurePanel.state !== "MEASURE_MODE") {
            mapView.resetMeasureTool()
        } else {
            searchPage.close()
            panelPage.close()
            mapView.cancelAllTasks()
        }
    }

    Component {
        id: discardMeasurements

        Controls.MessageDialog {
            id: discardDialog
            Material.primary: app.primaryColor
            Material.accent: app.accentColor
            pageHeaderHeight: app.headerHeight

            onCloseCompleted: {
                discardDialog.destroy()
            }
        }
    }
    function drawMapAreas()
    {
        polygonGraphicsOverlay.graphics.clear()
        mapPage.mapAreaGraphicsArray.forEach((graphic)=>{

                                                 polygonGraphicsOverlay.graphics.append(graphic)

                                             }
                                             )

        mapView.setViewpointGeometryAndPadding(polygonGraphicsOverlay.extent,100)

    }
    function highlightMapArea(index){
        var graphic = mapPage.mapAreaGraphicsArray[index]

        // mapView.setViewpointGeometryAndPadding(polygonGraphicsOverlay.extent,100)
        if(app.isLandscape)
            mapView.setViewpointCenterAndScale(graphic.geometry.extent.center,mapView.scale)



        var graphicList = []

        graphicList.push(graphic)

        polygonGraphicsOverlay.clearSelection()
        polygonGraphicsOverlay.selectGraphics(graphicList)
    }

    function showDiscardMeasurementsDialog (onAccepted, onRejected) {
        if (lineGraphics.hasData() || areaGraphics.hasData()) {
            var discardDialog = discardMeasurements.createObject(app)
            discardDialog.standardButtons = 0
            discardDialog.addButton(qsTr("DISCARD"), DialogButtonBox.AcceptRole, "#FFC7461A")
            discardDialog.addButton(qsTr("CANCEL"), DialogButtonBox.RejectRole, Qt.lighter(app.primaryColor))
            discardDialog.onAccepted.connect(onAccepted)
            discardDialog.onRejected.connect(onRejected)
            discardDialog.show("", qsTr("Discard measurements?"))
        } else {
            onAccepted()
        }
    }

    onPrevious: {
        mapView.map.cancelLoad()
    }

    CustomAuthenticationView {
        //TODO: This will be used to replace the runtime authentication popup. It has a consistent material look
        id: loginDialog
    }

    Component {
        id: listModelComponent

        ListModel {
        }
    }

    BusyIndicator {
        id: busyIndicator
        Material.primary: app.primaryColor
        Material.accent: app.accentColor
        visible: ((mapView.drawStatus === Enums.DrawStatusInProgress) && (mapView.mapReadyCount < 1)) || (mapView.identifyLayersStatus === Enums.TaskStatusInProgress)
        width: app.iconSize
        height: app.iconSize
        anchors.centerIn: parent

    }

    Connections {
        target: app

        onIsSignedInChanged: {
            if (!app.isSignedIn && !app.refreshTokenTimer.isRefreshing) {
                toolBarBtns.uncheckAll(mapPage.previous)
            }
        }

        onBackButtonPressed: {
            if (app.stackView.currentItem.objectName === "mapPage" &&
                    !app.aboutAppPage.visible && !hasVisibleSignInPage()) {
                if (more.visible) {
                    more.close()
                } else if (app.messageDialog.visible) {
                    app.messageDialog.close()
                } else if (loginDialog.visible) {
                    loginDialog.close()
                } else if (panelPage.visible) {
                    if (panelPage.tabBar.currentIndex) {
                        panelPage.tabBar.currentIndex = 0
                    } else if (panelPage.fullView && !app.isLarge) {
                        panelPage.collapseFullView()
                    } else {
                        panelPage.close()
                    }
                } else if (searchPage.visible) {
                    if (searchPage.tabBar.currentIndex) {
                        searchPage.tabBar.currentIndex = 0
                    } else {
                        searchPage.close()
                    }
                } else if (measureToolIcon.checked) {
                    measureToolIcon.checked = false
                } else {
                    mapPage.previous()
                }
            }
        }
    }

    onPortalItemChanged: {
        if (mapPage.portalItem) {
            //need to clear the info of previous item
            panelPage.owner = ""
            panelPage.modifiedDate = ""
            panelPage.mapTitle = ""
            switch(mapPage.portalItem.type) {
            case "Web Map":
                //mapPage.hasMapArea = true
                if(comingFromMapArea)
                {
                    var newItem = ArcGISRuntimeEnvironment.createObject("PortalItem", { url: portalItem.url });

                    // construct a map from an item
                    var newMap = ArcGISRuntimeEnvironment.createObject("Map", { item: newItem });

                    // add the map to the map view
                    mapView.map = newMap;

                    mapView.map.loadStatusChanged.connect(function () {
                        mapView.processLoadStatusChange()
                    })

                }
                mapPage.showUpdatesAvailable = false
                //Default map is a web map
                break
            case "Mobile Map Package":
                mapPage.hasMapArea = false
                mapPage.showUpdatesAvailable = false
                if (mapPage.mapProperties.needsUnpacking) {
                    mmpk.loadMmpk(mapPage.mapProperties.fileUrl.toString().replace(".mmpk", ""))
                } else {
                    mmpk.loadMmpk(mapPage.mapProperties.fileUrl)
                }
                break
            case "maparea":
                mapPage.hasMapArea = false
                mapPage.showUpdatesAvailable = false
                var _basemaps
                if(typeof(mapProperties.basemaps) !== "object")
                    _basemaps = mapProperties.basemaps.split(",")
                else
                    _basemaps = mapProperties.basemaps
                myWebmap.basemap.baseLayers.clear()
                myWebmap.operationalLayers.clear()
                polygonGraphicsOverlay.graphics.clear()
                panelPage.close()
                // myWebmap.
                var newBasemap = ArcGISRuntimeEnvironment.createObject("Basemap");
                for(var k=0;k<_basemaps.length;k++){
                    var filePath = mapProperties.fileUrl + _basemaps[k]
                    var fileInfo = AppFramework.fileInfo(filePath)
                    var suffix = fileInfo.suffix
                    var fileurl = ""
                    if(Qt.platform.os === "windows")
                        fileurl = "file:///"+ filePath
                    else
                        fileurl = "file://"+ filePath

                    var tiledLayer = null
                    if(suffix === "vtpk")
                        tiledLayer = ArcGISRuntimeEnvironment.createObject("ArcGISVectorTiledLayer",{url:fileurl})
                    else if(suffix === "tpk")
                        tiledLayer = ArcGISRuntimeEnvironment.createObject("ArcGISTiledLayer",{url:fileurl})

                    newBasemap.baseLayers.append(tiledLayer);

                    // myWebmap.basemap.baseLayers.append(tiledLayer)
                }
                myWebmap.basemap = newBasemap
                mapView.map = myWebmap

                displayLayersFromGeodatabase()

                break
            default:
                busyIndicator.visible = false
                app.messageDialog.show(qsTr("Unsupported Item Type"), qsTr("Cannot open item of type ") + mapPage.portalItem.type)
                app.messageDialog.connectToAccepted(function () { mapPage.previous() })
            }
        }
    }
    function displayLayersFromGeodatabase()
    {
        var gdbfilepath = ""
        if(Qt.platform.os === "windows")
            gdbfilepath = "file:///" + mapProperties.fileUrl + mapProperties.gdbpath
        else
            gdbfilepath = "file://" + mapProperties.fileUrl + mapProperties.gdbpath

        var dbfilePath = gdbfilepath
        offlineGdb = ArcGISRuntimeEnvironment.createObject("Geodatabase",{path:dbfilePath})
        offlineGdb.loadStatusChanged.connect(function(){
            if(offlineGdb.loadStatus === Enums.LoadStatusLoaded)
            {

                for(var i = 0; i<offlineGdb.geodatabaseFeatureTables.length;i++)
                {
                    var featureTable = offlineGdb.geodatabaseFeatureTables[i]
                    var featureLayer = ArcGISRuntimeEnvironment.createObject("FeatureLayer")
                    featureLayer.featureTable = featureTable
                    mapView.map.operationalLayers.append(featureLayer)

                }
                if(mapProperties.extent)
                    mapView.setViewpointGeometryAndPadding(mapProperties.extent,0)


                mapView.updateLayers()


            }


        }
        )
        offlineGdb.load()

    }

    function updateMapAreaInfo () {
        var fileName = "mapareasinfos.json"
        var mapAreafileName = "mobile_map.marea"
        var fileContent = {"results": []}
        var mapAreaFileContent = ""


        var storageBasePath = offlineMapAreaCache.fileFolder.path + "/"
        //first read the mapareasInfos.json file

        //var mapareacontainerpath = [storageBasePath,mapPortalItemId].join("/")
        let fileInfoMapAreaContainer = AppFramework.fileInfo(storageBasePath)
        let mapAreaContainerFolder = fileInfoMapAreaContainer.folder
        if (mapAreaContainerFolder.fileExists(fileName)) {
            fileContent = mapAreaContainerFolder.readJsonFile(fileName)
        }
        //filter the downloaded maparea from contents
        fileContent.results.map(item => item.id )
        const newArray = fileContent.results.map(item => {
                                                     if(item.id === mapPage.portalItem.id)
                                                     {
                                                         //var ts = Math.round((new Date()).getTime() / 1000)
                                                         var today = new Date();
                                                         var date = (today.getMonth()+1) + '/'+ today.getDate()+'/'+ today.getFullYear();
                                                         item.modifiedDate = date
                                                     }

                                                 }
                                                 );


        //update the jsonfile
        mapAreaContainerFolder.writeJsonFile(fileName, fileContent)
        portalSearch.populateLocalMapPackages()


    }




    function checkForUpdates()
    {
        offlineSyncTask = ArcGISRuntimeEnvironment.createObject("OfflineMapSyncTask",{map:mapView.map})

        offlineSyncTask.loadStatusChanged(getError)


        var mapUpdatesInfoTaskId =  offlineSyncTask.checkForUpdates()

        offlineSyncTask.checkForUpdatesStatusChanged.connect(function()
        {
            getUpdates(offlineSyncTask)
        }
        )

    }
    function updateMyMapArea(portalItem)
    {

        //create the map


        var newMap = ArcGISRuntimeEnvironment.createObject("Map",{ item: portalItem });

        syncGeodatabase(portalItem.title,newMap)
        //if updates available then download maparea
    }

    function syncGeodatabase(title,myMap)
    {
        var offlineSyncTask = ArcGISRuntimeEnvironment.createObject("OfflineMapSyncTask",{map:myMap})

        //check for updates
        offlineSyncTask.loadStatusChanged(getError)

        offlineSyncTask.loadErrorChanged(getError)
        //need to test below after updates
        var mapUpdatesInfoTaskId =  offlineSyncTask.checkForUpdates()

        offlineSyncTask.checkForUpdatesStatusChanged.connect(function()
        {
            getUpdates(offlineSyncTask,title)
        }
        )


    }

    function getError()
    {
        //console.log("error")
    }

    function getUpdates(offlineSyncTask,title)
    {
        var updatesInfo = offlineSyncTask.checkForUpdatesResult
        if(offlineSyncTask.checkForUpdatesStatus === Enums.TaskStatusCompleted)
        {
            var isDownloadAvailable = updatesInfo.downloadAvailability
            var isUploadAvailable = updatesInfo.uploadAvailability
            if(isUploadAvailable !== Enums.OfflineUpdateAvailabilityNone || isDownloadAvailable !== Enums.OfflineUpdateAvailabilityNone)
            {

                applyUpdates(offlineSyncTask)

            }

            else
            {
                toastMessage.show(qsTr("There are no updates available at this time."))
                mapareasbusyIndicator.visible = false
                mapSyncCompleted(title,false)
            }
        }
    }

    function applyUpdates(offlineSyncTask)
    {
        var mapsyncTaskId  = offlineSyncTask.createDefaultOfflineMapSyncParameters()

        offlineSyncTask.createDefaultOfflineMapSyncParametersStatusChanged.connect(function(){
            getParameters(offlineSyncTask)
        }
        )

    }

    function getParameters(offlineSyncTask)
    {
        if(offlineSyncTask.createDefaultOfflineMapSyncParametersStatus === Enums.TaskStatusCompleted)
        {

            var defaultMapSyncParams = offlineSyncTask.createDefaultOfflineMapSyncParametersResult
            defaultMapSyncParams.preplannedScheduledUpdatesOption = Enums.PreplannedScheduledUpdatesOptionDownloadAllUpdates


            var offlinemapSyncJob = offlineSyncTask.syncOfflineMap(defaultMapSyncParams)
            offlinemapSyncJob.start()

            offlinemapSyncJob.jobStatusChanged.connect(function(){
                updateMap(offlinemapSyncJob)
            }
            )

        }
    }
    function showDownloadCompletedMessage(message,body)
    {
        toastMessage.display(message,body)
    }

    function showDownloadFailedMessage(message,body)
    {
        if(message > "")
            messageDialog.show(qsTr("Download Failed"),body +": " + message)


    }
    function updateMap(offlinemapSyncJob)
    {
        var status = offlinemapSyncJob.jobStatus
        if(offlinemapSyncJob.jobStatus === Enums.JobStatusSucceeded)
        {
            var syncJobResult =  offlinemapSyncJob.result
            if(!syncJobResult.hasErrors)
            {


                toastMessage.show(qsTr("Offline map area syncing completed."))

                mapareasbusyIndicator.visible = false
                updateMapAreaInfo()

            }
            else
            {
                var errorMsg = syncJobResult.layerResults[0].syncLayerResult.error.additionalMessage
                //console.log("error while syncing:"+ errorMsg)
            }
        }
    }

}
