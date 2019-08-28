
## Basic map settings such as display a map, show map loaded status, change basemap, and set map spatial reference

This item demonstrates following 4 samples:
- Display a Map: This is the most basic sample for displaying a map. It can be considered the "Hello World" map app for the ArcGIS Runtime SDK for Qt. It shows how to create a map view, and add in a map that contains the imagery with labels basemap. By default, this map supports basic zooming and panning operations.
- Show Map Loaded Status: This sample demonstrates the load status which is obtained from the loadStatus property. The map is considered loaded when any of the following are true: the map has a valid spatial reference, the map has an initial viewpoint, or one of the map's predefined layers has been created. A signal handler is set up on the map to handle the loadStatusChanged signal by updating the text at the bottom of the display with the new load status.
- Change Basemap: This sample shows how to switch between different basemaps in the map. When a new item is selected from the combo box, a JavaScript function that determines the currently selected basemap is executed. The map's basemap is replaced by simply calling the writable basemap property, passing in the desired basemap. If there were operational layers present in the map, this would have no effect on them.
- Set Map Spatial Reference: This sample demonstrates how to set the initial spatial reference of a map so that all layers that support reprojection are projected into the map’s spatial reference.

[Resource Level](https://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest): 🍌🍌🍌


## Instructions to run this sample in AppStudio Desktop

1. Download the `.zip` file
2. Unzip and copy this folder into AppStudio Apps folder (Windows: `C:\Users\<username>\ArcGIS\AppStudio\Apps` Mac or linux: `Home\ArcGIS\AppStudio\Apps`)
3. The new app will now appear in the AppStudio Desktop. Run the application or open it in the bundled Qt-Creator IDE to look at the code and modify.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an issue.

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

## Licensing
Copyright 2019 Esri

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
