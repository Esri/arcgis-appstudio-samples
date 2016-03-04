// Copyright 2016 ESRI
//
// All rights reserved under the copyright laws of the United States
// Copyright 2015 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the Sample code usage restrictions document for further information.
//
//------------------------------------------------------------------------------

import QtGraphicalEffects 1.0
import QtPositioning 5.3
import QtSensors 5.0
import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0


//------------------------------------------------------------------------------

App {
    id: app
    width: 420
    height: 700

    // App titles and colors
    property string mapTitle: "My Map"
    property color headerBarColor: "#0055ff"
    property color headerTextColor: "#ffffff"
    property color attributeDisplayNameColor: "black"
    property color attributeValueColor: "#697797"
    property color attributeSeparatorColor: "#ABB6CD"
    //  #52bd61

    //property string featureServiceURL : app.info.propertyValue("featureServiceURL","");
    property var objectIdToEdit
    property string addButtonClicked: "no item"
    property var foundFeatureIds: null
    property int hitFeatureId
    property double scaleFactor: AppFramework.displayScaleFactor
    property bool featureAdded
    property bool isMobile: Qt.platform.os === "ios" || Qt.platform.os === "android" ? true : false
    property var fieldsArray

    property string displayField: "objectid"

    // Font
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
