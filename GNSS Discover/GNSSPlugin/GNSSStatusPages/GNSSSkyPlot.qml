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
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Positioning 1.0

import "../"
import "../controls"
import "../GNSSManager"

SwipeTab {
    id: tab

    title: qsTr("Satellites")
    icon: "../images/assessment-black-24dp.svg"

    //--------------------------------------------------------------------------

    property GNSSManager gnssManager

    readonly property PositionSourceManager positionSourceManager: gnssManager.positionSourceManager
    readonly property PositioningSourcesController controller: positionSourceManager.controller
    readonly property SatelliteInfoSource satelliteInfoSource: positionSourceManager.satelliteInfoSource

    property color inUseColor: "#408c31"
    property color inUseBorderColor: "#7cFc00"
    property real inUseSize: 15 * AppFramework.displayScaleFactor

    property color notInUseColor: "grey"
    property color notInUseBorderColor: "dimgrey"
    property real notInUseSize: 10 * AppFramework.displayScaleFactor

    property color textColor: "black"
    property color labelColor: "grey"
    property color backgroundColor: "white"
    property color snrLineColor: "#20000000"

    property color snrRangeColor0: "#a80000"
    property color snrRangeColor1: "#ffa500"
    property color snrRangeColor2: "#ffd700"
    property color snrRangeColor3: "yellow"
    property color snrRangeColor4: "#7cFc00"
    property color snrRangeColor5: "#32cd32"

    property int myMargin: 5 * AppFramework.displayScaleFactor

    property bool doSteregraphicProjection: true

    //--------------------------------------------------------------------------

    signal clear();

    //--------------------------------------------------------------------------

    Connections {
        target: satelliteInfoSource

        function onSatellitesInViewChanged() {
            clear();

            for (var i = 0; i < satelliteInfoSource.satellitesInView.count; i++) {
                var info = satelliteInfoSource.satellitesInView.get(i);

                if (info.satelliteIdentifier > -1) {
                    if (!info.isInUse) {
                        notInUseSeries.append(info.azimuth, project(info.elevation, doSteregraphicProjection));
                    } else {
                        inUseSeries.append(info.azimuth, project(info.elevation, doSteregraphicProjection));
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    onClear: {
        notInUseSeries.clear();
        inUseSeries.clear();
    }

    //--------------------------------------------------------------------------

    PolarChartView {
        id: polarChart

        anchors {
            top: parent.top
            topMargin: -7 * AppFramework.displayScaleFactor
            left: parent.left
            leftMargin: -7 * AppFramework.displayScaleFactor
            right: parent.right
            rightMargin: -7 * AppFramework.displayScaleFactor
        }

        height: tab.height * 0.6

        title: qsTr("In View: %1 / In Use: %2").arg(inUseSeries.count + notInUseSeries.count).arg(inUseSeries.count)

        titleColor: textColor
        titleFont {
            pixelSize: 12 * AppFramework.displayScaleFactor
            family: fontFamily
        }

        legend {
            visible: true
            markerShape: Legend.MarkerShapeCircle
            labelColor: tab.labelColor
            font {
                pixelSize: 12 * AppFramework.displayScaleFactor
                family: fontFamily

            }
        }

        antialiasing: true
        backgroundColor: tab.backgroundColor
        locale: tab.locale

        CategoryAxis {
            id: angularAxis

            min: 0
            max: 360
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue
            labelsColor: tab.labelColor
            labelsFont {
                pixelSize: 9 * AppFramework.displayScaleFactor
                family: fontFamily
            }

            CategoryRange {
                label: qsTr("N")
                endValue: 0
            }

            CategoryRange {
                label: qsTr("NE")
                endValue: 45
            }

            CategoryRange {
                label: qsTr("E")
                endValue: 90
            }

            CategoryRange {
                label: qsTr("SE")
                endValue: 135
            }

            CategoryRange {
                label: qsTr("S")
                endValue: 180
            }

            CategoryRange {
                label: qsTr("SW")
                endValue: 225
            }

            CategoryRange {
                label: qsTr("W")
                endValue: 270
            }

            CategoryRange {
                label: qsTr("NW")
                endValue: 315
            }
        }

        CategoryAxis {
            id: radialAxis

            min: 0
            max: 90

            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue
            labelsColor: "transparent"
            labelsFont {
                pixelSize: 8 * AppFramework.displayScaleFactor
                family: fontFamily
            }

            CategoryRange {
                label: "90°"
                endValue: project(90, doSteregraphicProjection)
            }

            CategoryRange {
                label: "60°"
                endValue: project(60, doSteregraphicProjection)
            }

            CategoryRange {
                label: "30°"
                endValue: project(30, doSteregraphicProjection)
            }

            CategoryRange {
                label: "0°"
                endValue: project(0, doSteregraphicProjection)
            }
        }

        ScatterSeries {
            id: notInUseSeries

            name: qsTr("Not In Use")
            axisAngular: angularAxis
            axisRadial: radialAxis
            markerSize: notInUseSize
            color: notInUseColor
            borderColor: notInUseBorderColor
            borderWidth: 1 * AppFramework.displayScaleFactor
            markerShape: ScatterSeries.MarkerShapeCircle
        }

        ScatterSeries {
            id: inUseSeries

            name: qsTr("In Use")
            axisAngular: angularAxis
            axisRadial: radialAxis
            markerSize: inUseSize
            color: inUseColor
            borderColor: inUseBorderColor
            borderWidth: 1 * AppFramework.displayScaleFactor
            markerShape: ScatterSeries.MarkerShapeCircle
        }
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: barChart

        anchors {
            top: polarChart.bottom
            topMargin: -5 * AppFramework.displayScaleFactor
            bottom: parent.bottom
            bottomMargin: myMargin
            left: parent.left
            leftMargin: myMargin
            right: parent.right
            rightMargin: myMargin
        }

        radius: 8 * AppFramework.displayScaleFactor

        color: tab.backgroundColor

        Row {
            id: view

            anchors {
                fill: parent
                margins: myMargin
            }

            property int minCount: 5
            property int maxCount: 30
            property int count: satelliteInfoSource.satellitesInView.count
            property int rows: count >= minCount ? count : minCount
            property int singleWidth: ((view.width - scale.width) / rows) - myMargin

            spacing: myMargin

            Rectangle {
                id: scale

                Layout.alignment: Qt.AlignLeft
                Layout.fillHeight: true

                width: strengthLabel.width + 10 * AppFramework.displayScaleFactor
                height: view.height

                color: snrRangeColor5

                Text {
                    id: sn100Text

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                    }

                    font {
                        pixelSize: 11 * AppFramework.displayScaleFactor
                        family: fontFamily
                    }

                    text: "100"
                }

                Text {
                    id: sn50Text

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: sn40Rect.top
                    }

                    font {
                        pixelSize: 11 * AppFramework.displayScaleFactor
                        family: fontFamily
                    }

                    text: "50"
                }

                Rectangle {
                    id: sn40Rect

                    anchors.bottom: sn30Rect.top

                    width: parent.width
                    height: parent.height*10/100

                    color: snrRangeColor4

                    Text {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                        }

                        font {
                            pixelSize: 11 * AppFramework.displayScaleFactor
                            family: fontFamily
                        }

                        text: "40"
                    }
                }

                Rectangle {
                    id: sn30Rect

                    anchors.bottom: sn20Rect.top

                    width: parent.width
                    height: parent.height*10/100

                    color: snrRangeColor3

                    Text {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                        }

                        font {
                            pixelSize: 11 * AppFramework.displayScaleFactor
                            family: fontFamily
                        }

                        text: "30"
                    }
                }

                Rectangle {
                    id: sn20Rect

                    anchors.bottom: sn10Rect.top

                    width: parent.width
                    height: parent.height*10/100

                    color: snrRangeColor2

                    Text {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                        }

                        font {
                            pixelSize: 11 * AppFramework.displayScaleFactor
                            family: fontFamily
                        }

                        text: "20"
                    }
                }

                Rectangle {
                    id: sn10Rect

                    anchors.bottom: sn00Rect.top

                    width: parent.width
                    height: parent.height*10/100

                    color: snrRangeColor1

                    Text {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                        }

                        font {
                            pixelSize: 11 * AppFramework.displayScaleFactor
                            family: fontFamily
                        }

                        text: "10"
                    }
                }

                Rectangle {
                    id: sn00Rect

                    anchors.bottom: parent.bottom

                    width: parent.width
                    height: parent.height*10/100

                    color: snrRangeColor0

                    Text {
                        id: strengthLabel

                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                        }

                        font {
                            pixelSize: 11 * AppFramework.displayScaleFactor
                            family: fontFamily
                        }

                        text: "00"
                    }
                }
            }

            Repeater {
                id: repeater

                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true
                Layout.fillHeight: true

                model: !controller.useInternalGPS ? satelliteInfoSource.satellitesInView : null

                delegate: Rectangle {
                    height: view.height
                    width: view.singleWidth

                    color: tab.backgroundColor

                    Rectangle {
                        id: bar

                        anchors {
                            bottom: parent.bottom
                        }

                        width: parent.width
                        height: parent.height*signalStrength/100 < parent.height ? parent.height*signalStrength/100 : parent.height

                        color: isInUse ? inUseColor : notInUseColor
                    }

                    Text {
                        visible: view.count <= view.maxCount
                        color: tab.textColor

                        anchors {
                            left: bar.left
                            right: bar.right
                            bottom: bar.top
                        }

                        font {
                            pixelSize: 11 * AppFramework.displayScaleFactor
                            family: fontFamily
                        }

                        fontSizeMode: Text.HorizontalFit
                        minimumPixelSize: 7 * AppFramework.displayScaleFactor
                        elide: Text.ElideNone

                        text: satelliteIdentifier
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        Item {
            anchors {
                left: view.left
                right: view.right
                bottom: view.bottom
            }

            height: view.height / 2

            Repeater {
                model: 5

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    y: view.height / 10 * index
                    height: 1
                    color: snrLineColor
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    // stereographic projection with origin at the nadir
    function project(elevation, doProjection) {
        return (doProjection ? 90 * Math.tan((90-elevation)/2 * Math.PI/180) : 90-elevation);
    }

    //--------------------------------------------------------------------------

    function snrColor(snr) {
        if (snr < 10) {
            return snrRangeColor0;
        } else if (snr < 20) {
            return snrRangeColor1;
        } else if (snr < 30) {
            return snrRangeColor2;
        } else if (snr < 40) {
            return snrRangeColor3;
        } else if (snr < 50) {
            return snrRangeColor4;
        } else {
            return snrRangeColor5;
        }
    }

    //--------------------------------------------------------------------------
}
