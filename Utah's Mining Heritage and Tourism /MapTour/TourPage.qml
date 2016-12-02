/* Copyright 2015 Esri
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

import QtQuick 2.3
import QtQuick.Controls 1.1
import QtPositioning 5.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0


TourPageHelper {
    id: tourPage

    tourMap {
        map: map
    }

    anchors.fill: parent

    property real ornamentsMinimumOpacity: 0.5
    property bool photoMode: false
    property bool isSmallScreen: (parent.width || parent.height) < 400*app.scaleFactor
    property bool mapMode: isSmallScreen ? false : true
    property bool descriptionReadMode: false

    property real screenHeight : parent.height
    property real screenWidth : parent.width
    property int bannerHeight: 50 * app.scaleFactor

    property bool isBusy : false

    property int currentPhotoIndex: -1

    property alias mapListView: featuresList


    AboutPage {
        id: aboutPage
    }


    //--------------- Basemap switching -------------

    ArcGISTiledMapServiceLayer {
        id: altBaseMap
        name: "Alt Base Map"
        url: app.basemapUrl
    }

    property bool basemapToggled : false

    //---------------------------------------------

    function toggleBasemap() {
        if(isBusy) return;
        isBusy = true
        console.log("********* ##TourPage:: toggleBaseMap ***********");

        console.log("Map WKID: ", map.spatialReference.wkid, " , Alt basemap wkid: ", altBaseMap.defaultSpatialReference.wkid, altBaseMap.spatialReference.wkid);

        //if(map.spatialReference.wkid !== altBaseMap.spatialReference.wkid) {
        if(map.spatialReference.wkid !== (102100 || 3857 || 103113)) {
            console.log("Spatial Ref do not match cannot change basemaps");
            return
        }

        var posToInsert = tourMap.basemapLayersCount;

        for (var index = 0; index < map.layerCount; index++) {
            var layer = map.layerByIndex(index);
            console.log("## ", index, " Map layer: " , layer.layerId , layer.name, layer.layerType, layer.url, layer.visible);

            if(layer.type === 2 && index<2) {
                layer.visible = basemapToggled ? true: false;
            }
        }

        console.log("Position to insert: ", posToInsert);

        if(!basemapToggled) {
            map.insertLayer(altBaseMap,parseInt(posToInsert))
            basemapToggled = true
        } else {
            //map.removeLayer(streetMapBaseMap)
            map.removeLayerByIndex(posToInsert)
            basemapToggled = false
        }

        console.log("****** AFTER *****")
        for (var index2 = 0; index2 < map.layerCount; index2++) {
            layer = null;
            layer = map.layerByIndex(index2);
            console.log("## ", index2, " Map layer: " , layer.layerId , layer.name, layer.layerType, layer.url, layer.visible);
        }
        isBusy = false
    }

    //-------------------- timer --------------------

    Timer {
        interval: 2500; running: true; repeat: false
        onTriggered: {
            if(isSmallScreen) {
                zoomButtons.visible = false
            }
        }
    }

    //------------------------- CARD VIEW -------------------------------------------

    Rectangle {
        anchors.fill: parent
        color: "black"
        z:-1

    }


    ScrollBar {
        id: scrollBar1
        scrollItem: cardList
        orientation: "vertical"
    }

    Component {
        id: cardListItemMobileDelegate
        CardListItemMobileDelegate {}
    }

    Component {
        id: cardListItemDelegate
        CardListItemDelegate {}
    }


    ListView {
        id: cardList
        //anchors.fill: parent
        orientation: ListView.Vertical
        height: screenHeight - bannerHeight
        width: screenWidth
        visible: !mapMode
        clip: true
        currentIndex: currentPhotoIndex
        spacing: 5*app.scaleFactor

        preferredHighlightBegin: 0;
        preferredHighlightEnd: 0  //this line means that the currently highlighted item will be central in the view

        highlightResizeDuration: 10
        highlightResizeVelocity: 2000
        highlightMoveVelocity: 2000
        highlightMoveDuration: 10

        cacheBuffer: isSmallScreen ? parent.height : parent.height*3

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: banner.bottom
            bottomMargin: 10*app.scaleFactor
            topMargin: 10*app.scaleFactor
        }

        highlight: Rectangle {
            id: rectangle

            width: parent.width
            height: 10
            anchors.horizontalCenter: parent.horizontalCenter

            color: app.selectColor
            opacity: 0.8
            radius: 0

            y: rectangle.ListView.view ? rectangle.ListView.view.currentItem.y : 0

            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }

        model:tourItemsListModel

        //delegate: CardListItemMobileDelegate{}
        delegate: isSmallScreen? cardListItemMobileDelegate : cardListItemDelegate

    }

    //--------------------------------------------------------------------------

    //--------------------------------------------------------------------------

    Map {
        id: map

        visible: mapMode && !photoMode

        anchors {
            left: parent.left
            right: parent.right
            //top: banner.bottom
            top: parent.top
            bottom: footer.visible ? footer.top : parent.bottom
        }

        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: true
        mapPanningByMagnifierEnabled: true

        positionDisplay {
            zoomScale: app.mapScale
            positionSource: PositionSource {
                id: positionSource
                onSourceErrorChanged: {
                    console.log("source error ", sourceError)
                    //TODO check for GPS error and handle it
                }
            }
        }

        onExtentChanged: {
            //console.log(JSON.stringify(map.extent.json))
            //console.log(JSON.stringify(map.extent.scale(2).json));
            console.log("Map Scale: ", map.mapScale)
        }

        onMouseClicked: {

            // find feature
            var features = null;
            var feature = null;

            if(tourFeatureLayer) {
                features = tourFeatureLayer.findFeatures(mouse.x, mouse.y, 10, 1);
                console.log("Features clicked : " + features.length);
                if(features.length > 0) {
                    var id = features[0];
                    console.log("##TourPage:: Feature Click ID: ", id);
                    //console.log(tourFeatureLayer.featureTable.tableName);

                    //new code 10/3 to fix crash
                    //var feature2 = tourFeatureLayer.featureTable.feature(id);

                    //console.log("############### ################# ################### ##################");
                    //printJson(feature2.json)

                    var newindex = getCurrentItemIndex(id);
                    console.log("##TourPage:: New index of list view is: ", newindex)

                    featuresList.currentIndex = newindex;
                    featuresList.positionViewAtIndex(newindex,ListView.Left);
                    feature = tourItemsListModel.get(newindex);

                    //printJson(feature.attributes)

                    //3/19/2015 to resolve wrong photo selection when clickin the map
                    //featuresList.currentIndex = id-1;
                    //featuresList.positionViewAtIndex(id-1,ListView.Left);
                    //feature = tourItemsListModel.get(id-1);

                    currentPhotoIndex = featuresList.currentIndex;

                    //new code 10/3 to fix crash - END

                    if(feature && feature.geometry) {

                        //console.log(map.resolution);

                        zoomMapToPoint(feature.geometry);

                        //var objectID = feature.attributes["objectid"] || feature.attributes["OBJECTID"] || feature.attributes["F__OBJECTID"];
                        var objectID = feature.attributes["objectid"];

                        console.log("##TourPage onMouseClicked:: objectID for click graphic: ", objectID);

                        if(isNumeric(objectID)) {
                            //featuresList.currentIndex = getCurrentItemIndex(objectID);
                            tourFeatureLayer.clearSelection();
                            tourFeatureLayer.selectFeature(objectID);
                        }
                    } else {
                        console.log("##TourPage onMouseClicked:: Unable to find feature from featurelayer.");
                    }
                } else {
                    //toggle the top bar
                    //banner.visible = app.showGallery && !banner.visible
                    console.log("Map scale: ", map.mapScale)
                }


            } else if (tourGraphicsLayer) {
                tourGraphicsLayer.findGraphics(mouse.x, mouse.y, 10, 1);
                console.log("Graphic click ");
            }

        }
    }
    //----------------------------------------------------------------------

    NorthArrow {
        id: northArrow
        anchors {
            right: parent.right
            top: banner.visible ? banner.bottom : parent.top
            margins: 5 * app.scaleFactor
        }

        map: map
        visible: map.mapRotation != 0
        fader.minumumOpacity: ornamentsMinimumOpacity
    }

    ZoomButtons {
        id: zoomButtons
        visible: mapMode && !photoMode && map.visible
        anchors {
            right: parent.right
            verticalCenter: map.verticalCenter
            margins: 5 * app.scaleFactor
        }
        map: map
        fader.minumumOpacity: ornamentsMinimumOpacity
    }

    ImageButton {
        id: basemapButton
        source: "images/basemap.png"
        visible: app.showBasemapSwitcher && zoomButtons.visible
        width: 40*app.scaleFactor
        height: width

        radius: 8

        opacity: zoomButtons.fader.minumumOpacity

        anchors {
            right: parent.right
            top: zoomButtons.bottom
            margins:5 * app.scaleFactor
        }

        checkedColor : "transparent"
        pressedColor : "transparent"
        hoverColor : "transparent"
        glowColor : "transparent"

        onClicked: {
            toggleBasemap();
        }
    }

    Item {

        anchors {
            left: map.left
            right: map.right
            bottom: map.bottom

        }

        visible: map.visible

        height: copyRightText.height
        width: copyRightText.width

        Rectangle {
            anchors.fill: copyRightText
            anchors.margins: -3;
            //color: "#444444"
            //opacity: 0.4;
            gradient: Gradient {
                GradientStop { position: 1.0; color: "#55000000";}
                GradientStop { position: 0.0; color: "#05000000";}
            }
        }

        Text {
            id: copyRightText
            text: qsTr("Map Credits: ") + tourPage.mapCredits;
            elide: Text.ElideRight
            textFormat: Text.PlainText
            anchors.margins: 5*app.scaleFactor;
            //anchors.right: map.width - 200
            width: map.width - 60*app.scaleFactor

            font {
                pointSize: app.baseFontSize * 0.5
            }
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            //wrapMode: Text.Wrap

            MouseArea {
                anchors.fill: parent
                onClicked: {

                    if(copyRightText.wrapMode == Text.Wrap) {
                        copyRightText.wrapMode = Text.NoWrap
                    } else {
                        copyRightText.wrapMode = Text.Wrap
                    }

                }

            }

        }
    }



    //---------------------------------------------

    Rectangle {
        anchors.fill: parent
        id: busyIndicator

        BusyIndicator {
            running: true
            anchors.centerIn: parent
        }
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: banner

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: bannerHeight
        color: app.headerBackgroundColor
        //opacity: 0.9


        MouseArea {
            anchors.fill: parent
            onClicked: {
                mouse.accepted = false
            }
        }


        ImageButton {
            id: exitButton

            visible: app.showGallery && !photoMode

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                margins: 5*app.scaleFactor
            }
            width: 36*app.scaleFactor

            source: "images/left1.png"

            checkedColor : "transparent"
            pressedColor : "transparent"
            hoverColor : "transparent"
            glowColor : "transparent"

            onClicked: {
                exit();
            }
        }

        ImageButton {

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                margins: 5*app.scaleFactor
            }

            checkedColor : "transparent"
            pressedColor : "transparent"
            hoverColor : "transparent"
            glowColor : "transparent"

            height: 30 * app.scaleFactor
            width: 30 * app.scaleFactor

            source: "images/info.png"

            visible: !app.showGallery

            onClicked: {
                aboutPage.visible = true;
            }
        }

        ImageButton {
            id: optionsButton

            visible: !photoMode && mapMode

            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                margins: 5 * app.scaleFactor
            }
            width: 30*app.scaleFactor

            source: "images/more.png"

            checkedColor : "transparent"
            pressedColor : "transparent"
            hoverColor : "transparent"
            glowColor : "transparent"

            onClicked: {
                zoomButtons.visible = !zoomButtons.visible
            }
        }


        Text {
            id: titleText

            anchors {
                left: exitButton.right
                right: parent.right
                //rightMargin: exitButton.width + exitButton.anchors.margins
                verticalCenter: parent.verticalCenter
            }

            text: tourItemInfo ? tourItemInfo.title : app.info.title
            elide: Text.ElideRight

            font.family: app.customTitleFont.name

            font {
                pointSize: app.baseFontSize * 0.8
            }
            //color: "#f7f8f8"
            color: app.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: false
        }


        Rectangle {
            id: buttonBar
            //visible: false
            anchors {
                left: exitButton.right
                //rightMargin: exitButton.width + exitButton.anchors.margins
                //verticalCenter: parent.verticalCenter
                //horizontalCenter: parent.horizontalCenter
                centerIn: parent
            }

            color: "transparent"
            radius: 2
            border.color: "#FFFFFF"
            border.width: 1

            height: bannerHeight*0.8
            width: 120 * app.scaleFactor

            GridLayout {
                rowSpacing: 0
                columnSpacing: 0
                columns: 2
                anchors.verticalCenter: parent.verticalCenter
                anchors {
                    fill: parent
                }

                Rectangle {
                    width:  buttonBar.width/2
                    height: parent.height
                    anchors.margins: 0
                    //border.color: "white"
                    // border.width: 2
                    radius: 2
                    color: (mapMode && !photoMode) ? "transparent" : "white"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mapMode = false
                            photoMode = false
                            zoomButtons.visible = false
                        }
                    }

                    Text {
                        text: qsTr("List")
                        anchors.centerIn: parent
                        font {
                            pointSize: app.baseFontSize * 0.8
                        }
                        anchors.verticalCenter: parent.verticalCenter
                        color: (mapMode && !photoMode)? "white" : "black"
                        font.family: app.customTextFont.name
                    }
                }

                Rectangle {
                    width:  buttonBar.width/2
                    height: parent.height
                    anchors.margins: 0
                    color: mapMode&&!photoMode ? "white" : "transparent"
                    Text {
                        text: qsTr("Map")
                        anchors.centerIn: parent
                        font {
                            pointSize: app.baseFontSize * 0.8
                        }
                        anchors.verticalCenter: parent.verticalCenter
                        color: mapMode&&!photoMode ? "black" : "white"
                        font.family: app.customTextFont.name
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            photoMode = false
                            mapMode = true
                        }
                    }
                }

            }
        }


    }

    //-----------------------------

    //check for internet

    AlertBox {
        visible: !AppFramework.network.isOnline
        text: qsTr("Network not available. Turn off airplane mode or use wifi to access data.")
    }

    //--------------------------------------------------------

    Rectangle {
        id: messageBox

        anchors {
            left: map.left
            right: map.right
            bottom: map.bottom
        }

        height: (messageBoxText.contentHeight + 20) * app.scaleFactor
        //color: app.headerBackgroundColor
        color: "red"
        //opacity: ornamentsMinimumOpacity

        visible: false

        Text {
            id: messageBoxText
            color: "white"
            //fontSizeMode: Text.Fit
            anchors.fill: parent
            anchors.margins: 10*app.scaleFactor
            maximumLineCount: 3
            font.family: app.customTextFont.name

            anchors.leftMargin: 5*app.scaleFactor
            anchors.rightMargin: 5*app.scaleFactor

            wrapMode: Text.Wrap

            anchors.verticalCenter: messageBox.verticalCenter
            anchors.horizontalCenter: messageBox.horizontalCenter

            font {
                pointSize: app.baseFontSize * 0.8
            }

        }
    }

    onTourError: {
        messageBox.visible = message&&app.isOnline? true : false;
        messageBoxText.text = message? message : "Something went wrong. Sorry!";
    }

    //----------------------------------

    Rectangle {
        id: footer

        visible: tourItemsListModel.count > 0 && mapMode ? true : false

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        //height: photoMode ? parent.height * 3/4 : parent.height/3
        height: photoMode ? (parent.height - banner.height) : parent.height/3
        width: map.width
        color: "#000000"
        //color: app.headerBackgroundColor





        ListView {
            id: featuresList
            anchors.fill: parent
            //anchors.margins: 2
            //anchors.topMargin: 20
            spacing: 5 * app.scaleFactor
            orientation: ListView.Horizontal
            //width: footer.width
            height: footer.height

            visible: mapMode

            //interactive: true


            highlight: Rectangle {
                id: itemHighlight
                color: app.selectColor
                height: featuresList.height
                radius: 0
                focus: true
                visible: !photoMode
            }




            focus: true
            clip: true


            // ------------------- Testing ------
            //snapMode: ListView.SnapToItem
            snapMode: ListView.SnapOneItem
            //cacheBuffer: width * 3;
            preferredHighlightBegin: 0;
            preferredHighlightEnd: 0  //this line means that the currently highlighted item will be central in the view
            //highlightRangeMode: ListView.StrictlyEnforceRange  //this means that the currentlyHighlightedItem will not be allowed to leave the view
            highlightFollowsCurrentItem: true  //updates the current index property to match the currently highlighted item
            highlightResizeDuration: 10
            highlightResizeVelocity: 2000
            highlightMoveVelocity: 2000
            highlightMoveDuration: 10

            currentIndex: -1


            //android back button
            Keys.onReleased: {
                if (event.key === Qt.Key_Back) {
                    console.log("Back button captured!")
                    event.accepted = true
                    if(mapMode || photoMode) {
                        mapMode = false
                        photoMode = false
                    } else {
                        //list view
                        exit();
                    }

                }
            }

            //key board support
            Keys.onLeftPressed: {
                console.log("left key pressed");
                if (currentIndex > 0 ) {
                    currentIndex = currentIndex-1;
                }
                onGraphicClickHandler(currentIndex);
            }
            Keys.onRightPressed: {
                console.log("right key pressed");
                if (currentIndex < count) {
                    currentIndex = currentIndex+1;
                }
                onGraphicClickHandler(currentIndex);
            }
            Keys.onEnterPressed: {
                console.log("enter key pressed ", currentIndex);
                onGraphicClickHandler(currentIndex);
            }

            Keys.onReturnPressed: {
                console.log("return key pressed ", currentIndex);
                onGraphicClickHandler(currentIndex);
            }

            //---------------------

            model:tourItemsListModel

            //----------------------

            Component {
                id: featuresListDelegate


                Rectangle {
                    id: itemOuterBox
                    color: "transparent"
                    height: featuresList.height
                    //width: photoMode? Math.min(map.width, 1024*app.scaleFactor) : height * 1.5
                    //width: photoMode? Math.min(map.width, 1024*app.scaleFactor) : Math.min(map.width, 640);

                    width: (function(){
                        var value = 100;

                        if(photoMode) {
                            value = Math.min(map.width, 1024*app.scaleFactor)
                        } else {
                            value = isSmallScreen ? map.width : itemOuterBox.height*1.5
                        }

                        return value;
                    })();

                    ScrollBar {
                        scrollItem: descriptionArea
                        orientation: "vertical"
                        isVisible: photoMode
                    }


                    Flickable {
                        id: descriptionArea

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                        }

                        //visible: photoMode;
                        width: parent.width
                        height: parent.height
                        //contentHeight: flickableDescription.contentHeight + flickableTitle.contentHeight + 30
                        contentHeight: photoMode ? height + flickableDescription.contentHeight - 60*app.scaleFactor : height
                        clip: true

                        Item {
                            anchors.fill: parent

                            Image {
                                id: itemImage
                                anchors.top: parent.top
                                width: parent.width
                                //height: photoMode? parent.height: parent.height - 5
                                height: photoMode ? attributes.description.length>0 ? itemOuterBox.height *4/5 : itemOuterBox.height : itemOuterBox.height - 5
                                //anchors.bottom: photoMode ? "a" : parent.bottom
                                asynchronous: true
                                //                                source: photoMode? (attributes.is_video ? attributes.thumb_url : attributes.pic_url) : attributes.thumb_url
                                source: photoMode? (attributes.is_video ? attributes.thumb_url : attributes.pic_url) : attributes.pic_url

                                fillMode: autoCropImage? Image.PreserveAspectCrop : Image.PreserveAspectFit
                                smooth: true

                                onStatusChanged: if (itemImage.status == Image.Error) itemImage.source = "images/placeholder.jpg"

                                Image {
                                    id: playVideoImage
                                    anchors.centerIn: parent
                                    visible: photoMode && attributes.is_video
                                    source: "images/video.png"
                                    width: 100*app.scaleFactor
                                    height: 100*app.scaleFactor
                                    z:25
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            console.log("Video button clicked!!!");
                                            console.log(attributes.pic_url);
                                            var url = (attributes.pic_url.indexOf("//") === 0 ? "http:" : "") + attributes.pic_url;
                                            console.log(url);
                                            Qt.openUrlExternally(url);
                                        }
                                    }



                                }


                                Text {
                                    visible: photoMode && attributes.is_video
                                    text: qsTr("Click to Open Video")
                                    font.bold: true
                                    font.family: app.customTextFont.name
                                    color: "white"

                                    horizontalAlignment: Text.AlignHCenter
                                    width: parent.width
                                    anchors {
                                        top: playVideoImage.bottom
                                        topMargin: 15*app.scaleFactor
                                    }
                                    font {
                                        pointSize: app.baseFontSize * 0.8
                                    }
                                    wrapMode: Text.Wrap
                                    textFormat: Text.StyledText
                                    linkColor: "#e5e6e7"

                                }




                                Rectangle {
                                    anchors.fill: parent
                                    //color: app.headerBackgroundColor
                                    color: "#000000"
                                    opacity: 0.9
                                    visible: true
                                    z:-1
                                }

                                BusyIndicator {
                                    visible: itemImage.status !== (Image.Ready || Image.Error)
                                    anchors.centerIn: parent
                                }

                                SwipeArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log(" **** Photo Clicked : " + index );
                                        featuresList.positionViewAtIndex(index,ListView.Left);
                                        featuresList.currentIndex = index;
                                        onGraphicClickHandler(index);
                                    }

                                    onDoubleClicked: {
                                        console.log(" %%%% Photo Double Clicked : " + index + " %% height & width => " , footer.parent.height, map.width);
                                        photoMode = !photoMode
                                        //featuresList.positionViewAtIndex(index,ListView.Left);
                                        //featuresList.currentIndex = index;
                                    }

                                    onSwipe: {
                                        console.log("###Tourpage:: Swipe gesture : ", direction)
                                        if(direction === "up") {
                                            photoMode = true
                                        }

                                        if(direction === "down") {
                                            photoMode = false
                                        }
                                    }
                                }

                                //---------------
                                Item {
                                    anchors.top: itemImage.top
                                    anchors.right: itemImage.right
                                    height: 35 * app.scaleFactor
                                    width: 35 * app.scaleFactor

                                    Rectangle {
                                        anchors.fill: parent
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "#66000000";}
                                            GradientStop { position: 1.0; color: "#22000000";}
                                        }

                                        ImageButton {
                                            id: expandButton
                                            source: "images/back-left.png"
                                            rotation: photoMode ? 270 : 90
                                            height: 30* app.scaleFactor
                                            width: 30* app.scaleFactor
                                            anchors.centerIn: parent
                                            checkedColor : "transparent"
                                            pressedColor : "transparent"
                                            hoverColor : "transparent"
                                            glowColor : "transparent"
                                            onClicked: {

                                                photoMode = !photoMode
                                                console.log(" **** expand button clicked : " + index);
                                                featuresList.positionViewAtIndex(index,ListView.Left);
                                                featuresList.currentIndex = index;
                                                onGraphicClickHandler(index);
                                            }
                                        }
                                    }

                                }

                                //----------------
                                Rectangle {
                                    id: itemCountBackground
                                    anchors {
                                        //fill: itemAttributes
                                        //left: itemImage.left
                                        top: itemImage.top
                                    }
                                    anchors.horizontalCenter: itemImage.horizontalCenter
                                    height: 35 * app.scaleFactor
                                    width: leftButton.width + rightButton.width + itemCountBanner.contentWidth + (index >0 && index <featuresList.count-1 ? 20 : 0)
                                    //color: "#80000000"
                                    //color: getColorName(attributes.icon_color)
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#66000000";}
                                        GradientStop { position: 1.0; color: "#22000000";}
                                    }


                                    GridLayout {
                                        columns: 3
                                        anchors {
                                            centerIn: parent
                                        }
                                        ImageButton {
                                            id: leftButton
                                            source: "images/back-left.png"
                                            height: 25 * app.scaleFactor
                                            width: 25 * app.scaleFactor
                                            anchors.rightMargin: 10
                                            checkedColor : "transparent"
                                            pressedColor : "transparent"
                                            hoverColor : "transparent"
                                            glowColor : "transparent"
                                            //anchors.top: parent.top
                                            //anchors.left: itemCountBanner.left
                                            visible: index > 0 ? 1 : 0
                                            onClicked: {
                                                console.log(" **** left arrow clicked : " + index);
                                                featuresList.positionViewAtIndex(index-1,ListView.Left);
                                                featuresList.currentIndex = index-1;
                                                onGraphicClickHandler(index-1);
                                            }
                                        }

                                        Text {
                                            id: itemCountBanner
                                            font.family: app.customTextFont.name
                                            text: (index+1) + qsTr(" of ") + featuresList.count
                                            color: "white"
                                            //color: getColorName(attributes.icon_color)
                                            //font.bold: true
                                            //font.italic: true
                                            anchors {
                                                //top: parent.top
                                                //right: itemImage.right
                                                //left: leftButton.right
                                                //centerIn: parent
                                                //margins:2
                                            }
                                            font {
                                                pointSize: app.baseFontSize * 0.6
                                            }
                                        }

                                        ImageButton {
                                            id: rightButton
                                            source: "images/back-left.png"
                                            rotation: 180
                                            height: 25 * app.scaleFactor
                                            width: 25 * app.scaleFactor
                                            checkedColor : "transparent"
                                            pressedColor : "transparent"
                                            hoverColor : "transparent"
                                            glowColor : "transparent"
                                            anchors.leftMargin: 10
                                            //anchors.top: parent.top
                                            //anchors.right: itemCountBanner.right
                                            visible: index < featuresList.count-1 ? 1 : 0
                                            onClicked: {
                                                console.log(" **** right arrow Clicked : " + index);
                                                featuresList.positionViewAtIndex(index+1,ListView.Left);
                                                featuresList.currentIndex = index+1;
                                                onGraphicClickHandler(index+1);
                                            }
                                        }
                                    }
                                }


                                //------
                                Rectangle {
                                    id: itemTextBackground
                                    anchors {
                                        fill: itemAttributes
                                        margins:-10*app.scaleFactor
                                    }
                                    height: itemAttributes.contentHeight + 10
                                    visible: itemAttributes.visible

                                    gradient: Gradient {
                                        GradientStop { position: 1.0; color: "#77000000";}
                                        GradientStop { position: 0.0; color: "#22000000";}
                                    }
                                }

                                Text {
                                    id: itemAttributes
                                    font.family: app.customTitleFont.name
                                    //text: truncate(name, itemImage.width)
                                    text: attributes.name
                                    color: "white"
                                    textFormat: Text.StyledText
                                    font.bold: photoMode
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    maximumLineCount: 2
                                    elide: Text.ElideNone
                                    anchors {
                                        left: itemImage.left
                                        right: itemImage.right
                                        bottom: itemImage.bottom
                                        margins: 8*app.scaleFactor

                                    }
                                    font {
                                        pointSize: app.baseFontSize * 0.8
                                    }
                                    width: itemImage.width
                                    //visible: !photoMode
                                }

                                //-------

                            }

                            //--------------

                            Item {
                                //anchors.fill: parent
                                anchors {
                                    left: itemImage.left
                                    right: itemImage.right
                                    top: itemImage.bottom
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    gradient: Gradient {
                                        GradientStop { position: 0.0; color: "#aa000000";}
                                        GradientStop { position: 1.0; color: "#77000000";}
                                    }
                                }

                                Text {
                                    id: flickableDescription
                                    font.family: app.customTextFont.name
                                    text: attributes.description
                                    wrapMode: Text.Wrap
                                    textFormat: Text.StyledText
                                    //visible: photoMode && attributes.description.length > 0
                                    font {
                                        pointSize: app.baseFontSize * 0.7
                                    }
                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        right: parent.right
                                        margins: 8*app.scaleFactor
                                    }
                                    color: "white"
                                    linkColor: "#e5e6e7"
                                    onLinkActivated: {
                                        Qt.openUrlExternally(link);
                                    }
                                }

                            }


                        } //--- item
                    } // ---- flickable
                    //-------
                }
                //------ end of outerbox ---
            }
            delegate: featuresListDelegate

            onFlickEnded: {
                //console.log("flick ended at ", contentX, contentY  , indexAt(contentX, contentY));
                currentIndex = indexAt(contentX, contentY);
                onGraphicClickHandler(currentIndex);
            }



        }
    }

    // -------------------------

    Connections {
        target: tourGraphicsLayer

        onFindGraphicsComplete  : {


            console.log(tourGraphicsLayer.selectionColor);

            var id = graphicIDs;
            console.log("##TourPage:: onFindGraphicComplete .... got id => ", id, typeof id);
            //tourGraphicsLayer.clearSelection();

            var feature = null;
            for(var i=0; i<tourGraphicsLayer.graphics.length; i++) {
                //console.log(tourGraphicsLayer.graphics[i].uniqueId, typeof id, typeof tourGraphicsLayer.graphics[i].uniqueId, parseInt(tourGraphicsLayer.graphics[i].uniqueId) === parseInt(id));
                //if(tourGraphicsLayer.graphics[i].attributes.__OBJECTID === id) {
                if(parseInt(tourGraphicsLayer.graphics[i].uniqueId) === parseInt(id)) {
                    feature = tourGraphicsLayer.graphics[i];
                    break;
                }

            }

            if(feature && feature.geometry && feature.geometry.x) {
                tourGraphicsLayer.clearSelection();
                tourGraphicsLayer.selectGraphic(feature.uniqueId);
                //printJsonFromObject(feature);
                //console.log("current item index: ", getCurrentItemIndex(feature.attributes.__OBJECTID));
                featuresList.currentIndex = getCurrentItemIndex(feature.attributes.__OBJECTID);
                currentPhotoIndex = featuresList.currentIndex
                zoomMapToPoint(feature.geometry);
            }
        }

    }

    // -------------------------

    function onGraphicClickHandler(index) {

        currentPhotoIndex = index

        if (index < tourItemsListModel.count) {
            index = index+1;
        }

        if (index > 0) {
            index = index-1;
        }

        console.log("Got index: ", index);

        var feature = null;
        var objectId = null;

        //printJson(tourItemsListModel.get(index));

        if(tourFeatureLayer) {
            //console.log("tourfeaturelayer ...");
            feature = tourItemsListModel.get(index);

            tourFeatureLayer.clearSelection();
            //objectId = tourItemsListModel.get(index).objectid || tourItemsListModel.get(index).OBJECTID;

            //printJsonFromObject(feature.attributes);
            objectId = feature.attributes.objectid || feature.attributes.OBJECTID;
            if(isNumeric(objectId)) {
                console.log("##TourPage:: onGraphicClickHandler : got objectid => ", objectId);
                //feature = tourFeatureLayer.featureTable.feature(objectId);
                tourFeatureLayer.selectFeature(objectId);
            } else {
                console.log("##TourPage:: onGraphicClickHandler:  ERROR OBjectID is NULL !!! PLEASE CHECK ******");
                printJson(tourItemsListModel.get(index));
            }
        } else if(tourGraphicsLayer) {
            tourGraphicsLayer.clearSelection();
            objectId = tourItemsListModel.get(index).attributes.__OBJECTID;
            if(isNumeric(objectId)) {
                //console.log(objectId);
                for(var i=0; i<tourGraphicsLayer.graphics.length; i++) {
                    console.log("Comparing: " , tourGraphicsLayer.graphics[i].attributes.__OBJECTID, objectId);
                    if(tourGraphicsLayer.graphics[i].attributes.__OBJECTID === objectId) {
                        feature = tourGraphicsLayer.graphics[i];
                        feature.bringToFront();
                        feature.selected = true;
                        //tourGraphicsLayer.selectGraphic(objectId);
                        tourGraphicsLayer.selectGraphic(tourGraphicsLayer.graphics[i].uniqueId);
                        break;
                    }
                }
            } else {
                console.log("####   ERROR OBjectID is NULL !!! PLEASE CHECK ******");
                printJson(tourItemsListModel.get(index));
            }
        }

        if(feature && isNumeric(objectId)) {
            console.log("## Map resolution: ", map.resolution , " Map Scale: ", map.mapScale);

            zoomMapToPoint(feature.geometry);

            //console.log(feature.geometry.x, feature.geometry.y);

        }

    }

    function getCurrentItemIndex(objectid) {
        console.log("##TourPage:: getCurrentItemIndex: Got objectid => ", objectid);
        for(var i = 0; i < tourItemsListModel.count; ++i) {
            var item = tourItemsListModel.get(i).attributes;
            //printJson(item)
            console.log("comparing ", item.objectid , " with ", objectid);
            if (parseInt(item.objectid) === parseInt(objectid) ||  item.OBJECTID === objectid || item.__OBJECTID === objectid) {
                console.log("found match, returning list view index: ", i)
                return i;
            }
        }
        return -1;
    }

    function zoomMapToPoint(point) {
        var max = parseFloat(app.mapScale);
        console.log("##TourPage:: zoomMapToPoint: Resolution=> ", map.resolution, " Mapscale => ", map.mapScale);
        if(map.mapScale > max) {
            map.zoomToScale(max, point)
        } else {
            map.panTo(point);
        }
    }

    function isNumeric(n) {
        return !isNaN(parseFloat(n)) && isFinite(n);
    }
}

