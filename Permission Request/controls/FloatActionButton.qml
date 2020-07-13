import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

RoundButton {

    property url imageSource: ""
    signal iconClicked()
    property alias colorOverlay: colorOverlay

    Layout.preferredWidth: 45 * scaleFactor
    Layout.preferredHeight: Layout.preferredWidth
    Material.elevation: 6
    Material.background:"#8f499c"

    contentItem: Image {
        id:image
        source:imageSource
        anchors.centerIn: parent
        mipmap: true
    }

    ColorOverlay {
        id: colorOverlay
        anchors.fill: image
        source: image
        //  color: "#4c4c4c"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            iconClicked();
        }
    }
}

