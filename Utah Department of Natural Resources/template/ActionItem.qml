import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0


Item {
    id: action

    property url image
    property string text

    signal clicked()

    width: parent.width
    height: row.height + 10

    Rectangle {
        anchors.fill: parent

        visible: mouseArea.containsMouse || mouseArea.pressed

        color: "#60ffffff"
    }

    Row {
        id: row

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: 2

        Image {
            id: actionImage

            anchors.verticalCenter: parent.verticalCenter
            width: visible ? 40 * AppFramework.displayScaleFactor : 0
            height: width
            fillMode: Image.PreserveAspectFit
            source: image
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.parent.width - actionImage.width - parent.spacing
            text: action.text
            font {
                pointSize: 24
            }
            color: "#f7f8f8"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        hoverEnabled: true

        onClicked: {
            action.clicked();
        }
    }
}
