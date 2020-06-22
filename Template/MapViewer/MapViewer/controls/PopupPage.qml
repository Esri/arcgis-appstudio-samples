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

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

Popup {
    id: root

    property int transitionDuration: 200
    property real pageExtent: 0
    property real base: root.height
    property string transitionProperty: "y"

    closePolicy: Popup.NoAutoClose

    width: parent.width
    height: parent.height
    padding: 0

    enter: Transition {
        NumberAnimation {
            id: bottomUp_MoveIn

            property: root.transitionProperty
            duration: root.transitionDuration
            from: root.base
            to: root.pageExtent
            easing.type: Easing.InOutQuad
        }
    }

    exit: Transition {
        NumberAnimation {
            id: topDown_MoveOut
            property: root.transitionProperty
            duration: root.transitionDuration
            from: root.pageExtent
            to: root.base
            easing.type: Easing.InOutQuad
        }
    }

    contentItem: BasePage {
        padding: 0
        anchors {
            fill: parent
            margins: 0
        }
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        onWheel: {
            wheel.accepted = true
        }
    }

    function toggle () {
        return visible ? close () : open ()
    }
}
