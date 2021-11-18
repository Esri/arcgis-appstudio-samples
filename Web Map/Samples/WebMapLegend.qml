import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10


Item {
    property real scaleFactor: AppFramework.displayScaleFactor
    property LegendInfoListModel legendInfoListModel:null

    // create MapView
    MapView {
        id:mapView
        anchors.fill: parent
        // make Drawing Window visible if map is drawing. Not visible if drawing completed
        Map{
            initUrl: "http://arcgis.com/sharing/rest/content/items/f503dd82450e4fe8824b3416f701df71"
            onLoadStatusChanged: {
                if(mapView.map.loadStatus === Enums.LoadStatusLoaded){
                    legendInfoListModel = mapView.map.legendInfos
                    legendInfoListModel.fetchLegendInfos(true)
                }
            }
        }

        //Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
        }

    }

    // Create outter rectangle for the legend
    Rectangle {
        id: legendRect
        anchors {
            margins: 10 * scaleFactor
            left: parent.left
            top: parent.top
        }
        property bool expanded: true
        height: 300 * scaleFactor
        width: 175 * scaleFactor
        color: "lightgrey"
        opacity: 0.95
        radius: 10
        clip: true
        border {
            color: "darkgrey"
            width: 1
        }

        // Animate the expand and collapse of the legend
        Behavior on height {
            SpringAnimation {
                spring: 3
                damping: .4
            }
        }

        // Catch mouse signals so they don't propagate to the map
        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true
            onWheel: wheel.accepted = true
        }

        // Create UI for the user to select the layer to display
        Column {
            anchors {
                fill: parent
                topMargin: 10 * scaleFactor
                bottomMargin: 10 * scaleFactor
            }
            spacing: 8 * scaleFactor

            Row {
                id: legendHeader
                x: 10 * scaleFactor
                spacing: 70 * scaleFactor

                Text {
                    text: qsTr("Legend")
                    font {
                        pixelSize: 18 * scaleFactor
                        bold: true
                    }
                }

                // Legend icon to allow expanding and collapsing
                Image {
                    source: legendRect.expanded ? "../assets/chevron-up.png" : "../assets/chevron-down.png"
                    width: 28 * scaleFactor
                    height: width
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (legendRect.expanded) {
                                legendRect.height = 45 * scaleFactor;
                                legendRect.expanded = false;
                            } else {
                                legendRect.height = 300 * scaleFactor;
                                legendRect.expanded = true;
                            }
                        }
                    }
                }
            }

            // Create a list view to display the legend
            ListView {
                id: legendListView
                anchors{
                    margins: 10 * scaleFactor
                }
                width: legendRect.width
                height: 240 * scaleFactor
                clip: true
                model: legendInfoListModel

                // Create delegate to display the name with an image
                delegate: Item {
                    x: 10 * scaleFactor
                    width: legendRect.width
                    height: 35 * scaleFactor
                    clip: true

                    Row {
                        spacing: 5
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            width: symbolWidth
                            height: symbolHeight
                            source: symbolUrl
                            //fillMode: Image.Stretch
                        }
                        Text {
                            width: 125 * scaleFactor
                            text: name
                            wrapMode: Text.WordWrap
                            font.pixelSize: 12 * scaleFactor
                        }

                    }
                }

                section {
                    property: "layerName"
                    criteria: ViewSection.FullString
                    labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels
                    delegate: Rectangle {
                        width: legendRect.width
                        height: childrenRect.height
                        color: "lightsteelblue"
                        Text {
                            x: 10 * scaleFactor
                            width: legendRect.width - (20 * scaleFactor)
                            text: section
                            wrapMode: Text.WordWrap
                            font.bold: true
                            font.pixelSize: 13 * scaleFactor
                        }
                    }
                }
            }
        }
    }
}
