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

import QtQuick 2.12
import QtQuick.Controls 2.12

import ArcGIS.AppFramework 1.0

import "./controls"

StyledImageButton {
    id: button

    //--------------------------------------------------------------------------
    // Public properties

    // Reference to GNSSSettingsPages (required)
    property GNSSSettingsPages gnssSettingsPages

    // Button styling
    color: "#ffffff"

    width: 30 * AppFramework.displayScaleFactor
    height: width

    //--------------------------------------------------------------------------
    // Internal properties

    readonly property StackView stackView: gnssSettingsPages.stackView

    source: gnssSettingsPages.settingsIcon

    //--------------------------------------------------------------------------

    onClicked: {
        gnssSettingsPages.showLocationSettings(stackView);
    }

    //--------------------------------------------------------------------------
}
