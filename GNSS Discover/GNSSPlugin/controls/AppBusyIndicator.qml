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
import QtGraphicalEffects 1.15

import ArcGIS.AppFramework 1.0

BusyIndicator {
    id: control

    property int implicitSize: 12 * AppFramework.displayScaleFactor
    property color backgroundColor: "#007ac2"

    contentItem: Item {
        anchors.fill: parent

        implicitWidth: implicitSize
        implicitHeight: implicitSize

        opacity: control.running ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Rectangle {
            id: rect
            width: parent.width
            height: parent.height
            color: Qt.rgba(0,0,0,0)
            radius: width/2
            border.width: width/6
            visible: true
        }

        ConicalGradient {
            width: rect.width
            height: rect.height
            gradient: Gradient {
                GradientStop { position: 0.0; color: backgroundColor }
                GradientStop { position: 1.0; color: Qt.lighter(backgroundColor) }
            }
            source: rect

            Rectangle {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: rect.border.width
                height: width
                radius: width/2
                color: Qt.darker(backgroundColor)
            }

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 800
                loops: Animation.Infinite
            }
        }
    }
}
