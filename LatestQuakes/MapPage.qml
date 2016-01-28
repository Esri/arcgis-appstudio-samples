/* ******************************************
Copyright 2015 Esri

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.​
******************************************* */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtPositioning 5.3

import "components"

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

Item {

    id: mapPage

    property bool menu_shown: false

    property url currentURL : "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_week.geojson"
    property string currentPeriod: "Past Week"

    anchors.fill: parent

    /* this functions toggles the menu and starts the animation */
    function onMenu()
    {
        game_translate_.x = menu_shown ? 0 : Math.min(app.width * 0.8, 300*app.scaleFactor)
        game_translate_header.x = menu_shown ? 0 : Math.min(app.width * 0.8, 300*app.scaleFactor)
        menu_shown = !menu_shown;
    }

    /* this rectangle contains the "menu" */
    Rectangle {
        id: menu_view_
        anchors.fill: parent
        color: app.headerBackgroundColor;
        opacity: mapPage.menu_shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        ListModel {
            id: menuModel

            ListElement {
                title: "Significant - Past Week"
                name: "Past Week"
                url: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_week.geojson"
            }

            ListElement {
                title: "Significant - Past Day"
                name: "Past Day"
                url: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_day.geojson"
            }

            ListElement {
                title: "Significant - Past Hour"
                name: "Past Hour"
                url: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_hour.geojson"
            }

            ListElement {
                title: "Significant - Last 30 Days"
                name: "Last 30 Days"
                url: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_month.geojson"
            }

        }

        /* this is menu content  */
        ListView {
            anchors { fill: parent; margins: 10*app.scaleFactor }
            model: menuModel
            delegate: Item {
                height: 80 * app.scaleFactor;
                width: parent.width;
                Text {
                    anchors { left: parent.left;verticalCenter: parent.verticalCenter }
                    color: app.textColor;
                    font.pointSize: app.textFontSize;
                    text: title

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("Menu clicked: ", url);
                            menuBackIcon.state = menuBackIcon.state === "menu" ? "back" : "menu"
                            onMenu();
                            if(currentURL != url) {
                                currentURL = url;
                                currentPeriod = name;
                                map.getRssData();
                            }
                        }
                    }
                }
                Rectangle { height: 1; width: parent.width; color: app.textColor; opacity: 0.4; anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom } }
            }
        }
    }

    AlertBox {
        visible: !AppFramework.network.isOnline
        text: "Network not available. Turn off airplane mode or use wifi to access data."
    }

    ModalWindow {
        id: modal
        backGroundColor: "white"
        textColor: "#444"
        titleTextColor: "white"
        titleBackGroundColor: app.headerBackgroundColor
        titleFont: app.customTitleFont.name
        textFont: app.cusomTextFont.name
        baseFontSize: app.baseFontSize
    }

    Rectangle {
        id: banner
        height: 50 * app.scaleFactor
        width: parent.width
        color: headerBackgroundColor

        /* this is what moves the normal view aside */
        transform: Translate {
            id: game_translate_header
            x: 0
            Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
        }

        //Add title text in the center of banner
        Text {
            id: title
            text: "Quake Feed"
            anchors.centerIn: parent
            color: textColor
            font.pointSize: app.titleFontSize
        }

        Rectangle {
            width: 48 * app.scaleFactor
            height: 48 * app.scaleFactor
            color: "transparent"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    menuBackIcon.state = menuBackIcon.state === "menu" ? "back" : "menu"
                    mapPage.onMenu();
                }
            }

            MenuBackIcon {
                id: menuBackIcon

                anchors.centerIn: parent
            }
        }

        //Add Button
        ImageButton {
            id: toggleButton
            source: "assets/refresh-white-128.png"
            width: 40 * app.scaleFactor
            height: 40 * app.scaleFactor
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 5

            checkedColor : "transparent"
            pressedColor : "transparent"
            hoverColor : "transparent"
            glowColor : "transparent"

            onClicked: {
                //refresh the data shown
                map.getRssData();
            }
        }
    }

    Map {
        id: map
        anchors.top: banner.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        //anchors.fill: parent

        /* this is what moves the normal view aside */
        transform: Translate {
            id: game_translate_
            x: 0
            Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
        }

        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: false
        mapPanningByMagnifierEnabled: false
        zoomByPinchingEnabled: true

        positionDisplay {
            positionSource: PositionSource {
            }
        }

        onExtentChanged: {
            txtLatLong.text = map.extent.center.toDecimalDegrees(4)
        }

        ArcGISTiledMapServiceLayer {
            id: topoLayer
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"
        }

        GroupLayer {
            visible: false
            id: hybridLayer

            ArcGISTiledMapServiceLayer {
                url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer"
            }

            ArcGISTiledMapServiceLayer {
                url: "http://server.arcgisonline.com/arcgis/rest/services/Reference/World_Boundaries_and_Places_Alternate/MapServer"
            }
        }

        OpenStreetMapLayer {
            id: openStreetMapLayer
            visible: false
            tileServerUrls: ["http://otile1.mqcdn.com/tiles/1.0.0/osm/",
                "http://otile2.mqcdn.com/tiles/1.0.0/osm/",
                "http://otile3.mqcdn.com/tiles/1.0.0/osm/",
                "http://otile4.mqcdn.com/tiles/1.0.0/osm/"]
            attributionText: "Data, imagery and map information provided " +
                             "by MapQuest, OpenStreetMap.org and contributors, CCBYSA"
            minZoomLevel: 0
            maxZoomLevel: 20
        }

//        ArcGISFeatureLayer {
//            url: "http://services.arcgis.com/ue9rwulIoeLEI9bj/arcgis/rest/services/Tectonic_Plate_Boundaries/FeatureServer/0"
//            maxAllowableOffset: map.resolution
//        }

        FeatureLayer {
            featureTable: GeodatabaseFeatureServiceTable {
                url: "http://services.arcgis.com/BG6nSlhZSAWtExvp/arcgis/rest/services/TectonicPlateBoundaries/FeatureServer/0"
            }
        }

        NorthArrow {
            anchors {
                right: parent.right
                top: parent.top
                margins: 5 * app.scaleFactor
            }

            visible: map.mapRotation != 0
        }

        ZoomButtons {
            id: zoomButtons
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                //top: parent.top
                margins: 5 * app.scaleFactor
            }
            map: map
        }

