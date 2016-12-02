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

import QtQuick 2.2
import QtQuick.Controls 1.1

//import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0


Image {
    id: gallery

    property Portal portal

    signal exitClicked()
    signal tourSelected(PortalItemInfo itemInfo);

    source: app.galleryPageBackground
    fillMode: Image.PreserveAspectCrop

    Component.onCompleted: {
        toursListView.refresh();
    }

    focus: true

    //android back button
    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            console.log("Back button captured!")
            event.accepted = true
            exitClicked();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#60000000"
    }

    Text {
        id: titleText

        font.family: app.customTitleFont.name

        anchors {
            left: exitButton.left
            right: parent.right
            top: parent.top
            topMargin: 6*app.scaleFactor
        }
        height: 50 * app.scaleFactor

        text: isSignedIn ? qsTr("Your Map Tours") : qsTr("Explore Map Tours")
        font {
            pointSize: app.baseFontSize * 0.9
        }
        color: "#f7f8f8"
        horizontalAlignment: Text.AlignHCenter
    }


    ImageButton {
        id: exitButton

        anchors {
            top: parent.top
            left: parent.left
            margins: 6*app.scaleFactor

        }
        checkedColor : "transparent"
        pressedColor : "transparent"
        hoverColor : "transparent"
        glowColor : "transparent"

        height: 36 * app.scaleFactor
        width : 36 * app.scaleFactor

        source: "images/left1.png"

        onClicked: {
            exitClicked();
        }
    }

    Item {
        anchors {
            left: parent.left
            right: parent.right
            top: titleText.bottom
            bottom: parent.bottom
            margins: 10
            topMargin: 20
        }

        clip: true


        //------------------------

        Text {
            id: galleryMessageBox
            color: "#f7f8f8"
            font {
                pointSize: app.baseFontSize * 0.9
            }
            font.family: app.customTextFont.name
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            visible: false
        }

        //---------------------------------------------

        Rectangle {
            anchors.fill: parent
            id: busyIndicator2
            visible: toursListView.count > 0 ? 0 : 1
            color: "transparent"
            //opacity: 0.2

            BusyIndicator {
                id: busyIndicator2Ctrl
                running: toursListView.count > 0 ? 0 : 1
                anchors.centerIn: parent
            }

        }
        //----------------------

        ToursListView {
            id: toursListView

            anchors.fill: parent

            portal: gallery.portal

            onSearchCompleted: {
                console.log("onsearch completed. Total results = ", model.length);
                if (model.length === 1) {
                    toursListView.currentIndex = 0;
                    gallery.tourSelected(toursListView.currentTour);
                }
            }

            delegate: TourItemView{


                onClicked: {
                    gallery.tourSelected(toursListView.currentTour);
                }

                onDoubleClicked: {
                    //gallery.tourSelected(toursListView.currentTour);
                }
            }


        }
    }


}

