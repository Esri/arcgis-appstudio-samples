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

Label {
    id: root

    property string fontNameFallbacks: "Helvetica,Avenir"
    property string baseFontFamily: root.getAppProperty (app.baseFontFamily, fontNameFallbacks)
    property string titleFontFamily: root.getAppProperty (app.titleFontFamily, "")
    property string accentColor: root.getAppProperty(app.accentColor)

    color: root.getAppProperty (app.baseTextColor, Qt.darker("#F7F8F8"))
    font {
        pointSize:12
        family: "%1,%2".arg(baseFontFamily).arg(fontNameFallbacks)
    }
    Material.accent: accentColor
    wrapMode: Text.WordWrap

    function getAppProperty (appProperty, fallback) {
        if (!fallback) fallback = ""
        try {
            return appProperty ? appProperty : fallback
        } catch (err) {
            return fallback
        }
    }
}

