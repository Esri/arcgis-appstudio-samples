import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "../Widgets"

RippleView {
    signal isClicked

    onClicked: {
        isClicked();
    }

    Rectangle{
        width: parent.width
        height: 1
        color: "#19000000"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }
}
