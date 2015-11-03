//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

//------------------------------------------------------------------------------

App {
    id: app
    width: 640
    height: 480

    // Scale factor
    property double scaleFactor : AppFramework.displayScaleFactor

    // Custom Font
    property alias fontSourceSansProReg : fontSourceSansProReg
    FontLoader {
        id: fontSourceSansProReg
        source: app.folder.fileUrl("assets/fonts/SourceSansPro-Regular.ttf")
    }


    StackView {
        id: stackView
        width: app.width
        height: app.height
        initialItem: mapPage
    }

    Component {
        id: mapPage

        MapPage {}

    }
}

//------------------------------------------------------------------------------
