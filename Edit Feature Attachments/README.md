
## Add, delete, and fetch attachments for a specific feature in a feature service.

Click or tap on a feature to show its callout. The callout specifies the number of attachments for that particular feature. Selecting on the info button inside the callout shows the list of those attachments. In the list, you can add a new attachment by selecting the + button. When clicking on the + button, a native document picker will open, which is invoked by DocumentDialog from AppFramework Platform plugin. You can delete an attachment by selecting an attachment and selecting the - button. This is all controlled through the attachment list model, which is obtained through the feature. The attachment list model works similarly to other QML models and can be directly fed into a list view for easy display and user interaction.

By default, fetchAttachmentInfos is called automatically for the selected feature, which will request the attachment info JSON from the service. This JSON contains information such as name (the file name) and attachmentUrl (the URL to the file data.)

To edit the attachments, call addAttachment or deleteAttachment on the AttachmentListModel. By default, edits are automatically applied to the service and applyEdits does not need to be called.

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
