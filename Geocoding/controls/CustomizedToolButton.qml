import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

ToolButton {
    property url imageSource: ""
    indicator: Image{
        width: parent.width*0.5
        height: parent.height*0.5
        anchors.centerIn: parent
        source: imageSource
        fillMode: Image.PreserveAspectFit
        mipmap: true
    }
}
