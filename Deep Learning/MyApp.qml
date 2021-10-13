/* Copyright 2021 Esri
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
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2
import QtMultimedia 5.6

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Multimedia 1.0
import ArcGIS.AppFramework.InterAppCommunication 1.0
import ArcGIS.AppFramework.DeepLearning 1.0


import "controls" as Controls

App {
    id: app
    width: 400
    height: 750
    Material.background: "#353535"
    signal selected(url source)
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)
    property var defaultMargin: 10 *scaleFactor
    property url clipBoardUrl: ""

    StackView {
        id: stackView

        anchors.fill: parent

        initialItem: startPage
    }

    Component {
        id: analysisPage

        ImageAnalysisPage {
        }
    }

    Page {
        id: startPage

        Material.background: "#353535"
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8F499C"
            Controls.HeaderBar{}
        }

        contentItem:ColumnLayout {
            anchors.fill: parent

            spacing: 24 * scaleFactor

            Item {
                Layout.preferredWidth: parent.width
                Layout.fillHeight: true
            }

            Label {
                text: "Select a model"
                font.bold: true
                font.pixelSize: 24
                color: "white"
                Layout.preferredWidth: parent.width
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: faceMaskBtn.height

                Button {
                    id:faceMaskBtn
                    Material.background: "#4A4A4A"
                    Material.foreground: "white"
                    text: qsTr("FACE MASK DETECTION")

                    anchors.horizontalCenter: parent.horizontalCenter

                    onClicked: {
                        stackView.push(analysisPage,
                                       {
                                           modelSource: modelsFolder.fileUrl("masks-FC.tflite"),
                                           headerTitle: "Face mask detection"
                                       });
                    }
                }
            }

            Item {
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: objectDetectBtn.height

                Button {
                    id:objectDetectBtn
                    Material.background: "#4A4A4A"
                    Material.foreground: "white"
                    text: qsTr("OBJECT DETECTION")
                    anchors.horizontalCenter: parent.horizontalCenter

                    onClicked: {
                        stackView.push(analysisPage,
                                       {
                                           modelSource: modelsFolder.fileUrl("COCO-SSD.tflite"),
                                           headerTitle: "Object detection"
                                       });
                    }
                }
            }

            Item {
                Layout.preferredWidth: parent.width
                Layout.fillHeight: true
            }
        }
    }

    FileFolder {
        id: modelsFolder

        path: app.folder.filePath("models")
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}


