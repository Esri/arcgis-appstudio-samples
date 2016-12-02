import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0


Rectangle {
    id: separatorText

    property var text

    width: parent.width
    height: textControl.height + 4
    
    color: "#e5e6e7"
    
    Text {
        id: textControl

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        text: separatorText.text
        color: "#4c4c4c"
        font {
            pointSize: 20
        }
    }
}
