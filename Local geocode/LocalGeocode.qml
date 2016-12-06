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

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0
import ArcGIS.AppFramework.Dialogs 1.0

App {
    id: app
    width: 400
    height: 640

    property int scaleFactor : AppFramework.displayScaleFactor

    property string dataPath: AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data")
    property string inputLocFolder: "SFLocator"
    property string outputLocFolder: dataPath + "/" + inputLocFolder

    property LocalLocator localLocator

    function copyLocalData() {
        var resourceFolder = AppFramework.fileFolder(app.folder.folder(inputLocFolder).path);

        var fileNames = resourceFolder.fileNames("*", true);

        for (var i = 0; i < fileNames.length; i++) {
            var fileName = fileNames[i];
            fileName = fileName.replace(/\\/g, "/");

            var outputFileFolder = AppFramework.fileFolder(outputLocFolder);
            var outputFileInfo = AppFramework.fileInfo(outputFileFolder.filePath(fileName));

            outputFileFolder.makePath(outputFileInfo.path);
            resourceFolder.copyFile(fileName, outputFileFolder.filePath(fileName));
        }
    }

    Component.onCompleted: {
        //ArcGISRuntime.license.setLicense("enter your licence string here to be able run this sample in player or as standalone app. Without this, the app can be run in AppStudio only in developer mode.");
        logLicenseLevel();

        copyLocalData();

        arcGISLocalTiledLayerBasemap.path = outputLocFolder + "/SanFrancisco.tpk";
        localLocator = ArcGISRuntime.createObject("LocalLocator", {path: outputLocFolder + "/SanFranciscoLocator.loc"});
    }

    function logLicenseLevel() {
        if (ArcGISRuntime.license.licenseLevel === Enums.LicenseLevelBasic) {
            console.log("basic")
            licenceLevel.text = "Licence Level: Basic"
        } else if (ArcGISRuntime.license.licenseLevel === Enums.LicenseLevelStandard) {
            console.log("standard")
            licenceLevel.text = "Licence Level: Standard"
        } else if (ArcGISRuntime.license.licenseLevel === Enums.LicenseLevelDeveloper) {
            console.log("developer")
            licenceLevel.text = "Licence Level: Developer"
        }
    }

    /*----------------------------------------------------------------------------------------------------------------
          Map
    ----------------------------------------------------------------------------------------------------------------*/

    Envelope {
        id: mapExtent
        xMin: -122.511
        yMin: 37.7474
        xMax: -122.3887
        yMax: 37.8125
        spatialReference: SpatialReference {
            wkid: 4326
        }
    }

    Map {
        id: mainMap
        anchors.fill: parent
        extent: mapExtent
        focus: true

        ArcGISLocalTiledLayer {
            id: arcGISLocalTiledLayerBasemap
        }

        GraphicsLayer {
            id: graphicsLayerStops
        }

        GraphicsLayer {
            id: graphicsLayerReverse
        }

        onMouseClicked: {
            graphicsLayerReverse.removeAllGraphics();
            var newGraphic = graphicReverseLocation.clone();
            newGraphic.geometry = mouse.mapPoint;
            graphicsLayerReverse.addGraphic(newGraphic);
            localLocator.reverseGeocode(mouse.mapPoint, 20, mainMap.spatialReference);
        }
    }

    Text {
        id: licenceLevel
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: 200 * scaleFactor
        height: 30 * scaleFactor
        font.pixelSize: 12 * scaleFactor
        text: "Im still thinking..."

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

    Graphic {
        id: graphicLocation
        symbol: simpleMarkerSymbolLocation
    }

    Graphic {
        id: graphicReverseLocation
        symbol: simpleMarkerSymbolReverseLocation
    }

    /*----------------------------------------------------------------------------------------------------------------
          Locator
    ----------------------------------------------------------------------------------------------------------------*/

    Connections {
        target: localLocator

        onFindStatusChanged: {
            if (localLocator.findStatus === Enums.FindStatusCompleted) {
                if (localLocator.findResults.length < 1) {
                    showError("No Match Found");
                } else {
                    for (var i = 0; i < localLocator.findResults.length; i++) {
                        var result = localLocator.findResults[i];
                        console.log("Result", i, result.address, result.score, result.location.x, result.location.y, result.extent.toText(), result.spatialReference.toText(), result.toText());
                        var newGraphic = graphicLocation.clone();
                        newGraphic.geometry = result.location;
                        var id = graphicsLayerStops.addGraphic(newGraphic);
                    }
                    mainMap.extent = localLocator.findResults[0].extent;
                }
            } else if (localLocator.findStatus === Enums.FindStatusErrored) {
                showError("Error: " + localLocator.findError.message + "\n\n");
            }
        }

        onReverseGeocodeStatusChanged: {
            if (localLocator.reverseGeocodeStatus === Enums.ReverseGeocodeStatusCompleted) {
                if (localLocator.reverseGeocodeResult.toString().length > 0) {
                    searchBox.descriptionTextVisibility = true;
                    searchBox.descriptionTextInput = "Address: "
                    var street = localLocator.reverseGeocodeResult.addressFields["Street"];
                    var city = localLocator.reverseGeocodeResult.addressFields["City"];
                    var state = localLocator.reverseGeocodeResult.addressFields["State"];
                    var zip = localLocator.reverseGeocodeResult.addressFields["ZIP"];
                    searchBox.descriptionTextInput += street + " " + city + ", " + state + " " + zip;
                } else {
                    showError("No Address Found");
                    searchBox.descriptionTextVisibility = false;
                }

            } else if (localLocator.reverseGeocodeStatus === Enums.ReverseGeocodeStatusErrored) {
                showError("Error: " + localLocator.reverseGeocodeError.message + "\n\n");
                searchBox.descriptionTextVisibility = false;
            }
        }
    }

    LocatorFindParameters {
        id: locatorFindParametersText
        text: searchBox.searchTextInput
        outSR: mainMap.spatialReference
        maxLocations: 3
        searchExtent: mainMap.extent
        distance: 2000.0
        sourceCountry: "USA"
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
            locatorFindParametersText.text = searchBox.searchTextInput
            localLocator.find(locatorFindParametersText);
        }

        onClear: {
            searchBox.searchTextInput = "";
            mainMap.extent = envelopeMapExtent;
            mainMap.mapRotation = 0;
            graphicsLayerStops.removeAllGraphics();
            graphicsLayerReverse.removeAllGraphics();
            searchBox.descriptionTextInput = "";
            searchBox.searchTextInput.focus = true;
            searchBox.descriptionTextVisibility = false;
        }

        Keys.onReturnPressed: {
            locatorFindParametersText.text = searchBox.searchTextInput
            localLocator.find(locatorFindParametersText);
            Qt.inputMethod.hide();
        }
    }

    MessageDialog {
        id: messageDialog
        title: "Error"
        icon: StandardIcon.Warning
        modality: Qt.WindowModal
        standardButtons: StandardButton.Ok
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
        messageDialog.text = errorString;
        messageDialog.visible = true;
    }
}
