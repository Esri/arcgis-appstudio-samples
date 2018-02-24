import QtQuick 2.9
import QtQuick.Layouts 1.3

RowLayout {
    Layout.fillWidth: true
    height: parent.height / 7

    property alias nameText: nameText.text
    property alias valueText: valueText.text

    Text {
        id: nameText

        anchors.left: parent.left
        anchors.leftMargin: 5 * scaleFactor
        anchors.verticalCenter: parent.verticalCenter

        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        font.pixelSize: baseFontSize
        font.bold: true
        color: "white"
    }

    Text {
        id: valueText

        property bool valid: true

        anchors.left: nameText.right
        anchors.verticalCenter: parent.verticalCenter

        font.pixelSize: baseFontSize
        font.bold: true
        font.italic: !valid
        color: valid ? "white" : "darkred"
    }
}
