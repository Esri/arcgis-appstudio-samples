import QtQuick 2.3
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

CheckBox {

    property alias textContent : smallCheckBox.text
    property bool isChecked: false
    property bool isEnabled: false

    id:smallCheckBox
    padding: 0
    font.weight: Font.Thin
    checked: isChecked
    enabled: isEnabled
    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: smallCheckBox.rightPadding
        y: smallCheckBox.topPadding + smallCheckBox.availableHeight / 2 - height / 2
        radius: 3
        color: "transparent"
        border.color: "#A9A9A9"

        Rectangle {
            width: 10
            height: 10
            x: 5
            y: 5
            radius: 2
            color: "#003300"
            visible: smallCheckBox.checked
        }
    }
}
