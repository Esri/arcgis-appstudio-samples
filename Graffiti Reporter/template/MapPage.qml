import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Rectangle {
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor
    signal next(string message)
    signal previous(string message)


    property int hitFeatureId
    property variant attrValue

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: mapPage_headerBar
            Layout.alignment: Qt.AlignTop
            //Layout.fillHeight: true
            color: app.headerBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            ImageButton {
                source: "images/back-left.png"
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    console.log("Back button from map page clicked")
                    previous("")
                }
            }

            Text {
                id: mapPage_titleText
                text: "Mapped Reports"
                textFormat: Text.StyledText
                anchors.centerIn: parent
                //anchors.left: parent.left
                //anchors.verticalCenter: parent.verticalCenter
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
                //anchors.leftMargin: 10
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            //color: app.pageBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - mapPage_headerBar.height
            Map {
                id: map
                anchors.fill: parent


                wrapAroundEnabled: true
                rotationByPinchingEnabled: true
                magnifierOnPressAndHoldEnabled: true
                mapPanningByMagnifierEnabled: true

                positionDisplay {
                    positionSource: PositionSource {
                        id: mapPage_positionSource

                        onPositionChanged: {
                            console.log("MapPage:: Lat: ", position.coordinate.latitude, "Long: ", position.coordinate.longitude)
                        }

                    }
                    mode: PositionDisplay.Default
                }

                ZoomButtons {
                    id: zoomButtons
                    anchors {
                        right: parent.right
                        //verticalCenter: parent.verticalCenter
                        top: parent.top
                        margins: 5
                    }
                    map: map
                    //homeExtent:
                    fader.minumumOpacity: 0.5
                }

                ArcGISTiledMapServiceLayer {
                    url: app.baseMapURL // "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
                }

                onStatusChanged: {
                    if(status == Enums.MapStatusReady) {
                        console.log("Map Ready!!");
                        map.addLayer(app.theFeatureLayer);

                        // var raw_extent = app.theFeatureLayer.fullExtent ? app.theFeatureLayer.fullExtent : app.theFeatureLayer.extent;
                        // var proj_extent = raw_extent.project(map.spatialReference)
                        // map.zoomTo(proj_extent);
                    }
                }

                onMousePressed: {
                    var features = app.theFeatureLayer.findFeatures(mouse.x, mouse.y, 0, 1)
                    for ( var i = 0; i < features.length; i++ ) {
                        hitFeatureId = features[i]
                        getFields(app.theFeatureLayer);
                    }
                }

                ListModel {
                    id: fieldsModel
                }

                function getFields( featureLayer ) {
                    fieldsModel.clear();
                    var fieldsCount = featureLayer.featureTable.fields.length;
                    for ( var f = 0; f < fieldsCount; f++ ) {
                        var fieldName = featureLayer.featureTable.fields[f].name;
                        attrValue = featureLayer.featureTable.feature(hitFeatureId).attributeValue(fieldName);
                        if ( fieldName !== "Shape" ) {
                            var attrString = attrValue.toString();
                            console.log("name: ", fieldName, " | value: ", attrString);
                            fieldsModel.append({"name": fieldName, "value": attrString});
                        }
                    }
                }

            }
        }
    }


}
