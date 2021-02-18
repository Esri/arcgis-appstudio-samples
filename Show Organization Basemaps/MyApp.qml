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

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.2
import Esri.ArcGISRuntime.Toolkit.Dialogs 100.2
import QtWebView 1.1

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
    property var porInfo: portal.portalInfo

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

            BusyIndicator {
                anchors.centerIn: parent
                running: !anonymousLogIn.visible && !mapView.visible && portal.loadStatus !== Enums.LoadStatusLoaded;
            }

            Credential {
                id: oAuthCredential
                oAuthClientInfo: OAuthClientInfo {
                    oAuthMode: Enums.OAuthModeUser
                    clientId: "W3hPKzPbeJ0tr8aj"
                }
            }

            Portal {
                id: portal

                //! [Portal fetchBasemaps after loaded]
                onLoadStatusChanged: {
                    if (loadStatus === Enums.LoadStatusFailedToLoad) {
                        retryLoad();
                        return;
                    }

                    if (loadStatus !== Enums.LoadStatusLoaded)
                        return;

                    fetchBasemaps();
                }

                onFetchBasemapsStatusChanged: {
                    if (fetchBasemapsStatus !== Enums.TaskStatusCompleted)
                        return;

                    basemapsGrid.model = basemaps;
                    gridFadeIn.running = true;
                }
                //! [Portal fetchBasemaps after loaded]
            }

            Text{
                id: title
                anchors {
                    top: parent.top;
                    left: parent.left;
                    right: parent.right;
                    margins: 10
                }
                font.pointSize: 14
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                text: anonymousLogIn.visible ? "Load Portal" :
                                               (basemapsGrid.count > 0 ? porInfo.organizationName + " Basemaps" : "Loading Organization Basemaps...")
                wrapMode: Text.Wrap
                elide: Text.ElideRight
            }

            MapView {
                id: mapView
                anchors {
                    top: title.bottom;
                    bottom: parent.bottom;
                    left: parent.left;
                    right: parent.right
                }
                visible: false
            }

            Button {
                id: backButton
                anchors {
                    top: mapView.top
                    left: mapView.left
                    margins: 16 * scaleFactor
                }
                visible: mapView.visible
                width: 80 * scaleFactor
                Material.background: "#8f499c"

                Image{
                    anchors.verticalCenter: parent.verticalCenter
                    source: "./assets/back.png"
                    height: 24 * scaleFactor
                    width:height
                }

                text: "Back"
                opacity: hovered ? 1 : 0.5

                onClicked: {
                    mapView.visible = false;
                    basemapsGrid.enabled = true;
                    gridFadeIn.running = true;
                }
            }

            GridView {
                id: basemapsGrid
                anchors {
                    top: title.bottom;
                    bottom: parent.bottom;
                    left: parent.left;
                    right: parent.right
                    leftMargin: (parent.width - Math.floor (parent.width / (cellWidth))*  (cellWidth)) / 2.0  //Make gridview appear in center of the screen
                }

                cellWidth: 128 * scaleFactor;
                cellHeight: 128 * scaleFactor
                opacity: 0
                focus: true
                clip: true

                delegate: Rectangle {
                    anchors.margins: 5 * scaleFactor
                    width: basemapsGrid.cellWidth
                    height: width
                    border {
                        width: 2;
                        color: index === basemapsGrid.currentIndex ? "blue" : "lightgrey"
                    }
                    color: index === basemapsGrid.currentIndex ? "yellow" : "white"
                    radius: 2
                    clip: true

                    //! [BasemapListModel example QML delegate]
                    Image {
                        id: basemapImg
                        anchors {
                            bottom: basemapLabel.top;
                            horizontalCenter: parent.horizontalCenter
                        }
                        height: parent.height - ( basemapLabel.height * 2 );
                        width: height
                        source: thumbnailUrl
                        fillMode: Image.PreserveAspectCrop
                    }

                    Text {
                        id: basemapLabel
                        anchors {
                            bottom: parent.bottom;
                            left: parent.left;
                            right: parent.right
                        }
                        height: 16 * scaleFactor
                        z: 100
                        horizontalAlignment: Text.AlignHCenter
                        text: title
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        font.pointSize: 8
                        font.bold: index === basemapsGrid.currentIndex
                    }
                    //! [BasemapListModel example QML delegate]

                    MouseArea {
                        enabled: !mapView.visible && portal.loadStatus === Enums.LoadStatusLoaded
                        anchors.fill: parent

                        onClicked: {
                            if (!enabled)
                                return;

                            basemapsGrid.currentIndex = index;
                        }

                        onDoubleClicked: {
                            if (!enabled)
                                return;

                            selectedAnimation.running = true;
                            chooseBasemap(basemapsGrid.model.get(index));
                        }
                    }

                    SequentialAnimation on opacity {
                        id: selectedAnimation
                        running: false
                        loops: 4
                        PropertyAnimation { to: 0; duration: 60 }
                        PropertyAnimation { to: 1; duration: 60 }
                    }
                }

                OpacityAnimator on opacity {
                    id: gridFadeIn
                    from: 0;
                    to: 1;
                    duration: 2000
                    running: false
                }

                OpacityAnimator on opacity {
                    id: gridFadeOut
                    from: 1;
                    to: 0;
                    duration: 2000
                    running: false
                }
            }

            Button {
                id: anonymousLogIn
                anchors {
                    margins: 16 * scaleFactor
                    horizontalCenter: parent.horizontalCenter
                    top: title.bottom
                }
                text: "Anonymous"
                width: 200 * scaleFactor

                Image {
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    source: "./assets/help.png"
                    height: 24 * scaleFactor
                    width:height
                }

                onClicked: {
                    portal.load();
                    anonymousLogIn.visible = false;
                    userLogIn.visible = false;
                }
            }

            Button {
                id: userLogIn
                anchors {
                    margins: 16 * scaleFactor
                    horizontalCenter: anonymousLogIn.horizontalCenter
                    top: anonymousLogIn.bottom
                }
                width: anonymousLogIn.width
                text: "Sign-in"
                Image{
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * scaleFactor
                    anchors.verticalCenter: parent.verticalCenter
                    source:"./assets/sign_in.png"
                    height:24*scaleFactor
                    width:height
                }

                onClicked: {
                    portal.credential = oAuthCredential;
                    portal.load();
                    anonymousLogIn.visible = false;
                    userLogIn.visible = false;
                }
            }

            AuthenticationView {
                authenticationManager: AuthenticationManager
            }
        }
    }
    function chooseBasemap(selectedBasemap) {
        title.text = selectedBasemap.item.title;
        basemapsGrid.enabled = false;

        var newMap = ArcGISRuntimeEnvironment.createObject("Map", {basemap: selectedBasemap});
        mapView.map = newMap;
        gridFadeOut.running = true;
        mapView.visible = true;
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

