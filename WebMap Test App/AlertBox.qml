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
    property color backgroundColor: "#165F8C"
    property color textColor : "#ffffff"
    property double scaleFactor : AppFramework.displayScaleFactor
    property int baseFontSize: 18
    z: 100

    Component.onCompleted: {
        console.log("#### ALERT BOX Component ####");
        console.log("Width: ", width, " Height: ", height, " z: ", z, " Text: ", text);
    }

    Rectangle {
        anchors.centerIn: parent;
        z: parent.z
        height: (alertBoxText.contentHeight + 20) * scaleFactor
        color: backgroundColor
        radius: 5*scaleFactor
        width: Math.min(parent.width, 400*scaleFactor)
        anchors.margins: 10*scaleFactor

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
            anchors.margins: 10*scaleFactor
            //maximumLineCount: 4
            textFormat: Text.StyledText

            anchors.leftMargin: 5*scaleFactor
            anchors.rightMargin: 5*scaleFactor

            wrapMode: Text.Wrap

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter


            font {
                pointSize: baseFontSize * 0.8
            }

            text: alertBox.text
        }
    }

}
