/*******************************************************************************
 * Copyright 2012-2014 Esri
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 ******************************************************************************/

import QtQuick 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {
    id: northArrow

    property alias image: image
    property Map map: null
    property real size: 40
    property bool resetOnDoubleClick: true
    property alias fader: fader

    signal clicked()
    signal doubleClicked()

    implicitWidth: 40
    implicitHeight: 40

    width: internal._size
    height: width

    Component.onCompleted: {
        if (!map && parent && parent.objectType && parent.objectType === "Map") {
            map = parent;
        }
    }

    QtObject {
        id: internal

        property real _size: size * AppFramework.displayScaleFactor
    }

    Fader {
        id: fader
        minumumOpacity: 0.25
    }

    Image {
        id: image
        anchors.fill: parent
        source: "images/NorthArrow.png"
        rotation: map != null ? -map.mapRotation : 0
        fillMode: Image.PreserveAspectFit

        onRotationChanged: {
            fader.start();
        }
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true

        onEntered: {
            fader.stop();
        }

        onExited: {
            fader.start();
        }

        onClicked: {
            fader.start();
            northArrow.clicked();
        }

        onDoubleClicked: {
            fader.start();

            if (map && resetOnDoubleClick) {
                map.mapRotation = 0;
            }

            northArrow.doubleClicked();
        }
    }
}
