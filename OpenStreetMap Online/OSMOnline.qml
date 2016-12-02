//------------------------------------------------------------------------------
// OSMOnline.qml
// Created 2015-03-20 16:10:56
//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.2
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
        property string attribution: "\u00A9 OpenStreetMap contributors";
        property double minZoomLevel: 0;
        property double maxZoomLevel: 18;
        property OpenStreetMapLayer openStreetMapLayer;


        Map {
            id: map
            anchors.fill: parent
        }

        Rectangle {
            anchors {
                fill: controlsColumn
                margins: -10
            }
            color: "lightgrey"
            radius: 5
            border.color: "black"
            opacity: 0.77
        }

        Column {
            id: controlsColumn
            anchors {
                left: parent.left
                top: parent.top
                margins: 20 * scaleFactor
            }
            spacing: 10 * scaleFactor

            Grid {
                columns: 2
                spacing: 10 * scaleFactor

                Button {
                    id: addTileServerButton
                    width: clearTileServersButton.width
                    enabled: openStreetMapLayer.status !== Enums.LayerStatusInitialized
                    text: "Add Tile Server"
                    style: ButtonStyle {
                        label: Text {
                            renderType: Text.NativeRendering
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 14 * scaleFactor
                            color: enabled ? "black" : "gray"
                            text: addTileServerButton.text
                        }
                    }

                    onClicked: {
                        addTileServerColumn.visible = true;
                    }
                }

                Button {
                    id: loadLayerButton
                    enabled: openStreetMapLayer.status !== Enums.LayerStatusInitialized &&
                             openStreetMapLayer.tileServerUrls.length !== 0
                    text: "Add Layer"
                    style: ButtonStyle {
                        label: Text {
                            renderType: Text.NativeRendering
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 14 * scaleFactor
                            color: enabled ? "black" : "gray"
                            text: loadLayerButton.text
                        }
                    }

                    onClicked: {
                        map.addLayer(openStreetMapLayer);
                    }
                }

                Button {
                    id: clearTileServersButton
                    text: "Clear Tile Servers"
                    style: ButtonStyle {
                        label: Text {
                            renderType: Text.NativeRendering
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 14 * scaleFactor
                            color: enabled ? "black" : "gray"
                            text: clearTileServersButton.text
                        }
                    }

                    onClicked: {
                        map.removeAll();
                        openStreetMapLayer = ArcGISRuntime.createObject("OpenStreetMapLayer");
                        openStreetMapLayer.tileServerUrls = [ ];
                        updateTileServerText();

                        if (addTileServerTextField.text === "")
                            addTileServerTextField.text = "http://a.tile.openstreetmap.org";
                    }
                }

                Button {
                    id: showDetailsButton
                    text: "Details"
                    width: loadLayerButton.width
                    style: ButtonStyle {
                        label: Text {
                            renderType: Text.NativeRendering
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 14 * scaleFactor
                            color: "black"
                            text: showDetailsButton.text
                        }
                    }

                    onClicked: {
                        detailsBox.visible    = !detailsBox.visible;
                        detailsColumn.visible = !detailsColumn.visible;
                    }
                }
            }
        }

        Rectangle {
            id: addTileServerBox
            color: "lightgrey"
            radius: 5
            border.color: "black"
            opacity: 0.77
            visible: addTileServerColumn.visible
            anchors {
                fill: addTileServerColumn
                margins: -10 * scaleFactor
            }
        }

        ColumnLayout {
            id: addTileServerColumn
            anchors {
                left: parent.left
                bottom: parent.bottom
                right: parent.right
                margins: 20 * scaleFactor
            }
            spacing: 10
            visible: false

            Text {
                text: "Add Tile Server:"
            }

            TextField {
                id: addTileServerTextField
                Layout.fillWidth: true
                text: "http://otile1.mqcdn.com/tiles/1.0.0/osm"
                style: TextFieldStyle {
                    textColor: "black"
                }
            }

            Row {
                spacing: 10

                Button {
                    id: okButton
                    text: "Ok"
                    style: ButtonStyle {
                        label: Text {
                            text: control.text
                            color:"black"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    onClicked: {
                      openStreetMapLayer.tileServerUrls.push(addTileServerTextField.text);
                      addTileServerTextField.text = "";
                      updateTileServerText();
                      addTileServerColumn.visible = false
                    }
                }

                Button {
                    text: "Cancel"
                    style: okButton.style
                    onClicked: addTileServerColumn.visible = false
                }
            }
        }

        Rectangle {
            id: detailsBox
            anchors {
                fill: detailsColumn
                margins: -10
            }
            color: "lightgrey"
            radius: 5
            border.color: "black"
            opacity: 0.77
            visible: false
        }

        Column {
            id: detailsColumn
            anchors {
                bottom: addTileServerBox.visible ? addTileServerBox.top : parent.bottom
                left: parent.left
                margins: 20 * scaleFactor
            }
            visible: false
            spacing: 5 * scaleFactor

            Grid {
                columns: 2
                spacing: 5 * scaleFactor

                Text {
                    text: "Tile Servers"
                    font.pixelSize: 12 * scaleFactor
                }

                Text {
                    id: tileServerText
                    font.pixelSize: 12 * scaleFactor
                }

                Text {
                    text: "Attribution"
                    font.pixelSize: 12 * scaleFactor
                }

                Text {
                    text: openStreetMapLayer.attributionText
                    font.pixelSize: 12 * scaleFactor
                }

                Text {
                    text: "minZoomLevel"
                    font.pixelSize: 12 * scaleFactor
                }

                Text {
                    text: openStreetMapLayer.minZoomLevel
                    font.pixelSize: 12 * scaleFactor
                }

                Text {
                    text: "maxZoomLevel"
                    font.pixelSize: 12 * scaleFactor
                }

                Text {
                    text: openStreetMapLayer.maxZoomLevel
                    font.pixelSize: 12 * scaleFactor
                }
            }
        }

        function updateTileServerText() {
            tileServerText.text = "";

            if (openStreetMapLayer.tileServerUrls.length === 0) {
                tileServerText.text = "N/A";
                return;
            }

            for (var i = 0; i < openStreetMapLayer.tileServerUrls.length; ++i) {
                tileServerText.text += openStreetMapLayer.tileServerUrls[i];

                if (i !== openStreetMapLayer.tileServerUrls.length - 1)
                    tileServerText.text += "\n";
            }
        }

        Component.onCompleted: {
            openStreetMapLayer = ArcGISRuntime.createObject("OpenStreetMapLayer");
            map.addLayer(openStreetMapLayer);
            updateTileServerText();
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border {
                width: 0.5 * scaleFactor
                color: "black"
            }
        }
}

