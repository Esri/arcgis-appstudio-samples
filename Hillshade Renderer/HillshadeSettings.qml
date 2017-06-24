import QtQuick 2.7
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

Rectangle {

    id: root
    color: "transparent"
    visible: false

    RadialGradient {
        anchors.fill: parent
        opacity: 0.7
        gradient: Gradient {
            GradientStop { position: 0.0; color: "lightgrey" }
            GradientStop { position: 0.7; color: "black" }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: mouse.accepted = true
        onWheel: wheel.accepted = true
    }

    Rectangle {
        anchors.centerIn: parent
        width: 225 * scaleFactor
        height: 215 * scaleFactor
        color: "lightgrey"
        radius: 5
        border {
            color: "#4D4D4D"
            width: 1
        }

        Column {
            anchors {
                fill: parent
                margins: 30 * scaleFactor
            }
            spacing: 0

            Text {

                anchors.horizontalCenter: parent.horizontalCenter
                text: "Hillshade Renderer Settings"
                font.weight: Font.DemiBold
                font.pixelSize: baseFontSize * 0.8
            }

            Row {
                spacing:0

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 75 * scaleFactor
                    text: "Altitude"
                    font.pixelSize: baseFontSize * 0.6
                }

                Slider {
                    anchors.verticalCenter: parent.verticalCenter
                    id: altitudeSlider
                    width: 100 * scaleFactor
                    from: 0
                    to: 90
                }
            }

            Row {
                spacing:0

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 75 * scaleFactor
                    text: "Azimuth"
                    font.pixelSize: baseFontSize * 0.6
                }

                Slider {
                    anchors.verticalCenter: parent.verticalCenter
                    id: azimuthSlider
                    width: 100 * scaleFactor
                    from: 0
                    to: 360
                }
            }

            Row {
                spacing: 0

                Text {
                    id:slopeText
                    width: 75 * scaleFactor
                    text: "Slope"
                    font.pixelSize: baseFontSize * 0.6
                }

                ComboBox {
                    id: slopeBox
                    model: hillshadeSlopeTypeModel
                    textRole: "name"
                    height: 30 * scaleFactor
                    width: 90 * scaleFactor
                    anchors.verticalCenter: slopeText.verticalCenter
                }
            }
            ListModel {
                id:hillshadeSlopeTypeModel
                ListElement {
                    name: "None"
                    value: -1
                }
                ListElement {
                    name: "Degree"
                    value: 0
                }
                ListElement {
                    name: "Percent Rise"
                    value: 1
                }
                ListElement {
                    name: "Scaled"
                    value: 2
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Apply"
                height: 30 * scaleFactor
                width: 90 * scaleFactor
                Material.background: "white"
                onClicked: {
                    var altitude = altitudeSlider.value;
                    var azimuth = azimuthSlider.value;
                    var slope = slopeBox.model.get(slopeBox.currentIndex).value;
                    applyHillshadeRenderer(altitude, azimuth, slope);
                    root.visible = false;
                }
            }
        }
    }
}

