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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

App {
    id: app
    width: 1000
    height: 800

    UrlInfo {
        id: urlInfo
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: "#EFEEEF"

        ColumnLayout {
            id: cl
            anchors {
                fill: parent
                margins: 10
            }
            Row {
                spacing: 5
                Layout.fillWidth:  true
                Button {
                    text: "Example.com"
                    onClicked:urlField.text =  "http://user:pass@www.example.com:1234/pathname/filename.html?param1=value1&param2=value2#frag"
                }
                Button {
                    text: qsTr("Feature Service")
                    onClicked:urlField.text =  "http://arcgis-server1022-2082234468.us-east-1.elb.amazonaws.com/arcgis/rest/services/MobileApps/Water_Leaks_VGI/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&gdbVersion=&returnDistinctValues=false&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&f=pjson"
                }
                Button {
                    text: qsTr("Online image")
                    onClicked:urlField.text =  "http://appstudio.arcgis.com/images/index/introview.jpg"
                }
            }

            TextField {
                id: urlField
                Layout.fillWidth: true
                Layout.maximumWidth: cl.width
                Layout.preferredHeight: contentHeight

                text: "http://arcgis-server1022-2082234468.us-east-1.elb.amazonaws.com/arcgis/rest/services/MobileApps/Water_Leaks_VGI/FeatureServer" //0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&gdbVersion=&returnDistinctValues=false&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&f=pjson"

                onTextChanged: {
                    urlInfo.fromUserInput(text);
                    console.log(urlInfo.url)
                    console.log("parent",urlInfo.isParentOf("http://arcgis-server1022-2082234468.us-east-1.elb.amazonaws.com/arcgis/rest/services/MobileApps/Water_Leaks_VGI/FeatureServer/0/query"))
                }
            }

            CheckBox {
                text: "<b>isValid</b>"
                checked: urlInfo.isValid
                enabled: false
            }

            CheckBox {
                text: "<b>isEmpty</b>"
                checked: urlInfo.isEmpty
                enabled: false
            }

            Text {
                text: "<b>url</b>: " + urlInfo.url
                wrapMode: Text.WrapAnywhere
                Layout.maximumWidth: cl.width

            }

            Text {
                text: "<b>scheme</b>: " + urlInfo.scheme
            }

            Text {
                text: "<b>host</b>: " + urlInfo.host
            }

            Text {
                text: "<b>topLevelDomain</b>: " + urlInfo.topLevelDomain
            }

            Text {
                text: "<b>port</b>: " + urlInfo.port.toString()
            }

            Text {
                text: "<b>path</b>: " + urlInfo.path
            }

            Text {
                text: "<b>fileName</b>: " + urlInfo.fileName
            }

            Text {
                text: "<b>authority</b>: " + urlInfo.authority
            }

            Text {
                text: "<b>userInfo</b>: " + urlInfo.userInfo
            }

            Text {
                text: "<b>userName</b>: " + urlInfo.userName
            }

            Text {
                text: "<b>password</b>: " + urlInfo.password
            }

            CheckBox {
                text: "<b>hasFragment</b>"
                checked: urlInfo.hasFragment
                enabled: false
            }

            Text {
                text: "<b>fragment</b>: " + urlInfo.fragment
            }

            CheckBox {
                text: "<b>hasQuery</b>"
                checked: urlInfo.hasQuery
                enabled: false
            }

            Text {
                text: "<b>query</b>: " + urlInfo.query
                Layout.maximumWidth: cl.width
                wrapMode: Text.WrapAnywhere

            }

            TextArea {
                Layout.fillWidth: true
                Layout.maximumWidth: cl.width
                Layout.fillHeight: true

                text: JSON.stringify(urlInfo.queryParameters, undefined, 2)
            }
        }
    }
}

