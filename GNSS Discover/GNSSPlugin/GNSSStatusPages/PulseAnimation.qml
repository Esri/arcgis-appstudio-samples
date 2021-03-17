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


SequentialAnimation {
    id: animation

    //--------------------------------------------------------------------------

    property alias target: animator1.target
    property alias from: animator1.from
    property alias to: animator1.to
    property int duration: 1000

    //--------------------------------------------------------------------------

    loops: Animation.Infinite

    onStopped: {
        target.opacity = animator1.from;
    }

    //--------------------------------------------------------------------------

    OpacityAnimator {
        id: animator1

        from: 1
        to: 0.15
        easing.type: Easing.InQuad
        duration: animation.duration / 2
    }

    OpacityAnimator {
        target: animator1.target
        from: animator1.to
        to: animator1.from
        easing.type: Easing.InQuad
        duration: animator1.duration
    }

    //--------------------------------------------------------------------------
}
