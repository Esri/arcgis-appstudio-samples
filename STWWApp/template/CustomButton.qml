import QtQuick 2.2
import QtQuick.Controls 1.1
import QtGraphicalEffects 1.0

Item {


    property string buttonText: qsTr("Click Me")
    property real buttonWidth: 200
    property real buttonHeight: buttonWidth/4
    property color buttonColor: "#165F8C"
    property bool buttonFill: true
    property color buttonTextColor: "#ffffff"
    property int buttonFontSize: 16
    property int buttonBorderRadius: 4
    property bool seperator: false

    height: buttonHeight
    width: buttonWidth
    //anchors.horizontalCenter: parent.horizontalCenter

//    DropShadow {
//                anchors.fill: parent
//                //cached: true;
//                horizontalOffset: 3;
//                verticalOffset: 3;
//                radius: buttonBorderRadius;
//                samples: buttonBorderRadius*2;
//                color: "#80000000";
//                //smooth: true;
//                source: parent;
//                visible: buttonFill
//    }

    Rectangle {
        width: buttonWidth
        height: buttonHeight
        color: buttonFill ? buttonColor : "transparent"
        border.color: buttonColor
        border.width: buttonFill ? 0 : 2
        radius:buttonBorderRadius
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            anchors.fill: parent
            visible: buttonFill
            gradient: Gradient {
                GradientStop { position: 1 ; color: "#33000000"}
                GradientStop { position: 0 ; color: "#22000000" }
            }
            radius:buttonBorderRadius
        }
        Text {
            width:parent.width;
            height:parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color:buttonFill ? buttonTextColor : buttonColor
            text:buttonText
            font.pointSize: buttonFontSize
        }
    }
}
