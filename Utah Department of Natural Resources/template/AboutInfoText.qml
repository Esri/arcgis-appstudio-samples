import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Column {
    property alias headingText: separatorText.text
    property alias text: textControl.text
    property bool html: false

    width: parent.width

    spacing: 5

    SeparatorText {
        id: separatorText

        visible: textControl.visible
    }


    Text {
        id: textControl

        width: parent.width
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        elide: Text.ElideRight
        visible: text > ""
        font {
            pointSize: 16
        }
        textFormat: html ? Text.RichText : Text.AutoText

        onLinkActivated: {
            Qt.openUrlExternally(link);
        }
    }
}
