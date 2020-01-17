import QtQuick 2.9
import QtQuick.Layouts 1.3

Item {
    property alias nameText: nameText.text
    property alias valueText: valueText.text

    height: metrics.height
    Layout.fillWidth: true

    RowLayout {
        anchors.fill: parent

        Text {
            id: nameText

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.leftMargin: 5 * scaleFactor

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.pixelSize: baseFontSize
            font.bold: true
            color: "white"
        }

        Text {
            id: valueText

            property bool valid: true

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            font.pixelSize: baseFontSize
            font.bold: true
            font.italic: !valid
            color: valid ? "white" : "darkred"
        }
    }

    TextMetrics {
        id: metrics
        font: nameText.font
        text: " "
    }
}
