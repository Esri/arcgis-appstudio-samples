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

import QtQuick 2.15

import ArcGIS.AppFramework 1.0

import "../controls"
import "../GNSSManager"

Page {
    id: locationInfoPage

    default property alias contentData: tabView.contentData

    property bool showData: true
    property bool showMap: true
    property bool showSkyPlot: true
    property bool showDebug: true

    bottomSpacingBackgroundColor: headerBarBackgroundColor

    //--------------------------------------------------------------------------

    readonly property PositionSourceManager positionSourceManager: gnssManager.positionSourceManager
    property NmeaLogger nmeaLogger

    property color labelColor: "#303030"

    property color buttonBarBorderColor: "#efefef"
    property color buttonBarButtonColor: "#8f499c"
    property color buttonBarRecordingColor: "mediumvioletred"
    property color buttonBarBackgroundColor: "#f8f8f8"

    property alias tabBarBackgroundColor: tabView.tabBarBackgroundColor
    property alias tabBarTabBorderColor: tabView.tabBarTabBorderColor
    property alias tabBarTabForegroundColor: tabView.tabBarTabForegroundColor
    property alias tabBarTabBackgroundColor: tabView.tabBarTabBackgroundColor
    property alias tabBarSelectedTabForegroundColor: tabView.tabBarSelectedTabForegroundColor
    property alias tabBarSelectedTabBackgroundColor: tabView.tabBarSelectedTabBackgroundColor
    property alias tabBarDisabledTabColor: tabView.tabBarDisabledTabColor

    property color tabBarTabForegroundColor: textColor
    property color tabBarSelectedTabForegroundColor: Qt.darker(tabBarTabForegroundColor, 1.25)

    //--------------------------------------------------------------------------

    SwipeTabView {
        id: tabView

        anchors.fill: parent

        backgroundColor: locationInfoPage.backgroundColor

        fontFamily: locationInfoPage.fontFamily

        clip: true
    }

    //--------------------------------------------------------------------------
}
