//------------------------------------------------------------------------------
//
// Change Basemap.qml
// Created 2014-05-19 10:11:54
//
//------------------------------------------------------------------------------
import QtQuick 2.3
import QtQuick.Controls 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1



Rectangle {
    id: project
    width: 800
    height: 600
    color: "black"

    property int visibleLayer
    visibleLayer: 1

    Map {
        id: map
        anchors.fill: parent
        wrapAroundEnabled: true
        hidingNoDataTiles: true
        positionDisplay {
            positionSource: PositionSource {
            }
        }


        ArcGISTiledMapServiceLayer {
            id: streetsBasemap
            visible: visibleLayer == 1
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }
        ArcGISTiledMapServiceLayer {
            id:lightGreyCanvas
            visible: visibleLayer == 2
            url: "http://server.arcgisonline.com/arcgis/rest/services/Canvas/World_Light_Gray_Base/MapServer"
        }
        ArcGISTiledMapServiceLayer {
            id:oceanBasemap
            visible: visibleLayer == 3
            url: "http://server.arcgisonline.com/arcgis/rest/services/Ocean_Basemap/MapServer"
        }
        ArcGISTiledMapServiceLayer {
            id:topoBasemap
            visible: visibleLayer == 4
            url: "http://server.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer"
        }
        ArcGISTiledMapServiceLayer {
            id:imageryBasemap
            visible: visibleLayer == 5
            url: "http://server.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer"
        }
        ArcGISTiledMapServiceLayer {
            id:usaTopo
            visible: visibleLayer == 6
            url: "http://server.arcgisonline.com/arcgis/rest/services/USA_Topo_Maps/MapServer"
        }
        ArcGISTiledMapServiceLayer {
            id:worldBoundaries
            visible: visibleLayer == 7
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer"
        }
        ArcGISTiledMapServiceLayer {
            id:worldRefernce
            visible: visibleLayer == 8
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Reference_Overlay/MapServer"
        }
        ArcGISTiledMapServiceLayer {
            id:natGeo
            visible: visibleLayer == 9
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer"
        }
        ArcGISTiledMapServiceLayer {
            id:shadedRelief
            visible: visibleLayer == 10
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer"
        }
        ArcGISTiledMapServiceLayer {
            id:worldPhysical
            visible: visibleLayer == 11
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Physical_Map/MapServer"
        }

        ZoomButtons {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 10

            }
        }
    }

    Rectangle {
        id: menu
        opacity: 0.25
        color: "black"
        width: 250
        height: project.height
        anchors {
            left: parent.left
        }
    }
            ListModel {
                id: nameModel
                ListElement { file: "basemap_streets.png"
                              name: "Streets Basemap"
                              value: 1}
                ListElement { file: "basemap_grey.png"
                              name: "Grey Canvas"
                              value: 2}
                ListElement { file: "basemap_oceans.png"
                              name: "Ocean Basemap"
                              value: 3}
                ListElement { file: "basemap_topo.png"
                              name: "Topographic"
                              value: 4}
                ListElement { file: "basemap_imagery.png"
                              name: "Imagery"
                              value: 5}
                ListElement { file: "basemap_usa_topo.png"
                              name: "USA Topographic"
                              value: 6}
                ListElement { file: "basemap_boundaries.png"
                              name: "Boundaries & Places"
                              value: 7}
                ListElement { file: "basemap_reference.png"
                              name: "Reference"
                              value: 8}
                ListElement { file: "basemap_natgeo.png"
                              name: "National Geographic"
                              value: 9}
                ListElement { file: "basemap_relief.png"
                              name: "Shaded Relief"
                              value: 10}
                ListElement { file: "basemap_physical.png"
                              name: "Physical"
                              value: 11}
            }
            Component {
                id: nameDelegate
                Column {
                   spacing: 10
                   anchors.horizontalCenter: parent.horizontalCenter
                    Image {
                        id: delegateImage
                        anchors.horizontalCenter: delegateText.horizontalCenter
                        source: file; width: 100; height: 100; smooth: true
                        fillMode: Image.PreserveAspectFit

                        MouseArea {
                            anchors.fill: parent
                            onClicked:{
                                visibleLayer = value;
                            }
                        }
                    }
                    Text {
                        id: delegateText
                        text: name; font.pixelSize: 24; color: "white"
                        font.bold: visibleLayer == value;
                    }
                }
            }

            ListView{
                id : listView
                spacing : 40
                anchors{
                    fill: menu
                    horizontalCenter: menu.horizontalCenter
                }
                orientation: ListView.Vertical
                model : nameModel
                delegate: nameDelegate
                flickableDirection: Flickable.VerticalFlick
       }
}


