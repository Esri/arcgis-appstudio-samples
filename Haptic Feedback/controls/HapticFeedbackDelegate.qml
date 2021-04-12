import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

import QtQuick.Controls.Material.impl 2.12
import QtSensors 5.0
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Notifications 1.0

Item {
    id: hapticFeedbackDelegate

    height: 132 * scaleFactor
    width: parent.width

    property var imgSource
    property string title
    property string desc
    property color iconColor
    property var type: "image"
    property int hapticType: 0

    Pane {
        anchors.fill: parent
        anchors.margins: 4 * scaleFactor

        background: Rectangle {
            color: "#FEFFFE"
            radius: 10 * scaleFactor

            layer.enabled: true
            layer.effect: ElevationEffect {
                elevation: 1
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if(type === "image")
                    hapticFeedbackDelegateClicked();
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 24 * scaleFactor

                Image {
                    id: thumbnail

                    visible: type === "image"
                    width: parent.width
                    height: width
                    anchors.centerIn: parent
                    source: visible ? imgSource : ""
                    fillMode: Image.PreserveAspectCrop
                    layer.enabled: true
                    smooth:true
                    mipmap: true
                }

                ColorOverlay {
                    visible: type === "image"
                    anchors.fill: thumbnail
                    source: thumbnail
                    color: iconColor
                }

                CheckBox {
                    visible: type === "check"
                    width: parent.width
                    height: width
                    anchors.centerIn: parent
                    onCheckedChanged: {
                        if(checked){
                            hapticFeedbackDelegateClicked();
                        }
                    }
                }

                Switch {
                    visible: type === "select"
                    width: parent.width/2
                    height: width
                    anchors.centerIn: parent
                    onCheckedChanged: {
                        if(checked){
                            hapticFeedbackDelegateClicked();
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 8 * scaleFactor
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20 * scaleFactor

                        text: title

                        font.pixelSize: 14 * scaleFactor
                        font.weight: Font.Bold
                        color: "#DE000000"
                        wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                        elide: Label.ElideRight

                        horizontalAlignment: Label.AlignLeft
                        verticalAlignment: Label.AlignVCenter
                    }

                    Item {
                        Layout.preferredHeight: 8 * scaleFactor
                        Layout.fillWidth: true
                    }

                    Label {
                        width: parent.width

                        Layout.fillWidth: true
                        Layout.preferredHeight: 48 * scaleFactor

                        font.pixelSize: 12 * scaleFactor
                        color: "#8A000000"

                        text: desc
                        elide: Label.ElideRight
                        maximumLineCount: 3
                        wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                        lineHeight: 16 * scaleFactor
                        lineHeightMode: Text.FixedHeight
                        verticalAlignment: Text.AlignTop

                        horizontalAlignment: Label.AlignLeft
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    function hapticFeedbackDelegateClicked() {
        console.log(hapticType);
        if(HapticFeedback.supported){
            HapticFeedback.send(hapticType);
        }
    }
}
