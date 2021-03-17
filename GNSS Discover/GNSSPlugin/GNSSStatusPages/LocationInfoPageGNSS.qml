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

import ArcGIS.AppFramework 1.0

LocationInfoPage {
    id: gnssStatus

    title: qsTr("GNSS Location Status")

    //--------------------------------------------------------------------------

    GNSSData {
        gnssManager: gnssStatus.gnssManager
        labelColor: gnssStatus.labelColor
        textColor: gnssStatus.textColor
        backgroundColor: gnssStatus.listBackgroundColor
        fontFamily: gnssStatus.fontFamily
        letterSpacing: gnssStatus.letterSpacing
        locale: gnssStatus.locale
        isRightToLeft: gnssStatus.isRightToLeft

        visible: gnssStatus.showData
    }

    GNSSMap {
        gnssManager: gnssStatus.gnssManager

        visible: gnssStatus.showMap
    }

    GNSSSkyPlot {
        gnssManager: gnssStatus.gnssManager
        labelColor: gnssStatus.labelColor
        textColor: gnssStatus.textColor
        backgroundColor: gnssStatus.listBackgroundColor
        fontFamily: gnssStatus.fontFamily
        letterSpacing: gnssStatus.letterSpacing
        locale: gnssStatus.locale
        isRightToLeft: gnssStatus.isRightToLeft

        visible: gnssStatus.showSkyPlot
    }

    GNSSDebug {
        gnssManager: gnssStatus.gnssManager
        nmeaLogger: gnssStatus.nmeaLogger
        textColor: gnssStatus.textColor
        backgroundColor: gnssStatus.listBackgroundColor
        buttonBarBorderColor: gnssStatus.buttonBarBorderColor
        buttonBarButtonColor: gnssStatus.buttonBarButtonColor
        buttonBarRecordingColor: gnssStatus.buttonBarRecordingColor
        buttonBarBackgroundColor: gnssStatus.buttonBarBackgroundColor
        fontFamily: gnssStatus.fontFamily
        letterSpacing: gnssStatus.letterSpacing
        locale: gnssStatus.locale
        isRightToLeft: gnssStatus.isRightToLeft

        visible: gnssStatus.showDebug
    }

    //--------------------------------------------------------------------------
}
