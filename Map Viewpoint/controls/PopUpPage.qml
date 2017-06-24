import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Rectangle {
    id:popUp
    anchors.fill: parent
    color: "#80000000"

    MouseArea {
        anchors.fill: parent
        onClicked: {
            mouse.accepted = false
        }
    }

    Rectangle {
        id:popUpWindow
        height: 270 * scaleFactor
        width: 280 * scaleFactor
        anchors.centerIn: parent
        radius: 3 * scaleFactor
        Material.background:  "#FAFAFA"
        Material.elevation:24

        Text {
            id: titleText
            text: qsTr("Choose a sample")
            font{
                pixelSize:app.baseFontSize
                bold:true
            }
            padding: 24 * scaleFactor
            anchors.top:parent.top
            anchors.bottom:popUpListView.top
            anchors.topMargin: 2* scaleFactor
            anchors.bottomMargin: 2 * scaleFactor
        }

        ListView{
            id:popUpListView
            anchors.topMargin: 68 * scaleFactor
            anchors.fill: parent
            model:ListModel {
                id:sampleItems
                ListElement {name:"Set Initial Map Location"; url:"../Samples/SetInitialMapLocation.qml";description:"<p> This sample demonstrates how to create a map with a basemap, centered at a specific location and scale. This is one of the most basic samples for the ArcGIS Runtime SDK for Qt. It shows how to construct a map by passing in a basemap type, a latitude and longitude, and a scale.  <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌 </p>" }
                ListElement {name:"Set Initial Map Area"; url:"../Samples/SetInitialMapArea.qml"; description:"<p>This sample demonstrates how to create a map with a predefined initial extent. A ViewpointExtent is declared with an Envelope, and is applied to the map by setting this value to the map's initialViewpoint property. <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌 </p>"  }
                ListElement {name:"Change Viewpoint"; url:"../Samples/ChangeViewpoint.qml";description:"<p>This sample demonstrates how to change the viewpoint of a map. The map view has several methods for setting its current viewpoint. Select a viewpoint from the UI to see the viewpoint changed using one of these methods. <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌 </p>" }
                ListElement {name:"Manage Bookmarks"; url:"../Samples/ManageBookmarks.qml";description:"<p>This sample demonstrates how to access and add bookmarks to a map. When the sample starts, the map contains a set of bookmarks. You can select a bookmark from the list, which changes the map's viewpoint. To create a new bookmark, pan and zoom to a new location and select the + button. A prompt appears to let you provide a name for the new bookmark. When you select Done the new bookmark is added to the bookmark list.  <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌🍌 </p>" }
            }
            onCurrentIndexChanged: {
                qmlfile = sampleItems.get(currentIndex).url
                sampleName = sampleItems.get(currentIndex).name
                descriptionText =sampleItems.get(currentIndex).description
            }
            delegate: Rectangle{
                width:280 * scaleFactor
                height: 40 * scaleFactor
                color: index===popUpListView.currentIndex? "#808c499c":"transparent"

                Label{
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 24 * scaleFactor
                    font {
                        pixelSize: app.baseFontSize * 0.8
                    }
                    text:name
                }

                MouseArea{
                    anchors.fill:parent
                    onClicked: {
                        popUp.visible = 0
                        popUpListView.currentIndex = index
                        qmlfile = sampleItems.get(index).url
                        sampleName = sampleItems.get(index).name
                        descriptionText =sampleItems.get(index).description
                    }
                }
            }

            Text{
                id:cancelText
                anchors.bottom: parent.bottom
                anchors.right:parent.right
                anchors.bottomMargin: 13 * scaleFactor
                anchors.rightMargin: 16 * scaleFactor
                text:qsTr("CANCEL")
                color:"#8f499c"
                font{
                    pixelSize: baseFontSize * 0.9
                    bold:true
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked :{
                        popUp.visible = 0
                    }
                }
            }
        }
    }

    DropShadow {
        id: headerbarShadow
        source: popUpWindow
        anchors.fill: popUpWindow
        width: source.width
        height: source.height
        cached: true
        radius: 8.0
        samples: 17
        color: "#80000000"
        smooth: true
    }
}




