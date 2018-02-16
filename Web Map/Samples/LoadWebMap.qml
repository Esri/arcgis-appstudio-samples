import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2


Item {
    property real scaleFactor: AppFramework.displayScaleFactor


    // create MapView
    MapView {
        id:mapView
        anchors.fill: parent

        //Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
        }
    }
    // create combo box to populate webmaps
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        ComboBox {
            id:combobox
            anchors.left:  parent.left
            anchors.top:  parent.top
            anchors.margins: 10 * scaleFactor
            width: 200 * scaleFactor
            height: 30 * scaleFactor
            clip:true
            Material.accent:"#8f499c"
            background: Rectangle {
                anchors.fill: parent
                radius: 6 * scaleFactor
                border.color: "darkgrey"
                width: 200 * scaleFactor
                height: 30 * scaleFactor
            }
            textRole:"name"
            model: ListModel {

                id: cbItems
                ListElement { name: "USA States and Cities"; item: "8ccfcc3a83d241ce9765ff4aea459617" }
                ListElement { name: "San Francisco"; item: "358e6f9bebf544699b005f066886579c" }
                ListElement { name: "OpenstreetMap"; item: "0d22c9bc992f4f218605d6edb042ff89" }

            }

            onCurrentIndexChanged: {
                //console.debug(cbItems.get(currentIndex).text + ", " + cbItems.get(currentIndex).item)
                loadWebMap(cbItems.get(currentIndex).item)
            }
            Component.onCompleted: {
                loadWebMap(cbItems.get(currentIndex).item)

            }
        }
    }

    // Javascript Functions
    // Function to load webmap
    function loadWebMap(webmapitemid){
        //! [Construct map from a webmap url]
        // construct the webmap Url using the itemId
        var organizationPortalUrl = "http://arcgis.com/sharing/rest/content/items/";
        var webmapUrl = organizationPortalUrl + webmapitemid;
        // Create a new map and assign it the initUrl
        var newMap = ArcGISRuntimeEnvironment.createObject("Map", {initUrl: webmapUrl, autoFetchLegendInfos:true});
        // Set the map to the MapView
        mapView.map = newMap;
    }
}

