import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "../Styles"

Item {
    id: view

    property alias text: textInput.text
    property alias readOnly: textInput.readOnly
    property alias selectByMouse: textInput.selectByMouse
    property alias wrapMode: textInput.wrapMode
    property alias color: textInput.color
    property bool moreEnabled: false

    Layout.minimumWidth: 100
    implicitHeight: frame.height

    signal accepted()
    signal moreClicked()

    Frame {
        id: frame

        width: parent.width

        background: Rectangle {
            color: textInput.activeFocus ? "#c0c0c0" : "#e0e0e0"
            border.color: "#c0c0c0"
            border.width: 1
            radius: 3
        }

        ColumnLayout {
            width: parent.width

            RowLayout {
                Layout.fillWidth: true

                NormalTextInput {
                    id: textInput

                    Layout.fillWidth: true

                    selectByMouse: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    visible: !readOnly

                    onAccepted: view.accepted()
                }

                NormalText {
                    id: readyOnlyText

                    Layout.fillWidth: true

                    text: textInput.text
                    visible: textInput.readOnly
                    wrapMode: textInput.wrapMode
                }

                NormalButton {
                    text: "..."

                    Layout.preferredWidth: height
                    visible: moreEnabled

                    onClicked: view.moreClicked()
                }
            }
        }
    }
}
