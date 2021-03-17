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

import QtQml 2.15
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Positioning 1.0

import "../"
import "../controls"
import "../GNSSManager"

import "../lib/CoordinateConversions.js" as CC

SwipeTab {
    id: gpsInfo

    title: qsTr("Data")
    icon: "../images/article-black-24dp.svg"

    //--------------------------------------------------------------------------

    property color textColor: "black"
    property color labelColor: "grey"
    property color backgroundColor: "white"

    //--------------------------------------------------------------------------

    property GNSSManager gnssManager
    readonly property PositionSourceManager positionSourceManager: gnssManager.positionSourceManager

    property var position: gnssManager.position

    property double positionTimestamp: positionSourceManager.positionTimestamp

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

        null,
    ]

    //--------------------------------------------------------------------------

    Connections {
        target: positionSourceManager

        function onNewPosition(position) {
            gpsInfo.position = position;
        }
    }

    //--------------------------------------------------------------------------

    Rectangle {
        anchors.fill: parent
        color: backgroundColor

        ScrollView {
            id: container

            anchors {
                fill: parent
                margins: 10 * AppFramework.displayScaleFactor
            }

            clip: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                width: container.width
                height: container.height

                spacing: 10 * AppFramework.displayScaleFactor

                InfoCoordinatesText {
                    Layout.fillWidth: true

                    position: gpsInfo.position
                    positionTimestamp: gpsInfo.positionTimestamp

                    labelColor: gpsInfo.labelColor
                    textColor: gpsInfo.textColor
                    fontFamily: gpsInfo.fontFamily
                    letterSpacing: gpsInfo.letterSpacing
                    locale: gpsInfo.locale
                    isRightToLeft: gpsInfo.isRightToLeft
                }

                InfoView {
                    Layout.fillWidth: true

                    model: kProperties

                    dataDelegate: propertiesText
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: propertiesText

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

        if (value && propertyInfo.property) {
            value = value[propertyInfo.property];
        }

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
