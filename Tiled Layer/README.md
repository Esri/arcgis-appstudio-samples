## Tiled Layer

This sample demonstrates how to use a Vector Tiled Layer and ArcGIS Tiled Layer

There are two samples in this item:
- Vector Tiled Layer: When a new item is selected from the combo box, a JavaScript function that determines the currently selected vector tiled layer basemap is executed. The map's basemap is replaced by setting basemap property to the desired basemap. If there were operational layers present in the map, this would have no effect on them.method is called to apply the edits to the service, deleting the feature from the service.
- ArcGIS Tiled Layer: This sample demonstrates how to display a tiled map service. An ArcGISTiledLayer is created by setting its url property to the URL of the map service endpoint. The ArcGISTiledLayer is nested within a basemap, thus becoming one of the basemap's layers. The basemap is set as the basemap of the map, and the map is set as the map for the map view. Note how default properties in QML make this nesting easier to code.

[Resource Level](https://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest): 🍌


## Instructions to run this sample in AppStudio Desktop

1. Download the `.zip` file
2. Unzip and copy this folder into AppStudio Apps folder (Windows: `C:\Users\<username>\ArcGIS\AppStudio\Apps` Mac or linux: `Home\ArcGIS\AppStudio\Apps`)
3. The new app will now appear in the AppStudio Desktop. Run the application or open it in the bundled Qt-Creator IDE to look at the code and modify.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an issue.

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

## Licensing
Copyright 2021 Esri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [license.txt](license.txt) file.


[](Esri Tags: ArcGIS Runtime SDK Qt QML JavaScript iOS Android Xamarin Ionic PhoneGap Mac linux Windows Apps samples templates appstudio)
[](Esri Language: Qt QML JavaScript)
