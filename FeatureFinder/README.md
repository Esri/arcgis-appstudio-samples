
## Searching for features in AppStudio using QML and JavaScript

A new component for AppStudio is available that allows developers to add a search box to their apps. The short video below demonstrates a search box component written in QML and JavaScript with AppStudio for ArcGIS.

With three or more characters entered in the search box, the ArcGIS Feature Layer is queried to provide a filtered list of options.  Each time the search box input changes (a character is added or deleted) the filtered list is updated to provide the user with all of the possible results that begin with the characters entered.  When an item in the list is selected, the corresponding feature geometry is highlighted, and a signal returns the geometry so the map component can zoom to the selected feature.

![](https://j.gifs.com/KjYWxZ.gif)


Watch: https://youtu.be/Ug8UoUC-6Dg

## Instructions to run this sample in AppStudio Desktop

1. Download the `.zip` file
2. Unzip and copy this folder into AppStudio Apps folder (Windows: `C:\Users\<username>\ArcGIS\AppStudio\Apps` Mac or linux: `Home\ArcGIS\AppStudio\Apps`)
3. The new app will now appear in the AppStudio Desktop. Run the application or open it in the bundled Qt-Creator IDE to look at the code and modify.

## Resources

* [AppStudio for ArcGIS Website](https://appstudio.arcgis.com/)
* [AppStudio for ArcGIS Developer Documentation](http://doc.arcgis.com/en/appstudio/extend-apps/useqtcreatorcreateapp.htm)
* [AppStudio for ArcGIS Geonet Forums](https://geonet.esri.com/groups/appstudio/)
* [AppStudio for ArcGIS Video Collection](http://video.arcgis.com/series/232/appstudio-for-arcgis)
* [Qt and QML](http://www.qt.io/)

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an issue.

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

## Licensing
Copyright 2015 Esri

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
