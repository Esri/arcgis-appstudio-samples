import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

import "components"

Item {
    property alias listModelLegendLayers: listModelLegendLayers
    ListModel {
        id: listModelLegendLayers
    }

    Rectangle {
        id: rectTitle
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        width: parent.width
        height: 60*app.scaleFactor
        color: app.themeColor
        MouseArea {
            anchors.fill: parent
            onClicked: {
                mouse.accepted = false
            }
        }

        Text {
            id: txtTitle
            anchors.centerIn: parent
            text: "My Map"
            color: "white"
            font.pointSize: 22*app.scaleFactor
            font.family: app.fontSourceSansProReg.name
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: rectLegend
            width: 50*app.scaleFactor
            height: parent.height
            color: "transparent"
            anchors {
                right: parent.right
                rightMargin: 15*app.scaleFactor
            }

            Image {
                id: imgLegend
                width: 35*app.scaleFactor
                height: 35*app.scaleFactor
                source: "assets/images/legend.png"
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    legend.show()
                }
            }
        }
    }

    Envelope {
        id: extent
        xMin:  -8574876.742323654
        yMin:  4705251.383377932
        xMax:  -8570676.93264509
        yMax:  4711751.088832853
    }

    Map {
        id: map
        anchors {
            left: parent.left
            right: parent.right
            top: rectTitle.bottom
            bottom: parent.bottom
        }
        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        zoomByPinchingEnabled: true
        extent: extent

        positionDisplay {
            positionSource: PositionSource {
            }
        }

        onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                // Persist layer order in legend
                for (var i = layers.length - 1; i > 0; i--) {
                    var lyr = layers[i]
                    if (lyr.layerName) {
                        listModelLegendLayers.append({"name": lyr.layerName, "isVisible": lyr.visible, "layerIndex": i})
                    }
                }
                legend.legendListModel = listModelLegendLayers
            }
        }

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        FeatureLayer {
            id: parksFeatLayer
            featureTable: parksFeatTable
            property string layerName: "Parks"
        }

        GeodatabaseFeatureServiceTable {
            id: parksFeatTable
            url: app.parksFeatureService
        }

        FeatureLayer {
            id: postFeatLayer
            featureTable: postFeatTable
            visible: false
            property string layerName: "Post Offices"
        }

        GeodatabaseFeatureServiceTable {
            id: postFeatTable
            url: app.postOfficeFeatureService
        }

        FeatureLayer {
            id: schoolsFeatLayer
            featureTable: schoolsFeatTable
            property string layerName: "Schools"
        }

        GeodatabaseFeatureServiceTable {
            id: schoolsFeatTable
            url: app.schoolsFeatureService
        }
    }

    Legend {
       id: legend
       width: parent.width
       height: parent.height

       legendHeaderColor: app.themeColor
       fontFamilyName: app.fontSourceSansProReg.name
       legendListModel: listModelLegendLayers

       onToggled: {
           for (var i = 0; i < listModelLegendLayers.count; i++) {
               if (layerIndex === listModelLegendLayers.get(i).layerIndex) {
                   var layer = map.layerByIndex(layerIndex)
                   layer.visible = !layer.visible
               }
           }
       }
    }
}

