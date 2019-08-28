import QtQuick 2.7
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

Item {
    id: root

    property string title: ""
    property bool isSelected: true
    property bool isLast: true
    property string iconUrl: ""

    Text{
        text: title
        width: parent.width
        height: parent.height - 1 * app.scaleFactor
        color: isSelected? app.primaryColor: "#66000000"
        font.bold: isSelected? true: false
        verticalAlignment: Text.AlignVCenter
        padding: 16 * app.scaleFactor
        font.pixelSize: 13 * app.scaleFactor
    }

    Rectangle{
        width: parent.width
        height: 1 * app.scaleFactor
        color: "#19000000"
        visible: !isLast
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }
}
