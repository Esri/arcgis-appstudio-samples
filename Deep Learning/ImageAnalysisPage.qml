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

import QtQml 2.12
import QtQuick 2.12
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.13
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import QtQuick.Window 2.13

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Multimedia 1.0
import "controls" as Controls


Page {
    id: page

    //--------------------------------------------------------------------------

    property FileInfo modelFileInfo
    property FileInfo emdFileInfo
    property FileInfo txtFileInfo

    property alias analysisModel: imageAnalysisVideoOutput.model
    property alias analysisFilter: imageAnalysisVideoOutput.filter
    property string headerTitle: headerTitle

    property string activeName
    property real activeScore


    //--------------------------------------------------------------------------

    readonly property var kObjectLabels: {
        "mask":  "You are wearing a mask",//"✔︎",
        "nomask": "You are not wearing a mask"//"X"
    }

    readonly property var kObjectColors: {
        "mask": "limegreen",
        "nomask": "red"
    }

    //--------------------------------------------------------------------------
    
    Camera {
        id: camera
        position: headerTitle === "Face mask detection" ? Camera.FrontFace : Camera.UnspecifiedPosition
//        deviceId: QtMultimedia.defaultCamera.deviceId
        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash
        
        exposure {
            exposureCompensation: -1.0
            exposureMode: Camera.ExposurePortrait
        }
    }
    
    //--------------------------------------------------------------------------

    header: ToolBar{
        id:modelHeader
        Material.background: "#8f499c"

        RowLayout {
            anchors.fill: parent
            spacing:0
            clip:true

            Rectangle{
                Layout.preferredWidth: 50*scaleFactor

                ToolButton {
                    id:backIcon
                    indicator: Image{
                        width: 24 * scaleFactor
                        height: 24 * scaleFactor
                        anchors.centerIn: parent
                        source: "assets/back.png"
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                    }
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    onClicked: {
                        page.StackView.view.pop();
                    }
                }
            }

            Text {
                text: headerTitle
                color:"white"
                font.pixelSize: app.baseFontSize * 1.1
                font.bold: true
                maximumLineCount:2
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignCenter
            }

            Rectangle{
                id:infoImageRect
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 50*scaleFactor

                ToolButton {
                    id:settingsIcon
                    indicator: Image{
                        width: 24 * scaleFactor
                        height: 24 * scaleFactor
                        anchors.centerIn: parent
                        source: "assets/settings.png"
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                    }
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    onClicked: {
                         drawer.open();
                    }
                }
            }
        }
    }

    background: Rectangle {
        color: "black"
    }

    //--------------------------------------------------------------------------

    Connections {
        target: analysisFilter

        function onDetected(result) {
            if (analysisModel.modelType === "ObjectClassification") {
                activeName = result.name;
                activeScore = result.score;
                timer.stop();
            }
        }
    }

    Connections {
        target: analysisFilter.resultsModel

        function onCountChanged() {
            if (analysisFilter.resultsModel.count < 1) {
                timer.restart();
            }
        }
    }

    Timer {
        id: timer

        interval: 1000

        onTriggered: {
            activeName = "";
            activeScore = -1;
        }
    }

    //--------------------------------------------------------------------------
    
    Item {
        anchors {
            fill: parent
            margins: 0
        }
        
        ImageAnalysisVideoOutput {
            id: imageAnalysisVideoOutput

            anchors.fill: parent

            source: camera
            model.tfliteFileInfo: modelFileInfo
            model.emdFileInfo: emdFileInfo
            model.txtFileInfo: txtFileInfo
            debug: debugCheckBox.checked
            minimumScore: minimumScoreSlider.value

            Component.onCompleted: fixOrientation();

            function fixOrientation() {
                if (Qt.platform.os === "ios") {
                    autoOrientation = false;
                    orientation = Qt.binding(function() {
                        var orientationRotation = 0;
                        switch (Screen.orientation) {
                        case 1:
                            orientationRotation = 0;
                            break;

                        case 2:
                            orientationRotation = 90;
                            break;

                        case 4:
                            orientationRotation = 180;
                            break;

                        case 8:
                            orientationRotation = -90;
                            break;
                        }

                        return (camera.position === Camera.FrontFace) ? ((camera.orientation + orientationRotation) % 360) : camera.orientation;
                    } );
                }
            }
        }

        Text {
            id: activeScoreText
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 70 * scaleFactor
            }

            visible: activeText.visible
            text: "%1%".arg(Math.round(activeScore * 100));
            color: activeText.color
            font {
                pointSize: 24
                bold: true
            }
        }

        Text {
            id: activeText

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: activeScoreText.bottom
                topMargin: 10 * scaleFactor
            }
            visible: activeScore > 0
            text: kObjectLabels[activeName] || "?"
            color: kObjectColors[activeName] || "lightgrey"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: parent.width
            elide: Text.ElideRight

            font {
                pointSize: 24
                bold: true
            }
        }
    }

    //--------------------------------------------------------------------------

    Drawer {
        id: drawer

        edge: Qt.RightEdge

        height: parent.height
        width: 300

        property color themeColor: "#8f499c"
        background: Rectangle {
            anchors.fill: parent
            color: "white"
        }
        ColumnLayout {
            anchors{
                fill: parent
                margins: 10
            }

            Item {
                visible: Qt.platform.os === "ios"
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }

            Label {
                Layout.fillWidth: true

                text: "Camera"
            }

            ComboBox {
                Layout.fillWidth: true

                model: QtMultimedia.availableCameras
                visible: QtMultimedia.availableCameras.length > 1
                textRole: "displayName"

                Material.accent: drawer.themeColor
                Material.background: "white"

                Component.onCompleted: {
                    for (var i = 0; i < model.length; i++) {
                        if (camera.deviceId === model[i].deviceId) {
                            currentIndex = i;
                            break;
                        }
                    }
                }

                onActivated: {
                    camera.deviceId = model[index].deviceId;
                    camera.start();
                }
            }

            Label {
                Layout.fillWidth: true

                text: "Sensitivity %1%".arg(Math.round(minimumScoreSlider.value * 100))
            }

            Slider {
                id: minimumScoreSlider

                Layout.fillWidth: true

                Material.accent: drawer.themeColor

                from: 0
                to: 1
                value: 0.45
            }

            Label {
                Layout.fillWidth: true

                text: "Analysis interval"
            }

            Label {
                Layout.fillWidth: true

                text: "%1ms".arg(analysisFilter.interval)
                font.bold: true
            }

            Label {
                Layout.fillWidth: true

                text: "Model type"
            }

            Label {
                Layout.fillWidth: true

                text: analysisModel.modelType
                font.bold: true
            }

            Label {
                Layout.fillWidth: true

                text: "Results"
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                model: imageAnalysisVideoOutput.filter.resultsModel
                clip: true

                delegate: Text {
                    width: ListView.view.width

                    text: "%1: %2 (%3%)".arg(index + 1).arg(model.name).arg(Math.round(model.score * 100))
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    Rectangle {
                        anchors.fill: parent

                        z: -1
                        color: model.color
                    }
                }
            }

            CheckBox {
                Layout.alignment: Qt.AlignHCenter

                text: "Overlay visible"
                checked: analysisFilter.overlay.visible

                Material.accent: drawer.themeColor

                onClicked: {
                    analysisFilter.overlay.visible = checked;
                }
            }

            CheckBox {
                id: debugCheckBox

                Layout.alignment: Qt.AlignHCenter

                Material.accent: drawer.themeColor

                text: "Debug mode"
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
            }
        }
    }

    //--------------------------------------------------------------------------
}
