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

Rectangle {
    property alias dialogMain: confirmChangesDialog

    id: confirmChangesDialog
    width: app.width
    height: app.height
    color: "white"
    opacity: .8
    visible: false

    Rectangle {
        id: confirmChangesHeader
        width: parent.width - 100 * scaleFactor
        height: rectHeader.height
        color: app.headerBarColor
        anchors{
            centerIn: confirmChangesDialog
            verticalCenterOffset: -100*scaleFactor
        }

        Text {
            id: confirmTxtDetails
            height: parent.height
            width: parent.width
            text: featureAdded ? "Save new feature?" : "Save changes?"
            color: app.headerTextColor
            font.pointSize: 18*app.scaleFactor
            font.family: app.fontSourceSansProReg.name
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        id: confirmChangesControlHeader
        width: parent.width - 100 * scaleFactor
        height: rectHeader.height
        color: app.headerBarColor
        anchors{
            top: confirmChangesHeader.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: rectSaveControl
            height: parent.height
            width: parent.width/2
            color: "transparent"
            anchors.left: parent.left

            Text {
                id: txtSaveControl
                text: "Save"
                color: app.headerTextColor
                font.pointSize: 16*app.scaleFactor
                font.family: app.fontSourceSansProReg.name
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("saved")
                    console.log(selectedId)
                    featureServiceTable.updateFeature(selectedId, featureToEdit)
                    featureServiceTable.applyFeatureEdits();
                    featureAdded = false
                    confirmChangesDialog.visible = false;
                    rectAttributes.y = app.height
                    flickableValuesList.contentY = 0
                    //queryFeatures()
                }
            }
        }

        Rectangle {
            id: rectCancelControl
            height: parent.height
            width: parent.width/2
            color: "transparent"
            anchors.right: parent.right

            Text {
                id: txtCancelControl
                text: "No"
                color: app.headerTextColor
                font.pointSize: 16*app.scaleFactor
                font.family: app.fontSourceSansProReg.name
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("No");
                    confirmChangesDialog.visible = false;
                    if (featureAdded == true){
                        featureServiceTable.deleteFeature(selectedId);
                        featureAdded = false
                        rectFeatures.y = app.height
                    }
                    queriedFeaturesModel.clear();
                    rectAttributes.y = app.height
                    // Update bool for feature selected
                    featureSelected = false
                }
            }
        }
    }
}

