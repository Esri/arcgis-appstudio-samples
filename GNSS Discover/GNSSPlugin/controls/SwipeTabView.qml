/* Copyright 2019 Esri
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

import QtQuick 2.12
import QtQuick.Controls 2.12

import ArcGIS.AppFramework 1.0

Rectangle {
    id: tabView

    default property alias contentData: swipeView.contentData

    property alias interactive: swipeView.interactive

    property alias showText: tabIndicator.showText
    property alias showImages: tabIndicator.showImages

    property string fontFamily: Qt.application.font.family

    property color tabBarBackgroundColor: "black"
    property alias selectedTextColor: tabIndicator.tabsSelectedTextColor
    property alias textColor: tabIndicator.tabsTextColor

    property alias resizeTabs: tabIndicator.resize

    //--------------------------------------------------------------------------

    SwipeView {
        id: swipeView

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            bottomMargin: tabIndicator.height
        }
    }
    
    //--------------------------------------------------------------------------

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: tabIndicator.top
            bottom: tabIndicator.bottom
        }

        color: tabBarBackgroundColor
    }

    SwipeTabIndicator {
        id: tabIndicator
        
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        
        swipeView: swipeView
        interactive: true

        fontFamily: tabView.fontFamily
    }

    //--------------------------------------------------------------------------
}