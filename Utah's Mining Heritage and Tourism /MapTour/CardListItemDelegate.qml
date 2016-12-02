/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtGraphicalEffects 1.0

Item {
    id: cardListItemDelegate

    signal clicked()
    signal doubleClicked()

    property real maxThumbnailWidth: screenWidth * 0.4
    property real maxThumbnailHeight: maxThumbnailWidth * 133 / 200

    width: isSmallScreen ? Math.min(parent.width, 800*app.scaleFactor) : parent.width*0.95
    height: maxThumbnailHeight

    anchors.horizontalCenter: parent.horizontalCenter

    Item {
        anchors {
            fill: parent
            topMargin: 5*app.scaleFactor
            bottomMargin: 5*app.scaleFactor

        }


        Rectangle {
            anchors.fill: parent
            color: "black"
            //color: app.headerBackgroundColor
            //            gradient: Gradient {
            //                GradientStop { position: 1.0; color: app.headerBackgroundColor;}
            //                GradientStop { position: 0.0; color: app.headerBackgroundColor;}
            //            }
            //radius: 5
            //opacity: 0.8
        }


        Image {
            id: cardThumbnailImage

            height: Math.min(parent.height, maxThumbnailHeight)
            width: height * 200 / 133
            anchors {
                left: parent.left
                top: parent.top

            }

            onStatusChanged: if (cardThumbnailImage.status == Image.Error) cardThumbnailImage.source = "images/item_thumbnail.png"

            asynchronous: true

            source : attributes.thumb_url
            //source: "images/item_thumbnail.png"
            fillMode: Image.PreserveAspectCrop

            //-------
            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    topMargin: 3*app.scaleFactor
                    leftMargin: 3*app.scaleFactor
                }
                radius: 3
                height: cardItemNumber.contentHeight + 2*app.scaleFactor
                width: cardItemNumber.contentWidth + 8*app.scaleFactor

                //color: "#80000000"
                color: app.customRenderer?getColorName(attributes.icon_color): "#000000"
                opacity: 0.9;

                Text {
                    id: cardItemNumber
                    text: index + 1
                    color: "white"
                    anchors {
                        centerIn: parent
                    }
                    font {
                        pointSize: app.baseFontSize * 0.6
                    }

                    font.family: app.customTextFont.name
                }
            }

            BusyIndicator {
                visible: cardThumbnailImage.status !== (Image.Ready || Image.Error)
                anchors.centerIn: parent
            }



            //---------------


        }

        Text {
            id: cardTitleText

            anchors {
                left: cardThumbnailImage.right
                leftMargin: 15 * app.scaleFactor
                right: parent.right
                topMargin: 5*app.scaleFactor

                //verticalCenter: parent.verticalCenter
            }

            font.family: app.customTitleFont.name

            text: attributes.name

            textFormat: Text.StyledText

            maximumLineCount: 3
            elide: Text.ElideRight

            font {
                pointSize: app.baseFontSize * (isSmallScreen ? 0.7 : 1)
            }
            wrapMode: Text.Wrap
            color: app.textColor
        }

        Text {
            id: cardDescriptionText

            font.family: app.customTextFont.name

            anchors {
                left: cardThumbnailImage.right
                leftMargin: 15 * app.scaleFactor
                right: parent.right
                top: cardTitleText.bottom
                topMargin: 10 * app.scaleFactor
                bottom: parent.bottom
                bottomMargin: 5 * app.scaleFactor
            }

            visible: !isSmallScreen

            linkColor: "#e5e6e7"

            onLinkActivated: {
                Qt.openUrlExternally(link);
            }

            //maximumLineCount: 2

            elide: Text.ElideRight

            text: attributes.description

            textFormat: Text.StyledText

            font {
                pointSize: app.baseFontSize * 0.8
            }

            wrapMode: Text.Wrap
            color: app.textColor

            opacity: 0.9
        }

        MouseArea {
            id: cardMouseArea
            anchors.fill: parent

            hoverEnabled: true

            onClicked: {
                console.log("card clicked: " + index);
                //cardList.ListView.view.currentIndex = index;
                //cardList.currentIndex = index;
                currentPhotoIndex = index
                mapListView.currentIndex = index
                mapListView.positionViewAtIndex(index,ListView.Left);
                onGraphicClickHandler(index);
                mapMode = true
                photoMode = true
            }
        }

    }

    //-------------------

    Connections {
        target: cardListItemDelegate
        onDoubleClicked : {
            console.log("## event: Photo double clicked");
        }
    }

    //--------------------------------

}
