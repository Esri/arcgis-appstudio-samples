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
import QtPositioning 5.15

import ArcGIS.AppFramework 1.0

import "../lib/CoordinateConversions.js" as CC

InfoView {
    id: coordinateInfo

    property var position: ({})
    property bool showAgeTimer: true

    property int llFormatIndex: 0
    property string llFormat: kLatLonFormats[llFormatIndex]
    property string latitude
    property string longitude
    property string altitude
    property int prjFormatIndex: 0
    property string prjText
    readonly property string prjLabel: kPrjFormats[prjFormatIndex].label

    property double positionTimestamp
    property real ageSeconds: Number.NaN
    property string ageText

    property color textColor: "black"
    property color labelColor: "grey"

    property string fontFamily: Qt.application.font.family
    property real letterSpacing: 0
    property var locale: Qt.locale()
    property bool isRightToLeft: AppFramework.localeInfo().esriName === "ar" || AppFramework.localeInfo().esriName === "he"

    //--------------------------------------------------------------------------

    readonly property var kLatLonFormats: ["dms", "ddm", "dd"]

    readonly property var kPrjFormats: [
        {
            label: qsTr("USNG"),
            format: CC.formatUsngCoordinate,
        },
        {
            label: qsTr("MGRS"),
            format: CC.formatMgrsCoordinate,
        },
        {
            label: qsTr("UTM/UPS"),
            format: CC.formatUniversalCoordinate,
        },
    ]

    //--------------------------------------------------------------------------

    readonly property var kProperties: [

        {
            name: "ageText",
            label: qsTr("Time since last update"),
            source: coordinateInfo,
        },

        {
            name: "latitude",
            label: qsTr("Latitude"),
            llFormat: true
        },

        {
            name: "longitude",
            label: qsTr("Longitude"),
            llFormat: true
        },

        {
            name: "altitude",
            label: qsTr("Altitude"),
        },

        null,

        {
            name: "prjText",
            label: prjLabel,
            prjFormat: true
        },
    ]

    //--------------------------------------------------------------------------

    model: kProperties

    //--------------------------------------------------------------------------

    onAgeSecondsChanged: {
        if (isFinite(ageSeconds)) {
            ageText = qsTr("%1 s").arg(ageSeconds.toFixed(1));
        } else {
            ageText = "";
        }
    }

    onPositionChanged: {
        update();
    }

    onLlFormatChanged: {
        update();
    }

    onPrjFormatIndexChanged: {
        update();
    }

    function update() {
        if (!position) {
            return;
        }

        var coordinate = position.coordinate;

        if (!coordinate || !coordinate.isValid) {
            return;
        }

        latitude = CC.formatLatitude(coordinate.latitude, llFormat);
        longitude = CC.formatLongitude(coordinate.longitude, llFormat);
        altitude = CC.toLocaleLengthString(coordinate.altitude, locale, 2);
        prjText = kPrjFormats[prjFormatIndex].format(coordinate);

        ageSeconds = ((new Date()).valueOf() - positionTimestamp) / 1000;

        if (showAgeTimer) {
            ageTimer.restart();
        }
    }

    //--------------------------------------------------------------------------

    dataDelegate: InfoDataText {
        label: modelData.label
        value: coordinateInfo[modelData.name]

        labelColor: coordinateInfo.labelColor
        textColor: coordinateInfo.textColor
        fontFamily: coordinateInfo.fontFamily
        letterSpacing: coordinateInfo.letterSpacing
        locale: coordinateInfo.locale
        isRightToLeft: coordinateInfo.isRightToLeft

        onLabelClicked: {
            if (modelData.llFormat) {
                llFormatIndex = (llFormatIndex + 1) % kLatLonFormats.length;
            } else if (modelData.prjFormat) {
                prjFormatIndex = (prjFormatIndex + 1) % kPrjFormats.length;
            }
        }
    }

    //--------------------------------------------------------------------------

    Timer {
        id: ageTimer

        triggeredOnStart: true
        interval: 100
        repeat: true

        onTriggered: {
            ageSeconds += 0.1;
        }
    }

    //--------------------------------------------------------------------------
}
