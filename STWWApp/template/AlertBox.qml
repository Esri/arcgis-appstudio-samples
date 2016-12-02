import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {

    id: alertBox
    visible: false
    property string text : "Alert!"
    width: parent.width
    height: parent.height
    property color backgroundColor: app.headerBackgroundColor
    property color textColor : app.textColor

    Rectangle {
        anchors.centerIn: parent;
        z:11
        height: (alertBoxText.contentHeight + 20) * app.scaleFactor
        color: backgroundColor
        radius: 5*app.scaleFactor
        width: Math.min(parent.width, 400*app.scaleFactor)
        anchors.margins: 10*app.scaleFactor

        MouseArea {
            anchors.fill: parent
            onClicked: {
                alertBox.visible = false
            }
        }

        Text {
            id: alertBoxText
            color: textColor
            //fontSizeMode: Text.Fit
            anchors.fill: parent
            anchors.margins: 10*app.scaleFactor
            maximumLineCount: 4
            textFormat: Text.StyledText

            anchors.leftMargin: 5*app.scaleFactor
            anchors.rightMargin: 5*app.scaleFactor

            wrapMode: Text.Wrap

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter


            font {
                pointSize: app.baseFontSize * 0.8
            }

            text: alertBox.text
        }
    }

}
