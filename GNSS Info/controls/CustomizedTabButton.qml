import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

TabButton {
    property alias imageSource: tabButtonImage.source
    property alias imageColor: overLayColor.color
    property alias imageText: iconText.text

    anchors.verticalCenter: parent.verticalCenter

    indicator: Image {
        source: ""
    }

    contentItem: Item {
        id: tab

        ColumnLayout {
            width: parent.width
            height: 43 * scaleFactor
            anchors.centerIn: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 24 * scaleFactor
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: tabButtonImage

                    anchors.fill: parent

                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    smooth: true
                }

                ColorOverlay {
                    id: overLayColor

                    anchors.fill: tabButtonImage
                    source: tabButtonImage
                }
            }

            Item {
                id: spacer

                Layout.preferredHeight: 5 * scaleFactor
            }

            Label {
                id: iconText

                Layout.preferredHeight: 12 * scaleFactor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: spacer.bottom

                font.pixelSize: 10.5 * scaleFactor
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                color: imageColor
            }
        }
    }
}
