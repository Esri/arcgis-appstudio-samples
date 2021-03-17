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
import QtGraphicalEffects 1.15

Item {
    id: button

    property alias source: image.source
    property color color: "transparent"

    Image {
        id: image

        anchors.fill: parent

        fillMode: Image.PreserveAspectFit
        visible: !overlay.visible
    }

    ColorOverlay {
        id: overlay

        anchors.fill: image

        source: image
        color: button.color
        visible: color !== "transparent"
    }

    Accessible.role: Accessible.Graphic
}
