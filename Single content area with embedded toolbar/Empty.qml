//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "./Components"

App {
    id: app
    width: 800
    height: 640

    property real formWidth: 10
    property real formMaxWidth: app.width * 0.8
    property bool isLandscape : width > height

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        ContentBlock {
            ToolBar {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 10

                }
                RowLayout {
    //                ToolButton {
    //                    text: "Button"
    //                }
                }
            }
        }

    }

}

