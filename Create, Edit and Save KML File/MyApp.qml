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


// You can run your app in Qt Creator by pressing Alt+Shift+R.
// Alternatively, you can run apps through UI using Tools > External > AppStudio > Run.
// AppStudio users frequently use the Ctrl+A and Ctrl+I commands to
// automatically indent the entirety of the .qml file.


import QtQuick 2.6
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls.Material 2.1
import QtPositioning 5.3
import QtSensors 5.3
import Qt.labs.platform 1.1 as Dialogs


import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0
import Esri.ArcGISRuntime 100.10

import "controls" as Controls

//------------------------------------------------------------------------------

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
            StackView {
                id: functionSelectionStack
                anchors.fill: parent

                initialItem: Item {
                    Rectangle{
                        id: subHeadBar
                        width: parent.width
                        height: 50*scaleFactor
                        Material.elevation :10
                        color: "#8f499c"
                        Text {
                            anchors{
                                verticalCenter: parent.verticalCenter
                                horizontalCenter:parent.horizontalCenter
                            }
                            color: "white"
                            font.pixelSize: baseFontSize * 1.1
                            font.bold: true
                            text: "Choose a sample"
                        }
                    }
                    ColumnLayout{
                        anchors.top: subHeadBar.bottom
                        anchors.topMargin: 20 * scaleFactor
                        width: parent.width
                        spacing :10 * scaleFactor
                        Button{
                            id:buttonCreateAndSave
                            Material.elevation :5
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: app.titleFontSize
                            text: qsTr("Create and Save KML File")
                            onClicked:{
                                functionSelectionStack.push(map1)
                            }
                        }
                        Button{
                            Material.elevation :5
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: app.titleFontSize
                            text: qsTr("Edit KML Ground Overlay")
                            onClicked:{
                                functionSelectionStack.push(map2)
                            }
                        }
                    }



                }
            }
        }
    }
    Component {
        id: map1
        Rectangle{
            clip: true
            MapView {
                id: mapView
                anchors.fill: parent

                Map {
                    BasemapDarkGrayCanvasVector {}

                    // add a KML Layer
                    KmlLayer {
                        KmlDataset {
                            id: kmlDataset
                            KmlDocument {
                                id: kmlDocument
                                name: qsTr("KML Sample Document")

                                onSaveStatusChanged: {
                                    if (saveStatus === Enums.TaskStatusErrored) {
                                        console.log(`Error: ${error.message} - ${error.additionalMessage}`);
                                    }
                                    else if (saveStatus === Enums.TaskStatusCompleted) {
                                        saveCompleteDialog.open();
                                    }
                                }
                            }
                        }
                    }

                    // set initial extent
                    ViewpointExtent {
                        Envelope {
                            id: myViewpoint
                            xMin: -123.0
                            yMin: 33.5
                            xMax: -101.0
                            yMax: 42.0
                            spatialReference: SpatialReference { wkid: 4326 }
                        }
                    }
                }

            }

            Button {
                anchors{
                    left: parent.left
                    top: parent.top
                    margins: 3
                }
                text: qsTr("Go Back")

                onClicked: {
                    pop();
                }
            }
            Button {
                anchors{
                    right: parent.right
                    top: parent.top
                    margins: 3
                }
                text: qsTr("Save kmz file")

                onClicked: {
                    console.log(kmlFileInfo.url)
                    kmlDocument.saveAs(kmlFileInfo.url)
                }
            }

            PolygonBuilder {
                id: polygonBuilder
                spatialReference: SpatialReference { wkid: 4326 }
            }

            PolylineBuilder {
                id: polylineBuilder
                spatialReference: SpatialReference { wkid: 4326 }
            }

            Point {
                id: point
                x: -117.195800
                y: 34.056295
                spatialReference: SpatialReference { wkid: 4326 }
            }

            BusyIndicator {
                id: busy
                anchors.centerIn: parent
                visible: kmlDocument.saveStatus === Enums.TaskStatusInProgress
            }

            FileInfo {
                id: kmlFileInfo
                filePath: AppFramework.standardPaths.writableFolder( StandardPaths.DownloadLocation ).filePath( "KmlFile.kmz" )
            }

            Dialog {
                id: saveCompleteDialog
                clip: true
                anchors.centerIn: parent
                modal: true
                standardButtons: Dialog.Ok
                Text {
                    id:textLabel
                    anchors.fill: parent
                    anchors.centerIn: parent
                    text: qsTr( "Item saved to the Downloads folder!" )
                    wrapMode: Text.WordWrap
                }
            }

            KmlStyle {
                id: kmlStyleWithPointStyle
                KmlIconStyle {
                    KmlIcon {
                        url: "https://static.arcgis.com/images/Symbols/Shapes/BlueStarLargeB.png"
                    }
                    scale: 1
                }
            }

            KmlStyle {
                id: kmlStyleWithLineStyle
                KmlLineStyle {
                    color: "red"
                    width: 2
                }
            }

            KmlStyle {
                id: kmlStyleWithPolygonStyle
                KmlPolygonStyle {
                    color: "yellow"
                }
            }

            Component.onCompleted: {
                createPolygon();
                createPolyline();
                createPoint();
            }

            function createPoint() {
                addToKmlDocument(point, kmlStyleWithPointStyle);
            }

            function createPolygon() {
                polygonBuilder.addPointXY(-109.048, 40.998);
                polygonBuilder.addPointXY(-102.047, 40.998);
                polygonBuilder.addPointXY(-102.037, 36.989);
                polygonBuilder.addPointXY(-109.048, 36.998);
                addToKmlDocument(polygonBuilder.geometry, kmlStyleWithPolygonStyle);
            }

            function createPolyline() {
                polylineBuilder.addPointXY(-119.992, 41.989);
                polylineBuilder.addPointXY(-119.994, 38.994);
                polylineBuilder.addPointXY(-114.620, 35.0);
                addToKmlDocument(polylineBuilder.geometry, kmlStyleWithLineStyle);
            }

            function addToKmlDocument(geometry, kmlStyle) {
                const kmlGeometry = ArcGISRuntimeEnvironment.createObject("KmlGeometry", {
                                                                              geometry: geometry,
                                                                              altitudeMode: Enums.KmlAltitudeModeClampToGround
                                                                          });
                let kmlPlacemark = ArcGISRuntimeEnvironment.createObject("KmlPlacemark");
                kmlPlacemark.geometriesListModel.append(kmlGeometry);
                kmlPlacemark.style = kmlStyle;
                kmlDocument.childNodesListModel.append(kmlPlacemark);
            }
        }
    }
    Component {
        id: map2
        Rectangle {
            clip: true

            SceneView {
                id: sceneView
                anchors.fill: parent

                Scene {
                    BasemapImagery {}

                    // Create a KML Layer
                    KmlLayer {
                        id: kmlLayer
                        // Create a KML Dataset
                        KmlDataset {
                            // Create a Ground Overlay by assigning an icon and geometry
                            KmlGroundOverlay {
                                id: groundOverlay
                                rotation: -3.046024799346924
                                KmlIcon {
                                    url: "assets/1944.jpg"
                                }
                                Envelope {
                                    id: env
                                    xMin: -123.066227926904
                                    yMin: 44.04736963555683
                                    xMax: -123.0796942287304
                                    yMax: 44.03878298600624
                                    SpatialReference {
                                        wkid: 4326
                                    }
                                }
                            }
                        }

                        // set viewpoint to the ground overlay
                        onLoadStatusChanged: {
                            if (loadStatus !== Enums.LoadStatusLoaded)
                                return;

                            const camera = ArcGISRuntimeEnvironment.createObject("Camera", {
                                                                                     location: env.center,
                                                                                     distance: 1250,
                                                                                     heading: 45,
                                                                                     pitch: 60,
                                                                                     roll: 0
                                                                                 });

                            sceneView.setViewpointCamera(camera);
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: slider
                radius: 5
            }

            Button {
                anchors{
                    left: parent.left
                    top: parent.top
                    margins: 3
                }
                text: qsTr("Go Back")

                onClicked: {
                    pop();
                }
            }

            Slider {
                id: slider
                anchors {
                    right: parent.right
                    top: parent.top
                    margins: 10
                }
                from: 0
                to: 1
                value: 1
                stepSize: 0.1
                onValueChanged: {
                    // modify the overlay's color/alpha value
                    groundOverlay.color = Qt.rgba(0, 0, 0, value);
                }
            }
        }
    }

    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

//------------------------------------------------------------------------------
