import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0

Pane {
    id: toastPane

    width: parent.width
    Material.background: app.primaryColor
    Material.elevation: state === "idle" ? 0 : 6
    state: "idle"
    padding: 0

    property bool isTall: deviceManager.isiPhone || deviceManager.isiPad
    property int intervalTime: 1500

    Behavior on height {
        NumberAnimation { duration: 250 }
    }

    Behavior on opacity {
        NumberAnimation { duration: 500 }
    }

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16 * app.scaleFactor
        }

        Label {
            id: toast

            Layout.fillWidth: true

            text: ""
            lineHeightMode: Text.FixedHeight
            lineHeight: 20 * app.scaleFactor
            clip: true
            wrapMode: Text.Wrap

            font.pixelSize: 13 * app.scaleFactor
            color: app.secondaryColor

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            leftPadding: 16 * app.scaleFactor
            rightPadding: 16 * app.scaleFactor
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: deviceManager.isiPad? 16 * app.scaleFactor:
                                                          (deviceManager.isiPhone?
                                                               (deviceManager.isiPhoneXSeries?
                                                                    40 * app.scaleFactor:
                                                                    16 * app.scaleFactor):16 * app.scaleFactor)
        }
    }

    Timer {
        id: timer
        interval: intervalTime
        onTriggered: {
            reset();
        }
    }

    states: [
        State {
            name: "idle"
            PropertyChanges { target: toastPane; height: 0; opacity: 0 }
        },
        State {
            name: "displayToast"
            PropertyChanges { target: toastPane; height: contentColumn.height; opacity: 1 }
        }
    ]

    function reset() {
        toastPane.state = "idle";
        toast.text = "";
    }

    function displayToast(message, isSticky) {
        toast.text = message;
        toastPane.state = "displayToast";
        if(!isSticky)timer.restart();
    }
}
