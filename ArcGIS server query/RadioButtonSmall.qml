import QtQuick 2.3
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

RadioButton {
    property alias textContent : smallRadioButton.text

    property bool isChecked: false
    property ButtonGroup buttonGroupName:({})

    signal checkedChangedAct
    signal completedAct

    id: smallRadioButton

    height: 25
    checked: isChecked
    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: parent.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13
        border.color: "#A9A9A9"

        Rectangle {
            width: 14
            height: 14
            x: 3
            y: 3
            radius: 7
            color: "#003300"
            visible: smallRadioButton.checked
        }
    }
    ButtonGroup.group: buttonGroupName
    onCheckedChanged: {
        checkedChangedAct()
    }
    Component.onCompleted:{
        completedAct()
    }
}
