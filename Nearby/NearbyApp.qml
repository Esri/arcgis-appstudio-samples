/* Copyright 2020 Esri
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
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0
import ArcGIS.AppFramework.Networking 1.0

import "./Controls"
import "./Views"
import "./Assets"
import "./Widgets"

AppLayout {
    id: appLayout

    width: 400
    height: 750

    delegate: App {
        id: app
        width: appLayout.width
        height: appLayout.height

        property double scaleFactor: AppFramework.displayScaleFactor
        readonly property color primaryColor: colors.primaryColor
        readonly property color secondaryColor: colors.secondaryColor
        readonly property color toolbarColor: colors.toolbarColor
        readonly property color btnColor: colors.btnColor
        readonly property color textColor: colors.textColor
        readonly property color darkIconOverlay: colors.darkIconOverlay

        readonly property real milesToMeters: 1609.34
        readonly property real kiloMetersToMeters: 1000
        property real searchDistance: app.deviceManager.localeInfoNameIsEn_US? 20 * app.milesToMeters: 20 * app.kiloMetersToMeters
        property bool locationAccessGranted: true
        property alias deviceManager: deviceManager
        property bool isOnline: deviceManager.isOnline

        MapView {
            id: mapView

            anchors.fill: parent
            anchors.bottomMargin: deviceManager.isiPhone || deviceManager.isiPad? 20 * app.scaleFactor: 0
        }

        Colors {
            id: colors
        }

        Strings {
            id: strings
        }

        Sources {
            id: sources
        }

        MapIConsSelector {
            id: mapIConsSelector
        }

        DeviceManager {
            id: deviceManager
        }

        ToastMessage {
            id: toastMessage
        }

        AppManager {
            id: appManager
        }

        Component.onCompleted: {
            StatusBar.theme = Material.Dark;
            StatusBar.color = Qt.darker(app.toolbarColor);
            appManager.initialize();
            deviceManager.initialize();
        }
    }
}
