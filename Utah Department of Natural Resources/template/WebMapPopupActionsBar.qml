import QtQuick 2.2
import QtQuick.Controls 1.2

import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Rectangle {
    id: titleBanner
    
    property string title

    property alias backVisible: backButton.visible
    property alias backEnabled: backButton.enabled
    property alias backImage: backButton.source
    property alias backText: backLabelText.text

    property alias previousVisible: previousButton.visible
    property alias previousEnabled: previousButton.enabled

    property alias nextVisible: nextButton.visible
    property alias nextEnabled: nextButton.enabled

    property alias closeVisible: closeButton.visible
    property alias closeEnabled: closeButton.enabled


    signal backClicked()
    signal previousClicked()
    signal nextClicked()
    signal closeClicked()

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
            
            height: parent.height
            width: height
            
            source: "images/back.png"
            hoverColor: app.hoverColor
            pressedColor: app.pressedColor
            checkedColor: app.selectedColor
            
            onClicked: {
                backClicked();
            }
        }

        Text {
            id: backLabelText

            text: "Back"
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            color: "#f7f8f8"
            font {
                pixelSize: parent.parent.height * 0.4
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    backClicked();
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
            id: previousButton
            
            height: parent.height
            width: height
            
            source: "images/pageUp.png"
            hoverColor: app.hoverColor
            pressedColor: app.pressedColor
            
            onClicked: {
                previousClicked();
            }
        }
        
        ImageButton {
            id: nextButton
            
            height: parent.height
            width: height
            
            source: "images/pageDown.png"
            hoverColor: app.hoverColor
            pressedColor: app.pressedColor
            
            onClicked: {
                nextClicked();
            }
        }
        
        ImageButton {
            id: actionsButton
            
            height: parent.height
            width: height
            visible: false
            
            source: "images/actions.png"
            hoverColor: app.hoverColor
            pressedColor: app.pressedColor
            checkedColor: app.selectedColor
            
            onClicked: {
            }
        }

        ImageButton {
            id: closeButton

            height: parent.height
            width: height
            visible: false

            source: "images/close.png"
            hoverColor: app.hoverColor
            pressedColor: app.pressedColor
            checkedColor: app.selectedColor

            onClicked: {
                closeClicked();
            }
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

/*
    PageFlipper {
        anchors {
            left: parent.left
            right: parent.right
            top: titleBanner.bottom
            bottom: parent.bottom
        }

        leftToRight: popupView.previousVisible
        rightToLeft: popupView.nextVisible

        onFlipped: {
            if (direction === Qt.LeftToRight) {
                previousClicked();
            } else if (direction === Qt.RightToLeft) {
                nextClicked();
            }
        }
    }
*/
