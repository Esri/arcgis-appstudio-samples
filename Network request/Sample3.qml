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
    title: "Open data request"

    Item {
        property string query : "SELECT * from \"fc4d55de-55a6-483e-924a-093639d95aed\" WHERE \"Latitude\" BETWEEN -37.829 AND -37 AND \"Longitude\" BETWEEN 144  AND 145"

        NetworkRequest {
            id: networkRequest
            url: "http://data.gov.au/api/action/datastore_search_sql"
            responseType: "json"
        }

        ScrollView {
            anchors.fill: parent

            ListView {
                anchors.margins: 10
                clip: true
                model: networkRequest.response.result.records
                delegate: Text {
                    text: modelData.Name + " , " + modelData.Longitude + " , " + modelData.Latitude
                }
            }
        }

        Component.onCompleted: {
            networkRequest.send( {sql:query} )
        }
    }
}
