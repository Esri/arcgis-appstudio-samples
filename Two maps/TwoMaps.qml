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
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0


App {
    id: app
    width: 640
    height: 480

    property bool mapsLinked: false

    RowLayout {
        anchors.fill: parent

        CustomMap {
            id: map1
            Layout.fillHeight: true
            Layout.fillWidth: true

            extent: mapsLinked ? map2.extent : null
            mapRotation: mapsLinked ? map2.mapRotation : null

            ZoomButtons{
                enabled: !mapsLinked
                visible: enabled

                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 10
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: mapsLinked
            }
        }

        CustomMap {
            id: map2
            Layout.fillHeight: true
            Layout.fillWidth: true

            onMapRotationChanged: console.log(mapRotation)

            ZoomButtons {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 10
                }
            }
        }
    }

    Image {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 10
        }

        width: 70
        height: 70

        antialiasing: true

        source: mapsLinked ? "./linked.png" : "./unlinked.png"

        MouseArea {
            anchors.fill: parent
            onClicked: mapsLinked = !mapsLinked
        }
    }

}

//------------------------------------------------------------------------------
