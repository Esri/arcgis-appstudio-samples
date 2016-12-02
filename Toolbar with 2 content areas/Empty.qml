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
        ToolBar {
            id: toolbar
            Layout.fillWidth: true
            RowLayout {
                //                ToolButton {
                //                    text: "Button"
                //                }
            }
        }

        GridLayout {
            id: grid
            Layout.fillHeight: true
            Layout.fillWidth: true
            columns: app.isLandscape ? children.length : 1
            rows: app.isLandscape ? 1 : children.length

            ContentBlock {

            }
            ContentBlock {

            }
        }
    }
}

