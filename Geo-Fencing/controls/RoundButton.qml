import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

RoundButton{
    property url imageSource: ""
    property alias imageColor: colorOverlay.color
    Material.background: "#ffffff"
    padding: 0
    contentItem: Image {
        id: image
        source: imageSource
        opacity: 0.4
        anchors {
            fill: parent
            margins: 10*app.scaleFactor
        }
        mipmap: true
    }
    ColorOverlay{
        id: colorOverlay
        anchors.fill: image
        source: image
        color: "#4c4c4c"
    }
}
