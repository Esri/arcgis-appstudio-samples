//------------------------------------------------------------------------------
// IdentifyOnline.qml
// Created 2015-03-20 15:41:39
//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
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
    property string serviceLayerUrl: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/USA/MapServer"

    Map {
        id: mainMap
        anchors.fill: parent
        extent: usExtent
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer"
        }

        ArcGISDynamicMapServiceLayer {
            url: serviceLayerUrl
        }

        // Starting map extent

        Envelope {
            id: usExtent
            xMax: -15000000
            yMax: 2000000
            xMin: -7000000
            yMin: 8000000
            spatialReference: mainMap.spatialReference
        }

        SimpleMarkerSymbol {
            id: simpleMarkerSymbolIdentifyLocation
            color: "blue"
            style: Enums.SimpleMarkerSymbolStyleX
            size: 16
        }

        Graphic {
            id: identifyGraphic
            symbol: simpleMarkerSymbolIdentifyLocation
        }

        GraphicsLayer {
            id: graphicsLayer
        }

        // Initiation of the identify task

        onMouseClicked: {
            resultsRow.visible = false;
            identifyDialog.visible = false;
            progressBar.visible = true;

            graphicsLayer.removeAllGraphics();
            var graphic1 = identifyGraphic.clone();
            graphic1.geometry = mouse.mapPoint;
            graphicsLayer.addGraphic(graphic1);

            identifyParameters.geometry = mouse.mapPoint;
            identifyParameters.mapExtent = mainMap.extent;
            identifyParameters.mapHeight = mainMap.height;
            identifyParameters.mapWidth = mainMap.width;
            identifyParameters.layerMode = Enums.LayerModeVisibleLayers;
            identifyParameters.DPI =  Screen.pixelDensity * 25.4;

            identifyTask.execute(identifyParameters);
        }

        // Dialog for instructions and error messages
        Rectangle {
            id: feedbackRectangle
            anchors {
                fill: messageColumn
                margins: -10 * scaleFactor
            }
            color: "lightgrey"
            radius: 5 * scaleFactor
            border.color: "black"
            opacity: 0.77
        }

        Column {
            id: messageColumn
            anchors {
                top: parent.top
                left: parent.left
                margins: 20 * scaleFactor
            }
            width: 210 * scaleFactor
            spacing: 10 * scaleFactor

            Row {
                id: intructionsRow
                spacing: 10 * scaleFactor
                visible: true
                width: parent.width

                Text {
                    text: qsTr("Click or tap on features from the map service to identify them.")
                    font.pixelSize: 14 * scaleFactor
                    width: parent.width
                    wrapMode: Text.WordWrap
                    visible: true
                }
            }

            Row {
                id: resultsRow
                spacing: 10 * scaleFactor
                visible: false
                width: parent.width

                Text {
                    id: resultText
                    text: qsTr("")
                    font.pixelSize: 12 * scaleFactor
                    width: parent.width
                    wrapMode: Text.WordWrap
                    visible: true
                }
            }
        }
    }

    // Progress bar
    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: mainMap.bottom
            bottomMargin: 5 * scaleFactor
        }

        ProgressBar {
            id: progressBar
            indeterminate: true
            visible: false
        }
    }

    Rectangle {
        id: rectangleBorder
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }

    // Dialog for results
    Dialog {
        id: identifyDialog
        title: "Features"
        modality: Qt.NonModal
        visible: false

        contentItem: Rectangle {
            id: dialogRectangle
            color: "lightgrey"
            width : 365 * scaleFactor
            height: 400 *scaleFactor

            ListView {
                model: fieldsModel
                //flickableData: elem
                anchors.fill: parent
                contentWidth: parent.width
                contentHeight: parent.height
                clip: true
                delegate: Text {
                    text: name + ": " + value
                }
            }
            Button {
                anchors {
                    margins: 10 * scaleFactor
                    bottom: parent.bottom
                    right: parent.right
                }
                text: "Ok"
                style: ButtonStyle {
                    label: Text {
                        text: control.text
                        color:"black"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                onClicked: identifyDialog.close();
            }
        }

    }

    ListModel {
        id:fieldsModel
    }

    // Identify task components
    IdentifyParameters {
        id: identifyParameters
    }

    IdentifyTask {
        id: identifyTask
        url: serviceLayerUrl

        onIdentifyTaskStatusChanged: {
            if (identifyTaskStatus === Enums.IdentifyTaskStatusCompleted) {
                resultText.text = "";
                fieldsModel.clear();

                for (var index in identifyResult) {
                    var result = identifyResult[index];
                    fieldsModel.append({"name": result.layerName, "value": result.value.toString()});
                }
                if (fieldsModel.count === 0)
                    fieldsModel.append({"name": "Results", "value": "none"});
                identifyDialog.visible = true;
                if(Qt.platform.os !== "ios" && Qt.platform.os != "android") {
                    identifyDialog.width = 365 * scaleFactor
                    identifyDialog.height = 400 * scaleFactor
                }
                progressBar.visible = false;
            } else if (identifyTaskStatus === Enums.IdentifyTaskStatusErrored) {
                resultText.text = identifyError.message;
                resultsRow.visible = true;
                identifyDialog.visible = false;
                progressBar.visible = false;
            }
        }
    }
}

