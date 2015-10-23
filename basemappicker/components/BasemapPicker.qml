/* ******************************************
Copyright 2015 Esri

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.​
******************************************* */

import QtQuick 2.0
import ArcGIS.AppFramework 1.0

Image {
    id: _root
    width: 210*scaleFactor
    height: 250*scaleFactor
    source: "images/basemap_selector_background.png"
    visible: false

    property string currentBaseMapName
    property int textFontPointSize: 10
    property string fontFamilyName: ""
    property color highLightColor: "#5AAFEE"
    property color textColor: "#697797"
    property double scaleFactor: AppFramework.displayScaleFactor

    signal change(string name, string url)

    //Base Map Picker model
    property alias baseMapPickerModel: baseMapPickerModel
    ListModel {
        id: baseMapPickerModel
        ListElement {
            name: "Topography"
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer"
            image: "images/topo_thumbnail.png"
        }
        ListElement {
            name: "Satellite"
            url: "http://services.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer"
            image: "images/satellite_thumbnail.png"
        }
        ListElement {
            name: "Streets"
            url: "http://services.arcgisonline.com/arcgis/rest/services/World_Street_Map/MapServer"
            image: "images/streets_thumbnail.png"
        }
        ListElement {
            name: "Oceans"
            url: "http://services.arcgisonline.com/arcgis/rest/services/Ocean_Basemap/MapServer"
            image: "images/oceans_thumbnail.png"
        }
        ListElement {
            name: "Light Gray"
            url: "http://services.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer"
            image: "images/lightgray_thumbnail.png"
        }
    }

    Flickable {
        id: flickableBaseMapPicker
        width: parent.width - (10*scaleFactor)
        height: parent.height - (10*scaleFactor)
        contentHeight: (baseMapPickerModel.count*(70*scaleFactor))+(baseMapPickerModel.count*5*scaleFactor)
        clip: true
        anchors.top: parent.top
        anchors.topMargin: 4*scaleFactor

        Rectangle {
            id: rectBaseMapPicker
            width: parent.width
            height: parent.height
            color: "transparent"
            anchors {
                left: parent.left
                leftMargin: 10*scaleFactor
            }

            Column {
                spacing: 5*scaleFactor

                Repeater {
                    id: repeaterBaseMapPicker
                    model: baseMapPickerModel

                    Rectangle {
                        width: flickableBaseMapPicker.width - (18*scaleFactor)
                        height: 70*scaleFactor
                        color: name === currentBaseMapName ? _root.highLightColor : "transparent"
                        radius: 2*scaleFactor

                        Image {
                            id: imgBaseMapThumbnail
                            width: 80*scaleFactor
                            height: 60*scaleFactor
                            source: image
                            anchors {
                                left: parent.left
                                leftMargin: 5*scaleFactor
                                verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            text: name
                            font.pointSize: textFontPointSize
                            font.family: fontFamilyName
                            color: name === currentBaseMapName ? AppFramework.contrastColor(_root.highLightColor) : _root.textColor
                            anchors {
                                left: imgBaseMapThumbnail.right
                                leftMargin: 5*scaleFactor
                                verticalCenter: imgBaseMapThumbnail.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                currentBaseMapName = name
                                change(name, url);
                                _root.visible = false
                            }
                        }
                    }
                }
            }
        }
    }

}




