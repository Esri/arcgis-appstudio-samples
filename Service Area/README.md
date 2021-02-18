## Service Area

This sample demonstrates how to find service areas around a point using the ServiceTask. Barriers can also be added which can affect the impedance by not letting traffic through or adding the time is takes to pass that barrier.

To display a service around a certain location:

1. Create a ServiceAreaTask from an online service.
2. Get a ServiceAreaParameter from the task using ServiceAreaTask.createDefaultParameters.
3. Set a spatial reference for the parameters using ServiceAreaParameters.outputSpatialReference. This will allow any geometry that is returned to be displayed on the Mapview.
4. Set the parameters to return polygons, which will return any service area that needs to be displayed.
5. Add a ServiceAreaFacility to parameters, ServiceAreaParameters.setFacilities
6. Optionally add PolylineBarriers to parameters, ServiceAreaParameters.setPolylineBarriers.
7. Get the ServiceAreaResult by solving the service area task using the parameters, ServiceAreaTask::solveServiceArea.
8. Get any ServiceAreaPolygons that were returned using ServiceAreaResult.resultPolygons.
9. Facility Index is the facility from the MapView that you want to get the service area of.
10. Display service areas to MapView by creating graphics for their geometry and adding to graphics overlay.

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
