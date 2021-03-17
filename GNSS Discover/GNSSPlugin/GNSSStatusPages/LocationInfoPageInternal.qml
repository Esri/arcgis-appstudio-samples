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
    id: gpsStatus

    title: qsTr("Location Status")

    //--------------------------------------------------------------------------

    GPSData {
        gnssManager: gpsStatus.gnssManager
        labelColor: gpsStatus.labelColor
        textColor: gpsStatus.textColor
        backgroundColor: gpsStatus.listBackgroundColor
        fontFamily: gpsStatus.fontFamily
        letterSpacing: gpsStatus.letterSpacing
        locale: gpsStatus.locale
        isRightToLeft: gpsStatus.isRightToLeft

        visible: gpsStatus.showData
    }

    GNSSMap {
        gnssManager: gpsStatus.gnssManager

        visible: gpsStatus.showMap
    }

    GNSSDebug {
        gnssManager: gpsStatus.gnssManager
        nmeaLogger: gpsStatus.nmeaLogger
        textColor: gpsStatus.textColor
        backgroundColor: gpsStatus.listBackgroundColor
        buttonBarBorderColor: gpsStatus.buttonBarBorderColor
        buttonBarButtonColor: gpsStatus.buttonBarButtonColor
        buttonBarRecordingColor: gpsStatus.buttonBarRecordingColor
        buttonBarBackgroundColor: gpsStatus.buttonBarBackgroundColor
        fontFamily: gpsStatus.fontFamily
        letterSpacing: gpsStatus.letterSpacing
        locale: gpsStatus.locale
        isRightToLeft: gpsStatus.isRightToLeft

        visible: gpsStatus.showDebug
    }

    //--------------------------------------------------------------------------
}
