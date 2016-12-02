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

Item {
    id: scrollbar

    //public API
    property variant scrollItem      // item to which the scrollbar is attached - this must be a Flickable, GridView or ListView
    property string orientation: ""  // possible values : "vertical", "horizontal" //mm Can this be made an enumeration?
    property bool isVisible: true

    //private
    width:  (scrollbar.orientation == "horizontal") ? scrollItem.width : 7
    height: (scrollbar.orientation == "horizontal") ? 7 : scrollItem.height
    anchors.left: (scrollbar.orientation == "horizontal") ? scrollItem.left : undefined
    anchors.right: scrollItem.right
    anchors.top: (scrollbar.orientation == "horizontal") ? undefined : scrollItem.top
    anchors.bottom: scrollItem.bottom
    z: 11

    opacity: (scrollItem.moving === true) ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 100 } }

    visible: scrollItem.visible || isVisible

    //property Component background: defaultStyle.background
    //property Component content: defaultStyle.content

    Loader {
        anchors.fill: parent
        sourceComponent: defaultStyle.content
    }

    QtObject {
        id: defaultStyle
        //    property Component background: defaultBackground
        property Component content: defaultContent

        property list<Component> elements: [
            Component {
                id: defaultContent
                Item {
                    id: track
                    height: parent.height - 8
                    width: parent.width - 8
                    anchors.centerIn: parent

                    Item {
                        id: thumb
                        x: (scrollbar.orientation == "horizontal") ? Math.min (Math.max ((scrollItem.visibleArea.xPosition * scrollItem.width), 0), (track.width - width)) : 0
                        y: (scrollbar.orientation == "horizontal") ? 0 : Math.min (Math.max ((scrollItem.visibleArea.yPosition * scrollItem.height), 0), (track.height - height))
                        width: (scrollbar.orientation == "horizontal") ? scrollItem.visibleArea.widthRatio * scrollItem.width : 3
                        height: (scrollbar.orientation == "horizontal") ? 3 : (scrollItem.visibleArea.heightRatio * scrollItem.height) - 8
                        Rectangle {
                            id: shadow
                            anchors.fill: thumb
                            radius: 3
                            color: "#999999"
                            opacity: 0.6
                        }

                        Rectangle {
                            height: thumb.height - 2
                            width: thumb.width - 2
                            anchors.centerIn: thumb
                            radius: 2
                            color: "#777777"
                        }
                    }
                }
            }
        ]
    }
}
