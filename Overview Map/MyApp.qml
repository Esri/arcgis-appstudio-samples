/* Copyright 2020 Esri
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


// You can run your app in Qt Creator by pressing Alt+Shift+R.
// Alternatively, you can run apps through UI using Tools > External > AppStudio > Run.
// AppStudio users frequently use the Ctrl+A and Ctrl+I commands to
// automatically indent the entirety of the .qml file.


/*
 *  @summary:
 *  Displays an overview map over an existing map.
 *  The overview map can be dragged and change basemap style
 */

import QtQuick 2.13
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.3
import QtQuick.Controls.Material.impl 2.12
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.14

import "Pages" as Pages
import "UIControls" as UIControls
import "Plugins/OverviewMap" as OverviewMap
import "Utility" as Utility

App {
    id: app

    width: 400
    height: 640

    //NEEDED FOR PLUGIN
    Utility.DeviceManager { id: deviceManager }

    //NEEDED FOR PLUGIN
    StackView {
        id: uiStackView
        anchors.fill: parent
        initialItem: mainPage
    }


    Page {
        id: mainPage
        header: ToolBar {
            id:header
            width: parent.width
            height: 50 *deviceManager.scaleFactor
            Material.background: "#8f499c"
            RowLayout{
                anchors.fill: parent
                spacing:0
                clip:true

                Rectangle{
                    Layout.preferredWidth: 50 * deviceManager.scaleFactor
                }

                Text {
                    text:app.info.title
                    color:"white"
                    font.pixelSize: deviceManager.baseFontSize * 1.1
                    font.bold: true
                    maximumLineCount:2
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    Layout.alignment: Qt.AlignCenter
                }

                Rectangle{
                    id:infoImageRect
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: 50 * deviceManager.scaleFactor

                    ToolButton {
                        id:infoImage
                        indicator: Image{
                            width: 30 * deviceManager.scaleFactor
                            height: 30 * deviceManager.scaleFactor
                            anchors.centerIn: parent
                            source: "./Assets/Images/info.png"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                        }
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        onClicked: {
                            descPage.visible = 1
                        }
                    }
                }
            }
        }
        //Sample starts here
        contentItem: Rectangle {
            id: rootRectangle
            clip: true
            width: 800
            height: 600
            //Main map mapview
            MapView {
                id: mapView
                anchors.fill: parent
                Map {
                    Basemap {
                        initStyle: Enums.BasemapStyleArcGISTopographic
                    }
                    initialViewpoint: viewpoint
                    FeatureLayer {
                        ServiceFeatureTable {
                            url: "https://services6.arcgis.com/Do88DoK2xjTUCXd1/arcgis/rest/services/OSM_Tourism_NA/FeatureServer/0"
                        }
                    }
                }

                //NEEDED FOR PLUGIN
                //Rectangle for containing the overview map
                OverviewMap.OverviewMapPage {
                    id: overviewMapBorder
                    //Update MapView id here
                    geoView: mapView
                }
            }

            /*
             *  @desc:  Viewpoint center for initial viewpoint of main map view
             */
            ViewpointCenter {
                id: viewpoint
                center: Point {
                    x: -123.12052
                    y: 49.28299
                    spatialReference: Factory.SpatialReference.createWgs84();
                }
                targetScale: 30000
            }
        }
    }


    Pages.DescriptionPage {
        id:descPage
        visible: false
    }
}

