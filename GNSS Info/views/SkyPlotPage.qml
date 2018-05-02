/* Copyright 2018 Esri
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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtCharts 2.2

import ArcGIS.AppFramework.Positioning 1.0

Page {
    id: skyPlotPage

    property PositionSource positionSource
    property Position position: positionSource.position
    property SatelliteInfoSource satelliteInfoSource

    property int numNotInUse
    property int numInUse

    property bool doSteregraphicProjection: true

    signal clear();

    //--------------------------------------------------------------------------

    onClear: {
        notInUseSeries.clear();
        inUseSeries.clear();

        numNotInUse = 0;
        numInUse = 0;
    }

    //--------------------------------------------------------------------------

    PolarChartView {
        id: chartView

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: app.height * 0.6

        title: qsTr("In View: %1 / In Use: %2").arg(position.satellitesVisible).arg(position.satellitesInUse)

        legend.visible: true
        legend.font.pointSize: 11
        antialiasing: true

        CategoryAxis {
            id: angularAxis
            min: 0
            max: 360
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue

            CategoryRange {
                label: "N"
                endValue: 0
            }
            CategoryRange {
                label: "NE"
                endValue: 45
            }
            CategoryRange {
                label: "E"
                endValue: 90
            }
            CategoryRange {
                label: "SE"
                endValue: 135
            }
            CategoryRange {
                label: "S"
                endValue: 180
            }
            CategoryRange {
                label: "SW"
                endValue: 225
            }
            CategoryRange {
                label: "W"
                endValue: 270
            }
            CategoryRange {
                label: "NW"
                endValue: 315
            }
        }

        CategoryAxis {
            id: radialAxis
            min: 0
            max: 90
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue

            CategoryRange {
                label: "90"
                endValue: project(90, doSteregraphicProjection)
            }
            CategoryRange {
                label: "60"
                endValue: project(60, doSteregraphicProjection)
            }
            CategoryRange {
                label: "30"
                endValue: project(30, doSteregraphicProjection)
            }
            CategoryRange {
                label: "0"
                endValue: project(0, doSteregraphicProjection)
            }
        }

        ScatterSeries {
            id: notInUseSeries

            name: qsTr("Not Used: %1").arg(numNotInUse)
            axisAngular: angularAxis
            axisRadial: radialAxis
            markerSize: 10
            color: "grey"
            borderColor: "dimgrey"
            markerShape: ScatterSeries.MarkerShapeRectangle
        }

        ScatterSeries {
            id: inUseSeries

            name: qsTr("In Use: %1").arg(numInUse)
            axisAngular: angularAxis
            axisRadial: radialAxis
            markerSize: 10
            color: primaryColor
            borderColor: darkPrimaryColor
            markerShape: ScatterSeries.MarkerShapeRectangle
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: satelliteInfoSource

        onSatellitesInViewChanged : {
            clear();

            for (var i = 0; i < satelliteInfoSource.satellitesInView.count; i++) {
                var info = satelliteInfoSource.satellitesInView.get(i);

                if (info.satelliteIdentifier > -1) {
                    if (!info.isInUse) {
                        notInUseSeries.append(info.azimuth, project(info.elevation, doSteregraphicProjection));
                        numNotInUse++;
                    } else {
                        inUseSeries.append(info.azimuth, project(info.elevation, doSteregraphicProjection));
                        numInUse++;
                    }
                }
            }
        }
    }

    Rectangle {
        id: chart

        anchors.top: chartView.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: rect.myMargin
        border.width: 3
        radius: 10
        border.color: "black"

        Item {
            id: rect

            anchors.fill: parent
            anchors.margins: myMargin
            property int myMargin: 5

            Row {
                id: view

                property int rows: satelliteInfoSource.satellitesInView.count
                property int singleWidth: ((rect.width - scale.width) / rows) - rect.myMargin
                spacing: rect.myMargin

                Rectangle {
                    id: scale
                    width: strengthLabel.width+10
                    height: rect.height
                    color: "#32cd32"
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: lawngreenRect.top
                        font.pointSize: 11
                        text: "50"
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        font.pointSize: 11
                        text: "100"
                    }

                    Rectangle {
                        id: redRect
                        width: parent.width
                        color: "red"
                        height: parent.height*10/100
                        anchors.bottom: parent.bottom
                        Text {
                            id: strengthLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            font.pointSize: 11
                            text: "00"
                        }
                    }
                    Rectangle {
                        id: orangeRect
                        height: parent.height*10/100
                        anchors.bottom: redRect.top
                        width: parent.width
                        color: "#ffa500"
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            font.pointSize: 11
                            text: "10"
                        }
                    }
                    Rectangle {
                        id: goldRect
                        height: parent.height*10/100
                        anchors.bottom: orangeRect.top
                        width: parent.width
                        color: "#ffd700"
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            font.pointSize: 11
                            text: "20"
                        }
                    }
                    Rectangle {
                        id: yellowRect
                        height: parent.height*10/100
                        anchors.bottom: goldRect.top
                        width: parent.width
                        color: "yellow"
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            font.pointSize: 11
                            text: "30"
                        }
                    }
                    Rectangle {
                        id: lawngreenRect
                        height: parent.height*10/100
                        anchors.bottom: yellowRect.top
                        width: parent.width
                        color: "#7cFc00"
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            font.pointSize: 11
                            text: "40"
                        }
                    }
                }

                Repeater {
                    id: repeater

                    model: satelliteInfoSource.satellitesInView
                    delegate: Rectangle {
                        height: rect.height
                        width: view.singleWidth

                        Rectangle {
                            id: bar

                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: parent.height*signalStrength/100 < parent.height ? parent.height*signalStrength/100 : parent.height
                            color: isInUse ? primaryColor : "darkgrey"
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: bar.top
                            text: satelliteIdentifier
                            Layout.alignment: horizontalAlignment
                            horizontalAlignment: Text.AlignHCenter
                            font.pointSize: 11
                        }
                    }
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
}




