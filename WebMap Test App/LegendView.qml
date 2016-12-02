import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0


ListView {
    id: legendView

    property Map map

    property ListModel legendModel

    model: legendModel

    anchors.fill: parent

    spacing: 3
    clip: true
    
    section {
        property: "layerName"
        criteria: ViewSection.FullString
        delegate: legendSectionDelegate
        labelPositioning: ViewSection.InlineLabels
    }

    Text {
        text: "No Legend Available"
        font.italic: true
        anchors.centerIn: parent
        font.pointSize: 15
        visible: model.count === 0
    }

    delegate: legendItemDelegate

    //--------------------------------------------------------------------------

    Component {
        id: legendSectionDelegate

        Item {
            width: parent.width
            height: textControl.height

            Text {
                id: textControl

                anchors.verticalCenter: parent.verticalCenter
                text: section
                width: parent.width
                font {
                    pointSize: 12
                    bold: true
                }
                color: "#4c4c4c"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: legendItemDelegate

        Item {
            width: parent.width
            height: Math.max(legendImage.height, legendText.height)

            Rectangle {
                id: legendImageContainer
                width: 30*AppFramework.displayScaleFactor
                height: width
                color: "#FDFDFD"
                anchors {
                    left: parent.left
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }

                Image {
                    id: legendImage
                    anchors.centerIn: parent
                    source: image
                    height: (imageHeight && imageHeight > -1 ? imageHeight : 30) * AppFramework.displayScaleFactor
                    width: imageWidth && imageWidth > -1 ? imageWidth * AppFramework.displayScaleFactor : height
                    fillMode: Image.PreserveAspectFit
                }
            }

            Text {
                id: legendText

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: legendImageContainer.right
                    leftMargin: 4
                    right: parent.right
                }

                text: label
                color: "#4c4c4c"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font {
                    pointSize: 12
                }
            }
        }
    }
}
