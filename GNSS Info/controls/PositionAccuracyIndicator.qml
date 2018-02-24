/* Copyright 2017 Esri
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

import QtQuick 2.9
import QtLocation 5.9

import ArcGIS.AppFramework.Positioning 1.0

MapCircle {
    property PositionIndicator positionIndicator

    readonly property real s: 40075000 * Math.cos(center.latitude * Math.PI / 180 ) / Math.pow(2, parent.zoomLevel + 8)   // S=C*cos(y)/2^(z+8) Pixels per meter
    readonly property real m: s * 10 * scaleFactor

    //--------------------------------------------------------------------------

    visible: positionIndicator.visible && positionIndicator.horizontalAccuracy > 0

    center: positionIndicator.center
    radius: Math.max(positionIndicator.horizontalAccuracy, m)

    color: "transparent"
    border {
        color: "#00b2ff"
        width: 3 * scaleFactor
    }

    //--------------------------------------------------------------------------

    ScaleAnimator on scale {
        loops: Animation.Infinite
        from: 0.0
        to: 1.1
        duration: 2000
    }

    //--------------------------------------------------------------------------
}
