import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import QtGraphicalEffects 1.0

TabButton {
    id: root

    anchors.verticalCenter: parent.verticalCenter

    property alias imageSource: tabImage.source

    property color imageColor: colors.white

    contentItem: Item {
        Image {
            id: tabImage

            width: 24 * constants.scaleFactor
            height: this.width
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }

        ColorOverlay {
            anchors.fill: tabImage
            source: tabImage
            color: imageColor
        }
    }
}
