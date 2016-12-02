import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {
    id: itemView

    signal clicked()
    signal doubleClicked()

    width: parent.width
    height: itemColumn.height + 10
    
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            itemView.ListView.view.currentIndex = index;
            itemView.clicked();
        }

        onDoubleClicked: {
            itemView.ListView.view.currentIndex = index;
            itemView.doubleClicked();
        }
    }

    Column {
        id: itemColumn

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }

        spacing: 5

        Item {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            width: Math.min(225 * AppFramework.displayScaleFactor, parent.width * 0.75)
            height: width * 133 / 200

            RectangularGlow {
                anchors.fill: thumbnailImage

                visible: mouseArea.pressed || mouseArea.containsMouse
                color: mouseArea.pressed ? app.pressedColor : app.hoverColor
                cornerRadius: 8
                glowRadius: 8
                spread: 0.2
            }

            Image {
                id: thumbnailImage

                anchors.fill: parent
                source: thumbnailUrl
                fillMode: Image.PreserveAspectFit

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border {
                        color: "darkgray"
                    }
                }
            }
        }

        Text {
            id: titleText

            width: parent.width
            text: title
            font {
                pointSize: 18
                bold: true
            }
            color: app.lightTextColor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: snippetText

            property bool showFull: true

            width: parent.width
            text: snippet
            font {
                pointSize: 14
            }
            color: titleText.color
            wrapMode: showFull ? Text.WordWrap : Text.NoWrap
            elide: showFull ? Text.ElideNone : Text.ElideRight
            horizontalAlignment: Text.AlignHCenter

            MouseArea {
                anchors.fill: parent
                enabled: false
                onClicked: {
                    snippetText.showFull = !snippetText.showFull;
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#40f7f8f8"
        }
    }
}

