import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {

    id: modalWindow

    width: parent.width
    height: parent.height

    z:100

    opacity: visible ? 1 : 0

    property string title: "Title"
    //property string description: "Description goes here"
    //property string buttonText: "OK"

    property string textFont: ""
    property string titleFont: ""

    property color titleBackGroundColor: "#444"
    property color titleTextColor: "white"
    property double baseFontSize: 18

    property color backGroundColor: "white"
    property color textColor: "#444"

    property alias dataModel : dataModel

    property double scaleFactor: AppFramework.displayScaleFactor

    Component.onCompleted: {
        console.log("Modal window size: ", width, height);
    }

    ListModel {
        id: dataModel

//        ListElement {
//            description: "hello"
//            title: "world"
//        }

    }

    Behavior on opacity {
        NumberAnimation { property: "opacity"; to:1;  duration: 250; }
    }

    visible: false

    focus: visible

    //android back button
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            console.log("Back button captured!")
            event.accepted = true
            visible = false;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerBar
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: titleBackGroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Text {
                id: titleText
                text: dataModel.count > 1 ? (modalListView.currentIndex+1) + " of " + dataModel.count + " Results" : "Result"
                textFormat: Text.StyledText
                font.family: titleFont
                //anchors.centerIn: parent
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font {
                    pointSize: baseFontSize * 1.1
                }
                color: titleTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
                anchors.leftMargin: 8*scaleFactor
            }

            ImageButton {
                source: app.folder.fileUrl("assets/close.png")
                opacity: modalWindow.opacity
                //rotation: -90
                height: 30 * scaleFactor
                width: 30 * scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10*scaleFactor
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    opacity = 0
                    modalWindow.opacity = 0
                    modalWindow.visible = false
                }
                Behavior on opacity { NumberAnimation { property: "opacity"; to: 1; duration: 500; } }
            }
        }


        Component {
            id: test

            Text {

                font.family: textFont
                text: index + ". " +  description
                textFormat: Text.StyledText
                //anchors.fill: parent
                width: modalWindow.width
                anchors.margins: {
                    left: 5*scaleFactor
                    right: 5*scaleFactor
                    top: 10*scaleFactor
                    bottom: 10*scaleFactor
                }
                font {
                    pointSize: baseFontSize * 0.7
                }
                color: textColor
                wrapMode: Text.Wrap
                linkColor: AppFramework.alphaColor(textColor, 0.8)
                onLinkActivated: {
                    Qt.openUrlExternally(unescape(link));
                }
            }

        }

        Component {
            id: attributesList
            Flickable {
                //anchors.fill: parent
                //width: parent.width
                //height: parent.height
                width: modalWindow.width
                height: modalWindow.height
                contentHeight: descriptionText.contentHeight + 50
                clip: true

                Item {
                    anchors.fill: parent

                    Text {
                        id: descriptionText
                        font.family: textFont
                        text: description
                        textFormat: Text.StyledText
                        anchors.fill: parent
                        anchors.margins: {
                            left: 5*scaleFactor
                            right: 5*scaleFactor
                            top: 10*scaleFactor
                            bottom: 10*scaleFactor
                        }
                        font {
                            pointSize: baseFontSize * 0.7
                        }
                        color: textColor
                        wrapMode: Text.Wrap
                        linkColor: "#e5e6e7"
                        onLinkActivated: {
                            Qt.openUrlExternally(unescape(link));
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: backGroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - headerBar.height

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            ListView {
                id: modalListView
                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                model: dataModel
                width: modalWindow.width
                height: modalWindow.height
                clip: true
                focus: true
                currentIndex: 0
                delegate:attributesList

//                header: Rectangle {
//                    visible: dataModel.count > 1
//                    height: 20*scaleFactor
//                    //width: modalWindow.width
//                    width: 300
//                    Text {
//                        //anchors.centerIn: parent
//                        text: "Swipe left or right to see more information."
//                        font.italic: true
//                        font.pointSize: baseFontSize * 0.5
//                        color: textColor
//                    }
//                }

                onFlickEnded: {
                    console.log(currentIndex)
                    console.log("flick ended at ", contentX, contentY  , indexAt(contentX, contentY));
                    currentIndex = indexAt(contentX, contentY);
                }

            }

            ScrollBar {
                flickableItem: modalListView
            }
        }
    }

}
