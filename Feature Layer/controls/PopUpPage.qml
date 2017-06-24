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
        height: 300 * scaleFactor
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

                ListElement { name:"Feature Layer"; url:"../Samples/FeatureLayer.qml";description:"<p>This sample demonstrates how to add a feature layer using a feature service to the map.  \  <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌 </p>" }

                ListElement { name:"Feature Layer Query"; url:"../Samples/FeatureLayerQuery.qml"; description:"<p>Enter part of a USA state name in the text box and select the Find and Select button. The sample uses the text from the text box to query for the state name, and will select the features returned from the query. Also, the map view will pan and zoom to the first feature in the list of selected features.  <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌🍌 </p>"  }

                ListElement { name:"Feature Layer Selection"; url:"../Samples/FeatureLayerSelection.qml";description:"<p> Click or tap on an area of the map where you see features to select features. This will execute an identifyLayer operation on the map view. When the operation completes, the identifyLayerStatusChanged signal emits, and a list of features is returned. Call the selectFeatures method on the feature layer, passing in the list of features. This will select the features and highlight them on the map view.   <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌🍌 </p>" }

                ListElement { name:"Feature Layer Definition Expression"; url:"../Samples/FeatureLayerDefinitionExpression.qml";description:"<p>This sample demonstrates how to limit the features to display on the map using a definition expression. Press the Apply Expression button to select only features requested using a definition expression.  <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌 </p>" }

                ListElement { name:"Feature Layer (Dictionary Renderer)"; url:"../Samples/FeatureLayerDictionaryRenderer.qml";description:"<p>This sample loads a number of point, line, and polygon feature tables from a Runtime geodatabase. For each feature table, a `FeatureLayer` is created, and a `DictionaryRenderer` object is created and applied to the layer. Note that each layer needs its own renderer, though all renderers can share the DictionarySymbolStyle, in which case all layers will use the same symbology specification (MIL-STD-2525D in the case of this sample). Each layer is added to the map, and when all layers are loaded, the map's viewpoint is set to zoom to the full extent of all feature layers.  <br><p></p><a href='http://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest'><span style=' text-decoration: underline; color:#0000ff;'>Resource Level:</span></a>🍌 </p>" }
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




