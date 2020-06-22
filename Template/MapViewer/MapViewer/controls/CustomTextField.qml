import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

Item {
    id: root

    property alias properties: textField
    property real defaultMargin: app.units(16)

    signal accepted ()
    signal closeButtonClicked ()
    signal backButtonPressed()

    TextField {
        id: textField

        inputMethodHints: Qt.ImhNoPredictiveText
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            right: closeBtn.left
            rightMargin: root.defaultMargin
        }
        selectByMouse: true
        bottomPadding: topPadding
        background: Rectangle {
            color: "transparent"
            border.color: "transparent"
        }

        onAccepted: {
            root.accepted()
        }

        Keys.onReleased: {
            if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape){
                event.accepted = true
                backButtonPressed ()
            }
        }
    }

    Icon {
        id: closeBtn

        imageSource: "../images/close.png"
        visible: textField.text > ""
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
        maskColor: app.subTitleTextColor

        onClicked: {
            closeButtonClicked()
            textField.text = ""
        }
    }

    Label {
        id: placeholder

        width: textField.width
        text: textField.placeholderText
        leftPadding: textField.leftPadding
        rightPadding: textField.rightPadding
        topPadding: textField.topPadding
        bottomPadding: textField.bottomPadding
        color: textField.color
        opacity: 0.5
        anchors.verticalCenter: textField.verticalCenter
        font.pixelSize: textField.font.pixelSize
    }

    states: [
        State {
            name: "FOCUSSED"
            when: textField.focus || textField.text > ""

            PropertyChanges {
                target: placeholder
                visible: false
            }
        }
    ]
}
