import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
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
        height: 290 * scaleFactor
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
        }

        ListView{
            id:popUpListView
            anchors.topMargin: 64 * scaleFactor
            anchors.fill: parent
            model:ListModel {
                id:sampleItems

                ListElement { name:"Identify Graphics"; url:"../Samples/IdentifyGraphics.qml";description:"<p>This sample demonstrates how to identify graphics in a graphics overlay. When you select a graphic on the map, a message box appears.  <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌🍌 </p>" }

                ListElement { name:"Add Graphics With Renderers"; url:"../Samples/AddGraphicsWithRenderers.qml";description:"<p>This sample demonstrates how to add graphics and set renderer on graphic overlays. <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌🍌 </p>" }

                ListElement { name:"Add Graphics With Symbols"; url:"../Samples/AddGraphicsWithSymbols.qml"; description:"<p>This sample demonstrates how to add graphics with symbols to a graphics overlay. <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌🍌 </p>"  }

                ListElement { name:"Graphic Overlay"; url:"../Samples/GraphicOverlay.qml";description:"<p> This sample demonstrates applying a dictionary renderer to graphics to display military symbology. This sample loads a number of point, line, and polygon military elements from an XML file and adds them as graphics to a GraphicsOverlay. A DictionaryRenderer is applied to the GraphicsOverlay in order to display the graphics with MIL-STD-2525D military symbology. When all graphics are created, the map's viewpoint is set to zoom to the full extent of all graphics.   <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌🍌 </p>" }

                ListElement { name:"Graphic Overlay 3D"; url:"../Samples/GraphicOverlay3D.qml";description:"<p>This sample demonstrates applying a dictionary renderer to a graphics overlay in a 3D scene to display military symbology. The sample loads a number of point military elements from an XML file and adds them as graphics to a GraphicsOverlay. A DictionaryRenderer is applied to the GraphicsOverlay in order to display the graphics with MIL-STD-2525D military symbology. <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌🍌 </p>" }

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




