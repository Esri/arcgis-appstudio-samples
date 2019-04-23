import QtQuick 2.9
import QtQuick.Controls 2.2

MenuItem {
    id: root

    highlighted: this.enabled && hovered

    property color textColor: colors.black

    contentItem: Text {
        text: root.text

        font {
            family: fonts.avenirNextRegular
            pixelSize: 16 * constants.scaleFactor
        }

        color: textColor
        clip: true
        elide: Text.ElideRight

        horizontalAlignment: appManager.isRTL ? Text.AlignRight : Text.AlignLeft
    }
}
