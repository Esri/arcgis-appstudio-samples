import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {
    visible: false
    width: parent.width
    height: parent.height

    property string text : "Alert!"
    property color backgroundColor: app.headerBackgroundColor
    property color textColor : "white" //app.textColor
    property variant actionMode : ["quit", "retryService"]
    property string actionRequest: ""
    property alias buttonText : alertButton.buttonText

    Rectangle {
        anchors.fill: parent
        z:10
        color: "grey"
        opacity: 0.8
    }

    Rectangle {
        anchors {
            centerIn: parent;
            fill: alertContent
            margins: -10
        }
        z:11
        color: backgroundColor
        radius: 5*app.scaleFactor
//        MouseArea {
//            anchors.fill: parent
//            onClicked: {
//                alertBox.visible = false
//            }
//        }
    }

    Column {
        id: alertContent
        //anchors.centerIn: parent
        anchors {
            top: parent.top
            bottom: parent.bottom
            centerIn: parent
        }
        width: Math.min(parent.width, 400*app.scaleFactor)
        spacing: 10
        z:12

        Text {
            id: alertBoxText
            color: textColor
            //fontSizeMode: Text.Fit
            width: parent.width * 0.8
            //maximumLineCount: 4
            textFormat: Text.StyledText

            wrapMode: Text.Wrap
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter

            font {
                pointSize: app.baseFontSize * 0.8
            }

            text: alertBox.text
        }

        CustomButton {
            id: alertButton
            //buttonText: "OK"
            buttonTextColor: isOnline ? "white" : "lightgrey"
            buttonColor: isOnline ? app.buttonColor : "grey"
            buttonFill: true
            enabled: isOnline
            buttonWidth: 300 * app.scaleFactor
            buttonHeight: buttonWidth/5

            anchors.horizontalCenter: parent.horizontalCenter
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if ( actionRequest === "quit"){
                        Qt.quit();
                    }
                    else if ( actionRequest === "retryService") {
                        serviceInfoTask.fetchFeatureServiceInfo();
                        alertBox.visible = false;
                    }
                }
            }
        }


    }

}
