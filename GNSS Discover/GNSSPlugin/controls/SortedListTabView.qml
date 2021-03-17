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
import QtQml.Models 2.15

import ArcGIS.AppFramework 1.0

Item {
    property alias tabViewContainer: container

    default property alias contentData: container.data

    property alias listTabView: listTabViewListView
    property alias listSpacing: listTabViewListView.spacing

    property alias delegate: delegateModel.delegate
    property alias model: delegateModel.items

    // Set this to sort the list view. Must be a function of the form
    // 'function(left, right) { return left < right; }'
    property alias lessThan: delegateModel.lessThan

    property color backgroundColor: "#e1f0fb"

    //--------------------------------------------------------------------------

    signal selected(Item item)
    signal sort()

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        console.log("# ListTab items:", container.children.length);
    }

    //--------------------------------------------------------------------------

    onSort: {
        if (delegateModel.items.count > 0) {
            delegateModel.items.setGroups(0, delegateModel.items.count, "unsorted")
        }
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

            model: delegateModel
        }
    }

    // -------------------------------------------------------------------------

    DelegateModel {
        id: delegateModel

        property var lessThan

        // We can't use container.visibleChildren here since they and their delegates
        // will be destroyed when we navigate away from the current page (they're not
        // visible anymore). Any signals connected to the delegates that are supposed
        // to be run (e.g. when the model changes) won't be called in this case.
        model: container.children

        items.includeByDefault: false

        groups: VisualDataGroup {
            id: unsortedItems
            name: "unsorted"

            includeByDefault: true

            onChanged: {
                if (lessThan && lessThan instanceof Function) {
                    // sort list view according to function 'lessThan(left, right)'
                    delegateModel.sort();
                } else {
                    // do not sort
                    setGroups(0, count, "items");
                }
            }
        }

        function sort() {
            while (unsortedItems.count > 0) {
                var item = unsortedItems.get(0);
                var index = insertPosition(item);

                item.groups = "items";
                items.move(item.itemsIndex, index);
            }
        }

        function insertPosition(item) {
            var lower = 0;
            var upper = items.count;
            while (lower < upper) {
                var middle = Math.floor(lower + (upper - lower) / 2);
                var result = lessThan(item.model, items.get(middle).model);
                if (result) {
                    upper = middle;
                } else {
                    lower = middle + 1;
                }
            }
            return lower;
        }
    }

    //--------------------------------------------------------------------------

    Item {
        id: container
    }

    //--------------------------------------------------------------------------
}
