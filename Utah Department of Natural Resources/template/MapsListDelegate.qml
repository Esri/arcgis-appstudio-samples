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
    height: 150 * AppFramework.displayScaleFactor
    property real maxThumbnailWidth: itemBody.width * 0.5
    property real maxThumbnailHeight: maxThumbnailWidth * 133 / 200
    
    Item {
        id: itemBody

        anchors {
            fill: parent
            margins: 10
        }

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

        Item {
            id: thumbnailItem

            anchors {
                left: parent.left
                top: parent.top
            }

            height: Math.min(parent.height, maxThumbnailHeight)
            width: height * 200 / 133

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

            anchors {
                left: thumbnailItem.right
                leftMargin: 5
                right: parent.right
            }

            text: title
            font {
                pointSize: 18
                bold: true
            }
            color: app.lightTextColor
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }

        Text {
            id: snippetText

            anchors {
                left: titleText.left
                leftMargin: 5
                right: parent.right
                top: titleText.bottom
                topMargin: 5
                bottom: parent.bottom
            }

            text: snippet
            font {
                pointSize: 14
            }
            color: titleText.color
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }
    }
}
