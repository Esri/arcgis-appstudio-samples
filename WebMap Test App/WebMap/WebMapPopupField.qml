import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework.Runtime 1.0
import "WebMap.js" as JS

Column {
    property var fieldInfo
    property var attributes
    property string linkText

    property alias labelFont: fieldLabel.font
    property alias labelColor: fieldLabel.color

    property alias valueFont: fieldValue.font
    property alias valueColor: fieldValue.color

    visible: fieldInfo.visible
    spacing: 2

    Label {
        id: fieldLabel

        width: parent.width
        text: fieldInfo.label
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
        font {
            pointSize: 12
        }
        color: "darkgray"
    }

    Text {
        id: fieldValue

        width: parent.width
        text: visible ? JS.formattedFieldValue(fieldInfo, attributes, { "linkText": linkText }) : ""
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
        font {
            pointSize: 14
        }
        color: "#4c4c4c"
        textFormat: Text.RichText

        onLinkActivated: {
            Qt.openUrlExternally(link);
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: "#efeeef"
    }
}
