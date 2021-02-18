## Unique Value Renderer

This sample demonstrates how to use a UniqueValueRenderer to style different Features in a FeatureLayer with different Symbols.

First a ServiceFeatureTable and a FeatureLayer are constructed and added to the Map. Then a UniqueValueRenderer is created, and the fieldName to be used as the renderer field is set as ("STATE_ABBR"). You can use multiple fields; this sample only uses one. Multiple SimpleFillSymbols are defined for each type of feature we want to render differently (in this case different states of the USA). SimpleFillSymbols can be applied to polygon features; these are the types of features found in the feature service used for this ServiceFeatureTable. A default symbol is also created; this will be used for all other features that do not match the all of the UniqueValues defined. Separate UniqueValues objects are created which define the values in the renderer field and what symbol should be used for matching features. These are added to the UniqueValue list. The renderer is set on the layer and is rendered in the MapView accordingly.

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
