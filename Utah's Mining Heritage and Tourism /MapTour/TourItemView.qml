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

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {
    id: itemView

    signal clicked()
    signal doubleClicked()
    signal searchCompleted()

    width: parent.width
    //height: 133 * app.scaleFactor

    height: maxThumbnailHeight


    property real maxThumbnailWidth: app.width * 0.3
    property real maxThumbnailHeight: maxThumbnailWidth * 133 / 200

    Item {
        anchors {
            fill: parent
            margins: 10 * app.scaleFactor
            //bottomMargin: 20
        }

        RectangularGlow {
            anchors.fill: thumbnailImage

            visible: mouseArea.pressed || mouseArea.containsMouse
            color: mouseArea.pressed ? app.selectColor : app.valuehighlightColor
            cornerRadius: 4
            glowRadius: 4
            spread: 0.1
        }


        Image {
            id: thumbnailImage

            height: Math.min(parent.height, maxThumbnailHeight)
            width: height * 200 / 133
            anchors {
                left: parent.left
                top: parent.top

            }

            sourceSize.width: 200
            sourceSize.height: 133

            asynchronous: true

            //source: thumbnailUrl && thumbnailUrl.length>1 ? thumbnailUrl : "images/item_thumbnail.png"
            source : getThumbnail(thumbnailUrl, thumbnail)
            //source: thumbnailUrl || "images/item_thumbnail.png"
            fillMode: Image.PreserveAspectFit


            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border {
                    color: "darkgray"
                }
            }
        }

        Text {
            id: titleText

            anchors {
                left: thumbnailImage.right
                leftMargin: 5 * app.scaleFactor
                right: parent.right
            }

            text: title

            font.family: app.customTitleFont.name

            font {
                pointSize: app.baseFontSize * 0.8
                bold: true
            }
            wrapMode: Text.Wrap
            color: "#f7f8f8"
            //elide: Text.ElideRight
        }

        Text {
            id: snippetText

            anchors {
                left: thumbnailImage.right
                leftMargin: 5 * app.scaleFactor
                right: parent.right
                top: titleText.bottom
                topMargin: 5 * app.scaleFactor
                //bottom: parent.bottom
            }

            font.family: app.customTextFont.name
            height: parent.height - titleText.contentHeight -5

            text: snippet
            font {
                pointSize: app.baseFontSize * 0.6
            }
            color: "#f7f8f8"
            wrapMode: Text.Wrap
            elide: Text.ElideRight
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
                //itemView.ListView.view.currentIndex = index;
                //itemView.doubleClicked();
            }
        }
    }

    //-------------------

    Connections {
        target: itemView
        onDoubleClicked : {
            console.log("## event: Photo double clicked");
        }
    }

    //--------------------------------

    function getThumbnail(thumbUrl, thumb) {

        //console.log("get thumbnail: ", thumb, typeof thumb, Object.keys(thumb));


        if(thumb) {

            return thumbUrl;
        } else {
            return "images/item_thumbnail.png";
        }
    }
}
