//------------------------------------------------------------------------------
// TimeZones.qml
// Created 2014-11-20 14:05:45
//------------------------------------------------------------------------------

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Controls 1.0

Rectangle {

    property var selectedFeature
    property var selectedId
    property real timeShift
    property bool internationalTime: localTime.checked ? true : false
    property double scaleFactor: AppFramework.displayScaleFactor

    clip: true

    GeodatabaseFeatureServiceTable {
        id: featureServiceTable
        url: "http://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/World_Time_Zones/FeatureServer/0"
    }

    QueryTask {
        id: queryTask
        url: "http://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/World_Time_Zones/FeatureServer/0"

        onQueryTaskStatusChanged:{

            if (queryTaskStatus === Enums.QueryTaskStatusCompleted) {
                timeZonesLayer.clearSelection();
                for (var i = 0; i < queryResult.graphics.length; i++) {
                    selectedFeature = queryResult.graphics[i].attributes["ZONE"]; // Get the time zone value
                    timeShift = selectedFeature; //Use the time zone value to shift the clock
                    selectedId = queryResult.graphics[i].attributes["FID"]; //Get the time zone ID
                    timeZonesLayer.selectFeature(selectedId); //Select the current time zone by ID
                }
            } else if (queryTaskStatus === Enums.QueryTaskStatusErrored) {
                console.log("error" + queryError.details, queryError.message);
            }
        }
    }

    Query {
        id: queryParams
        spatialRelationship: Enums.SpatialRelationshipIntersects
        outFields: ["ZONE", "FID"]
    }

    Map {
        id: mainMap
        anchors.fill: parent
        wrapAroundEnabled: true
        extent: mapExtent

        ZoomButtons {

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 10
            }
        }

        ArcGISTiledMapServiceLayer {
            id:imageryBasemap
            url: "http://server.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer"
        }

        FeatureLayer {
            id: timeZonesLayer
            featureTable: featureServiceTable
            opacity: localTime.checked ? 1 : 0 //Hide the time zones layer when using Local Time
            //visible: localTime.checked ? true : false
        }

        onMouseDoubleClicked: {
            mouse.accepted = localTime.checked //Query on double-click when using International Time
            if (localTime.checked) {
                queryParams.geometry = mouse.mapPoint;//Use the mouse coordinates for the spatial query
                queryTask.execute(queryParams);
            }
        }
    }

    Item {
        id : clock

        property int hours
        property int minutes
        property int seconds
        property bool night: false

        function timeChanged() {
            var date = new Date;
            hours = internationalTime ? date.getUTCHours() + Math.floor(timeShift) : date.getHours()
            night = ( hours < 7 || hours > 19 )
            minutes = internationalTime ? date.getUTCMinutes() + ((timeShift % 1) * 60) : date.getMinutes()
            seconds = date.getUTCSeconds();
        }

        Timer {
            interval: 100
            running: true
            repeat: true
            onTriggered: clock.timeChanged()
        }
    }

    Rectangle {
        anchors {
            margins: -10 * scaleFactor
            fill: controls
        }
        radius: 5
        border.color: "black"
        color: "lightgrey"
        opacity : 0.75
    }

    ColumnLayout {
        id: controls
        spacing: 5 * scaleFactor
        anchors {
            top: parent.top
            left: parent.left
            margins: 20 * scaleFactor
        }

        Item {
            id:clockGraphic
            width: 200
            height: 240
            Layout.alignment: Qt.AlignHCenter

            Image {
                id: background
                source: "clock.png"
                visible: clock.night === false
            }

            Image {
                source: "clock-night.png"
                visible: clock.night === true
            }

            Image {
                x: 92.5
                y: 27
                source: "hour.png"
                transform: Rotation {
                    origin.x: 7.5
                    origin.y: 73
                    angle: (clock.hours * 30) + (clock.minutes * 0.5)
                    Behavior on angle {
                        SpringAnimation {
                            spring: 2
                            damping: 0.2
                            modulus: 360
                        }
                    }
                }
            }

            Image {
                x: 93.5
                y: 17
                source: "minute.png"
                transform: Rotation {
                    origin.x: 6.5
                    origin.y: 83
                    angle: clock.minutes * 6
                    Behavior on angle {
                        SpringAnimation {
                            spring: 2
                            damping: 0.2
                            modulus: 360
                        }
                    }
                }
            }

            Image {
                x: 97.5
                y: 20
                source: "second.png"
                transform: Rotation {
                    origin.x: 2.5
                    origin.y: 80
                    angle: clock.seconds * 6
                    Behavior on angle {
                        SpringAnimation {
                            spring: 2
                            damping: 0.2
                            modulus: 360
                        }
                    }
                }
            }

            Image {
                source: "center.png"
                anchors.centerIn: background
            }
        }

        Text {
            text: localTime.checked ? "International" : "Local Time"
            Layout.alignment: Qt.AlignHCenter
            font {
                pointSize: 10 * scaleFactor
                bold: true
            }
        }

        Switch {
            id: localTime
            checked: false
            Layout.alignment: Qt.AlignHCenter

            onCheckedChanged: {
                if (timeZonesLayer.selectedFeatures.length === 0){
                    timeZonesLayer.selectFeature(16); //Select default Time Zone
                }
            }
        }
    }

    Envelope {
        id: mapExtent
        xMin: -9908547
        yMin: -5120850
        xMax: 10128960
        yMax: 14916657
    }

    Rectangle {
        id: borderRectangle
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }
}










