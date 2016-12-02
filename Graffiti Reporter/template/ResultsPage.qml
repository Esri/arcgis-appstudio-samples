import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import QtQuick.LocalStorage 2.0
import "LocalStorage.js" as LocStor

Rectangle {
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor


    property bool isBusy: false

    signal next(string message)
    signal previous(string message)

    Feature {
        id: featureToEdit2
        geometry: Point {
            x:0
            y:0
            spatialReference: SpatialReference {
                wkid: 4326
            }
        }
    }


    function saveReport() {
        isBusy = true
        app.featureServiceStatusString = "Saving report as draft";

        var item;

        var attrs = [];

        var description = "No description available";

        for(var i=0; i<theFeatureAttributesModel.count; i++) {
            item = theFeatureAttributesModel.get(i);
            console.log(JSON.stringify(item));
            //attrs.push(JSON.stringify(item));
            attrs.push(item);
            if(item.name == theFeatureServiceTable.displayField) {
                console.log("found display field: ", item.name, theFeatureServiceTable.displayField);
                description = item.value
            }
        }

        var json = {}
        json.attributes = attrs;
        json.imageFilePath = app.selectedImageFilePath
        json.description = description;
        json.created = new Date().getTime()

        //var id = LocStor.getCount("drafts") || 0

        var id = json.created;

        LocStor.set("drafts",id,JSON.stringify(json));
        console.log(JSON.stringify(json));
        app.featureServiceStatusString = "Yay! Report saved as draft.";
        isBusy = false;
        app.theFeatureEditingAllDone = true
        app.hasDrafts = true
        app.featureServiceStatusString += "<br><br>You can submit the saved reports "
        app.featureServiceStatusString += "later using the SAVED DRAFTS button."
        //next("");
    }

    function submitReport(){

        //isBusy = true

        console.log("New point geom: ", JSON.stringify(app.theNewPoint.json));
        console.log("Project to Spatial Ref: ", theFeatureServiceWKID)

        var featureToEdit = ArcGISRuntime.createObject("GeodatabaseFeature");
        var pt = app.theNewPoint.project(app.theFeatureServiceSpatialReference);
        console.log("Pt geom: ", JSON.stringify(pt.json));

        featureToEdit.geometry = pt;
        console.log("Adding geometry: ", JSON.stringify(featureToEdit.geometry.json));

        var val = "", item;

        var placeHolderTextArray = {
            "esriFieldTypeInteger": console.log("int value..."),
            "esriFieldTypeSmallInteger": console.log("small int value..."),
            "esriFieldTypeSingle": console.log("float value..."),
            "esriFieldTypeDouble": console.log("double value..."), // item["fieldValue"],
            "esriFieldTypeDate": console.log("date value..."), //(new Date(item["fieldValue"])).getTime(), // || (new Date()).getTime(),
            "esriFieldTypeString": console.log("string value...") //item["fieldValue"]
        };

        var valueBlankArray = {
            "esriFieldTypeInteger": 0,
            "esriFieldTypeSmallInteger": 0,
            "esriFieldTypeSingle": 0,
            "esriFieldTypeDouble":  0,
            "esriFieldTypeDate": "",
            "esriFieldTypeString": ""
        };


        for ( var field in attributesArray) {
            console.log("!!test", field , JSON.stringify(attributesArray[field]))
             featureToEdit.setAttributeValue(field, attributesArray[field]);
        }

//        for(var i=0; i < theFeatureAttributesModel.count; i++) {
//            //item = theFeatureAttributesModel.get(i);

//            console.log(theFeatureAttributesModel.get(i).fieldType, theFeatureAttributesModel.get(i).fieldValue);

//            if (theFeatureAttributesModel.get(i).fieldValue > "") {
//                val = theFeatureAttributesModel.get(i).fieldValue;
//            }
//            else val = valueBlankArray[theFeatureAttributesModel.get(i).fieldType];

//            console.log("val is:", typeof(val), val);

//            if(theFeatureAttributesModel.get(i).fieldType === "esriFieldTypeDate") {
//                val = (new Date(theFeatureAttributesModel.get(i).fieldValue)).getTime() || (new Date()).getTime()
//            }
//// else {
////                val = item["fieldValue"] || "N/A"
////            }

//           //console.log("Setting ", item["fieldName"]);

//            featureToEdit.setAttributeValue(theFeatureAttributesModel.get(i).fieldName, val);
//        }

        app.featureServiceStatusString = "Adding the report ...";

        console.log("Submitting feature: ", JSON.stringify(featureToEdit.json));

        var id = theFeatureServiceTable.addFeature(featureToEdit);
        console.log("Feature ID:", id)

        app.theFeatureToBeInsertedID = id;
        app.featureServiceStatusString = "Submitting the report";
        app.currentAddedFeatures = theFeatureServiceTable.addedFeatures;
        theFeatureServiceTable.applyFeatureEdits();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: resultsPage_headerBar
            Layout.alignment: Qt.AlignTop
            //Layout.fillHeight: true
            color: app.headerBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            ImageButton {
                source: "images/back-left.png"
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    console.log("Back button from create page clicked")
                    previous("")
                }
            }

            Text {
                id: resultsPage_titleText
                text: "Thank You"
                textFormat: Text.StyledText
                anchors.centerIn: parent
                //anchors.left: parent.left
                //anchors.verticalCenter: parent.verticalCenter
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
                //anchors.leftMargin: 10
            }
        }

        CustomButton{
            id:page2_button3
            buttonText: "DONE"
            buttonColor: app.buttonColor
            buttonWidth: 300 * app.scaleFactor
            buttonHeight: buttonWidth/5
            opacity: app.theFeatureEditingAllDone ? 1 : 0.5
            anchors {
                //left: parent.left
                //right: parent.right
                //top: resultsPage_statusText.bottom
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                topMargin: 10*app.scaleFactor
                bottomMargin: 10*app.scaleFactor
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    next("home")
                    app.theFeatureEditingAllDone = false;
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            //color: app.pageBackgroundColor
            color:"transparent"
            Layout.preferredWidth: parent.width
            //Layout.preferredHeight: parent.height - resultsPage_headerBar.height
            anchors.topMargin: 20*app.scaleFactor
            anchors.top: resultsPage_headerBar.bottom
            anchors.bottom: page2_button3.top

            Flickable {
                //anchors.fill: parent
                width: parent.width
                height: parent.height - 100
                contentHeight: parent.height + 30

                clip: true

                Item {
                    anchors.fill: parent

                    Text {
                        id: resultsPage_statusText
                        text: app.featureServiceStatusString
                        textFormat: Text.StyledText
                        //width: 300*app.scaleFactor
                        width: parent.width
                        //anchors.top: parent.top
                        //anchors.left: parent.left
                        //anchors.right: parent.right
                        horizontalAlignment: Text.AlignHCenter
                        font {
                            pointSize: app.baseFontSize * 0.9
                        }
                        color: app.textColor
                        maximumLineCount: 8
                        wrapMode: Text.Wrap
                        lineHeight: 1.2
                        elide: Text.ElideRight
                        anchors.margins: 10*app.scaleFactor
                        anchors.topMargin: 20*app.scaleFactor

                        Component.onCompleted: {
                            Qt.inputMethod.hide();
                            if(AppFramework.network.isOnline) {
                                submitReport()
                                //saveReport();
                                if ( theFeatureServiceTable.hasAttachments && skipPressed){
                                    app.hasAttachment = true;
                                }
                            } else {
                                saveReport()
                            }
                        }
                    }

                    BusyIndicator {
                        z:11
                        visible: !app.theFeatureEditingAllDone
                        anchors.centerIn: parent
                    }

                    Image {
                        source: app.theFeatureEditingSuccess ? "./images/tick.png" : "./images/sad.png"
                        visible: app.theFeatureEditingAllDone
                        //anchors.left: parent.left
                        //anchors.right: parent.right
                        anchors.top: resultsPage_statusText.bottom
                        anchors.bottom: page2_button3.top
                        width: 128*app.scaleFactor
                        height: 128*app.scaleFactor
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }


                }
            }



        }
    }
}
