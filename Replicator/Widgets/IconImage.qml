import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    property alias source: image.source
    property alias color: imageColorOverLay.color

    Image {
        id: image
        anchors.fill: parent
        source: sources.profileCameraImageSource
        fillMode: Image.PreserveAspectFit
        mipmap: true
    }
    
    ColorOverlay {
        id: imageColorOverLay
        anchors.fill: image
        source: image
    }
}
