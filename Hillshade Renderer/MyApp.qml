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

    property string dataPath:  AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data")

    property string inputdata: "srtm.tiff"
    property string outputdata: dataPath + "/" + inputdata

    function copyLocalData(input, output) {
        var resourceFolder = AppFramework.fileFolder(app.folder.folder("data").path);
        AppFramework.userHomeFolder.makePath(dataPath);
        resourceFolder.copyFile(input, output);
        return output
    }

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
            MapView {
                id: mapView
                anchors.fill: parent

                //! [HillshadeRenderer QML apply to layer snippet]
                Map {
                    Basemap {
                        // add a raster to the basemap
                        RasterLayer {
                            id: rasterLayer

                            Raster {
                                path:AppFramework.resolvedPathUrl(copyLocalData(inputdata, outputdata))
                            }

                            // declare a HillshadeRaster as a child of RasterLayer,
                            // as renderer is a default property of RasterLayer
                            HillshadeRenderer {
                                altitude: 45
                                azimuth: 315
                                zFactor: 0.000016
                                slopeType: Enums.SlopeTypeNone
                                pixelSizeFactor: 1
                                pixelSizePower: 1
                                outputBitDepth: 8
                            }
                        }
                    }
                    //! [HillshadeRenderer QML apply to layer snippet]

                    onLoadStatusChanged: {
                        if (loadStatus === Enums.LoadStatusLoaded) {
                            mapView.setViewpointScale(754479);
                        }
                    }
                }
            }

            Button {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: 25 * scaleFactor
                }
                text: "Edit Renderer"
                onClicked: hillshadeSettings.visible = true;
            }

            HillshadeSettings {
                id: hillshadeSettings
                anchors.fill: parent


                function applyHillshadeRenderer(altitude, azimuth, slope) {
                    // create the new renderer
                    var hillshadeRenderer = ArcGISRuntimeEnvironment.createObject("HillshadeRenderer", {
                                                                                      altitude: altitude,
                                                                                      azimuth: azimuth,
                                                                                      zFactor: 0.000016,
                                                                                      slopeType: slope,
                                                                                      pixelSizeFactor: 1,
                                                                                      pixelSizePower: 1,
                                                                                      outputBitDepth: 8
                                                                                  });

                    // set the renderer on the layer
                    rasterLayer.renderer = hillshadeRenderer;
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

