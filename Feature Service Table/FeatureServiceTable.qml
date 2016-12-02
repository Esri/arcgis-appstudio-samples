//------------------------------------------------------------------------------
// FeatureServiceTable.qml
// Created 2015-03-13 13:32:37
//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
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


    property int hitFeatureId
    property variant attrValue
    property real scaleFactor: AppFramework.displayScaleFactor

    SimpleRenderer {
        id: customRender
        symbol: SimpleMarkerSymbol {
            style: Enums.SimpleMarkerSymbolStyleCircle
            color: "red"
            size: 9
        }
    }

    Envelope {
        id: initialExtent
        xMin: -13048433
        yMin: 4033843
        xMax: -13043833
        yMax: 4037293
        spatialReference: SpatialReference {
            wkid: 102100
        }
    }

    GeodatabaseFeatureServiceTable {
        id: featureServiceTable
        url: "http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Demographics/ESRI_Census_USA/MapServer/0"
    }

    Map {
        anchors.fill: parent
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }


        ArcGISDynamicMapServiceLayer {
            url: "http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Demographics/ESRI_Census_USA/MapServer"
        }

        FeatureLayer {
            id:featureLayer
            featureTable: featureServiceTable
            renderer: customRender
        }

        onStatusChanged: {
            if (status === Enums.MapStatusReady)
                extent = initialExtent;
        }

        onMousePressed: {
            var tolerance = Qt.platform.os === "ios" || Qt.platform.os === "android" ? 4 : 1;
            var features = featureLayer.findFeatures(mouse.x, mouse.y, tolerance * scaleFactor, 1)
            for ( var i = 0; i < features.length; i++ ) {
                hitFeatureId = features[i];
                getFields(featureLayer);
                identifyDialog.title = "Object ID: " + hitFeatureId;
                identifyDialog.visible = true;
                if(Qt.platform.os !== "ios" && Qt.platform.os != "android") {
                    identifyDialog.width = 200 * scaleFactor;
                    identifyDialog.height = 235 * scaleFactor;
                }
            }
        }
    }

    // Dialog for results
    Dialog {
        id: identifyDialog
        title: "Features"
        modality: Qt.ApplicationModal
        visible: false

        contentItem: Rectangle {
            id: dialogRectangle
            color: "lightgrey"
            width : 200 * scaleFactor
            height: 235 *scaleFactor

            Column {
                id: column
                anchors {
                    fill: parent
                    margins: 10 * scaleFactor
                }

                spacing: 5 * scaleFactor
                clip: true

                Repeater {
                    model: fieldsModel
                    clip: true
                    Row {
                        id: row
                        spacing: (80 * scaleFactor)  - nameLabel.width
                        Label {
                            id: nameLabel
                            text: name + ": "
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 10 * scaleFactor
                        }
                        Label {
                            text: value
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 10 * scaleFactor
                        }
                    }
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

    Rectangle {
        id: backgroundRectangle
        anchors {
            fill: backgroundColumn
            margins: -10 * scaleFactor
        }
        color: "lightgrey"
        radius: 5
        border.color: "black"
        opacity: 0.77
    }

    Column {
        id: backgroundColumn
        anchors {
            top: parent.top
            left: parent.left
            margins: 20 * scaleFactor
        }
        width: 150 * scaleFactor
        spacing: 7 * scaleFactor

        Text {
            id: descriptionText
            text: qsTr( "Red points are stored in the feature service table. Blue points are drawn dynamically.")
            font.pixelSize: 14 * scaleFactor
            width: 150 * scaleFactor
            wrapMode: Text.WordWrap
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }

    function getFields( featureLayer ) {
        fieldsModel.clear();
        var fieldsCount = featureLayer.featureTable.fields.length;
        for ( var f = 0; f < fieldsCount; f++ ) {
            var fieldName = featureLayer.featureTable.fields[f].name;
            attrValue = featureLayer.featureTable.feature(hitFeatureId).attributeValue(fieldName);
            if ( fieldName !== "Shape" ) {
                var attrString = attrValue.toString();
                fieldsModel.append({"name": fieldName, "value": attrString});
            }
        }
    }
}

