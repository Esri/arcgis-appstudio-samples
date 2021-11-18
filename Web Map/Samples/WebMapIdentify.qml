
import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10

import "../controls" as Controls

Item {
    property real scaleFactor: AppFramework.displayScaleFactor
    property bool ready: mapView.map.loadStatus === Enums.LoadStatusLoaded
    property var selectedFeature: null
    property var popupDef:null
    property string popupTitle
    property real curIndx: -1


    ListModel{
        id:popupListModel
    }

    // create MapView
    MapView {
        id:mapView
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: statusBar.top
        }

        // Make Drawing Window visible if map is drawing. Not visible if drawing completed
        onDrawStatusChanged: {
            drawStatus === Enums.DrawStatusInProgress ? mapDrawingWindow.visible = true : mapDrawingWindow.visible = false;
        }

        GraphicsOverlay{
            id:polygonGraphicsOverlay

        }
        GraphicsOverlay{
            id:pointGraphicsOverlay

        }

        Map{
            initUrl: "http://arcgis.com/sharing/rest/content/items/8ccfcc3a83d241ce9765ff4aea459617"
            onLoadErrorChanged:{
                console.log(mapView.map.loadError.additionalMessage)
            }
        }

        SimpleFillSymbol {
            id: simpleFillSymbol
            color: "red"
            style: Enums.SimpleFillSymbolStyleSolid

            //set the outline
            SimpleLineSymbol {
                style: Enums.SimpleLineSymbolStyleSolid
                color: "black"
                width: 2.0
            }
        }

        // Signal handler for mouse click event on the map view
        onMouseClicked: {
            if(!ready) return;
            var tolerance = 10;
            var returnPopupsOnly = true;
            var maximumResults = 2;
            mapView.identifyLayersWithMaxResults(mouse.x, mouse.y, tolerance, returnPopupsOnly, maximumResults);

        }
        // Signal handler for identify
        onIdentifyLayersStatusChanged: {
            if (identifyLayersStatus === Enums.TaskStatusCompleted) {

                pointGraphicsOverlay.graphics.clear()
                polygonGraphicsOverlay.graphics.clear()
                popupListModel.clear()
                // No results found
                if(identifyLayersResults.length === 0) return;
                // Going through individual Layer results list
                // individual layer result can be from a FeatureLayer or MapServiceLayer

                for(var k = 0; k < identifyLayersResults.length ; k++){
                    var identifyLayerResult = identifyLayersResults[k];
                    if(identifyLayerResult.sublayerResults && identifyLayerResult.sublayerResults.length > 0){
                        // Results are from Map Service Layer
                        for(var i = 0; i < identifyLayerResult.sublayerResults.length; i++){
                            var subLayerResult = identifyLayerResult.sublayerResults[i];
                            // iterate through individual features of the sub layer results
                            for(var j = 0; j < subLayerResult.popups.length; j++){
                                var popup = subLayerResult.popups[j];
                                selectedFeature = popup.geoElement;
                                popupDef = popup.popupDefinition;
                                // Appending the result to the model
                                var newPopup = ArcGISRuntimeEnvironment.createObject("Popup", {
                                                                                         initGeoElement: selectedFeature,
                                                                                         initPopupDefinition: popupDef
                                                                                     });
                                // create a popup manager
                                var  newPopupManager = ArcGISRuntimeEnvironment.createObject("PopupManager", {popup: newPopup});
                                popupListModel.append({'popupManager': newPopupManager})
                            }
                        }
                    }else{
                        // Results are from Feature Layer
                        // iterate through individual features of the feature Layer results
                        for(var f = 0; f < identifyLayerResult.popups.length; f++){
                            popup = identifyLayerResult.popups[f];
                            selectedFeature = popup.geoElement;
                            popupDef = popup.popupDefinition;
                            // Appending the result to the model
                            newPopup = ArcGISRuntimeEnvironment.createObject("Popup", {
                                                                                 initGeoElement: selectedFeature,
                                                                                 initPopupDefinition: popupDef
                                                                             });

                            // create a popup manager
                            newPopupManager = ArcGISRuntimeEnvironment.createObject("PopupManager", {popup: newPopup});
                            popupListModel.append({'popupManager': newPopupManager});
                        }
                    }

                }


            } else if (identifyLayersStatus === Enums.TaskStatusErrored) {
                console.log(errorString);
            }
        }
    }

    // pop up to show if MapView is drawing
    Rectangle {
        id:mapDrawingWindow
        anchors.centerIn: parent
        width: 100 * scaleFactor
        height: 100 * scaleFactor
        radius: 3
        opacity: 0.85
        color: "#E0E0E0"
        border.color: "black"

        Column {
            anchors.centerIn: parent
            topPadding: 5 * scaleFactor
            spacing: 5 * scaleFactor

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                height: 60 * scaleFactor
                running: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font {
                    weight: Font.Black
                    pixelSize: 12 * scaleFactor
                }
                height: 20 * scaleFactor
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
                text: "Drawing..."
            }
        }
    }

    // Neatline rectangle
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }



    Pane {
        id: popupAsDialog
        Material.primary: "white"
        Material.elevation: 2
        padding: 5 * scaleFactor
        visible: popupListModel.count > 0
        contentWidth: swipeView.implicitWidth
        contentHeight: swipeView.implicitHeight

        x: 10 * scaleFactor
        y: 10 * scaleFactor
        SwipeView{
            id:swipeView
            implicitHeight: 165 * scaleFactor
            implicitWidth: 175 * scaleFactor
            clip: true
            Repeater {
                id: popupViewDialog
                model:popupListModel
                Rectangle{
                    color: "white"
                    clip: true
                    Flickable {
                        anchors.fill:parent
                        contentWidth:parent.width
                        contentHeight: popupColumn.height
                        clip: true
                        flickableDirection: Flickable.VerticalFlick
                        ColumnLayout {
                            id: popupColumn
                            width: parent.width *  0.95
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 3 * scaleFactor
                            clip: true
                            Text {
                                Layout.preferredWidth:  parent.width
                                id:itemDesc
                                text: popupManager.popup.title
                                elide: Text.ElideRight
                                color: "red"
                                font {
                                    family: "serif"
                                    pixelSize: 14 * scaleFactor
                                    bold: true
                                }
                                renderType: Text.NativeRendering
                            }
                            Rectangle {
                                Layout.preferredWidth: parent.width
                                Layout.preferredHeight: 2 * scaleFactor
                                color: "black"
                            }
                            Repeater {
                                model: popupManager.displayedFields
                                RowLayout {
                                    Layout.fillWidth: true
                                    clip: true
                                    spacing: 5 * scaleFactor
                                    visible: attributeVisible

                                    Text {
                                        Layout.preferredWidth: popupColumn.width * 0.55
                                        Layout.fillHeight: true
                                        text:  label ? label : ""
                                        wrapMode: Text.WrapAnywhere
                                        font.pixelSize: 12 * scaleFactor
                                        color: "gray"
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        text:formattedValue? formattedValue: popupManager.popup.geoElement.attributes.attributeValue(label)
                                        wrapMode: Text.WrapAnywhere
                                        font.pixelSize: 12 * scaleFactor
                                        color: "#4f4f4f"

                                    }
                                }
                            }
                        }
                    }
                }
            }

            onCurrentIndexChanged: {
                //console.log("currentIndex",currentIndex, popupListModel.count)
                if(currentIndex < 0)return;

                if(popupListModel.count > 0){
                    var feat = popupListModel.get(currentIndex).popupManager.popup.geoElement;
                    pointGraphicsOverlay.graphics.clear()
                    polygonGraphicsOverlay.graphics.clear()

                    if(feat.geometry.geometryType === Enums.GeometryTypePoint ){
                        var simpleMarker = ArcGISRuntimeEnvironment.createObject("SimpleMarkerSymbol", {color: "cyan", size: 10, style: Enums.SimpleMarkerSymbolStyleCircle});
                        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {symbol: simpleMarker, geometry: feat.geometry});
                        // add the graphic to the graphics overlay
                        pointGraphicsOverlay.graphics.append(graphic);
                        mapView.setViewpointCenterAndScale(pointGraphicsOverlay.extent.center, 10000000 * scaleFactor)
                    }else{
                        graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {symbol: simpleFillSymbol, geometry: feat.geometry});
                        polygonGraphicsOverlay.graphics.append(graphic);
                        mapView.setViewpointGeometryAndPadding(polygonGraphicsOverlay.extent, 100 * scaleFactor)
                    }
                    curIndx = currentIndex + 1
                }

            }
        }

        //Displays page # of page count and buttons to change
        Rectangle{
            width: parent.width * 0.75
            color:"transparent"
            anchors  {
                horizontalCenter : parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 8 * scaleFactor
            }
            Controls.Icon {
                id: previousPage
                Material.elevation: 0
                maskColor: "#4c4c4c"
                enabled: swipeView.currentIndex >= 1
                rotation: app.isLeftToRight ? 90 : -90
                imageSource: "../assets/chevron-up.png"
                anchors.left : parent.left
                anchors.verticalCenter: countText.verticalCenter
                onClicked: {
                    swipeView.currentIndex--
                }
            }

            Controls.BaseText {
                id: countText
                text: qsTr("%1 of %2").arg(swipeView.currentIndex + 1).arg(swipeView.count)
                elide: Text.ElideRight
                maximumLineCount: 1
                verticalAlignment: Text.AlignVCenter
                anchors.centerIn: parent
                anchors.bottom: parent.bottom
            }

            Controls.Icon {
                id: nextPage
                Material.elevation: 0
                maskColor: "#4c4c4c"
                enabled: swipeView.currentIndex + 1 < swipeView.count
                rotation: app.isLeftToRight ? -90 : 90
                imageSource: "../assets/chevron-up.png"
                anchors.right:parent.right
                anchors.verticalCenter: countText.verticalCenter
                onClicked: {
                    swipeView.currentIndex++
                }
            }

        }

    }
    Rectangle {
        id: statusBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 30 * scaleFactor
        color: "lightgrey"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }

        Text {
            id:statusBarText
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: 10 * scaleFactor
            }
            text: popupListModel.count > 0 ? "Feature Identified: " + popupListModel.count.toString() : "Tap on the feature(s) to identify."
            font.pixelSize: 14 * scaleFactor
        }
    }
}



