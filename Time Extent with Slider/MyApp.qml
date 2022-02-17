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

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.3
import QtQuick.Controls.Material.impl 2.12

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.13
import Esri.ArcGISRuntime.Toolkit 100.13

import "controls" as Controls

App {
    id: app

    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int  baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isCompact ? 0 : 3)
    readonly property real baseUnit: app.units(8)
    readonly property real defaultMargin: 2 * app.baseUnit
    property real maximumScreenWidth: app.width > 1000 * scaleFactor ? 800 * scaleFactor : 568 * scaleFactor

    readonly property real compactThreshold: app.units(496)
    readonly property bool isCompact: app.width <= app.compactThreshold
    readonly property bool isMidsized: (app.width > app.compactThreshold) && (app.width <= 800)
    readonly property bool isLarge: !app.isCompact && !app.isMidsized
    readonly property bool isLandscape: app.width > app.height
    readonly property bool isMobile: ( Qt.platform.os === "ios") || ( Qt.platform.os === "android")

    readonly property real heightOffset: isIphoneX ? app.units(20) : 0
    readonly property real widthOffset: isIphoneX && isLandscape ? app.units(40) : 0
    property bool isIphoneX: false

    width: 800
    height: 600

    Page {
        anchors.fill: parent
        header: ToolBar {
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }
        //Sample starts here
        contentItem: Rectangle {
            id: rootRectangle
            clip: true
            width: 800
            height: 600

            MapView {
                id: mapView
                anchors.fill: parent

                Map {
                    id: map
                    BasemapTopographic{}
                    FeatureLayer {
                        ServiceFeatureTable {
                            id: featureLayer
                            url: "https://services5.arcgis.com/N82JbI5EYtAkuUKU/ArcGIS/rest/services/Hurricane_time_enabled_layer_2005_1_day/FeatureServer/0"
                        }
                    }
                }

                // Add a TimeSlider from the toolkit to the MapView
                TimeSlider {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    geoView: mapView
                }
            }
        }
    }

    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

