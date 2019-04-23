import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    anchors.centerIn: parent

    property alias source: image.source
    property alias color: imageColorOverLay.color
    property alias status: image.status

    Image {
        id: image

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        mipmap: true
    }

    ColorOverlay {
        id: imageColorOverLay

        anchors.fill: image
        source: image
    }
}
