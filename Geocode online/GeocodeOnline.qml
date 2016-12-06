/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

App {
    id: app
    width: 800
    height: 532

    property double scaleFactor: AppFramework.displayScaleFactor
    property string errorMsg

    Map {
        id: mainMap
        anchors.fill: parent
        extent: usExtent
        focus: true

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        SimpleMarkerSymbol {
            id: simpleMarkerSymbolLocation
            color: "red"
            style: Enums.SimpleMarkerSymbolStyleCross
            size: 10
        }

        SimpleMarkerSymbol {
            id: simpleMarkerSymbolReverseLocation
            color: "blue"
            style: Enums.SimpleMarkerSymbolStyleDiamond
            size: 10
        }

        GraphicsLayer {
            id: graphicsLayerGeocode
        }

        GraphicsLayer {
            id: graphicsLayerReverse
        }

        Graphic {
            id: locationGraphicReverse
            symbol: simpleMarkerSymbolReverseLocation
        }

        Graphic {
            id: locationGraphicGeocode
            symbol: simpleMarkerSymbolLocation
        }

        Envelope {
            id: usExtent
            xMax: -15000000
            yMax: 2000000
            xMin: -7000000
            yMin: 8000000
            spatialReference: mainMap.spatialReference
        }

        onMouseClicked: {
            graphicsLayerReverse.removeAllGraphics();
            var graphic1 = locationGraphicReverse.clone();
            graphic1.geometry = mouse.mapPoint;
            graphicsLayerReverse.addGraphic(graphic1);
            locator.reverseGeocode(mouse.mapPoint, 500, mainMap.spatialReference);
        }
    }

    ServiceLocator {
        id: locator
        url: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"

        onFindStatusChanged: {
            if (findStatus === Enums.FindStatusCompleted) {
                progressBar.visible = false;
                if (findResults.length < 1) {
                    showError("No address Found");
                } else {
                    for (var i = 0; i < findResults.length; i++) {
                        var result = findResults[i];
                        var graphic = locationGraphicGeocode.clone()
                        graphic.geometry = result.location;
                        graphicsLayerGeocode.addGraphic(graphic);
                    }
                    mainMap.zoomTo(graphic.geometry);
                }
            } else if (findStatus === Enums.FindStatusErrored) {
                progressBar.visible = false;
                showError(findError.message + "\nNo Address Found");
            }
        }

        onReverseGeocodeStatusChanged: {
            if (reverseGeocodeStatus === Enums.ReverseGeocodeStatusCompleted) {
                searchBox.descriptionTextVisibility = true;
                searchBox.descriptionTextInput = "Address: "
                var address = reverseGeocodeResult.addressFields["Address"];
                var city = reverseGeocodeResult.addressFields["City"];
                var state = reverseGeocodeResult.addressFields["Region"];
                var zip = reverseGeocodeResult.addressFields["Postal"];
                searchBox.descriptionTextInput += address + " " + city + ", " + state + " " + zip;
            } else if (reverseGeocodeStatus === Enums.ReverseGeocodeStatusErrored) {
                showError(reverseGeocodeError.message + "\nNo Address Found");
                searchBox.descriptionTextVisibility = false;
            }
        }
    }

    LocatorFindParameters {
        id: findTextParams
        text: searchBox.searchTextInput
        outSR: mainMap.spatialReference
        maxLocations: 1
        searchExtent: usExtent
        sourceCountry: "US"
    }

    /*-----------------------------------------------------------------------------------------------------------------------
         Search button / box
         ---------------------------------------------------------------------------------------------------------------------*/

    SearchBox {
        id: searchBox

        anchors {
            left: parent.left
            top: parent.top
            margins: 20 * scaleFactor
        }

        onSearch: {
            findTextParams.text = searchBox.searchTextInput
            graphicsLayerGeocode.removeAllGraphics();
            locator.find(findTextParams);
            progressBar.visible = true;
        }

        onClear: {
            mainMap.extent = usExtent;
            mainMap.mapRotation = 0;
            graphicsLayerGeocode.removeAllGraphics();
            graphicsLayerReverse.removeAllGraphics();
            searchBox.descriptionTextInput = "";
            searchBox.searchTextInput.focus = true;
            searchBox.descriptionTextVisibility = false;
            searchBox.searchTextInput = "";
        }

        Keys.onReturnPressed: {
            findTextParams.text = searchBox.searchTextInput
            graphicsLayerGeocode.removeAllGraphics();
            locator.find(findTextParams);
            progressBar.visible = true;
            Qt.inputMethod.hide();
        }
    }

    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: mainMap.bottom
            bottomMargin: 5 * scaleFactor
        }

        ProgressBar {
            id: progressBar
            indeterminate: true
            visible: false
        }
    }


    MessageDialog {
        id: messageDialog
        title: "Error"
        icon: StandardIcon.Warning
        modality: Qt.WindowModal
        standardButtons: StandardButton.Ok
        text: errorMsg
    }

    Rectangle {
        id: rectangleBorder
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }

    function showError(errorString) {
        errorMsg = errorString;
        messageDialog.visible = true;
    }
}

