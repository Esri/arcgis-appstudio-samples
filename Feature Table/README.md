
## Using a feature table in three different cache mode

This item has the following three samples:
- Service Feature Table (Cache): This sample demonstrates how to use a feature table with the OnInteractionCache feature request mode. This mode will cache features locally from the remote feature service. This is the default mode, and will minimize the amount of requests sent to the server, thus lending itself to be the ideal choice for working in a partially connected environment.

- Service Feature Table (Manual Cache): This sample demonstrates how to use a feature service in manual cache mode. In this mode, an app explicitly requests features as needed from the remote service. The sample creates a service feature table by supplying the URL to the REST endpoint of the feature service, and set the caching mode to manual. It creates a new feature layer that uses the service feature table, and adds the feature layer to the map. When the Populate button is pressed, the sample calls the populateFromService method on the feature layer to fetch new features from the service, which are automatically added to the map.

- Service Feature Table (No Cache): This sample demonstrates how to use a feature table in on interaction no cache mode. In this mode, an app requests features from the remote service and does not cache them. This means that new features are requested from the service each time the viewpoint's visible extent changes. The sample creates an instance of ServiceFeatureTable by supplying the URL to the REST endpoint of the feature service. The FeatureRequestModeOnInteractionNoCache feature request mode is set on the ServiceFeatureTable as well. The feature layer is then supplied with the ServiceFeatureTable and added to the map.

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
Copyright 2017 Esri

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
