import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Rectangle {
    id: textField

    property bool stateVisible: true

    Layout.alignment: Qt.AlignCenter
    radius: height/2
    color: app.secondaryColor

    Behavior on width {
        NumberAnimation {
            duration: 600
            easing.type: Easing.OutQuad
        }
    }

    states: [
        State {
            when: stateVisible;
            PropertyChanges {
                target: textField
                opacity: 1.0
            }
        },
        State {
            when: !stateVisible;
            PropertyChanges {
                target: textField
                opacity: 0.0
            }
        }
    ]
    transitions: Transition {
        NumberAnimation {
            property: "opacity";
            duration: 500
        }
    }
}
