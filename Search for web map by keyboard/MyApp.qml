/* Copyright 2021 Esri
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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10
import Esri.ArcGISRuntime.Toolkit 100.10

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736

    Material.accent: "#8f499c"

    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    property var portalItem
    // webmaps authored prior to July 2nd, 2014 are not supported - so search only from that date to the current time
    property string fromDate: "000000" + new Date('Wed, 02 Jul 2014 00:00:00 GMT').getTime()
    property string toDate: "000000" + new Date().getTime()

    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle{
            anchors.top:header.bottom



            //! [Portal findItems webmaps part 1]


            PortalQueryParametersForItems {
                id: webmapQuery
                types: [ Enums.PortalItemTypeWebMap ]

                searchString: 'tags:\"' + keyWordField.text + '\" AND + uploaded:[' + fromDate + ' TO ' + toDate +']';
            }
            //! [Portal findItems webmaps part 1]

            Portal {
                id: portal

                Component.onCompleted: load();

                onLoadStatusChanged: {
                    if (loadStatus === Enums.LoadStatusFailedToLoad)
                        retryLoad();

                    if (loadStatus !== Enums.LoadStatusLoaded)
                        return;

                    searchBox.visible = true
                    keyWordField.focus = true
                }

                //! [Portal findItems completed]
                onFindItemsResultChanged: {
                    if (portal.findItemsStatus !== Enums.TaskStatusCompleted)
                        return;

                    // bind the item list model to the view
                    webmapsList.model = portal.findItemsResult.itemResults
                    webmapsList.visible = true;
                    webmapsList.focus = true;
                }
                //! [Portal findItems completed]
            }

            Component {
                id: webmapDelegate
                Rectangle {
                    anchors.margins: 25
                    width: webmapsList.width
                    height: 32 * scaleFactor
                    border.color: "white"
                    border.width: 2 * scaleFactor
                    color: "lightgrey"
                    radius: 10

                    //! [PortalItemListModel example QML delegate]
                    Text {
                        anchors {
                            fill: parent;
                            margins: 10
                        }
                        text: title
                        color: "white"
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                    //! [PortalItemListModel example QML delegate]

                    MouseArea {
                        anchors.fill: parent
                        onClicked: webmapsList.currentIndex = index;
                        onDoubleClicked: loadSelectedWebmap(webmapsList.model.get(index));
                    }
                }
            }

            Component {
                id: highlightDelegate
                Rectangle {
                    z: 110
                    anchors.margins: 25
                    width: webmapsList.width
                    height: 24 * scaleFactor
                    color: "orange"
                    radius: 4

                    Text {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        text: webmapsList.model.count > 0 ? webmapsList.model.get(webmapsList.currentIndex).title : ""
                        font.bold: true
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            BusyIndicator {
                anchors.centerIn: parent
                running: portal.loadStatus !== Enums.LoadStatusLoaded
            }

            Rectangle {
                id: resultsBox
                visible: webmapsList.model && webmapsList.model.count > 0
                anchors {top: searchBox.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: 10 * scaleFactor}
                border.color: "grey"
                border.width: 2
                radius: 5

                Text {
                    id: resultsTitle
                    anchors { margins: 10; top: parent.top; left: parent.left; right: parent.right }
                    text: "web maps: " + keyWordField.text
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    font.bold: true
                    font.pointSize: 10
                    horizontalAlignment: Text.AlignHCenter
                }

                ListView {
                    id: webmapsList
                    anchors { margins: 20; top: resultsTitle.bottom; bottom: moreResultsButton.top; left: parent.left; right: parent.right }
                    clip: true
                    delegate: webmapDelegate
                    highlightFollowsCurrentItem: true
                    highlight: highlightDelegate
                    model: null
                }

                Button {
                    id: moreResultsButton
                    height: 20 * scaleFactor
                    anchors { margins: 20; bottom: parent.bottom; horizontalCenter: resultsBox.horizontalCenter }
                    text: "More Results"
                    visible: portal.findItemsStatus === Enums.TaskStatusCompleted && portal.findItemsResult.nextQueryParameters !== null
                    onClicked: searchNext();
                }
            }

            Column {
                visible: portal.loadStatus === Enums.LoadStatusLoaded
                id: searchBox
                anchors {top: parent.top; horizontalCenter: parent.horizontalCenter; margins: 10 * scaleFactor}
                spacing:5

                Text {
                    id: instruction
                    text: qsTr("search for webmaps:")
                    font.bold: true
                    font.pixelSize: baseFontSize * 0.8
                }

                Row {
                    spacing: 5
                    TextField {
                        id: keyWordField
                        placeholderText: "enter keyword"

                        Keys.onReturnPressed: {
                            if (text.length > 0)
                                search(text);
                        }
                    }

                    Image {
                        source: "./assets/searchIcon.png"
                        width: height
                        height: 30 * scaleFactor

                        MouseArea {
                            anchors.fill: parent
                            enabled: keyWordField.text.length > 0
                            onClicked : search(keyWordField.text);
                        }
                    }

                    SequentialAnimation on x {
                        id: noResultsAnimation
                        loops: 10
                        running: false
                        PropertyAnimation { to: 50; duration: 20 }
                        PropertyAnimation { to: 0; duration: 20 }
                    }

                }
            }

            MapView {
                id: mapView
                visible: false
                anchors {top: searchBox.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: 10 * scaleFactor}
            }

            AuthenticationView {
                anchors.fill: parent
            }

            MessageDialog {
                id: webMapMsg
                title: "Could not load web map!"
                visible: false

                onAccepted: visible = false;
            }
        }
    }
    function search() {
        mapView.visible = false;
        mapView.map = null;
        //! [Portal findItems webmaps part 2]
        portal.findItems(webmapQuery);
        //! [Portal findItems webmaps part 2]
    }

    function searchNext(){
        //! [Portal find with nextQueryParameters]
        var nextQuery = portal.findItemsResult.nextQueryParameters;
        // check whether the startIndex of the new query is valid
        if (nextQuery.startIndex !== -1)
            portal.findItems(nextQuery);
        //! [Portal find with nextQueryParameters]
    }

    function loadSelectedWebmap(selectedWebmap) {
        portalItem = selectedWebmap;

        portalItem.loadStatusChanged.connect(createMap);
        portalItem.loadErrorChanged.connect( function() {
            webMapMsg.text = portalItem.loadError.message;
            webMapMsg.visible = true;
        });

        portalItem.load();
    }

    function createMap() {
        if (portalItem.loadStatus !== Enums.LoadStatusLoaded)
            return;

        mapView.map = ArcGISRuntimeEnvironment.createObject("Map", {"item": portalItem});

        mapView.map.loadStatusChanged.connect(assignWebmap);
        mapView.map.loadErrorChanged.connect( function() {
            webMapMsg.text = mapView.map.loadError.message;
            webMapMsg.visible = true;
        });

        mapView.map.load();
    }

    function assignWebmap() {
        if (mapView.map.loadStatus !== Enums.LoadStatusLoaded)
            return;

        webmapsList.visible = false;
        mapView.visible = true;
    }



    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

