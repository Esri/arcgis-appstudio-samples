/* ******************************************
Copyright 2015 Esri

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.​
******************************************* */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    id: _root
    width: rectFeatures.rListView.width
    height: rectFeatures.rListView.height

    Rectangle {
        id: rectFeature
        width: parent.width - 20*app.scaleFactor
        height:parent.height - 15*app.scaleFactor
        radius: 3*app.scaleFactor
        anchors.centerIn: parent
        clip: true
        color: "white"
        border.color: "darkgray"


        Rectangle {
            color: "transparent"
            width: 35*app.scaleFactor
            height: 35*app.scaleFactor
            clip: true
            anchors {
                left: parent.left
                leftMargin: 15*app.scaleFactor
                verticalCenter: parent.verticalCenter
            }

//            Image {
//                width: geometry.geometryType > 1 ? parent.width : symbolImage.defaultSize[0]
//                height: geometry.geometryType > 1 ? parent.height : symbolImage.defaultSize[1]
//                //width: parent.width
//                //height: parent.height
//                anchors.centerIn: parent
//                source: symbolImage.url
//                fillMode: Image.PreserveAspectFit
//                clip: true
//            }
        }

        Text {
            id: txtFeature
            width: parent.width - 110*app.scaleFactor
            anchors.centerIn: parent
            text: displayValue
            font.pointSize: 14*app.scaleFactor
            font.family: app.fontSourceSansProReg.name
            color: app.attributeValueColor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

