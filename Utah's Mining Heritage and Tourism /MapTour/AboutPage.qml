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

import QtQuick 2.2

Item {

    id: aboutPage
    visible: false
    width: parent.width
    height: parent.height

    z:100

    onVisibleChanged: {
        console.log("About page visibility: ", visible);
        aboutModalWindow.visible = visible;
    }

    ModalWindow {
        id: aboutModalWindow
        //visible: aboutPage.visible
        onVisibleChanged: {
            aboutPage.visible = visible
        }
    }

    Component.onCompleted: {

        var html = app.info.description;

        if(app.info.licenseInfo && app.info.licenseInfo.length>0) {
            html+= "<br><br><b>Access and Use Constraints:</b><br>" + app.info.licenseInfo
        }

        if(app.info.accessInformation && app.info.accessInformation.length>0) {
            html+= "<br><br><b>Credits:</b><br>" + app.info.accessInformation
        }

        html+= "<br><br><b>About the App:</b><br>" + "This app was built using the new AppStudio for ArcGIS. Mapping API provided by Esri ArcGIS Runtime SDK for Qt.";

        html +="<br><br>Version: " + app.info.version

        aboutModalWindow.title = "About"
        aboutModalWindow.description = html

    }

}
