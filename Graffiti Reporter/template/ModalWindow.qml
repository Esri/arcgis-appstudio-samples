import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {

    id: modalWindow

    width: parent.width
    height: parent.height

    z: 55

    property string title: "Title"
    property string description: "Description goes here"
    //property string buttonText: "OK"

    visible: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerBar
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: app.headerBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Text {
                id: titleText
                text: title
                textFormat: Text.StyledText
                //anchors.centerIn: parent
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
                anchors.leftMargin: 10
            }

            ImageButton {
                source: "images/close.png"
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    modalWindow.visible = false
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: app.pageBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - headerBar.height

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Flickable {
                //anchors.fill: parent
                width: parent.width
                height: parent.height
                contentHeight: descriptionText.contentHeight + 50
                clip: true

                Item {
                    anchors.fill: parent

                    Text {
                        id: descriptionText
                        text: description
                        textFormat: Text.StyledText
                        anchors.fill: parent
                        anchors.margins: {
                           left: 10
                           right: 10
                           top: 20
                           bottom: 20
                        }
                        font {
                            pointSize: app.baseFontSize * app.subTitleFontScale
                        }
                        color: app.textColor
                        wrapMode: Text.Wrap
                        linkColor: "#e5e6e7"
                        onLinkActivated: {
                            Qt.openUrlExternally(link);
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        visible: false
        radius: 5
        color: "#EBEBEB"
        width: parent.width * 0.9
        height: parent.height * 0.9
        anchors.centerIn: parent





    }
}
