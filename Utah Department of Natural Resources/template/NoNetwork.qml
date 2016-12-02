import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0

Rectangle {
    anchors.fill: parent
    
    visible: !AppFramework.network.isOnline
    
    color: "#80ffffff"
    
    Image {
        anchors {
            centerIn: parent
        }
        
        width: 100 * AppFramework.displayScaleFactor
        height:width
        source: "images/networkOffline.png"
    }
    
    MouseArea {
        anchors.fill: parent
        
        onClicked: {
            
        }

        onDoubleClicked: {

        }

        onWheel: {

        }
    }
}
