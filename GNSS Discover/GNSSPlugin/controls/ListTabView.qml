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
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0

Item {
    default property alias contentData: container.data
    property alias listTabView: listTabViewListView
    property alias listSpacing: listTabViewListView.spacing

    property alias tabViewContainer: container
    property alias delegate: listTabViewListView.delegate

    property color backgroundColor: "#e1f0fb"

    //--------------------------------------------------------------------------

    signal selected(Item item)

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        console.log("# ListTab items:", container.children.length);
    }

    //--------------------------------------------------------------------------

    Rectangle {
        anchors.fill: parent

        color: backgroundColor

        ListView {
            id: listTabViewListView

            anchors.fill: parent
            clip: true

            boundsBehavior: Flickable.StopAtBounds
            spacing: 2 * AppFramework.displayScaleFactor

            model: container.visibleChildren
        }
    }

    //--------------------------------------------------------------------------

    Item {
        id: container
    }

    //--------------------------------------------------------------------------
}
