## Managed App Config

This sample app demonstrates how to use AppFramework.Management plugin -ManagedAppConfiguration QML type to allow Enterprise Mobility Management (EMM) software to overwrite certain provided default settings. Currently, managed app configuration is only supported on iOS and Android platforms.

In this sample app, the default portal URL is “www.arcgis.com” and the default portal name is “ArcGIS”. You can upload the app installation file into the EMM software and set the preferred portal URL and name values. The portal URL and name set in the EMM will be shown in the Settings portalURL and Settings portalName field in the sample app. You can see what happens when changing values in EMM software in Settings JSON field.

To use this feature, you will need to:

Step 1:  Include restriction .xml file for Android and configuration schema .xml file for iOS in your app project folder. In this sample app, the restriction file is "restrictions.xml" and the configuration schema file is "specfile.xml".

Step 2: Include the management property into the appinfo.json file. You can go to the appinfo.json file, line 82 to check how we add the management property.   

Step 3: Use ManagedAppConfiguration QML type to read policy settings in AppStudio app.

Step 4: Upload the app to your EMM software and follow the steps provided by your EMM software to setup managed app configuration using key-value pairs.

Please read this [blog](https://community.esri.com/groups/appstudio/blog/2019/03/04/support-for-managed-app-configuration-with-enterprise-mobility-management-solutions) to learn more.



[Resource Level](https://geonet.esri.com/groups/appstudio/blog/2016/12/06/how-to-describe-our-resources-in-terms-of-difficulty-complexity-and-time-to-digest): 🍌🍌


## Instructions to run this sample in AppStudio Desktop

1. Download the `.zip` file
2. Unzip and copy this folder into AppStudio Apps folder (Windows: `C:\Users\<username>\ArcGIS\AppStudio\Apps` Mac or linux: `Home\ArcGIS\AppStudio\Apps`)
3. The new app will now appear in the AppStudio Desktop. Run the application or open it in the bundled Qt-Creator IDE to look at the code and modify.

## Issues

Find a bug or want to request a new feature?  Please let us know by submitting an issue.

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

## Licensing
Copyright 2020 Esri

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
