import QtQuick 2.2
import QtQuick.Controls 1.2

import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Rectangle {
    id: titleBar
    
    property string title

    property alias backButton: backButton
    property alias closeButton: closeButton


    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
    }
    
    height: 60 * AppFramework.displayScaleFactor
    color: "#e04c4c4c"
    
    Row {
        id: leftButtons
        
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }
        
        ImageButton {
            id: backButton

            property alias text: backLabelText.text
            
            height: parent.height
            width: height
            
            source: "images/back.png"
            hoverColor: app.hoverColor
            pressedColor: app.pressedColor
            checkedColor: app.selectedColor
            visible: false
        }

        Text {
            id: backLabelText

            text: ""
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            color: "#f7f8f8"
            font {
                pixelSize: parent.parent.height * 0.4
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    backButton.clicked();
                }
            }
        }
    }
    
    Row {
        id: rightButtons
        
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: 5
        }
        
        spacing: 2
        
        ImageButton {
            id: closeButton

            height: parent.height
            width: height
            visible: false

            source: "images/close.png"
            hoverColor: app.hoverColor
            pressedColor: app.pressedColor
            checkedColor: app.selectedColor
        }
    }
    
    Text {
        id: titleText
        
        anchors {
            left: leftButtons.right
            right: rightButtons.left
            rightMargin: 4
            verticalCenter: parent.verticalCenter
        }
        
        text: title
        elide: Text.ElideRight
        
        font {
            pixelSize: parent.height * 0.4
        }
        fontSizeMode: Text.HorizontalFit
        color: "#f7f8f8"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
