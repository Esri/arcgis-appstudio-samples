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
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 400
    height: 640
    property double scaleFactor: AppFramework.displayScaleFactor

    Map {
        id: hideNoDataTilesMap
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width * 0.5
        extent: initalExtent
        hidingNoDataTiles: true // Hide No Data Tiles

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer"
        }
    }

    Map {
        id: showNoDataTilesMap
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: parent.width * 0.5
        extent: initalExtent
        hidingNoDataTiles: false // Show No Data Tiles

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer"
        }
    }

    Rectangle {
        color: "lightgrey"
        radius: 5
        border.color: "black"
        opacity: 0.77
        anchors {
            fill: controlsColumn
            margins: -10 * scaleFactor
        }
    }

    Column {
        id: controlsColumn
        anchors {
            left: parent.left
            top: parent.top
            margins: 20 * scaleFactor
        }
        spacing: 10 * scaleFactor

        Button {
            id:zoomToNoTilesButton
            text: " Zoom to tiles which have no data "
            style: ButtonStyle {
                label: Text {
                    text: control.text
                    color:"black"
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            onClicked: {
                showNoDataTilesMap.zoomToScale(83132.62532398953);
                hideNoDataTilesMap.zoomToScale(83132.62532398953);
            }
        }

        Button {
            id:zoomToTilesButton
            text: " Zoom to tiles which have data "
            width: zoomToNoTilesButton.width
            style: zoomToNoTilesButton.style

            onClicked: {
                showNoDataTilesMap.zoomToScale(229135.44217293584);
                hideNoDataTilesMap.zoomToScale(229135.44217293584);
            }
        }
    }

    Envelope {
        id:initalExtent
        xMin: 16129840
        yMin: -4559530
        xMax: 16142736
        yMax: -4546850
        spatialReference: hideNoDataTilesMap.spatialReference
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }
}

