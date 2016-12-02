//------------------------------------------------------------------------------
// ProjectPointOnline.qml
// Created 2015-03-13 13:55:23
//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 800
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor
    property real lat
    property real lon

    Envelope {
        id: envelopeInitalExtent
        xMin: -15000000
        yMin: 2000000
        xMax: -7000000
        yMax: 8000000
        spatialReference: map.spatialReference
    }

    Map {
        id: map
        anchors.fill: parent
        focus: true
        extent: envelopeInitalExtent
        zoomSnapEnabled: true

        ArcGISTiledMapServiceLayer {
            id: basemap
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer"
        }

        SimpleMarkerSymbol {
            id: projectPoint
            color: "red"
            style: Enums.SimpleMarkerSymbolStyleCross
            size: 10
        }

        GraphicsLayer {
            id: graphicsLayerProjectPoint
        }

        Graphic {
            id: projectPointGraphic
            symbol: projectPoint
        }

        ZoomButtons {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 10
            }

            map: map
            homeExtent: envelopeInitalExtent
            fader.minumumOpacity: ornamentsMinimumOpacity
        }
    }

    Rectangle {
        id: controlsBackground
        anchors {
            fill: menuColumn
            margins: -10 * scaleFactor
        }
        color: "lightgrey"
        radius: 5 * scaleFactor
        border.color: "black"
        opacity: 0.77

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse.accepted = true)
        }
    }

    Column {
        id: menuColumn
        anchors {
            left: app.left
            leftMargin: 20 * scaleFactor
            top: app.top
            topMargin: 20 * scaleFactor
        }
        spacing: 10 * scaleFactor

        Row {
            spacing: 10 * scaleFactor

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Latitude:"
                font.bold: true
                width: 80 * scaleFactor
            }

            TextField {
                id: latitude
                anchors.verticalCenter: parent.verticalCenter
                text: "38.8977"
                width: 50 * scaleFactor
                style: TextFieldStyle {
                    textColor: "black"
                }
            }
        }

        Row {
            spacing: 10 * scaleFactor

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Longitude:"
                font.bold: true
                width: 80 * scaleFactor
            }

            TextField {
                id: longitude
                anchors.verticalCenter: parent.verticalCenter
                text: "-77.0366"
                width: 50 * scaleFactor
                style: TextFieldStyle {
                    textColor: "black"
                }
            }
        }

        Button {
            id: okButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Project"
            style: ButtonStyle {
                label: Text {
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 14 * scaleFactor
                    color: enabled ? "black" : "grey"
                    text: control.text
                }
                background: Rectangle {
                    implicitWidth: 100 * scaleFactor
                    implicitHeight: 25 * scaleFactor
                    border.width: control.activeFocus ? 2 : 1
                    border.color: "#888"
                    radius: 4 * scaleFactor
                    gradient: Gradient {
                        GradientStop { position: 0 ; color: control.pressed ? "#ccc" : "#eee" }
                        GradientStop { position: 1 ; color: control.pressed ? "#aaa" : "#ccc" }
                    }
                }
            }

            onClicked: {
                if(longitude.text.trim() !== "" && latitude.text.trim() !== "") {
                    if (latitude.text.trim().match(/[a-z]/i) || longitude.text.trim().match(/[a-z]/i))
                        statusText.visible = true;
                    else {
                        lat = latitude.text.trim();
                        lon = longitude.text.trim();
                        if (-180.0 < lon  && lon < 180.0 && -90.0 < lat && lat < 90.0) {
                            statusText.visible = false;
                            var geometry = ArcGISRuntime.geometryEngine.project(lon,lat,map.spatialReference);
                            projectPointGraphic.geometry = geometry;
                            graphicsLayerProjectPoint.addGraphic(projectPointGraphic);
                            map.zoomToScale(map.scale/2);
                            map.zoomTo(projectPointGraphic.geometry);
                        } else
                            statusText.visible = true;
                    }
                } else
                    statusText.visible = true;
            }
        }
    }

    Rectangle {
        anchors {
            fill: msgRow
        }
        color: "red"
        border.color: "black"
        opacity: 0.77
    }

    Row {
        id: msgRow
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Text {
            id: statusText
            anchors.bottom: parent.bottom
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: 14 * scaleFactor
            color: "white"
            visible: false
            text: "Latitude ranges between -90.0 to 90.0 and longitude -180 to 180"
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5
            color: "black"
        }
    }
}

