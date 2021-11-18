// [WriteFile Name=Geotriggers, Category=Analysis]
// [Legal]
// Copyright 2021 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// [Legal]

import QtQuick 2.6
import QtQuick.Controls 2.2

Pane {
    id: aboutCurrentDeviceFeaturePane

    property string featureName: ""
    property string featureAmenity: ""
    property string featureHouseNumber: ""
    property string featureStreet: ""
    property string featureCity: ""
    property string featureState: ""
    property string featureProvince: ""
    property string featureCountry: ""
    property string featurePostcode: ""
    property string featureUnit: ""
    property string featureBuilding: ""

    anchors {
        top: parent.top
        right: parent.right
    }

    width: parent.width < 300 ? parent.width : 300
    height: parent.height
    visible: false
    clip: true

    background: Rectangle {
        color: "white"
        border.color: "black"
    }

    contentItem: ScrollView {
        id: scrollViewComponent
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        Column {
            id: sectionInfoColumn
            spacing: 20

            Text {
                id: featureNameTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                width: scrollViewComponent.width
                text: featureName !== "" ? featureName : "Name Unavailable"
                font {
                    bold: true
                    pointSize: 20
                }
                color: "#3B4E1E"
                wrapMode: Text.WordWrap
            }

            Text {
                id: featureAmenityTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                width: scrollViewComponent.width
                text: qsTr("<b>Amenity:  </b>") + featureAmenity
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                visible: featureAmenity !== ""
            }
            Text {
                id: featureHousenumberTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                width: scrollViewComponent.width
                text: qsTr("<b>House Number:  </b>") + featureHouseNumber
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                visible: featureHouseNumber !== ""
            }
            Text {
                id: featureStreetTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                width: scrollViewComponent.width
                text: qsTr("<b>Street:  </b>") +featureStreet
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                visible: featureStreet !== ""
            }
            Text {
                id: featureCityTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                width: scrollViewComponent.width
                text: qsTr("<b>City:  </b>") +featureCity
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                visible: featureCity !== ""
            }
            Text {
                id: featureStateTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                width: scrollViewComponent.width
                text: qsTr("<b>State:  </b>") +featureState
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                visible: featureState !== ""
            }
            Text {
                id: featureProvinceTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                width: scrollViewComponent.width
                text: qsTr("<b>Province:  </b>") +featureProvince
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                visible: featureProvince !== ""
            }
            Text {
                id: featureCountryTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                width: scrollViewComponent.width
                text: qsTr("<b>Country:  </b>") +featureCountry
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                visible: featureCountry !== ""
            }
            Text {
                id: featurePostcodeTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                width: scrollViewComponent.width
                text: qsTr("<b>Postcode:  </b>") +featurePostcode
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                visible: featurePostcode !== ""
            }
            Text {
                id: featureUnitTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                width: scrollViewComponent.width
                text: qsTr("<b>Unit:  </b>") + featureUnit
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                visible: featureUnit !== ""
            }
            Text {
                id: featureBuildingTextBox
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
                width: scrollViewComponent.width
                text: qsTr("<b>Building:  </b>") + featureBuilding
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                visible: featureBuilding !== ""
            }

            Button {
                id: closeButton
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    anchors.centerIn: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    text: "Close"
                }

                onClicked: {
                    aboutCurrentDeviceFeaturePane.visible = false
                }
            }
        }
    }
}
