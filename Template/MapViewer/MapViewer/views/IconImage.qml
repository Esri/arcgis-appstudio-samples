import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

import "../controls"


Item {
    property alias source: image.source
    property alias color: imageColorOverLay.color

    Image {
        id: image
        source:"../images/appstudio.png"
        anchors.fill: parent
        mipmap: true
        asynchronous: true
    }

    ColorOverlay {
        id: imageColorOverLay

        anchors.fill: image
        source: image
    }
}

