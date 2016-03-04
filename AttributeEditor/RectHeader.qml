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


Rectangle {
    id: rectHeader
    width: parent.width
    height: 50*app.scaleFactor
    color: app.info.propertyValue("titleBackgroundColor", "darkblue")
    anchors.top: parent.top
    
    Text {
        id: txtHeader
        text: app.mapTitle
        color: app.headerTextColor
        font.pointSize: 18*app.scaleFactor
        font.family: app.fontSourceSansProReg.name
        anchors.centerIn: parent
    }
    
    Rectangle {
        id: rectClear
        height: parent.height
        width: 35*app.scaleFactor
        color: "transparent"
        anchors {
            right: parent.right
            rightMargin: 15*app.scaleFactor
        }
        
        Text {
            id: txtClear
            text: "Clear(" + queriedFeaturesModel.count + ")"
            color: featureSelected ? app.headerTextColor : "transparent"
            font.bold: featureSelected
            font.pointSize: 14*app.scaleFactor
            font.family: app.fontSourceSansProReg.name
            anchors.centerIn: parent
        }
        
        MouseArea {
            anchors.fill: parent
            
            onClicked: {
                // Clear selection
                featureLayer.clearSelection();
                // Update bool for feature selected
                featureSelected = false
                // Hide features rectangle
                rectFeatures.y = app.height
                //remove popup features
                queriedFeaturesModel.clear();
            }
        }
    }
}
