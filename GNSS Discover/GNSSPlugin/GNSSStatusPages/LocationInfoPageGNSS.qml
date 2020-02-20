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

import ArcGIS.AppFramework 1.0

import "../controls"
import "../GNSSManager"

Page {
    id: gnssStatus

    title: qsTr("GNSS Location Status")

    property color debugButtonColor: headerBarBackgroundColor

    bottomSpacingBackgroundColor: headerBarBackgroundColor

    //--------------------------------------------------------------------------

    property NmeaLogger nmeaLogger

    property color labelColor: "grey"

    //--------------------------------------------------------------------------

    readonly property PositionSourceManager positionSourceManager: gnssManager.positionSourceManager

    //--------------------------------------------------------------------------

    contentItem: SwipeTabView {
        fontFamily: gnssStatus.fontFamily
        tabBarBackgroundColor: gnssStatus.headerBarBackgroundColor
        selectedTextColor: gnssStatus.headerBarTextColor
        color: gnssStatus.backgroundColor

        clip: true

        GNSSData {
            positionSourceManager: gnssStatus.positionSourceManager
            gnssSettings: gnssStatus.gnssManager.gnssSettings
            labelColor: gnssStatus.labelColor
            textColor: gnssStatus.textColor
            backgroundColor: gnssStatus.listBackgroundColor
            fontFamily: gnssStatus.fontFamily
            letterSpacing: gnssStatus.letterSpacing
            locale: gnssStatus.locale
            isRightToLeft: gnssStatus.isRightToLeft
        }

        GNSSSkyPlot {
            positionSourceManager: gnssStatus.positionSourceManager
            labelColor: gnssStatus.labelColor
            textColor: gnssStatus.textColor
            backgroundColor: gnssStatus.listBackgroundColor
            fontFamily: gnssStatus.fontFamily
            letterSpacing: gnssStatus.letterSpacing
            locale: gnssStatus.locale
            isRightToLeft: gnssStatus.isRightToLeft
        }

        GNSSDebug {
            positionSourceManager: gnssStatus.positionSourceManager
            nmeaLogger: gnssStatus.nmeaLogger
            textColor: gnssStatus.textColor
            buttonColor: gnssStatus.debugButtonColor
            backgroundColor: gnssStatus.listBackgroundColor
            fontFamily: gnssStatus.fontFamily
            letterSpacing: gnssStatus.letterSpacing
            locale: gnssStatus.locale
            isRightToLeft: gnssStatus.isRightToLeft
        }
    }

    //--------------------------------------------------------------------------
}
