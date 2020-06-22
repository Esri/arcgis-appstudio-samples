import QtQuick 2.7

import "../controls" as Controls

Rectangle {
    id: mapunitsLabel
    
    property string text: ""
    property string textColor: "#FFFFFF"
    
    height: textObject.height + 2 * textObject.padding
    width: Math.min(textObject.width + 8 * textObject.padding, app.width - app.defaultMargin)
    color: "#66000000"
    radius: app.units(1)
    
    Controls.BaseText {
        id: textObject
        
        text: mapunitsLabel.text
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent
        elide: Text.ElideRight
        padding: app.units(4)
        color: textColor
    }
}
