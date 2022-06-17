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
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

ToolButton {
    id: root

    property bool isDebug: false
    property int iconSize: root.getAppProperty(24, root.units(24))
    property color maskColor: root.getAppProperty("transparent", "transparent")
    property url imageSource: ""
    property real imageWidth: 0.5 * root.width
    property real imageHeight: 0.5 * root.height

    Layout.preferredHeight: root.iconSize
    Layout.preferredWidth: root.iconSize

    highlighted: checked

    Rectangle {
        anchors.centerIn: parent
        width: 0.8 * parent.width
        height: width
        radius: width/2
        color: checked ? "#40FFFFFF" : "transparent"
    }

    indicator: Image {
        id: image

        width: imageWidth
        height: imageHeight
        anchors.centerIn: parent
        source: root.imageSource
        mipmap: true
    }

    ColorOverlay {
        id: mask

        anchors.fill: image
        source: image
        color: enabled ? root.maskColor : Qt.lighter(root.maskColor, 2.4)
    }

    function getAppProperty (appProperty, fallback) {
        if (!fallback) fallback = ""
        try {
            return appProperty
        } catch (err) {
            return fallback
        }
    }

    function units(num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }

}
