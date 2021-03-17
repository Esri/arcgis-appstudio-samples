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
import QtQuick.Controls 2.15

import ArcGIS.AppFramework 1.0

Rectangle {
    id: tabView

    default property alias contentData: swipeView.contentData

    property alias interactive: swipeView.interactive

    property alias showText: tabIndicator.showText
    property alias showImages: tabIndicator.showImages

    property alias backgroundColor: tabView.color

    property alias tabBarBackgroundColor: background.color
    property alias tabBarTabBorderColor: tabIndicator.tabBarTabBorderColor
    property alias tabBarTabForegroundColor: tabIndicator.tabBarTabForegroundColor
    property alias tabBarTabBackgroundColor: tabIndicator.tabBarTabBackgroundColor
    property alias tabBarSelectedTabForegroundColor: tabIndicator.tabBarSelectedTabForegroundColor
    property alias tabBarSelectedTabBackgroundColor: tabIndicator.tabBarSelectedTabBackgroundColor
    property alias tabBarDisabledTabColor: tabIndicator.tabBarDisabledTabColor

    property string fontFamily: Qt.application.font.family

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

        interactive: false

        Component.onCompleted: {
            // remove hidden items
            for (var i=swipeView.count-1; i>=0; i--) {
                let item = swipeView.itemAt(i);
                if (!item.visible) {
                    swipeView.removeItem(item)
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: background

        anchors {
            left: parent.left
            right: parent.right
            top: tabIndicator.top
            bottom: tabIndicator.bottom
        }

        color: "#8f499c"
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
