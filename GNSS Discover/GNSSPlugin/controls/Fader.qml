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

Item {
    id: fader

    //--------------------------------------------------------------------------

    property QtObject target: parent
    property bool enabled: true
    property int timeoutDuration: 3000
    property int animationDuration: 3000
    property real minumumOpacity: 0.4
    property real maximumOpacity: 1

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        if (enabled) {
            start();
        }
    }

    //--------------------------------------------------------------------------

    function start() {
        if (!enabled) {
            return;
        }

        fadeTimer.stop();
        fadeAnimation.stop();
        target.opacity = maximumOpacity;
        fadeTimer.start();
    }

    function stop() {
        fadeTimer.stop();
        fadeAnimation.stop();
        target.opacity = maximumOpacity;
    }

    //--------------------------------------------------------------------------

    onEnabledChanged: {
        if (enabled) {
            start();
        } else {
            stop();
        }
    }

    //--------------------------------------------------------------------------

    PropertyAnimation {
        id: fadeAnimation
        target: fader.target
        property: "opacity"
        to: minumumOpacity
        duration: animationDuration
        easing {
            type: Easing.OutCubic
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        id: fadeTimer
        repeat: false
        interval: timeoutDuration

        onTriggered: {
            fadeAnimation.restart();
        }
    }

    //--------------------------------------------------------------------------
}
