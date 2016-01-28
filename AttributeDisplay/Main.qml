/* ******************************************
Copyright 2015 Esri

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.​
******************************************* */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

//------------------------------------------------------------------------------

App {
    id: app
    width: 420
    height: 700

    // Scale factor
    property double scaleFactor : AppFramework.displayScaleFactor

    // App titles and colors
    property string mapTitle: "My Map"
    property color headerBarColor: "#0055ff"
    property color headerTextColor: "#ffffff"
    property color attributeDisplayNameColor: "#B6B6CD"
    property color attributeValueColor: "#697797"
    property color attributeSeparatorColor: "#ABB6CD"


    // Map layers and field info for attribute display
    property string parksFeatureService: "http://services1.arcgis.com/e7dVfn25KpfE6dDd/arcgis/rest/services/WashingtonDCMap/FeatureServer/2"
    property string schoolsFeatureService: "http://services1.arcgis.com/e7dVfn25KpfE6dDd/arcgis/rest/services/WashingtonDCMap/FeatureServer/0"
    property string postOfficeFeatureService: "http://services1.arcgis.com/e7dVfn25KpfE6dDd/arcgis/rest/services/WashingtonDCMap/FeatureServer/1"
    /*
      Field Options:
      fieldName: Name of field in feature layer (string)
      displayName: Name to display in attribute window; field alias used by default (string)
      decimalPlaces: Number of decimal places (number)
      thousandsSeparator: Thousands separator for numbers >= 1,000; false by default (bool)
      dateFormat: See http://momentjs.com/docs/#/displaying/format/ for possible formats (string)
      prefix: Character(s) to prepend value (string)
      suffix: Character(s) to append to value (string)
      isHidden: Field hidden or shown; false by default (bool)
      isLink: Value is link; false by default (bool)
    */
    property var queryLayers: [
        {url: parksFeatureService,
            fields: [
                {fieldName: "name", displayName: "Name"},
                {fieldName: "location", displayName: "Address"},
                {fieldName: "objectid", isHidden: true},
                {fieldName: "sq_meters", displayName: "Area", decimalPlaces: 2, thousandsSeparator: true, suffix: " sq m"},
                {fieldName: "lastupdate", displayName: "Last Update", dateFormat: "MM/DD/YYYY"}],
            displayField: "name"},
        {url: schoolsFeatureService,
            fields: [
                {fieldName: "name", displayName: "Name"},
                {fieldName: "address", displayName: "Address"},
                {fieldName: "phone", displayName: "Phone"},
                {fieldName: "facuse", displayName: "Type"},
                {fieldName: "capacity", displayName: "Capacity"},
                {fieldName: "square_foo", displayName: "Area", suffix: " sq ft", thousandsSeparator: true},
                {fieldName: "bldg_num", displayName: "Building Number", prefix: "# "},
                {fieldName: "web_url", displayName: "Link", isLink: true},
                {fieldName: "year_built", isHidden: true},
                {fieldName: "last_update", displayName: "Last Update", dateFormat: "MMM Do, YYYY"}],
            displayField: "facuse"},
        {url: postOfficeFeatureService,
            fields: [
                {fieldName: "name", displayName: "Name"},
                {fieldName: "address", displayName: "Address"},
                {fieldName: "phone", display: "Phone"},
                {fieldName: "type", displayName: "Type"},
                {fieldName: "web_url", displayName: "Link", isLink: true},
                {fieldName: "ssl", isHidden: true},
                {fieldName: "gis_id", isHidden: true},
                {fieldName: "last_update", displayName: "Last Update", dateFormat: "DD-MMM-YYYY"}],
            displayField: "name"}]

    // Font
    property alias fontSourceSansProReg : fontSourceSansProReg
    FontLoader {
        id: fontSourceSansProReg
        source: app.folder.fileUrl("assets/fonts/SourceSansPro-Regular.ttf")
    }

    StackView {
        id: stackView
        width: app.width
        height: app.height
        initialItem: mapPage
    }

    Component {
        id: mapPage

        MapPage {}

    }
}

//------------------------------------------------------------------------------
