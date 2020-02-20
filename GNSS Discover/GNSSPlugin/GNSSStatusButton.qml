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

import QtQuick 2.12
import QtQuick.Controls 2.12

import ArcGIS.AppFramework 1.0

import "./GNSSManager"
import "./controls"

Item {
    id: item

    //--------------------------------------------------------------------------
    // Public properties

    // Reference to GNSSStatusPages (required)
    property GNSSStatusPages gnssStatusPages

    // Button styling
    property color color: "#ffffff"

    width: 30 * AppFramework.displayScaleFactor
    height: width

    //--------------------------------------------------------------------------
    // Internal properties

    readonly property StackView stackView: gnssStatusPages.stackView
    readonly property GNSSManager gnssManager: gnssStatusPages.gnssManager

    readonly property PositionSourceManager positionSourceManager: gnssManager.positionSourceManager
    readonly property bool isConnecting: positionSourceManager && positionSourceManager.isConnecting
    readonly property bool isConnected: positionSourceManager && positionSourceManager.isConnected
    readonly property bool isWarmingUp: positionSourceManager && positionSourceManager.isWarmingUp

    property bool blinkTrigger: false
    property bool blinkState: false

    signal clicked(var mouse)
    signal pressAndHold(var mouse)

    //--------------------------------------------------------------------------

    StyledImageButton {
        id: button

        anchors.fill: parent

        source: isConnecting
                ? (blinkState ? "./images/satellite-link.png" : "./images/satellite-0.png")
                : isWarmingUp
                  ? "./images/satellite-%1.png".arg(positionSourceManager.positionCount % 4)
                  : isConnected
                    ? (blinkState ? "./images/satellite-f.png" : "./images/satellite.png")
                    : ""

        visible: positionSourceManager && !positionSourceManager.onDetailedSettingsPage && (positionSourceManager.active || isConnecting)
        enabled: visible && source > ""

        color: item.color

        onClicked: {
            gnssStatusPages.showGNSSStatus(stackView);

            item.clicked(mouse)
        }

        onPressAndHold: {
            item.pressAndHold(mouse);
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        interval: 250
        repeat: true
        running: button.visible

        onTriggered: {
            if (blinkTrigger || isConnecting) {
                blinkState = !blinkState;
                blinkTrigger = false;
            }
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: positionSourceManager

        onNewPosition: {
            Qt.callLater(activity);
        }
    }

    function activity() {
        blinkTrigger = true;
    }

    //--------------------------------------------------------------------------
}
