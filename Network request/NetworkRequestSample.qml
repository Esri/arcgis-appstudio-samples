//------------------------------------------------------------------------------
// NetworkRequestSample.qml
// Created 2015-06-15 13:10:39
//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

App {
    id: app
    width: 800
    height: 600

    property real displayScaleFactor: AppFramework.displayScaleFactor

    TabView{
        anchors {
            margins: 10
            fill: parent
        }
        Sample1 {
            anchors.fill: parent
        }
        Sample2 {
            anchors.fill: parent
        }
        Sample3 {
            anchors.fill: parent
        }
        Sample4 {
            anchors.fill: parent
        }
    }
}

