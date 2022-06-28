import QtQuick 2.7
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1
import QtQuick.Controls.Styles 1.4

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.13


Page {
    id:fullPageSetting
    property bool overviewMapUnlocked: false
    property bool originalMapLock: false
    property bool changesMade: false

    signal closeSettingsPage()

    height: deviceManager.isCompact ? parent.height : parent.height * 0.65
    width: deviceManager.isCompact ? parent.width : parent.width * 0.55
    anchors.centerIn: parent

    header: Rectangle {
        id:header
        width: parent.width
        height: 50 * deviceManager.scaleFactor
        color: "#f3f3f4"
        RowLayout{
            anchors.fill: parent
            spacing:0
            clip:true

            Rectangle{
                Layout.alignment: Qt.AlignLeft
                Layout.preferredWidth: 60 * deviceManager.scaleFactor
                ToolButton {
                    id:clearButton
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    indicator: Image{
                        id: clearImage
                        height: 25
                        width: 25
                        anchors.centerIn: parent
                        source: "./Assets/Images/clear.png"
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: clearImage
                        source: clearImage
                        color: "#707070"
                    }
                    onClicked: {
                        overviewMapUnlocked = originalMapLock
                        overviewMapRepositionSwitch.checked = originalMapLock
                        basemapGridView.currentIndex = basemapGridView.originalIndex
                        closeSettingsPage()
                    }
                }
            }


            Text {
                text: "Overview Map Setting"
                color: "black"
                font.pixelSize: deviceManager.baseFontSize * 1.2
                font.bold: true
                maximumLineCount:2
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignCenter
            }

            Text{
                id:cancelText
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 60 * deviceManager.scaleFactor
                text: qsTr("Apply")
                color: changesMade ? "#1363DF" : "#707070"
                font{
                    pixelSize: deviceManager.baseFontSize * 0.9
                    bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    visible: changesMade
                    onClicked :{
                        changesMade = false
                        originalMapLock = overviewMapUnlocked
                        overviewMapRepositionSwitch.checked = overviewMapUnlocked
                        basemapGridView.originalIndex = basemapGridView.currentIndex
                        overviewMapBorder.map.basemap = basemapGridView.baseMap
                        closeSettingsPage()
                    }
                }
            }
        }
    }

    Rectangle {
        id:popUpWindow
        height: parent.height
        width: parent.width
        color: "#f3f3f4"
        Column {
            id: menuList
            height: parent.height
            width: parent.width
            spacing: 10
            Text {
                leftPadding: parent.width * 0.025 * deviceManager.scaleFactor
                bottomPadding: 10 * deviceManager.scaleFactor
                text: qsTr("SELECT BASEMAP STYLE")
                font.pixelSize: deviceManager.baseFontSize
                font.bold: true
            }

            //Display Basemap
            Rectangle {
                height: deviceManager.isLandscape ? basemapGridView.cellHeight * (Math.ceil(basemapGridView.count / 6)) + 50 * deviceManager.scaleFactor : basemapGridView.cellHeight * (Math.ceil(basemapGridView.count / 3)) + 50 * deviceManager.scaleFactor
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                color: "white"
                BasemapGridView{
                    id: basemapGridView
                    onCurrentIndexChanged: {
                        if(currentIndex !== basemapGridView.originalIndex || originalMapLock !== overviewMapRepositionSwitch.checked){
                            changesMade = true
                        } else {
                            changesMade = false
                        }
                    }
                }

            }
            Text {
                topPadding: 10 * deviceManager.scaleFactor
                leftPadding: parent.width * 0.025 * deviceManager.scaleFactor
                text: qsTr("ALLOW REPOSITIONING")
                font.pixelSize: deviceManager.baseFontSize
                font.bold: true

            }
            Rectangle {
                height: 50 * deviceManager.scaleFactor
                width: parent.width
                Layout.fillWidth: true
                color: "white"
                RowLayout {
                    height: 50 * deviceManager.scaleFactor
                    width: parent.width
                    Layout.fillWidth: true
                    Text {
                        leftPadding: parent.width * 0.075 * deviceManager.scaleFactor
                        text: "Drag to move"
                    }

                    Switch {
                        id: overviewMapRepositionSwitch
                        Layout.alignment: Qt.AlignRight
                        rightPadding: parent.width * 0.075 * deviceManager.scaleFactor

                        indicator: Rectangle {
                            id: switchArea
                            implicitWidth: 48 * deviceManager.scaleFactor
                            implicitHeight: 20 * deviceManager.scaleFactor
                            x: overviewMapRepositionSwitch.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 13 * deviceManager.scaleFactor
                            color: overviewMapRepositionSwitch.checked ? "#90499C" : "#BFBFBF"
                            opacity: 0.5
                        }
                        Item{
                            id: knobContainer
                            width: switchKnob.width + (4 * knobShadow.radius)
                            height: switchKnob.height + (2 * knobShadow.radius)
                            visible: false
                            Rectangle {
                                id: switchKnob
                                x: (overviewMapRepositionSwitch.checked ? switchArea.width - width : 0) + switchArea.x
                                y: switchArea.y / 2
                                width: 26 * deviceManager.scaleFactor
                                height: 26 * deviceManager.scaleFactor
                                radius: 13 * deviceManager.scaleFactor
                                antialiasing: true
                                color: overviewMapRepositionSwitch.checked ? "#90499C" : "#EAEAEA"
                                opacity: 1
                            }
                        }
                        DropShadow {
                            id: knobShadow
                            anchors.fill: source
                            cached: true
                            horizontalOffset: 0
                            verticalOffset: 0
                            radius: 8
                            samples: 16
                            color: "#80000000"
                            smooth: true
                            source: knobContainer
                        }
                        contentItem: Text {
                            text: overviewMapRepositionSwitch.text
                            font: overviewMapRepositionSwitch.font
                            opacity: enabled ? 1.0 : 0.3
                            color: overviewMapRepositionSwitch.down ? "#90499C" : "#21be2b"
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: overviewMapRepositionSwitch.indicator.width + overviewMapRepositionSwitch.spacing
                        }
                        onCheckedChanged: {
                            if(basemapGridView.currentIndex !== basemapGridView.originalIndex || originalMapLock !== checked){
                                changesMade = true
                            } else {
                                changesMade = false
                            }
                            overviewMapUnlocked = overviewMapRepositionSwitch.checked
                        }
                    }
                }
            }
        }
    }
}




