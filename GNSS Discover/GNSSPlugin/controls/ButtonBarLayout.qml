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

import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0

Control {
    id: control

    //--------------------------------------------------------------------------

    default property alias content: layout.data
    readonly property alias visibleItemsCount: layout.visibleItemsCount

    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    property int orientation: Qt.Horizontal
    property alias border: background.border
    property alias fader: fader
    property alias layout: layout
    property alias dropShadow: dropShadow
    property alias color: background.color

    //--------------------------------------------------------------------------

    spacing: 6 * AppFramework.displayScaleFactor
    padding: 6 * AppFramework.displayScaleFactor

    //--------------------------------------------------------------------------

    background: Item {
        DropShadow {
            id: dropShadow

            anchors.fill: source

            horizontalOffset: 3 * AppFramework.displayScaleFactor
            verticalOffset: horizontalOffset

            radius: 8 * AppFramework.displayScaleFactor
            samples: 17
            color: "#80000000"
            source: background
        }

        Rectangle {
            id: background

            anchors.fill: parent

            color: "#f8f8f8"
            border {
                width: 2 * AppFramework.displayScaleFactor
                color: "lightgrey"
            }

            radius: orientation === Qt.Vertical
                    ? width / 2
                    : height / 2

            MouseArea {
                anchors.fill: parent

                enabled: control.enabled
                hoverEnabled: enabled

                //acceptedButtons: Qt.NoButton

                onPositionChanged: {
                    fader.start();
                }

                onClicked: {
                    fader.start();
                }
            }
        }

        Fader {
            id: fader
        }
    }

    //--------------------------------------------------------------------------

    contentItem: GridLayout {
        id: layout

        property int visibleItemsCount

        columns: orientation == Qt.Vertical ? 1 : 9999
        rows: orientation == Qt.Horizontal ? 1 : 9999

        flow: orientation == Qt.Vertical
              ? GridLayout.TopToBottom
              : GridLayout.LeftToRight

        layoutDirection: isRightToLeft ? Qt.RightToLeft : Qt.LeftToRight
        LayoutMirroring.enabled: false

        rowSpacing: control.spacing
        columnSpacing: control.spacing

        onHeightChanged: {
            Qt.callLater(countVisible);
        }

        function countVisible() {
            var count = 0;

            for (var i = 0; i < children.length; i++) {
                if (children[i].visible) {
                    count ++;
                }
            }

            visibleItemsCount = count;
        }
    }

    //--------------------------------------------------------------------------
}

