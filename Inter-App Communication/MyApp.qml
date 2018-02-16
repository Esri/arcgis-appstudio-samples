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
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2

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

    property url shareURL

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
                anchors.fill: parent
                spacing: 0 * scaleFactor

                anchors.centerIn: parent.Center


                TextField {
                    id:inputText
                    placeholderText: "Enter Text or Url"
                    Material.accent: "#8f499c"
                    Layout.preferredWidth: parent.width * 0.7
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                RowLayout {
                    spacing: 30 * scaleFactor
                    layoutDirection: Qt.LeftToRight
                     anchors.horizontalCenter: parent.horizontalCenter


                    Button {
                        text: "Share as text"

                        onClicked: {
                            AppFramework.clipboard.share(inputText.text)
                        }
                    }

                    Button {
                        text: "Share as Url"

                        onClicked: {
                            shareURL = inputText.text
                            AppFramework.clipboard.share(shareURL)
                        }
                    }
                }

                Item{
                    height: 400 * scaleFactor
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

