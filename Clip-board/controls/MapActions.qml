import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtLocation 5.3
import QtPositioning 5.3
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0


Page {
    id: mapactions

    anchors.fill: parent
    header: ToolBar{
        id:header
        width: parent.width
        height: 50 * scaleFactor
        Material.background: "#8f499c"
        HeaderBar{}
    }

    PositionSource {
        id: positionSource

        active: true
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 5 * AppFramework.displayScaleFactor
        }

        Map {
            id: map

            Layout.fillWidth: true
            Layout.fillHeight: true

            plugin: Plugin {
                name: "AppStudio"
            }

            center {
                latitude: -38
                longitude: 144.5
            }

            activeMapType: supportedMapTypes[0]
        }


    }

    RoundButton{
        width: radius*2
        height:width
        radius: 32*app.scaleFactor
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin:16*app.scaleFactor
            bottomMargin: 35*app.scaleFactor
        }
        Material.elevation: 6
        Material.background: "#8f499c"
        contentItem: Image {
            width: parent.radius
            height: width
            mipmap: true
            rotation: messageDialog.visible ? 45:0
            source: "../assets/add.png"
            Behavior on rotation{
                NumberAnimation{duration: 200}
            }
        }

        onClicked:{
            messageDialog.open();
        }
    }

    Dialog {
        id: messageDialog
        Material.accent: app.primaryColor
        x: (parent.width - width)/2
        y: (parent.height - height)/2
        title: qsTr("Clipboard Operations")
        width: Math.min(0.8 * parent.width, 400*AppFramework.displayScaleFactor)
        closePolicy: Popup.NoAutoClose
        height: parent.height/1.5
        modal: true
        ColumnLayout {

            Button {
                text: "Copy Map as Image"

                onClicked: {
                    AppFramework.clipboard.copy(map);
                }
            }

            Button {
                text: "Copy center as geometry"

                onClicked: {
                    var geometry = {
                        x: map.center.longitude,
                        y: map.center.latitude,
                        spatialReference: {
                            wkid: 4326
                        }
                    }

                    AppFramework.clipboard.copy(geometry);
                }
            }

            Button {
                text: "Copy position as feature"
                enabled: positionSource.active && positionSource.valid

                onClicked: {
                    var position = positionSource.position;

                    var feature = {
                        geometry: {
                            x: position.coordinate.longitude,
                            y: position.coordinate.latitude,
                            z: position.coordinate.altitude,
                            spatialReference: {
                                wkid: 4326
                            }
                        },
                        attributes: {
                            horizontalAccuracy: position.horizontalAccuracyValid
                                                ? position.horizontalAccuracy
                                                : undefined,

                            verticalAccuracy: position.verRticalAccuracyValid
                                                  ? position.verticalAccuracy
                                                  : undefined,

                            speed: position.speedValid
                                                  ? position.speed
                                                  : undefined,

                            verticalSpeed: position.verticalSpeedValid
                                                  ? position.verticalSpeed
                                                  : undefined,

                            direction: position.directionValid
                                                  ? position.direction
                                                  : undefined,

                            magneticVariation: position.magneticVariationValid
                                                  ? position.magneticVariation
                                                  : undefined
                        }
                    }

                    AppFramework.clipboard.copy(feature);
                }
            }
            Text{
                text: "Click on above operation and"
                wrapMode: Text.WrapAnywhere
            }
            Text{
                text: "paste the result to Paste or Image tab"
                wrapMode: Text.WrapAnywhere
            }
                 }
        standardButtons: Dialog.Ok
    }

}





