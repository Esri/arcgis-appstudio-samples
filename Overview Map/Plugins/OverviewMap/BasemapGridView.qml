import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15

import Esri.ArcGISRuntime 100.13


GridView {
    id: baseMapGridView

    ListModel {
        id: baseMapStyles
        ListElement {
            name: "Topographic"
            desc: "Topographic Basemap"
            thumbnail: "https://www.arcgis.com/sharing/rest/content/items/dd247558455c4ffab54566901a14f42c/info/thumbnail/thumbnail1607389112065.jpeg?f=json"
            initStyleEnum: 14
        }
        ListElement {
            name: "Imagery"
            desc: "Imagery Basemap"
            thumbnail: "https://www.arcgis.com/sharing/rest/content/items/c7d2b5c334364e8fb5b73b0f4d6a779b/info/thumbnail/thumbnail1607389529861.jpeg?f=json"
            initStyleEnum: 0
        }
        ListElement {
            name: "Navigation"
            desc: "Navigation Basemap"
            thumbnail: "https://www.arcgis.com/sharing/rest/content/items/78c096abedb9498380f5db1922f96aa0/info/thumbnail/thumbnail1607388861033.jpeg?f=json"
            initStyleEnum: 9
        }
        ListElement {
            name: "Dark Gray"
            desc: "Dark Gray Basemap"
            thumbnail: "https://www.arcgis.com/sharing/rest/content/items/7742cd5abef8497288dc81426266df9b/info/thumbnail/thumbnail1607387673856.jpeg?f=json"
            initStyleEnum: 6
        }
    }

    property var baseMap: null
    property int originalIndex: 0

    anchors {
        fill: parent
        leftMargin: 15 * deviceManager.scaleFactor
        topMargin: 25 * deviceManager.scaleFactor
        rightMargin: 15 * deviceManager.scaleFactor
        bottomMargin: 25 * deviceManager.scaleFactor
    }

    cellWidth: deviceManager.isLandscape ? width / 6 : width / 3
    cellHeight: cellWidth
    interactive: false
    model: baseMapStyles
    delegate: ItemDelegate {
        height: cellHeight
        width: cellWidth

        Column {
            anchors.centerIn: parent
            height: parent.height * 0.75
            width: parent.width * 0.75
            spacing: 8

            Rectangle{
                id: imageMask
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: imageBorder.width
                height: imageBorder.height
                radius: 4 * deviceManager.scaleFactor
                visible: false
            }

            Rectangle {
                id: imageBorder
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.75
                height: parent.height * 0.75
                radius: 8 * deviceManager.scaleFactor
                border.color: "#90499C"
                border.width: currentIndex === index ? 5 : 0
                Image {
                    id: basemapImage
                    width: parent.width - (2 * imageBorder.border.width)
                    height: parent.height - (2 * imageBorder.border.width)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    source: thumbnail
                    smooth: true
                    mipmap: true
                    clip: true
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: imageMask
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                width: baseMapGridView.cellWidth * 0.75
                height: width * 0.2
                text: name
            }
        }
        onClicked: {
            baseMapGridView.currentIndex = index
            baseMap = ArcGISRuntimeEnvironment.createObject("Basemap", {
                                                                    initStyle: initStyleEnum
                                                                });
        }
    }
}
