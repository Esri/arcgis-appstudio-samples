/* Copyright 2021 Esri
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
import QtQuick.Controls 2.1
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
                    implicitHeight: 30
                    text: "Example.com"
                    onClicked:urlField.text =  "http://user:pass@www.example.com:1234/pathname/filename.html?param1=value1&param2=value2#frag"
                }
                Button {
                    implicitHeight: 30
                    text: qsTr("Feature Service")
                    onClicked:urlField.text =  "http://arcgis-server1022-2082234468.us-east-1.elb.amazonaws.com/arcgis/rest/services/MobileApps/Water_Leaks_VGI/FeatureServer/0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&gdbVersion=&returnDistinctValues=false&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&f=pjson"
                }
                Button {
                    implicitHeight: 30
                    text: qsTr("Online image")
                    onClicked:urlField.text =  "http://appstudio.arcgis.com/images/index/introview.jpg"
                }
            }

            TextField {
                id: urlField
                selectByMouse: true
                Layout.fillWidth: true
                Layout.maximumWidth: cl.width
                implicitHeight: 30

                text: "http://arcgis-server1022-2082234468.us-east-1.elb.amazonaws.com/arcgis/rest/services/MobileApps/Water_Leaks_VGI/FeatureServer" //0/query?where=1%3D1&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&gdbVersion=&returnDistinctValues=false&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&f=pjson"

                onTextChanged: {
                    urlInfo.fromUserInput(text);
                    console.log(urlInfo.url)
                    console.log("parent",urlInfo.isParentOf("http://arcgis-server1022-2082234468.us-east-1.elb.amazonaws.com/arcgis/rest/services/MobileApps/Water_Leaks_VGI/FeatureServer/0/query"))
                }
            }

            CheckBoxSmall{
                id: isValidCheckBox
                textContent: "<b>isValid</b>"
                isChecked: urlInfo.isValid
                isEnabled: false
            }

            CheckBoxSmall{
                id: isEmptyCheckBox
                textContent: "<b>isEmpty</b>"
                isChecked: urlInfo.isEmpty
                isEnabled: false
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

            CheckBoxSmall{
                id: hasFragmentCheckBox
                textContent: "<b>hasFragment</b>"
                isChecked: urlInfo.hasFragment
                isEnabled: false
            }

            Text {
                text: "<b>fragment</b>: " + urlInfo.fragment
            }

            CheckBoxSmall{
                id: hasQueryCheckBox
                textContent: "<b>hasQuery</b>"
                isChecked: urlInfo.hasQuery
                isEnabled: false
            }

            Text {
                text: "<b>query</b>: " + urlInfo.query
                Layout.maximumWidth: cl.width
                wrapMode: Text.WrapAnywhere

            }
            Flickable {
                id: flickable

                Layout.fillWidth: true
                Layout.maximumWidth: cl.width
                Layout.fillHeight: true
                clip: true

                TextArea.flickable:TextArea{
                    id: textArea

                    text: JSON.stringify(urlInfo.queryParameters, undefined, 2)
                    wrapMode: Text.WrapAnywhere
                    background: Rectangle {
                        id:bg
                        implicitWidth: 200
                        implicitHeight: 40
                        color:"white"
                        border.color:"#A9A9A9"
                    }
                    transformOrigin: Item.Center
                }
                ScrollBar.vertical: ScrollBar {}
            }
        }
    }
}

