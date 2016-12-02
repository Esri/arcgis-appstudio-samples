import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0
//import ArcGIS.AppFramework.Runtime.Dialogs 1.0
//import ArcGIS.AppFramework.Runtime.WebMap 1.0
import "WebMap"
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app

    width: 700
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor
    property bool isSmallScreen: (app.width || app.height) < 400*scaleFactor
    property bool isPortait: app.height > app.width
    property bool isOnline: AppFramework.isOnline

    //-------------------------------------------------------------------------

    WebMap {
        id: map

        anchors.fill: parent
        wrapAroundEnabled: true

        //webMapId: "cc5cf4c861b347409a3b09b87f8e4656"
        //webMapId: "4778fee6371d4e83a22786029f30c7e1"
        //webMapId: "9a2a8232692943d5a733b05d1ce585a8"
        //webMapId: "0b93a68842f648a1a4f006346a4c931f"
        //webMapId: "de198cb6bda04d94ac6a0ee4bcfbd448"
        //webMapId: "e7ef98e6c0c24b76ba7ad9b8396c6501"
        //webMapId: "99c6098ef355487790f2100aa5fc0908"
        //webMapId: "a9a07b4cb5e344c4bfed1d9e9a09845c"
        //webMapId: "4e8c7d64efc7490da95c57da43fff9fa"
        //webMapId: "dfa1e187310c4c7a897e4c919dd3f781"

        //UniqueValueRenderer
        //Portland Bike Map
        webMapId: "8e42e164d4174da09f61fe0d3f206641"

        //Class break renderer
        //webMapId: "050c25d3964a444dad8ed2a080967b66"

        //webMapId: "6b0f4b1488a146f79ec8ac92aa6beb82"
        //webMapId: "abef9f01d0f94104ad58159019359c38"
        //webMapId: "e62c2eead8eb4c7d92b8cb0680d1540b"

        //bookmarks
        //webMapId: "8047eda3656e4241b75463a5451ba9e2"


        //legneds Not working
        //webMapId: "13397c0cfd56410ba4e3b845f8f0b929"


        onWebMapError: {
            console.log("### WEBMAP Error: ", message)
            alertBox.backgroundColor = "red"
            alertBox.text = message.toString()
            alertBox.visible = true
        }

        northArrow.image {
            source: "images/compass.png"
        }

        mapControls.visible: false

        ZoomButtonsNew {
            z:11

            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 10
            }

            backgroundColor: "transparent"
            borderColor: "transparent"

            homeButton.iconSource: "images/home.png"
            zoomInButton.iconSource: "images/plus.png"
            zoomOutButton.iconSource: "images/minus.png"
            zoomInButton.text: ""
            zoomOutButton.text:""

            map: map
        }


        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            z:11
            color: "white"
            width:  row_footer.childrenRect.width + 10
            height: text_mapScale.contentHeight + 5

            Row {
                id: row_footer
                spacing: 5*app.scaleFactor

                Text {
                    id: text_mapScale
                    anchors.margins: 5
                    text: "Map Scale 1:" + map.niceScale
                    //anchors.centerIn: parent
                }

                Text {
                    visible: !isSmallScreen
                    text: qsTr(" | <a href='http://maps.esri.com/SP_DEMOS/offlinemaps/wysiwyg/?webmap=" + map.webMapId + "'>Web Link</a>");
                    textFormat: Text.StyledText
                    anchors.margins: 5
                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }
                }

                Text {
                    visible: !isSmallScreen
                    text: qsTr(" | <a href='http://www.arcgis.com/sharing/rest/content/items/" + map.webMapId + "/data?f=json'>JSON</a>");
                    textFormat: Text.StyledText
                    anchors.margins: 5
                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }
                }

                Text {
                    text: qsTr(" | <a href='mailto:sprasad@esri.com?subject=Feedback about my WebMap " + map.webMapId + "'>Send Feedback</a>")
                    textFormat: Text.StyledText
                    anchors.margins: 5
                    onLinkActivated: {
                        Qt.openUrlExternally(link);
                    }
                }

                Text {
                    text: qsTr(" | <a href='#'>Help</a>")
                    textFormat: Text.StyledText
                    anchors.margins: 5
                    onLinkActivated: {
                        alertBox.height = 400
                        alertBox.text = "Use this app to test your webmaps and report any issues using the <i>Send Feedback</i> link. <br><br>If you have webmapid paste it in the text box or alternatively you can use the <i>Web Map Picker</i> button to select a webmap to test.";
                        alertBox.visible = true;
                    }
                }

            }
        }


    }
    //-------------------------------------------



    Connections {
        target: button_layers
        onClicked: {
            if(table_layers.visible) {
                table_layers.visible = false;
                return;
            }

            layersModel.clear();

            var count = 0, layer = null, attr = {};
            for (var layerIndex = map.layerCount-1; layerIndex>=0; layerIndex--) {
                layer = map.layerByIndex(layerIndex);
                count++;
                attr = {};
                attr.index =  count;
                attr.layerid = layer.layerId.toString();
                attr.name = layer.layerTitle || layer.name;
                attr.type = layer.layerType;
                attr.visible = layer.visible;
                attr.minscale = layer.minScale.toString();
                attr.maxscale = layer.maxScale.toString();

                layersModel.append(attr)
            }

            table_layers.visible = true
        }
    }

    ListModel {
        id: layersModel
    }

    TableView {
        id: table_layers
        visible: false
        width: parent.width-50
        height: parent.height-100
        anchors.centerIn: parent
        z:12

        TableViewColumn {
            role: "index"
            title: "#"
            width: 50
        }
        TableViewColumn {
            role: "layerid"
            title: "ID"
            width: 100
        }
        TableViewColumn {
            role: "name"
            title: "Name"
            width: 300
        }
        TableViewColumn {
            role: "type"
            title: "Type"
            width: 60
        }
        TableViewColumn {
            role: "visible"
            title: "Visible"
            width: 60
        }
        TableViewColumn {
            role: "minscale"
            title: "Min Scale"
            width: 80
        }
        TableViewColumn {
            role: "maxscale"
            title: "Max Scale"
            width: 80
        }
        model: layersModel
    }
    //---------------------------------------------

    Row {
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 5*app.scaleFactor
        z:11

        Button {
            text: "Web Map Picker"

            onClicked: {
                portalItemsDialog.visible = true;
            }
        }

        Button {
            id: button_layers
            visible: !isSmallScreen
            z:11
            text: "Layers"
        }

        Button {
            id: button_bookmarks
            z:11
            visible: map.bookmarksModel.count
            text: "Bookmarks"
            onClicked: {
                bookmarksContainer.visible = !bookmarksContainer.visible
                if(bookmarksContainer.visible) {
                    map.updateBookmarksModel();
                    bookmarksView.model = map.bookmarksModel
                }
            }
        }

        Button {
            id: button_legend
            text: "Legend"
            //anchors.margins: 5
            z:11
            onClicked: {
                legendContainer.visible = !legendContainer.visible
                if(legendContainer.visible) {
                    map.updateLegendModel();
                }
            }
        }
    }

    //-------------------------------------------

    Rectangle {
        id: bookmarksContainer

        anchors {
            verticalCenter: parent.verticalCenter
            left: map.left
        }

        visible: false

        width: 200*scaleFactor
        height: map.height*0.5
        color: "white"

        BookmarksView {
            id:bookmarksView
            webMap: map
            model: map.bookmarksModel
            anchors.fill: parent
        }
    }




    //--------------------------------------------

    Rectangle {
        id: legendContainer
        visible: false

        anchors {
            verticalCenter: parent.verticalCenter
            left: map.left
        }

        width: 250*scaleFactor
        height: map.height*0.8
        color: "white"

        LegendView {
            id: legendView            
            anchors.margins: 5
            map: map
            model: map.legendModel
        }
    }
    //-------------------------------------------------------------------------

    Row {
        width: parent.width
        spacing: 10

        TextField {
            visible: !isSmallScreen
            width: 400
            anchors.topMargin: 10
            text: map.webMapId
            placeholderText: "Enter WebMap ID"
            onEditingFinished: {
                map.webMapId = text;
                legendContainer.visible = false;
            }
            font {
                pointSize: 14
            }
        }
    }
    //----------------------------------------------------

    AlertBox {
        id: alertBox
        visible: false
        z:111
    }


    //-----------------------------------------------------
    PortalItemsDialog {
        id: portalItemsDialog

        title: "Web Map Picker"
        width: app.width * 0.9
        height: app.height * 0.9

        portal: Portal {

            onError: {
                alertBox.text = error.toString()
                alertBox.visible = true
            }
        }

        query: 'type: "Web Map" -type: "web mapping application" -tags:"basemap"'

        onAccepted: {
            legendContainer.visible = false;
            if(itemInfo.itemId)
                map.webMapId = itemInfo.itemId;
        }
    }

    //-------------------------------------------------------------------------
}

