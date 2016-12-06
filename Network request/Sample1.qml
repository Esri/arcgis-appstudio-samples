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

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

Tab {
    title: "ArcGIS REST"

    Item {
        NetworkRequest {
            id: networkRequest
            url: "https://sampleserver6.arcgisonline.com/arcgis/rest/services/Wildfire/FeatureServer"
            responseType: "json"
        }

        Flickable {
            anchors {
                fill:parent
                margins: 10 * AppFramework.displayScaleFactor
            }
            contentHeight: jsonText.height
            contentWidth: jsonText.width

            clip: true

            Text {
                id: jsonText
                clip: true
                text : JSON.stringify(networkRequest.response, undefined, 2)
            }
        }

        Component.onCompleted: {
            networkRequest.send( {"f":"pjson"} )
        }
    }
}
