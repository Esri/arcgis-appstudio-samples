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
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import QtPositioning 5.3
import QtSensors 5.3

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)
    property string compassMode: "Compass"
    property string navigationMode: "Navigation"
    property string recenterMode: "Re-Center"
    property string onMode: "On"
    property string stopMode: "Stop"
    property string closeMode: "Close"
    property string currentModeText: stopMode
    property string currentModeImage:"assets/Stop.png"



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


            // Create MapView that contains a Map with the Imagery with Labels Basemap
            MapView {
                id: mapView
                anchors.fill: parent
                Map {
                    BasemapImagery {}

                    // start the location display
                    onLoadStatusChanged: {
                        if (loadStatus === Enums.LoadStatusLoaded) {
                            // populate list model with modes
                            autoPanListModel.append({name: compassMode, image:"assets/Compass.png"});
                            autoPanListModel.append({name: navigationMode, image:"assets/Navigation.png"});
                            autoPanListModel.append({name: recenterMode, image:"assets/Re-Center.png"});
                            autoPanListModel.append({name: onMode, image:"assets/Stop.png"});
                            autoPanListModel.append({name: stopMode, image:"assets/Stop.png"});
                            autoPanListModel.append({name: closeMode, image:"assets/Close.png"});
                        }
                    }
                }

                // set the location display's position source
                locationDisplay {
                    positionSource: PositionSource {
                    }
                    compass: Compass {}
                }
            }

            Rectangle {
                id: rect
                anchors.fill: parent
                visible: autoPanListView.visible
                color: "black"
                opacity: 0.7
            }

            ListView {
                id: autoPanListView
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: 10 * scaleFactor
                }
                visible: false
                width: parent.width
                height: 300 * scaleFactor
                spacing: 10 * scaleFactor
                model: ListModel {
                    id: autoPanListModel
                }

                delegate: Row {
                    id: autopanRow
                    anchors.right: parent.right
                    spacing: 10

                    Text {
                        text: name
                        font.pixelSize: 25 * scaleFactor
                        color: "white"
                        MouseArea {
                            anchors.fill: parent
                            // When an item in the list view is clicked
                            onClicked: {
                                autopanRow.updateAutoPanMode();
                            }
                        }
                    }

                    Image {
                        source: image
                        width: 40 * scaleFactor
                        height: width
                        MouseArea {
                            anchors.fill: parent
                            // When an item in the list view is clicked
                            onClicked: {
                                autopanRow.updateAutoPanMode();
                            }
                        }
                    }

                    // set the appropriate auto pan mode
                    function updateAutoPanMode() {
                        switch (name) {
                        case compassMode:
                            mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeCompassNavigation;
                            mapView.locationDisplay.start();
                            break;
                        case navigationMode:
                            mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeNavigation;
                            mapView.locationDisplay.start();
                            break;
                        case recenterMode:
                            mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeRecenter;
                            mapView.locationDisplay.start();
                            break;
                        case onMode:
                            mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeOff;
                            mapView.locationDisplay.start();
                            break;
                        case stopMode:
                            mapView.locationDisplay.stop();
                            break;
                        }

                        if (name !== closeMode) {
                            currentModeText = name;
                            currentModeImage = image;
                        }

                        // hide the list view
                        currentAction.visible = true;
                        autoPanListView.visible = false;
                    }
                }
            }

            Row {
                id: currentAction
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: 25 * scaleFactor
                }
                spacing: 10

                Text {
                    text: currentModeText
                    font.pixelSize: 25 * scaleFactor
                    color: "white"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentAction.visible = false;
                            autoPanListView.visible = true;
                        }
                    }
                }

                Image {
                    source: currentModeImage
                    width: 40 * scaleFactor
                    height: width
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentAction.visible = false;
                            autoPanListView.visible = true;
                        }
                    }
                }
            }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}


