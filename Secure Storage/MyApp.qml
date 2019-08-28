/* Copyright 2019 Esri
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

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
//import Esri.ArcGISRuntime 100.1

import ArcGIS.AppFramework.SecureStorage 1.0

import "controls" as Controls

App {
    id: app
    width: 400
    height: 750
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    property string insertSuccessMessage: qsTr ("Inserted into Keychain")
    property string removeSuccessMessage: qsTr ("Removed from Keychain")

    property string failMessage:qsTr("Something Went Wrong")

    property color successColor: Material.color(Material.Teal)
    property color errorColor: Material.color(Material.DeepOrange)

    Page {
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle {
            anchors.top:header.bottom

            ColumnLayout {
                spacing: 5 * scaleFactor
                anchors.horizontalCenter: parent.horizontalCenter
                // Insert key in this text field
                TextField {
                    id: key
                    placeholderText: "Enter key"
                    Material.accent: "#8f499c"
                    Layout.topMargin: 100 * scaleFactor
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
                // Insert value in this text field
                TextField {
                    id: value
                    placeholderText: "Enter value"
                    Material.accent: "#8f499c"
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                //Click on the button to store key and value in the keychain
                Button {
                    id: secureButton
                    text: qsTr("Secure Data to Keychain")
                    onClicked: {
                        toastMessageRec.visible = true
                        retrieveData.visible = false

                        // check if key and value is not null and not empty
                        if (key.text.length > 0 && key.text !== null) {

                            // store key and value into Keychain
                            SecureStorage.setValue(key.text,value.text)
                            toastMessage.text = insertSuccessMessage
                            toastMessageRec.color = successColor
                        }
                        else {
                            toastMessage.text = failMessage;
                            toastMessageRec.color = errorColor;
                        }
                    }
                }

                //Click on the button to retrive data
                Button{
                    id: retrieveButton
                    text: qsTr("Retrieve Data From Keychain")
                    onClicked: {
                        // Retrive value
                        retrieveData.text = qsTr("Value: ") + SecureStorage.value(key.text);
                        toastMessageRec.visible = false
                        retrieveData.visible = true
                    }
                }

                //Click on the button to remove data from the keychain
                Button {
                    id: removeButton
                    text: qsTr("Clear Entry From Keychain")
                    onClicked: {
                        retrieveData.visible = false
                        toastMessageRec.visible = true
                        // check if key and value is not null and not empty
                        if ( key.text.length > 0 && key.text !== null) {
                            // Remove key by setting vlaue as an empty string
                            SecureStorage.setValue(key.text,"")
                            toastMessage.text = removeSuccessMessage
                            toastMessageRec.color = successColor
                            key.text = ""
                            value.text = ""
                        }
                        else {
                            toastMessage.text = failMessage;
                            toastMessageRec.color = errorColor;
                        }
                    }
                }

                //Display retrieved data
                Text {
                    id: retrieveData
                    Layout.fillWidth: true
                    font.pointSize: 10
                    Layout.preferredWidth: parent.width
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    id: maximumKey
                    Layout.fillWidth: true
                    font.pointSize: 10
                    Layout.preferredWidth: parent.width
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("Maximum Key Size: ") + SecureStorage.maximumKeyLength
                }

                Text {
                    id: maximumValue
                    Layout.fillWidth: true
                    font.pointSize: 10
                    Layout.preferredWidth: parent.width
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignLeft
                    text: qsTr("Maximum Value Size: ") + SecureStorage.maximumValueLength
                }
            }
        }

        //Display toast message
        Rectangle {
            id: toastMessageRec
            height: 40 * scaleFactor
            width: toastMessage.text === "" ? 0 : toastMessage.width + 30 * scaleFactor
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 18 * scaleFactor

            Label {
                id: toastMessage
                anchors.centerIn: parent
                font.bold: true
                font.pointSize: 10
                color: "white"
            }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

