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
    id: positionIndicator

    property PositionSource positionSource
    property real horizontalAccuracy

    //--------------------------------------------------------------------------

    visible: positionSource.active
    opacity: 0.5

    radius: horizontalAccuracy

    color: horizontalAccuracy > 0 ? "#00b2ff" : "#ff0000"
    border {
        color: "#ffffff"
        width: 1
    }

    //--------------------------------------------------------------------------

    Connections {
        target: positionSource

        onPositionChanged: {
            positionIndicator.center = positionSource.position.coordinate;

            if (positionSource.position.horizontalAccuracyValid) {
                positionIndicator.horizontalAccuracy = positionSource.position.horizontalAccuracy;
            } else {
                positionIndicator.horizontalAccuracy = -1;
            }
        }
    }

    //--------------------------------------------------------------------------
}
