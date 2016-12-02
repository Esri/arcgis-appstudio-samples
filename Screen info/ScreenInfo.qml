//------------------------------------------------------------------------------

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.0

import ArcGIS.AppFramework 1.0


Rectangle {
    id: app
    width: 800
    height: 532

    function ppmmToDpi(ppmm) {
        return Math.round(ppmm * 25.4 * 100) / 100;
    }

    property real referenceDpi: Qt.platform.os === "windows" ? 96 : 72
    property real displayScaleFactor: (Screen.logicalPixelDensity * 25.4) / (Qt.platform.os === "windows" ? 96 : 72)

    ScrollView {
        anchors {
            fill: parent
            margins: 10
        }

        Column {
            spacing: 5

            Row {
                width: parent.width

                spacing: 5

                Image {
                    source: "thumbnail.png"
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Screen Information"
                    font {
                        pointSize: 24
                        bold: true
                    }
                }
            }

            Rectangle {
                height: 1
                width: parent.width
                color: "#00b2ff"
            }

            Text {
                text: "name: " + Screen.name
            }

            Text {
                text: "width: " + Screen.width
            }

            Text {
                text: "height: " + Screen.height
            }

            Text {
                text: "desktopAvailableWidth: " + Screen.desktopAvailableWidth
            }

            Text {
                text: "desktopAvailableHeight: " + Screen.desktopAvailableHeight
            }

            Text {
                text: "orientation: " + Screen.orientation
            }

            Text {
                text: "primaryOrientation: " + Screen.primaryOrientation
            }

            Text {
                text: "pixelDensity: " + Screen.pixelDensity + " <i>(" + ppmmToDpi(Screen.pixelDensity).toString() + " dpi)</i>"
            }

            Text {
                text: "logicalPixelDensity: " + Screen.logicalPixelDensity + " <i>(" + ppmmToDpi(Screen.logicalPixelDensity).toString() + " dpi)</i>"
            }

            Text {
                text: "referenceDPi: " + referenceDpi + " os:" + Qt.platform.os
            }

            Text {
                text: "displayScaleFactor: " + displayScaleFactor
            }

            Rectangle {
                height: 1
                width: parent.width
                color: "#00b2ff"
            }

            Text {
                text: "AppFramework.displayScaleFactor: " + AppFramework.displayScaleFactor
            }
        }
    }
}
