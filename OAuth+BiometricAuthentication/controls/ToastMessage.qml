import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Pane {
    id: toastPane
    width: app.width
    height: 0
    Material.background: primaryColor
    Material.elevation: 0
    anchors.bottom: parent.bottom
    opacity: 0.5

    property int intervalTime: 2000
    property int durationTime: 200

    Behavior on height {
        NumberAnimation { duration: durationTime }
    }

    Label {
        id: toast
        width: parent.width
        height: parent.height
        font.pixelSize: 16
        color: "black"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: ""
        leftPadding: 24 * scaleFactor
        rightPadding: 24 * scaleFactor
        clip: true
        elide: Text.ElideRight
    }

    Timer {
        id: timer
        interval: intervalTime
        onTriggered: {
            toastPane.state = "default";
            toast.text = "";
        }
    }

    states: [
        State {
            name: "default"
            PropertyChanges { target: toastPane; height: 0 }
        },
        State {
            name: "displayToast"
            PropertyChanges { target: toastPane; height: 48 * scaleFactor }
        }
    ]

    function displayToast(message) {
        toast.text = message;
        timer.start();
        toastPane.state = "displayToast";
    }
}
