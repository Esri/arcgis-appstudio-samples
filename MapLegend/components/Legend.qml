import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    width: parent.width
    height: parent.height
    visible: false

    // Properties
    property color legendHeaderColor: "blue"
    property string legendTitle: "Layers"
    property color legendTitleColor: "white"
    property color legendBackgroundColor: "white"
    property color legendTextColor: "#696969"
    property color toggleOnColor: "#0066ff"
    property color toggleOffColor: "#808080"
    property color toggleHandleColor: "white"
    property color toggleHandleBorderColor: "#959595"
    property color layerSeparatorColor: "#696969"
    property string fontFamilyName
    property var legendListModel

    // Signals
    signal toggled(string name, bool isVisible, int layerIndex)

    // Scale factor
    property double scaleFactor: AppFramework.displayScaleFactor

    function show() {
        visible = true
    }

    function hide() {
        visible = false
    }

    Rectangle {
        id: rectLegendHeader
        width: parent.width
        height: 60*scaleFactor
        color: legendHeaderColor

        Rectangle {
            height: parent.height
            width: 25*scaleFactor
            color: "transparent"
            anchors {
                right: parent.right
                rightMargin: 15*scaleFactor
                verticalCenter: parent.verticalCenter
            }

            Image {
                id: imgClose
                width: 25*scaleFactor
                height: width
                anchors.centerIn: parent
                source: "images/close.png"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    hide()
                }
            }
        }

        Text {
            id: txtLegendHeader
            anchors.centerIn: parent
            text: legendTitle
            color: legendTitleColor
            font.pointSize: 22*scaleFactor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: fontFamilyName
        }
    }

    Rectangle {
        id: rectLegend
        width: parent.width
        height: parent.height - rectLegendHeader.height
        anchors.top: rectLegendHeader.bottom
        color: legendBackgroundColor

        Flickable {
            id: flickableValuesList
            width: parent.width
            height: parent.height
            contentHeight: col.implicitHeight
            clip: true

            Column {
                id: col
                width: parent.width
                height: parent.height
                anchors.top: parent.top

                Repeater {
                    id: repeaterLegend
                    model: legendListModel
                    anchors.centerIn: parent
                    Rectangle {
                        width: parent.width
                        height: Math.max(txtLayerName.implicitHeight + (10*scaleFactor), 50*scaleFactor)
                        color: "transparent"
                        Text {
                            id: txtLayerName
                            width: parent.width - layerToggle.implicitWidth - (30*scaleFactor)
                            text: name
                            font.pointSize: 18*scaleFactor
                            font.family: fontFamilyName
                            color: legendTextColor
                            verticalAlignment: Text.AlignVCenter
                            anchors {
                                left: parent.left
                                margins: 10*scaleFactor
                                verticalCenter: layerToggle.verticalCenter
                            }
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }

                        Switch {
                            id: layerToggle
                            checked: isVisible
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                margins: 20*scaleFactor
                            }

                            onClicked: {
                                toggled(name, isVisible, layerIndex)
                            }

                            style: SwitchStyle {
                                groove: Rectangle {
                                    width: 55*scaleFactor
                                    height: 30*scaleFactor
                                    radius: 20*scaleFactor
                                    color: layerToggle.checked ? toggleOnColor : toggleOffColor
                                }
                                handle: Rectangle {
                                    width: 30*scaleFactor
                                    height: 30*scaleFactor
                                    radius: 30*scaleFactor
                                    color: toggleHandleColor
                                    border.width: 1*scaleFactor
                                    border.color: toggleHandleBorderColor
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width - (10*scaleFactor)
                            height: 1*scaleFactor
                            color: layerSeparatorColor
                            anchors {
                                top: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }

        }
    }
}
