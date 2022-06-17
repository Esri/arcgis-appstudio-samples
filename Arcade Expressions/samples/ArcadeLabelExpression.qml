import QtQuick 2.3
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12

import Esri.ArcGISRuntime 100.13
import Esri.ArcGISRuntime.Toolkit 100.13

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Scripting 1.0

import "../controls" as Controls


Rectangle {
    id: rootRectangle
    clip: true
    anchors.fill: parent



    property var arcadeExpressions: ["N/A", "$feature.E_DAYPOP", "ROUND($feature.E_DAYPOP/$feature.AREA_SQMI)"]
    property int index: 0

    ListModel {
        id: arcadeExpressionsList
        ListElement {
            expression: "N/A"
            summary: "No arcade expression used"
        }
        ListElement {
            expression: "$feature.E_DAYPOP"
            summary: "Total Population"
        }
        ListElement {
            expression: "ROUND($feature.E_DAYPOP/$feature.AREA_SQMI)"
            summary: "Total population per square mile"
        }
    }

    MapView {
        id: mapView
        anchors.fill: parent

        Component.onCompleted: {

            //Set initial label expression
            var labelExpression = ArcGISRuntimeEnvironment.createObject("ArcadeLabelExpression", {
                                                                            expression: arcadeExpressions[index]
                                                                        })
            lowRanking.expression = labelExpression

            // Set the focus on MapView to initially enable keyboard navigation
            forceActiveFocus();
        }

        Map {

            BasemapDarkGrayCanvasVector{}
            initialViewpoint: viewpoint
            FeatureLayer {
                // Add a feature service
                ServiceFeatureTable {
                    url: "https://services3.arcgis.com/ZvidGQkLaDJxRSJ2/arcgis/rest/services/CDC_Social_Vulnerability_Index_2018/FeatureServer/1"
                }

                // Enable Labels
                labelsEnabled: true

                //Label based on an Arcade Expression
                LabelDefinition {
                    id: lowRanking
                    //Text styling for the label
                    textSymbol: TextSymbol {
                        size: 11
                        color: "red"
                        haloColor: "white"
                        haloWidth: 2
                        horizontalAlignment: Enums.HorizontalAlignmentCenter
                        verticalAlignment: Enums.VerticalAlignmentMiddle
                    }
                }
            }
        }
    }

    ViewpointCenter {
        id: viewpoint
        center: Point {
            x: -10985519.67113797
            y: 3617707.86118573
        }
        targetScale: 9896998.665743142
    }


    Rectangle {
        id: rect
        anchors{
            top: parent.top
            topMargin: 14
            horizontalCenter: parent.horizontalCenter
        }
        radius: 4
        width: Math.min(parent.width * 0.8, 500)
        height: Math.min(parent.height * 0.25, 155)

        color: "white"
        RowLayout {
            width: parent.width
            height: parent.height
            Controls.Icon {
                id: previousPage
                Layout.preferredWidth: 35 * app.scaleFactor
                Layout.preferredHeight: 35 * app.scaleFactor

                Material.elevation: 0
                maskColor: "#4c4c4c"
                enabled: swipeView.currentIndex >= 1
                imageSource: "../assets/chevron-left.png"
                onClicked: {
                    swipeView.currentIndex--
                }
            }
            ColumnLayout{
                Layout.preferredWidth: parent.width * 0.85
                SwipeView {
                    id: swipeView
                    currentIndex: 0
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Repeater {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        model: arcadeExpressionsList
                        ColumnLayout {
                            Layout.fillWidth: true
                            clip: true
                            visible: index === swipeView.currentIndex
                            Text {
                                Layout.topMargin: 14
                                Layout.preferredWidth: parent.width
                                text: "Arcade Label Info"
                                color: "black"
                                wrapMode: Text.WordWrap
                                font.pixelSize: 18
                                font.bold: true
                            }
                            Text {
                                Layout.preferredWidth: parent.width
                                text: "<b>Expression used: </b><br>" + expression
                                color: "black"
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                layer.enabled: true
                            }

                            Text {
                                Layout.preferredWidth: parent.width
                                text: "<b>Summary: </b><br>" + summary
                                color: "black"
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                layer.enabled: true
                            }
                        }
                    }

                    onCurrentIndexChanged: {
                        index = currentIndex
                        updateExpression()
                    }
                }
                PageIndicator {
                    id: indicator

                    count: swipeView.count
                    currentIndex: swipeView.currentIndex

                    Layout.alignment: Qt.AlignHCenter
                }
            }
            Controls.Icon {
                id: nextPage
                Layout.preferredWidth: 35 * app.scaleFactor
                Layout.preferredHeight: 35 * app.scaleFactor
                Material.elevation: 0
                maskColor: "#4c4c4c"
                enabled: swipeView.currentIndex + 1 < swipeView.count
                imageSource: "../assets/chevron-right.png"
                onClicked: {
                    swipeView.currentIndex++
                }
            }
        }
    }

    //Update label expression
    function updateExpression(){
        var labelExpression = ArcGISRuntimeEnvironment.createObject("ArcadeLabelExpression", {
                                                                        expression: arcadeExpressions[index]
                                                                    })
        lowRanking.expression = labelExpression
    }
}
