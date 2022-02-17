/**********************************************************
Handle is used for creating a custom handle component
for the Split View component.
**********************************************************/
import QtQuick 2.0

//Divider of split view
Rectangle {
    implicitHeight: isMobile ? 18 : 12
    implicitWidth: isMobile ? 18 : 12
    color: "black"
    //Small handle bar
    Rectangle {
        implicitWidth: splitView.orientation === Qt.Vertical ? 30 : 4
        implicitHeight: splitView.orientation === Qt.Vertical ? 4 : 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        color: "whitesmoke"
        radius: 10
    }
}
