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
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1

import Esri.ArcGISRuntime 100.7

import "../controls" as Controls

Controls.Panel {
    id: panelPage

    property MapView mapView
    property string mapTitle:""
    property string owner:""
    property string modifiedDate:""

    property var headerTabNames: []
    property real headerRowHeight: 0.8 * app.headerHeight
    property real preferredContentHeight: (panelPage.fullView ? (panelPage.isLargeScreen ? panelContent.parent.height - 55 * scaleFactor : parent.height - panelHeaderHeight) : parent.height - panelPage.pageExtent - panelHeaderHeight)
    property real tabButtonHeight: headerRowHeight


    separatorColor: app.separatorColor
    panelHeaderHeight: headerRowHeight
    defaultMargin: app.defaultMargin
    appHeaderHeight: app.headerHeight
    headerBackgroundColor: app.backgroundColor
    backgroundColor: "#FFFFFF"
    isLargeScreen: app.isLarge
    iconSize: app.iconSize
    property string headerText:""
    property int currentIndex:0




    content:
        Item{

        ColumnLayout{
            id:relateddetails
            visible:false
            anchors.fill: parent
            spacing: 0

            ToolBar {

                id: identifyRelatedFeaturesViewheader

                Layout.preferredHeight:headerRowHeight
                Layout.fillWidth: true
                Material.background: headerBackgroundColor
                Material.elevation: 0

                RowLayout {
                    anchors.fill: parent
                    Controls.Icon {
                        id: closeBtn

                        visible: true
                        imageSource: "../controls/images/back.png"

                        leftPadding: 16 * scaleFactor

                        Material.background: app.backgroundColor
                        Material.elevation: 0
                        maskColor: "#4c4c4c"
                        onClicked: {
                            relateddetails.visible=false
                            panelContent.visible=true
                            isHeaderVisible = true

                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color:"transparent"

                        Controls.BaseText {

                            width:parent.width

                            text: headerText
                            maximumLineCount: 1

                            anchors.centerIn: parent

                            elide: Text.ElideRight

                            color: app.baseTextColor
                            font {
                                pointSize: app.textFontSize
                            }
                            rightPadding: app.units(16)
                        }

                    }



                }
            }


            ListView {
                id: identifyRelatedFeaturesViewlst
                Layout.fillWidth: true
                Layout.fillHeight: true


                clip: true

                delegate: ColumnLayout {
                    id: contentColumn

                    width: parent.width
                    spacing: 0

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: app.units(6)
                    }

                    Controls.SubtitleText {
                        id: lbl

                        objectName: "label"


                        text: typeof FieldName !== "undefined" ? (FieldName ? FieldName : "") : ""
                        Layout.fillWidth: true

                        Layout.preferredHeight: visible ? implicitHeight:0
                        Layout.leftMargin: app.defaultMargin
                        Layout.rightMargin: app.defaultMargin
                        Layout.bottomMargin: 6 * scaleFactor

                        wrapMode: Text.WrapAnywhere
                    }



                    Controls.BaseText {
                        id: desc
                        Layout.preferredWidth: parent.width - 16 * scaleFactor

                        objectName: "description"


                        text: typeof FieldValue !== "undefined" ? (FieldValue ? FieldValue : "") : ""

                        Layout.preferredHeight: visible ? implicitHeight:0
                        Layout.leftMargin: app.units(16)
                        Layout.rightMargin: app.units(16)
                        rightPadding: app.units(16)
                        Layout.bottomMargin: 10 * scaleFactor
                        elide: Text.ElideRight

                        wrapMode: Text.WordWrap
                        textFormat: Text.StyledText
                        Material.accent: app.accentColor





                    }


                }

            }

        }



        ColumnLayout {
            id: panelContent
            visible:true
            width:parent.width


            spacing: 0

            TabBar {
                id: tabBar
                Layout.topMargin: 0
                Layout.fillWidth: true
                clip: true

                visible: tabView.model.length > 1

                padding: 0

                Material.primary: app.primaryColor
                currentIndex: swipeView.currentIndex
                position: TabBar.Header
                Material.accent: app.primaryColor
                Material.background: headerBackgroundColor

                property alias tabView: tabView
                Repeater {
                    id: tabView

                    model: panelPage.headerTabNames
                    anchors.horizontalCenter: parent.horizontalCenter

                    TabButton {
                        id: tabButton

                        contentItem: Controls.BaseText {
                            text: modelData
                            color: tabButton.checked ? app.primaryColor : app.subTitleTextColor
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                        clip: true
                        padding: 0
                        background.height: height
                        height: tabButtonHeight

                        width: Math.max(100,(panelContent.width)/tabView.model.length)

                        Keys.onReleased: {
                            if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape){
                                event.accepted = true
                                backButtonPressed ()
                            }
                        }
                    }
                }
            }



            SwipeView {
                id: swipeView

                property QtObject currentView

                clip: true
                bottomPadding: !panelPage.fullView ? app.heightOffset : 0
                Layout.fillWidth: true

                Layout.preferredHeight:panelPage.preferredContentHeight
                Material.background:"#FFFFFF"
                currentIndex: tabBar.currentIndex
                interactive: false

                Repeater {
                    id: swipeViewDelegate

                    model: tabBar.tabView.model.length
                    Loader {
                        active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                        visible: SwipeView.isCurrentItem
                        sourceComponent: swipeView.currentView
                    }
                }

                onCurrentIndexChanged: {
                    addDataToSwipeView (swipeView.currentIndex)
                }

                Component.onCompleted: {
                    addDataToSwipeView (swipeView.currentIndex)
                }

                function addDataToSwipeView (index) {
                    if (panelPage.headerTabNames.length <= 0) return
                    switch (panelPage.headerTabNames[index]) {
                     case app.tabNames.kMapAreas:
                         swipeView.currentView = mapAreasView
                         break


                    case app.tabNames.kLegend:

                        mapView.sortLegendContentByLyrIndex()
                        swipeView.currentView = legendView
                        break
                    case app.tabNames.kContent:
                        mapView.sortLegendContent()
                        swipeView.currentView = contentView
                        break
                    case app.tabNames.kInfo:
                        mapView.updateMapInfo()
                        swipeView.currentView = infoView
                        break
                    case app.tabNames.kBookmarks:
                        swipeView.currentView = bookmarksView
                        break
                    case app.tabNames.kBasemaps:
                        swipeView.currentView = basemapsView
                        break
                    case app.tabNames.kMapUnits:
                        swipeView.currentView = mapunitsView
                        break
                    case app.tabNames.kGraticules:
                        swipeView.currentView = graticulesView
                        break
                    case app.tabNames.kFeatures:
                        swipeView.currentView = identifyFeaturesView
                        break
                    case app.tabNames.kAttachments:
                        swipeView.currentView = identifyAttachmentsView
                        break
                    case app.tabNames.kRelatedRecords:
                        swipeView.currentView = identifyRelatedFeaturesView
                        break
                    case app.tabNames.kMedia:
                        swipeView.currentView = identifyMediaView
                        break
                    case app.tabNames.kOfflineMaps:
                        swipeView.currentView = offlineMapsView
                        break
                    }
                }
            }

            Controls.SpaceFiller {}
        }
    }




    //--------------------------------------------------------------------------
    function hideDetailsView()
    {
        relateddetails.visible=false
        panelContent.visible = true
    }

    function showFeaturesView()

    {
        relateddetails.visible=false
        panelContent.visible = true
        panelPage.isHeaderVisible = true
        swipeView.addDataToSwipeView(0)
        tabBar.currentIndex = 0
    }

    function showMapAreas()
    {
        relateddetails.visible=false
        panelContent.visible = true
        panelPage.isHeaderVisible = true
        swipeView.addDataToSwipeView(0)
        tabBar.currentIndex = 0
    }

    onCurrentIndexChanged: {
        swipeView.currentIndex = 0
    }

    onBackButtonPressed: {
        app.backButtonPressed()
    }

    onVisibleChanged: {
        if (!visible) {
            app.focus = true
        }
    }

    onNextButtonClicked: {
    }

    onPreviousButtonClicked: {
    }

    Component {
        id: defaultListModel

        ListModel {
        }
    }

    //--------------------------------------------------------------------------

    onCurrentPageNumberChanged: {
        if (visible) {
            mapView.identifyProperties.highlightFeature(currentPageNumber-1)
        }
    }

    Connections {
        target: mapView.identifyProperties

        onPopupManagersCountChanged: {
            if (mapView.identifyProperties.popupManagers.length) {
                pageCount = mapView.identifyProperties.popupManagers.length
                currentPageNumber = 1
            }
        }
    }

    Component {
        id: identifyFeaturesView

        IdentifyFeaturesView {
            id: featuresView

            Component.onCompleted: {
                featuresView.bindModel()
            }

            Connections {
                target: mapView.identifyProperties

                onPopupManagersCountChanged: {
                    featuresView.bindModel()
                }
            }

            Controls.CustomListModel {
                id: attrListModel
            }

            function bindModel () {
                featuresView.model = Qt.binding(function () {
                    try {
                        var popupManager = mapView.identifyProperties.popupManagers[currentPageNumber-1]
                        featuresView.layerName = popupManager.objectName
                        var popupModel = popupManager.displayedFields
                        if (popupModel.count) {
                            var feature1 = mapView.identifyProperties.features[currentPageNumber-1]
                            var attributeJson1 = feature1.attributes.attributesJson
                            attrListModel.clear()
                            // Muhammad Ali Sr. GIS Developer Master Code Change +923332771109 | 77.muhammadali@gmail.com...
                            // Popup-Template Code | display the feilds that is being configured visible at ArcGIS Online popup configuration template
                            for(var index=0; index<popupModel.count;index ++)
                            {
                                var key = popupModel.get(index)
                                if(attributeJson1.hasOwnProperty(key.fieldName))
                                {
                                    attrListModel.append({
                                                             "label": key.label,
                                                             "fieldValue": attributeJson1[key.fieldName]!== null?attributeJson1[key.fieldName].toString():null
                                                         })
                                }

                            }
                            // END Popup-Template Code
                            // OLD Code
                           /* for(var key in attributeJson1)
                            {
                                if(attributeJson1.hasOwnProperty(key))
                                {
                                    attrListModel.append({
                                                             "label": key,
                                                             "fieldValue": attributeJson1[key]!== null?attributeJson1[key].toString():null
                                                         })
                                }

                            }*/
                            // END OLD Code
                            return attrListModel
                            //return popupManager.displayedFields
                        } else {
                            // This case handles map notes
                            var feature = mapView.identifyProperties.features[currentPageNumber-1]
                            var attributeJson = feature.attributes.attributesJson
                            attrListModel.clear()
                            if (attributeJson.hasOwnProperty("TITLE")) {
                                if (attributeJson["TITLE"]) {
                                    attrListModel.append({
                                                             "label": "TITLE", //qsTr("Title"),
                                                             "fieldValue": attributeJson["TITLE"].toString()
                                                         })
                                }
                            }
                            if (attributeJson.hasOwnProperty("DESCRIPTION")) {
                                if (attributeJson["DESCRIPTION"]) {
                                    attrListModel.append({
                                                             "label": "DESCRIPTION", //qsTr("Description"),
                                                             "fieldValue": attributeJson["DESCRIPTION"].toString()
                                                         })
                                }
                            }
                            if (attributeJson.hasOwnProperty("IMAGE_LINK_URL")) {
                                if (attributeJson["IMAGE_LINK_URL"]) {
                                    attrListModel.append({
                                                             "label": "IMAGE_LINK_URL",
                                                             "fieldValue": attributeJson["IMAGE_LINK_URL"].toString()
                                                         })
                                }
                            }
                            return attrListModel
                        }
                    } catch (err) {
                        featuresView.layerName = ""
                        return defaultListModel
                    }
                })
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: identifyAttachmentsView

        IdentifyAttachmentsView {
            id: attachementsView

            Component.onCompleted: {
                attachementsView.bindModel()
            }

            Connections {
                target: mapView.identifyProperties

                onPopupManagersCountChanged: {
                    attachementsView.bindModel()

                }
            }

            Connections {
                target: panelPage

                onCurrentPageNumberChanged: {
                    //attachementsView.bindModel()
                    attachementsView.busyIndicator.visible = true
                }
            }

            function bindModel () {
                attachementsView.busyIndicator.visible = true
                attachementsView.model = defaultListModel
                attachementsView.model = Qt.binding(function () {
                    try {
                        var popupManager = mapView.identifyProperties.popupManagers[currentPageNumber-1]
                        attachementsView.layerName = popupManager.objectName
                        return popupManager.attachmentManager.attachmentsModel
                    } catch (err) {
                        attachementsView.layerName = ""
                        return defaultListModel
                    }
                })
            }
        }
    }




    Component{
        id:identifyRelatedFeaturesView
        IdentifyRelatedFeaturesView {
            id:relatedFeaturesView

            Component.onCompleted: {
                relatedFeaturesView.bindModel()
            }
            Controls.CustomListModel {
                id: relatedFeaturesModel
            }

            Connections {
                target: mapView.identifyProperties

                onPopupManagersCountChanged: {
                    relatedFeaturesView.bindModel()
                }
            }


            Connections {
                target: panelPage

                onCurrentPageNumberChanged: {
                    relatedFeaturesView.bindModel()

                }
            }

            function getFeatureList()
            {


                relatedFeaturesModel.clear()
                var relatedFeatures = mapView.identifyProperties.relatedFeatures[currentPageNumber-1]

                var sortedFeatures =   getSortedRelatedFeatures(relatedFeatures)
                sortedFeatures.forEach(function(obj){
                    relatedFeaturesModel.append((obj))
                }
                )
                return relatedFeaturesModel


            }

            function bindModel () {

                relatedFeaturesView.featureList = getFeatureList() //Qt.binding(function () {

            }

            function getSortedRelatedFeatures(relatedFeaturesList)
            {
                var relatedFeatures = []
                relatedFeaturesList.forEach(function(feature){
                    var fclass = feature["serviceLayerName"]
                    var displayField = feature["displayFieldName"]


                    var fclassObject =  relatedFeatures.filter(function(featObj) {
                        return featObj.serviceLayerName === fclass;
                    });
                    if(fclassObject && fclassObject.length > 0)
                    {
                        relatedFeatures.map(function(featObj) {
                            if (featObj["serviceLayerName"] === fclass)
                            {
                                var isPresent = false

                                if(!isPresent)
                                {
                                    var feat = {}
                                    feat["displayFieldName"] = displayField
                                    feat["serviceLayerName"] = fclass
                                    feat.fields = feature["fields"]
                                    if(feature["geometry"])
                                        feat["geometry"] = feature["geometry"]
                                    else
                                        feat["geometry"] = ""


                                    featObj.features.append(feat)

                                }
                            }
                        })
                    }
                    else
                    {
                        fclassObject = {}
                        fclassObject["serviceLayerName"] = fclass
                        fclassObject["showInView"] = false

                        fclassObject.features =  featureListModel.createObject(parent);
                        var feat = {}
                        feat.fields = feature["fields"]
                        feat["displayFieldName"] = displayField
                        feat["serviceLayerName"] = fclass
                        if(feature["geometry"])
                            feat["geometry"] = feature["geometry"]
                        else
                            feat["geometry"] = ""

                        fclassObject.features.append(feat)
                        relatedFeatures.push(fclassObject)

                    }
                }
                )
                return relatedFeatures
            }
        }
    }

    Component {
        id: featureListModel
        ListModel {
        }
    }
    //--------------------------------------------------------------------------

    Component {
        id: identifyMediaView

        IdentifyMediaView {
            id: mediaView

            defaultContentHeight: parent ? panelPage.preferredContentHeight : 0
            Component.onCompleted: {
                mediaView.bindModel()
            }

            Connections {
                target: mapView.identifyProperties

                onPopupManagersCountChanged: {
                    mediaView.bindModel()
                }
            }

            Connections {
                target: panelPage

                onCurrentPageNumberChanged: {
                    //mediaView.bindModel()
                    mediaView.busyIndicator.visible = true
                }
            }

            function bindModel () {
                mediaView.busyIndicator.visible = true
                media = Qt.binding(function () {
                    try {
                        var identifyProperties = mapView.identifyProperties
                        layerName = identifyProperties.popupManagers[currentPageNumber-1].objectName
                        attributes = identifyProperties.features[currentPageNumber-1].attributes.attributesJson
                        fields = identifyProperties.fields[currentPageNumber-1]
                        return identifyProperties.popupDefinitions[currentPageNumber-1].media
                    } catch (err) {
                        layerName = ""
                        return []
                    }
                })
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: bookmarksView

        BookmarksView {

            model: mapView.map.bookmarks
            onBookmarkSelected: {
                mapView.setViewpointWithAnimationCurve(mapView.map.bookmarks.get(index).viewpoint, 2.0, Enums.AnimationCurveEaseInOutCubic)
                panelPage.collapseFullView()
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: offlineMapsView

        OfflineMapsView {

            model: mapView.offlineMaps
            onMapSelected: {
                mapView.mmpk.loadMmpkMapInMapView(index)
                mapView.map.legendInfos.fetchLegendInfos(true)
                mapView.updateMapInfo()
                mapView.updateLayers()
                panelPage.collapseFullView()
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: infoView

        InfoView {
            titleText: panelPage.mapTitle > ""? panelPage.mapTitle:mapView.mapInfo.title
            ownerText:panelPage.owner > ""? panelPage.owner : ""
            modifiedDateText: panelPage.modifiedDate > ""? panelPage.modifiedDate:""
            snippetText: mapView.mapInfo.snippet
            descriptionText: mapView.mapInfo.description
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: legendView

        LegendView {

            model: mapView.orderedLegendInfos//mapView.legendInfos


            Component.onCompleted: {
                mapView.updateLegendInfos()
            }

        }
    }

    Component {
        id: mapAreasView

        MapAreasView {

            model: mapAreasModel
            mapAreas: mapAreaslst
            onMapAreaSelected: {

            }


        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: contentView

        ContentView {

            model: mapView.contentsModel

            onChecked: {
                var layers = mapView.map.operationalLayers
                for (var i=0; i<layers.count; i++) {
                    var layer = layers.get(i)
                    if (!layer) continue
                    if (layer.name === name) {
                        layer.visible = checked
                        mapView.contentsModel.setProperty(index, "checkBox", checked)
                        break
                    }
                }
                var item = mapView.contentsModel.get(index)

                mapView.populateLegend(layer,item)

                app.focus = true
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: basemapsView

        BasemapsView {

            property var listModel: app.portal.basemaps

            model: listModel
            onBasemapSelected: {
                mapView.map.basemap = listModel.get(index)
                panelPage.collapseFullView()
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: mapunitsView

        MapUnitsView {
            id: mapUnits

            model: mapView.mapunitsListModel
            onCurrentSelectionUpdated: {
                mapView.updateMapUnitsModel()
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: graticulesView

        GraticulesView {
            id: graticules

            model: mapView.gridListModel
            onCurrentSelectionUpdated: {
                mapView.updateGridModel()
            }
        }
    }

    //--------------------------------------------------------------------------
}
