import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework.Runtime 1.0
import "WebMap.js" as JS

Column {
    property var mediaInfo
    property var attributes

    spacing: 5

    Text {
        width: parent.width
        text: JS.replaceVariables(mediaInfo.title, attributes)
        wrapMode: Text.Wrap
        font {
            pointSize: 14
            bold: true
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: "darkgrey"
    }

    Text {
        width: parent.width
        text: JS.replaceVariables(mediaInfo.caption, attributes)
        wrapMode: Text.Wrap
        font {
            pointSize: 12
            italic: true
            bold: false
        }
    }

    Image {
        width: parent.width
        visible: mediaInfo.type === "image"
        source: JS.replaceVariables(mediaInfo.value.sourceURL, attributes)
        fillMode: Image.PreserveAspectFit

        MouseArea {
            anchors.fill: parent
            onClicked: {
                Qt.openUrlExternally(JS.replaceVariables(mediaInfo.value.linkURL, attributes));
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: "#efeeef"
    }
}
