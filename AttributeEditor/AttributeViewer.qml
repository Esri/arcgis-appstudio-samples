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
    property var featureToEdit: null
    property alias rBehavior: behaviorOnYAttributes
    property alias rRepeater: repeater
    property alias rFlickableValuesList: flickableValuesList

    width: parent.width
    height: parent.height - rectFeatures.height
    y: parent.height
    color: "white"
    visible: false

    MouseArea{
        anchors.fill: parent
        onClicked: {
            mouse.accepted = false
        }
    }

    Rectangle {
        id: rectAttributeHeader
        width: parent.width
        height: rectHeader.height
        color: app.info.propertyValue("titleBackgroundColor", "darkblue")

        Text {
            id: txtDetails
            height: parent.height
            width: parent.width
            text: "Details"
            color: app.headerTextColor
            font.pointSize: 18*app.scaleFactor
            font.family: app.fontSourceSansProReg.name
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            id: rectMapControl
            height: parent.height
            width: imgMapControl.implicitWidth
            color: "transparent"
            anchors {
                left: parent.left
                leftMargin: 15*app.scaleFactor
                verticalCenter: parent.verticalCenter
            }

            ImageButton {
                id: imgMapControl
                width: 20 * AppFramework.displayScaleFactor
                height: width
                source: "assets/images/map.png"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    saveFeature()
                }
            }
        }

        Rectangle {
            id: rectDeleteControl
            height: parent.height
            width: imgDeleteControl.implicitWidth
            color: "transparent"
            anchors {
                right: parent.right
                rightMargin: 35*app.scaleFactor
                verticalCenter: parent.verticalCenter
            }

            ImageButton {
                id: imgDeleteControl
                width: 20 * AppFramework.displayScaleFactor
                height: width
                source: "assets/images/trash_red.png"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    confirmDeleteDialog.dialogMain.visible = true;
                    console.log("delete button");
                }
            }
        }
    }

    Flickable {
        id: flickableValuesList
        width: parent.width
        height: parent.height - rectAttributeHeader.height
        contentHeight: col.implicitHeight
        clip: true
        anchors.top: rectAttributeHeader.bottom

        Column {
            id: col
            width: parent.width
            height: parent.height
            spacing: 5*app.scaleFactor
            anchors.top: parent.top

            Repeater {
                id: repeater

                Rectangle {
                    id: rectRepeaterItem
                    width: col.width
                    height: Math.max(35*app.scaleFactor, txtDisplayname.implicitHeight, valueEdit.implicitHeight)
                    color: "transparent"
                    visible: true//!isHidden && (fieldType > 0 && fieldType < 7)
                    anchors {
                        left: col.left
                        right: col.right
                    }

                    Text {
                        id: txtDisplayname
                        width: (parent.width/2) - 5*app.scaleFactor
                        color: app.attributeDisplayNameColor
                        text: nameAlias
                        font.family: app.fontSourceSansProReg.name
                        font.pointSize: 16*app.scaleFactor
                        wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere
                        horizontalAlignment: Text.AlignLeft
                        anchors {
                            left: parent.left
                            leftMargin: 10*app.scaleFactor
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    TextField {
                        id: valueEdit
                        width: (parent.width/2) - 5*app.scaleFactor
                        readOnly: !editable
                        text: formattedValue //isLink ? "<a href='" + value + "'>More info</a>" : value
                        placeholderText: placeHolderValue ? placeHolderValue : ""
                        font.family: app.fontSourceSansProReg.name
                        font.pointSize: 16*app.scaleFactor
                        //wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere
                        horizontalAlignment: Text.AlignRight
                        //                            linkColor: "blue"
                        //                            onLinkActivated: {
                        //                                Qt.openUrlExternally(unescape(link));
                        //                            }
                        anchors {
                            right: parent.right
                            rightMargin: 10*app.scaleFactor
                            verticalCenter: parent.verticalCenter
                        }

                        style: TextFieldStyle {
                            id: textFieldStyle
                            textColor: "black"

                            background: Rectangle {
                                radius: 2
                                border.color: "#333"
                                border.width: 1
                                color: editable ? "#ffffff" : "#e2e2e2"
                            }
                        }
                    }
                }
            }
        }
    }

    Behavior on y {
        id: behaviorOnYAttributes
        enabled: false
        NumberAnimation { duration: 400 }
    }

    ConfirmSaveDialog {
        id: confirmSaveDialog
    }

    ConfirmDeleteDialog {
        id: confirmDeleteDialog
    }

    function saveFeature(){
        var wasEdited = false;
        featureToEdit = null;

        for(var j=0; j < repeater.model.count; j++){

            var fieldName = repeater.model.get(j).name
            var displayName = repeater.model.get(j).nameAlias
            var origVal = repeater.model.get(j).originalValue
            var formatVal = repeater.model.get(j).formattedValue
            var fieldType = repeater.model.get(j).fieldType
            var textFieldVal = repeater.itemAt(j).children[1].text
            console.log(42, origVal)
            console.log(43, formatVal)

            if (formatVal !== textFieldVal){

                if (!featureToEdit) {
                    //create copy of feature
                    featureToEdit = featureServiceTable.feature(selectedId);
                    console.log(selectedId)
                    //console.log(3, featureToEdit.attributeValue(fieldName))
                    //console.log(4, fieldName)
                }

                //update generic feature
                var newDatabaseVal = textToValue(textFieldVal, fieldType);
                //console.log("here", newDatabaseVal)
                featureToEdit.setAttributeValue(fieldName, newDatabaseVal);
                //console.log(4, featureToEdit.attributeValue(fieldName))

                //table's new value
                //console.log(6, featureServiceTable.feature(selectedId).attributeValue(fieldName))

                confirmSaveDialog.dialogMain.visible = true;
                //console.log(fieldName + " not equal!")
                wasEdited = true
            }
        }

        if (featureToEdit) {
            console.log(7, featureToEdit.attributeValue(fieldName))
            console.log(8, featureServiceTable.feature(selectedId).attributeValue(fieldName))
            //queryFeatures()
        }
        else if(featureAdded == true && wasEdited == false){
            confirmSaveDialog.dialogMain.visible = true;
        }

        else{
            rectAttributes.y = app.height
            flickableValuesList.contentY = 0;
        }
    }
}
