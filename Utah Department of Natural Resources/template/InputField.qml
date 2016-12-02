import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

TextField {
    property alias leftButton: leftButton

    signal cleared();

    ImageButton {
        id: leftButton

        property real leftMargin: visible ? width + anchors.margins * 1.5 : 0

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }

        visible: false
        width: height

        Component.onCompleted: {
            if (parent.__panel) {
                parent.__panel.leftMargin = Qt.binding(function() { return leftMargin; });
            }
        }
    }

    ImageButton {
        id: clearButton

        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }

        visible: parent.text > "" && !parent.readOnly
        width: height

        source: "images/delete.png"

        onClicked: {
            parent.text = "";
            cleared();
        }

        onVisibleChanged: {
            if (parent.__panel) {
                parent.__panel.rightMargin = visible ? clearButton.width + clearButton.anchors.margins * 1.5 : 0;
            }
        }
    }
}
