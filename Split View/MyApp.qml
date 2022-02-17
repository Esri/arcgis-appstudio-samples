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

import "./views"
import "./widgets"
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
    //    readonly property bool isMidsized: (app.width > app.compactThreshold) && (app.width <= 800)
    //    readonly property bool isLarge: !app.isCompact && !app.isMidsized
    readonly property bool isLandscape: app.width > app.height
    readonly property bool isMobile: ( Qt.platform.os === "ios") || ( Qt.platform.os === "android")

    readonly property real heightOffset: isIphoneX ? app.units(20) : 0
    readonly property real widthOffset: isIphoneX && isLandscape ? app.units(40) : 0
    property bool isIphoneX: false

    //Presets for scene view center viewpoints and camera points
    property real viewPointX: 13.40257374908252
    property real viewPointY: 52.51198222143838
    property real viewPointZ: 500

    //QML Loader components for splitview
    property string secondLoaderItem: "./views/SecondLoader.qml"
    property string firstLoaderItem: "./views/FirstLoader.qml"

    width: 400
    height: 640

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
            SplitView {
                id: splitView
                anchors.fill: parent
                //Orientation dynamically changes based on whether screen is compact (small) or not.
                orientation: !isLandscape ? Qt.Vertical : Qt.Horizontal
                //Custom spitview handle ui
                handle: Handle{}

                //first item of split view
                Item {
                    id: firstItem
                    property real itemArea: (height * width) / (app.height * app.width)
                    implicitHeight: app.height * 0.5
                    implicitWidth: app.width * 0.5
                    SplitView.minimumWidth: app.width * 0.25
                    SplitView.minimumHeight: app.height * 0.25
                    Loader {
                        id: firstLoader
                        height: parent.height
                        width: parent.width
                        source: firstLoaderItem
                    }
                }

                //second item of split view
                Item {
                    id: secondItem
                    property real itemArea: (height * width) / (app.height * app.width)
                    implicitHeight: app.height * 0.5
                    implicitWidth: app.width * 0.5
                    SplitView.minimumWidth: app.width * 0.25
                    SplitView.minimumHeight: app.height * 0.25
                    Loader{
                        id: secondLoader
                        height: parent.height
                        width: parent.width
                        source: secondLoaderItem
                    }
                }
            }
        }
    }

    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

