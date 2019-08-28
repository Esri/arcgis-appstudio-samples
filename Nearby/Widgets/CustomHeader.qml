import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.1

ToolBar {
    id:header

    Material.background: app.toolbarColor
    Material.elevation: 4
    property bool stateVisible: true

    states: [
        State {
            when: stateVisible;
            PropertyChanges {
                target: header
                opacity: 1.0
            }
        },
        State {
            when: !stateVisible;
            PropertyChanges {
                target: header
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

