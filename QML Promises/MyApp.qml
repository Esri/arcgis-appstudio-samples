/* Copyright 2017 Esri
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

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Promises 1.0


import "controls" as Controls

App {
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    property bool busy: false
    property string message: ""
    property var facilities: []
    property var facilityParams: null

    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle{
            anchors.top:header.bottom
            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 5 * AppFramework.displayScaleFactor
                }



                Image {
                    id : image

                    Layout.fillWidth: true
                    //Layout.fillHeight: 50 * scaleFactor

                    opacity: 0

                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    source : "https://lh3.googleusercontent.com/_yimBU8uLUTqQQ9gl5vODqDufdZ_cJEiKnx6O6uNkX6K9lT63MReAWiEonkAVatiPxvWQu7GDs8=s640-h400-e365-rw";
                }


            }

            //--------------------------------------------------------------------------

            Timer {
                id: timer
                running: true
                interval: 3000
            }

            //--------------------------------------------------------------------------

            Promise {
                // Resolve when the image is ready
                resolveWhen: image.status === Image.Ready

                // Reject when time out.
                rejectWhen: timer.triggered

                onFulfilled:  {
                    console.log("Fulfilled - Image was ready first");
                    // If the timer is reached, the image will not be shown even it is ready.
                    image.opacity = 1;
                }

                onRejected: {
                    console.log("Rejected - Timer got there first");
                }
            }


            }
    }

    // sample ends here ------------------------------------------------------------------------

    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

