import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.2


Item {
    property real scaleFactor: AppFramework.displayScaleFactor
    property LegendInfoListModel legendInfoListModel:null

    // create MapView
    MapView {
        id:mapView
        anchors.fill: parent
        // make Drawing Window visible if map is drawing. Not visible if drawing completed
        Map{
            initUrl: "http://arcgis.com/sharing/rest/content/items/de4a605afa3540f7835e659c23d90e8e"
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
                margins: 10 * scaleFactor
            }
            spacing: 2 * scaleFactor

            Row {
                spacing: 55 * scaleFactor

                Text {
                    text: qsTr("Legend")
                    font {
                        pixelSize: 18 * scaleFactor
                        bold: true
                    }
                }

                // Legend icon to allow expanding and collapsing
                Image {
                    source: legendRect.expanded ? "../assets/ic_menu_legendpopover_light_d.png" : "../assets/ic_menu_legendpopover_light.png"
                    width: 28 * scaleFactor
                    height: width

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (legendRect.expanded) {
                                legendRect.height = 40 * scaleFactor;
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
                anchors.margins: 10 * scaleFactor
                width: 165 * scaleFactor
                height: 240 * scaleFactor
                clip: true
                model: legendInfoListModel

                // Create delegate to display the name with an image
                delegate: Item {
                    width: parent.width
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
                        width: 180 * scaleFactor
                        height: childrenRect.height
                        color: "lightsteelblue"

                        Text {
                            text: section
                            font.bold: true
                            font.pixelSize: 13 * scaleFactor
                        }
                    }
                }
            }
        }
    }
}
