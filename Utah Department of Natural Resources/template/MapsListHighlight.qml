import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

Rectangle {
    id: rectangle

    width: parent.width
    height: 150 * AppFramework.displayScaleFactor

    color: "#2000b2ff"
    radius: 4
    
    y: rectangle.ListView.view ? rectangle.ListView.view.currentItem.y : 0
    
    Behavior on y {
        SpringAnimation {
            spring: 3
            damping: 0.2
        }
    }
}
