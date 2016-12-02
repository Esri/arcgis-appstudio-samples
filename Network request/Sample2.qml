import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

Tab {
    title: "ArcGIS Geocode"

    property var locatorArray: [{"Europe": "ESRI_Geocode_EU", "North America": "ESRI_Geocode_NA", "United States": "ESRI_Geocode_USA"}]
    property string locatorRegion: "Europe"
    property string address: "145 Mergnaser Drive"
    property string city: "Bicester"
    property string country: "UK"

    property var symbolTransparency

    Map {
        id: map

        anchors.fill: parent

        Envelope {
            id: env
            spatialReference: map.spatialReference
        }

        ArcGISTiledMapServiceLayer {
            url: "http://services.arcgisonline.com/arcgis/rest/services/World_Topo_Map/MapServer"
        }

        GraphicsLayer {
            id: graphicsLayer
        }

        Graphic {
            id: redCircle

            symbol: PictureMarkerSymbol {
                id: pms
                image: "./esri_pin_blue.png"
                width: 20 * AppFramework.displayScaleFactor
                height: 37 * AppFramework.displayScaleFactor
                //opacity: app.symbolTransparency
            }
        }

        Rectangle {
            anchors {
                fill: detailsColumn
                margins: -5
            }
            color: "lightsteelblue"
            opacity: 0.8
        }

        ColumnLayout {
            id: detailsColumn
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 10
            }
            spacing: 3
            Text {
                text: "Enter an address from " + locatorRegion
                font.bold: true
            }

            //RowLayout {
                Text {
                    text:"Street Address"
                    enabled: false
                    Layout.fillWidth: true
                }
                TextField {
                    id: addressCandidate
                    Layout.fillWidth: true
                    text: address
                    onTextChanged: address = text
                }
            //}

            //RowLayout {
                Text {
                    text:"City"
                    enabled: false
                    Layout.fillWidth: true
                }
                TextField {
                    id: cityCandidate
                    anchors.right: addressCandidate.right
                    Layout.fillWidth: true
                    text: city
                    onTextChanged: city = text
                }
            //}

            //RowLayout {
                Text {
                    text:"Country"
                    enabled: false
                    Layout.fillWidth: true
                }
                TextField {
                    id: countryCandidate
                    text: country
                    Layout.fillWidth: true
                    onTextChanged: country = text
                }
            //}

            Row {
                spacing: 5
                Button {
                    id: findButton
                    text: "Find candidates"
                    onClicked: {
                        networkRequest.send({"f":"json", "Address":address, "City":city, "Country":country, "outSR": map.spatialReference.wkid})
                        busyIndicator.visible = true
                    }
                }
                BusyIndicator{
                    id: busyIndicator
                    visible: false
                    height: findButton.height
                    width: height
                }
            }
        }

        NetworkRequest {
            id: networkRequest
            url: "http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Locators/" + locatorArray[0][locatorRegion] + "/GeocodeServer/findAddressCandidates"
            responseType: "json"

            onReadyStateChanged: {
                if (readyState === NetworkRequest.DONE){
                    busyIndicator.visible = false;
                    graphicsLayer.removeAllGraphics();

                    console.log(JSON.stringify(response, undefined, 2))


                    for (var i = 0; i < response.candidates.length; i++){
                        pms.opacity = (networkRequest.response.candidates[i].score / 100)

                        var g = redCircle.clone();
                        var pt = ArcGISRuntime.createObject("Point");
                        pt.json = {
                            "spatialReference":{"wkid": map.spatialReference.wkid},
                            "x": networkRequest.response.candidates[i].location.x,
                            "y": networkRequest.response.candidates[i].location.y
                        }
                        g.geometry = pt;
                        graphicsLayer.addGraphic(g);
                    }

                    var xArray = networkRequest.response.candidates.map(function(e){return e.location.x;});
                    var yArray = networkRequest.response.candidates.map(function(e){return e.location.y;});
                    env.xMin = Math.min.apply(null, xArray) -1000;
                    env.xMax = Math.max.apply(null, xArray) +1000;
                    env.yMin = Math.min.apply(null, yArray) -1000;
                    env.yMax = Math.max.apply(null, yArray) +1000;

                    map.zoomTo(env);
                }
            }
        }
    }
}

