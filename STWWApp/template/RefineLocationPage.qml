import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtPositioning 5.3
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1

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

    property alias theMap : page3_map
    property string gpsLocationString : ""

    Point {
        id: myPosition
        property bool valid : false
        spatialReference: SpatialReference {
            wkid: 4326
        }
    }

    PositionSource {
       id: gpsPositionSource
       active: true
    }


    Component.onCompleted: {

    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: createPage_headerBar
            Layout.alignment: Qt.AlignTop
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
                    console.log("Back button from create page clicked");
                    skipPressed = false;
                    previous("");
                }
            }

            Text {
                id: createPage_titleText
                text: "Add Location"
                textFormat: Text.StyledText
                anchors.centerIn: parent
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: "transparent"
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - createPage_headerBar.height

            Text {
                id: page3_description
                text: "Move the map to choose location"
                textFormat: Text.StyledText
                horizontalAlignment: Text.AlignHCenter
                anchors {
                    margins: 10 * app.scaleFactor
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                font {
                    pointSize: app.baseFontSize * 0.8
                }
                color: app.textColor
                wrapMode: Text.Wrap
                linkColor: "#e5e6e7"
                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
            }


            Rectangle {
                visible: !AppFramework.network.isOnline
                width: parent.width
                height: Math.max(320*app.scaleFactor, parent.height/3)
                anchors {
                    top: page3_description.bottom
                    margins: 10 * app.scaleFactor
                }

                color: app.pageBackgroundColor

                Text {
                    text: "Map not available in offline mode."
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    color: app.textColor                   
                    width: 300*app.scaleFactor
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    font {
                        pointSize: app.baseFontSize * 0.7
                    }
                }
            }


            Map {
                id: page3_map
                width: parent.width
                height: Math.max(280*app.scaleFactor, parent.height/3)
                anchors {
                    top: page3_description.bottom
                    margins: 10 * app.scaleFactor
                }

                visible: AppFramework.network.isOnline

                wrapAroundEnabled: true
                rotationByPinchingEnabled: false
                magnifierOnPressAndHoldEnabled: false
                mapPanningByMagnifierEnabled: false

                ArcGISTiledMapServiceLayer {
                    url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
                }

                Image {
                    source: "images/esri_pin_red.png"
                    width: 20*app.scaleFactor
                    height: 40*app.scaleFactor
                    //anchors.centerIn: parent
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.verticalCenter
                    }

                }

                positionDisplay {
                    positionSource: PositionSource {

                    }
                }

                ZoomButtons {
                    id: zoomButtons
                    anchors {
                        right: parent.right
                        //verticalCenter: parent.verticalCenter
                        top: parent.top
                        margins: 5
                    }
                    map: page3_map
                    //homeExtent:
                    fader.minumumOpacity: 0.5
                }

                onExtentChanged: {
                    page3_latlong.text = page3_map.extent.center.toDecimalDegrees(4);
                    var pt_wgs = page3_map.extent.center.project(theNewPoint.spatialReference);
                    theNewPoint.x = pt_wgs.x;
                    theNewPoint.y = pt_wgs.y;
                    console.log("Report location after extent changed: ", JSON.stringify(theNewPoint.json));
                }

                onStatusChanged: {
                    if(status == Enums.MapStatusReady) {
                        if(!app.selectedImageHasGeolocation) {
                            theNewPoint = ArcGISRuntime.createObject("Point");
                            theNewPoint.spatialReference = ArcGISRuntime.createObject("SpatialReference", {"json":{"wkid":4326}});
                        }
                        console.log("RefineLocation: Map Ready!");
                        console.log("RefineLocation: Photo Exif Point: ", JSON.stringify(theNewPoint.json));

                        if(theNewPoint.x && theNewPoint.y){
                            //photo exif
                            page3_latlong.text = theNewPoint.toDecimalDegrees(4) + " (Photo)";
                            var pt = theNewPoint.project(page3_map.spatialReference);
                            page3_map.zoomTo(pt);
                        } else {
                            //current device position
                            page3_map.positionDisplay.positionSource.active = true;
                            page3_map.positionDisplay.mode = Enums.AutoPanModeDefault;
                        }
                    }
                }
            }

            Text {
                id: page3_latlong
                text:"No Location available."
                textFormat: Text.StyledText
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                wrapMode: Text.Wrap
                anchors {
                    margins: 10
                    left: parent.left
                    right: parent.right
                    top: page3_map.bottom
                }
                font {
                    pointSize: app.baseFontSize * 0.7
                }
                color: app.textColor
            }

            CustomButton{
                id:page3_button1
                buttonText: "Next: ADD DETAILS"
                buttonColor: app.buttonColor
                buttonWidth: 300 * app.scaleFactor
                buttonHeight: buttonWidth/5
                anchors {
                    left: parent.left
                    right: parent.right
                    top: page3_latlong.bottom
                    topMargin: 20*app.scaleFactor
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        next("");

                    }
                }
            }
        }
    }
}