//        ScaleBar {
//            id: scaleBar
//            map: map
//        }

        //display on top
        Text {
            text: currentPeriod + " : " + rssGraphicLayer.numberOfGraphics
            anchors {
                margins:10*app.scaleFactor
                left: parent.left
                top: parent.top
            }

            width: parent.width

            textFormat: Text.StyledText
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 2
            wrapMode: Text.Wrap
            font {
                pointSize: app.baseFontSize * 0.9
            }
            color: app.headerBackgroundColor
        }

        Row {
            anchors.bottom: map.bottom
            anchors.left: map.left
            width: 200 * app.scaleFactor
            spacing: 2 * app.scaleFactor
            anchors.bottomMargin: 5 * app.scaleFactor
            anchors.leftMargin: 5 * scaleFactor

            CustomButton {
                buttonWidth: 50 * app.scaleFactor
                buttonHeight: 25*app.scaleFactor
                buttonText: "Topo"
                buttonFill: true
                buttonBorderRadius: 2
                buttonColor: topoLayer.visible ? app.headerBackgroundColor : AppFramework.alphaColor(app.headerBackgroundColor, 0.7)
                //buttonTextColor: topoLayer.visible? app.headerBackgroundColor : ""
                buttonFontSize: app.baseFontSize * 0.5
                onButtonClicked: {
                    hybridLayer.visible = false
                    openStreetMapLayer.visible = false
                    topoLayer.visible = true
                }
            }
            CustomButton {
                buttonWidth: 50 * app.scaleFactor
                buttonHeight: 25*app.scaleFactor
                buttonText: "OSM"
                buttonFill: true
                buttonBorderRadius: 2
                buttonColor: openStreetMapLayer.visible ? app.headerBackgroundColor : AppFramework.alphaColor(app.headerBackgroundColor, 0.7)
                buttonFontSize: app.baseFontSize * 0.5
                onButtonClicked: {
                    hybridLayer.visible = false
                    openStreetMapLayer.visible = true
                    topoLayer.visible = false

                }
            }
            CustomButton {
                buttonWidth: 50 * app.scaleFactor
                buttonHeight: 25*app.scaleFactor
                buttonText: "Hybrid"
                buttonFill: true
                buttonBorderRadius: 2
                buttonFontSize: app.baseFontSize * 0.5
                buttonColor: hybridLayer.visible ? app.headerBackgroundColor : AppFramework.alphaColor(app.headerBackgroundColor, 0.7)
                onButtonClicked: {
                    hybridLayer.visible = true
                    openStreetMapLayer.visible = false
                    topoLayer.visible = false
                }
            }
        }

        SpatialReference {
            id: wgs84
            wkid: 4326
        }

        MultiPoint {
            id: mp

            function removeAllPoints() {
                for(var i=0; i<mp.pointCount; i++) {
                    mp.removePoint(i);
                }
            }
        }

        onMouseClicked: {
            txtLatLong.text = mouse.mapPoint.toDecimalDegrees(4)
            rssGraphicLayer.findGraphics(mouse.x, mouse.y, 10, 10);
        }

        PictureMarkerSymbol {
            id: rssSymbol
            height: 8
            width: 8
            image: "assets/pin-256.png"
        }

        PictureMarkerSymbol {
            id: highlightSymbol
            height: 30
            width: 30
            image: "assets/pin-256.png"
        }


        TextSymbol {
            id: textSymbol
            size: 5
            textColor: "white"
            textOutlineColor: app.headerBackgroundColor
            textOutlineWidth: 1
        }

        function zoomMapToPoint(point) {
            var max = parseFloat(app.mapScale);
            console.log("##MapPage:: zoomMapToPoint: Resolution=> ", map.resolution, " Mapscale => ", map.mapScale);
            if(map.mapScale > max) {
                map.zoomToScale(max, point)
            } else {
                map.panTo(point);
            }
        }

        GraphicsLayer {
            id: rssGraphicLayer

            selectionSymbol: highlightSymbol

            onFindGraphicsComplete  : {

                if(!graphicIDs || graphicIDs.length === 0) {
                    console.log("No Results from graphics layer click");
                    return;
                }

                //test
                console.log(graphicIDs, graphicIDs.length, typeof graphicIDs);

                var graphics = [];
                for(var j in graphicIDs) {
                    graphics.push(rssGraphicLayer.graphic(graphicIDs[j]));
                }

                //console.log(graphics.toString())

                var id = graphicIDs;
                console.log("onFindGraphicComplete .... got id => ", id);

                clearSelection();
                modal.dataModel.clear();

                for (var i in graphics) {
                    var feature = graphics[i];
                    var attr = feature.attributes;
                    selectGraphic(feature.uniqueId);
                    //console.log(JSON.stringify(feature.attributes));
                    modal.dataModel.append({"index": i+1, "description": attr.title + "<br><br>" + attr.type + " of magnitude " + attr.mag + ". More details here: <a href='" + attr.url + "'>" + attr.url + "</a><br><br>" + new Date(attr.time).toLocaleString()})
                }
                modal.visible = true;
            }

        }

        GraphicsLayer {
            id: textGraphicsLayer
        }

        onStatusChanged: {
            if(status === Enums.MapStatusReady) {
                console.log("Map is Ready!");

                //1. Get GeoRSS points
                getRssData("http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_week.geojson")

            }
        }


        Text {
            id: txtLatLong
            text:""
            anchors {
                margins:10*app.scaleFactor
                left: parent.left
                bottom: parent.bottom
                bottomMargin: 35*app.scaleFactor
            }

            textFormat: Text.StyledText
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 2
            wrapMode: Text.Wrap
            font {
                pointSize: app.baseFontSize * 0.5
            }
            color: app.headerBackgroundColor
        }

        function getRssData() {
            var request = new XMLHttpRequest()
            request.onreadystatechange = function() {
                if (request.readyState == 4) {
                    var response = request.responseText
                    //console.log("!!! Data !!! " + response);
                    var json = JSON.parse(request.responseText);
                    //2. Parse and Add the results to the map
                    addPointsToMap(json.features);
                }
            }
            request.open("GET", currentURL, true);
            request.send();
        }

        function addPointsToMap(data) {
            var graphic, geom, attr, pt_str="", pt_wgs84;

            rssGraphicLayer.removeAllGraphics();
            textGraphicsLayer.removeAllGraphics();
            mp.removeAllPoints();

            //3. Get attributes and geometry of each entry and add it as graphic
            for(var i=0; i<data.length; i++) {

                //console.log(JSON.stringify(data[i]));

                if(data[i].properties && data[i].geometry) {
                    attr = data[i].properties;
                    pt_str = data[i].geometry.coordinates;

                    graphic = ArcGISRuntime.createObject("Graphic");
                    pt_wgs84 = ArcGISRuntime.createObject("Point");
                    pt_wgs84.spatialReference = wgs84
                    pt_wgs84.x = pt_str[0]
                    pt_wgs84.y = pt_str[1]

                    //console.log(JSON.stringify(pt_wgs84.json))

                    graphic.geometry = pt_wgs84.project(map.spatialReference);
                    graphic.attributes = attr;
                    graphic.symbol = rssSymbol
                    graphic.symbol.width = 7 * data[i].properties.mag
                    graphic.symbol.height = 7 * data[i].properties.mag
                    //console.log(JSON.stringify(graphic.json));
                    mp.add(graphic.geometry);
                    rssGraphicLayer.addGraphic(graphic);


                    var graphic2 = ArcGISRuntime.createObject("Graphic");
                    graphic2.geometry = graphic.geometry
                    textSymbol.text = data[i].properties.mag.toFixed(1)
                    graphic2.symbol = textSymbol
                    graphic2.symbol.size = 2*Math.ceil(data[i].properties.mag)
                    graphic2.attributes = {}
                    textGraphicsLayer.addGraphic(graphic2);
                }
            }

            console.log("Total points added: ", rssGraphicLayer.numberOfGraphics);

            if(mp.pointCount > 1) {
                var extent = mp.queryEnvelope();
                zoomButtons.homeExtent = extent.scale(1.2);
                map.zoomTo(extent.scale(1.2));
            }


        }
    }
}

