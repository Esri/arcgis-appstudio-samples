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

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import ArcGIS.AppFramework 1.0

import "../controls"
import "../GNSSManager"
import "../lib/CoordinateConversions.js" as CC

Page {
    id: gpsInfo

    title: qsTr("Location Status")

    bottomSpacingBackgroundColor: listBackgroundColor

    //--------------------------------------------------------------------------

    readonly property PositionSourceManager positionSourceManager: gnssManager.positionSourceManager

    property double positionTimestamp: positionSourceManager.positionTimestamp
    property double timeOffset: positionSourceManager.timeOffset

    property var position: ({})

    //--------------------------------------------------------------------------

    property color labelColor: "grey"

    //--------------------------------------------------------------------------

    readonly property var kProperties: [
        null,

        {
            name: "speed",
            label: qsTr("Speed"),
            valueTransformer: speedValue,
        },

        {
            name: "verticalSpeed",
            label: qsTr("Vertical speed"),
            valueTransformer: speedValue,
        },

        null,

        {
            name: "direction",
            label: qsTr("Direction"),
            valueTransformer: angleValue,
        },

        {
            name: "magneticVariation",
            label: qsTr("Magnetic variation"),
            valueTransformer: angleValue,
        },

        null,

        {
            name: "horizontalAccuracy",
            label: qsTr("Horizontal accuracy"),
            valueTransformer: linearValue,
        },

        {
            name: "verticalAccuracy",
            label: qsTr("Vertical accuracy"),
            valueTransformer: linearValue,
        },
    ]

    //--------------------------------------------------------------------------

    Connections {
        target: positionSourceManager

        onNewPosition: {
            gpsInfo.position = position;
        }
    }

    //--------------------------------------------------------------------------

    contentItem: Rectangle {
        color: listBackgroundColor

        ScrollView {
            id: container

            anchors {
                fill: parent
                margins: 10 * AppFramework.displayScaleFactor
            }

            clip: true
            ScrollBar.vertical.policy: availableHeight < contentHeight
                                       ? ScrollBar.AlwaysOn
                                       : ScrollBar.AlwaysOff

            Column {
                anchors.fill: parent

                spacing: 10 * AppFramework.displayScaleFactor

                InfoCoordinatesText {
                    width: parent.width

                    positionTimestamp: gpsInfo.positionTimestamp
                    timeOffset: gpsInfo.timeOffset
                    position: gpsInfo.position

                    labelColor: gpsInfo.labelColor
                    textColor: gpsInfo.textColor
                    fontFamily: gpsInfo.fontFamily
                    letterSpacing: gpsInfo.letterSpacing
                    locale: gpsInfo.locale
                    isRightToLeft: gpsInfo.isRightToLeft
                }

                InfoView {
                    width: parent.width

                    model: kProperties

                    dataDelegate: infoText
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: infoText

        InfoDataText {
            label: kProperties[modelIndex].label
            value: dataValue(kProperties[modelIndex]);

            labelColor: gpsInfo.labelColor
            textColor: gpsInfo.textColor
            fontFamily: gpsInfo.fontFamily
            letterSpacing: gpsInfo.letterSpacing
            locale: gpsInfo.locale
            isRightToLeft: gpsInfo.isRightToLeft
        }
    }

    //--------------------------------------------------------------------------

    function dataValue(propertyInfo) {
        var source = propertyInfo.source;
        var valid = true;

        if (!source) {
            source = position;
            valid = source[propertyInfo.name + "Valid"];
        }

        var value = source[propertyInfo.name];

        if (!valid || value === undefined || value === null || (typeof value === "number" && !isFinite(value))) {
            return;
        }

        if (propertyInfo.valueTransformer) {
            return propertyInfo.valueTransformer(value);
        } else {
            return value;
        }
    }

    //--------------------------------------------------------------------------

    function linearValue(metres) {
        return CC.toLocaleLengthString(metres, locale);
    }

    //--------------------------------------------------------------------------

    function speedValue(metresPerSecond) {
        return CC.toLocaleSpeedString(metresPerSecond, locale);
    }

    //--------------------------------------------------------------------------

    function angleValue(degrees) {
        return "%1°".arg(degrees);
    }

    //--------------------------------------------------------------------------
}
