import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {
    id: attributesPage
    focus: true
    anchors.fill: parent

    ListView {
        id: listView
        clip: true
        spacing: 20*app.scaleFactor
        width: 300*app.scaleFactor
        height: parent.height
        anchors.topMargin: 20*app.scaleFactor
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        model: fields.length

        property bool canSubmit: true

        delegate: Component {

            Loader {
                id: loader
                property string fieldName : fields[index]["name"]
                property string fieldAlias : fields[index]["alias"]
                property int fieldType: fields[index]["fieldType"]
                property bool hasSubTypeDomain: featureTypes[pickListIndex].domains[fields[index]["name"]] ? true : false
                property bool isSubTypeField : fields[index]["name"] === theFeatureServiceTable.typeIdField ? true : false
                property bool hasPrototype: featureTypes[pickListIndex].templates[0].prototype[fields[index]["name"]] > "" ? true : false
                property var defaultValue : hasPrototype ? featureTypes[pickListIndex].templates[0].prototype[fields[index]["name"]] : fieldType == Enums.FieldTypeString ? "" : null
                property string defaultDate : hasPrototype && fieldType == Enums.FieldTypeDate ? getDateValue() : ""
                property int defaultIndex
                property var rangeArray: []
                property var codedValueArray : []
                property var codedCodeArray: []
                property int domainTypeIndex: 0
                property var domainTypeArray
                property var functionArray

                anchors.horizontalCenter: parent.horizontalCenter

                width: 300 * app.scaleFactor

                sourceComponent: (function(){
                    //attributesArray.push( JSON.parse('{"' + fieldName + '":' + defaultValue + '}') );
                    attributesArray[fieldName] = defaultValue;
                    console.log("Attr Array for", fieldName, defaultValue )
                    console.log(JSON.stringify(attributesArray));

                    domainTypeArray = {
                        0: editControl,
                        1: rangeControl,
                        3: cvdControl,
                        99: subTypeCvdControl
                    }

                    functionArray = {
                        0: getEditControlValues,
                        1: getRangeDomainValues,
                        3: getAtrributeDomainValues,
                        99: getSubTypeAtrributeDomainValues
                    }

                    //Get the SubType Attribute codes
                    console.log("is sub type field?", isSubTypeField)
                    if ( isSubTypeField ) {
                        if ( fields[index]["domain"]) {
                            domainTypeIndex = 3;
                            functionArray[domainTypeIndex](fields[index]["domain"]);
                        }
                        else {
                            domainTypeIndex = 99;
                            functionArray[domainTypeIndex](featureTypes);
                        }

                        return domainTypeArray[domainTypeIndex];
                    }

                    console.log("...", fieldName, "has a subtype domain", hasSubTypeDomain)
                    if (hasSubTypeDomain){
                        if (featureTypes[pickListIndex].domains[fields[index]["name"]]["domainType"] == Enums.DomainTypeInherited) {
                            getFieldDomainDetails( fields[index]["domain"] );
                            domainTypeIndex =  fields[index]["domain"]["domainType"];
                        }
                        else {
                            //console.log(JSON.stringify(featureTypes[pickListIndex].domains[fields[index]["name"]], undefined, 2))

                            domainTypeIndex = featureTypes[pickListIndex].domains[fields[index]["name"]]["domainType"];
                            console.log("!!!domain index", domainTypeIndex,featureTypes[pickListIndex].domains[fields[index]["name"]])
                            getFieldDomainDetails(featureTypes[pickListIndex].domains[fields[index]["name"]]);

                        }
                        return domainTypeArray[domainTypeIndex];
                    }

                    if ( fields[index]["domain"] ) {
                        console.log("...", fieldName, "has a domain")
                        getFieldDomainDetails( fields[index]["domain"] );
                        domainTypeIndex =  fields[index]["domain"]["domainType"];
                        return domainTypeArray[domainTypeIndex];
                    }

                    functionArray[domainTypeIndex]();
                    return domainTypeArray[domainTypeIndex];
                })()

                function getFieldDomainDetails(fieldDomain){
                    domainTypeIndex = fieldDomain["domainType"];
                    console.log("...getFieldDomainDetails", domainTypeIndex)

                    functionArray[domainTypeIndex](fieldDomain);
                }

                function getEditControlValues(){
                    console.log("This is a text box");
                }

                function getRangeDomainValues(domainObject){
                    rangeArray.push(domainObject["minValue"], domainObject["maxValue"])
                }

                function getAtrributeDomainValues(domainObject){
                    console.log("getAtrributeDomainValues...");
                    console.log(JSON.stringify(domainObject, undefined, 2));

                    var array = domainObject["codedValues"];

                    console.log(array)
                    for ( var i = 0; i < array.length; i++ ) {
                        console.log(array[i]["value"], array[i]["code"])

                        codedCodeArray.push(array[i]["code"]);
                        codedValueArray.push(array[i]["name"]);
                    }
                }

                function getSubTypeAtrributeDomainValues(typesObject){
                    console.log("getSubTypeAtrributeDomainValues...");

                    for ( var type in typesObject){
                        codedCodeArray.push(typesObject[type]["featureTypeId"]);
                        codedValueArray.push(typesObject[type]["name"]);
                    }
                }

                function getDateValue(){
                    var dateMilliseconds = new Date(defaultValue)
                    defaultValue = dateMilliseconds.toLocaleDateString(Qt.locale(), app.dateTimeFormat);
                }
            }
        }

        header: Text {
            text: "Fill in the fields below"
            height: 50*app.scaleFactor
            textFormat: Text.StyledText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20*app.scaleFactor
            anchors.bottomMargin: 20*app.scaleFactor

            font {
                pointSize: app.baseFontSize * 0.9
            }

            color: app.textColor
            maximumLineCount: 1
            elide: Text.ElideRight
        }

        footer: Rectangle {
            color: "transparent"
            width: parent.width
            anchors.margins: 20*app.scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            height: page4_button1.height+page4_button2.height+50*app.scaleFactor

            CustomButton {
                id:page4_button1
                buttonText: AppFramework.network.isOnline ? "SUBMIT" : "SAVE AS DRAFT"
                buttonColor: listView.canSubmit ? app.buttonColor : "lightgrey"
                buttonWidth: 300 * app.scaleFactor
                buttonHeight: buttonWidth/5
                //visible: listView.canSubmit
                enabled: listView.canSubmit

                anchors {
                    //left: parent.left
                    //right: parent.right
                    bottom: page4_button2.top
                    //top:attributesRepeater.bottom
                    bottomMargin: 20*app.scaleFactor
                    horizontalCenter: parent.horizontalCenter
                    //centerIn: parent

                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        next("results")
                    }
                }
            }
            CustomButton {
                id:page4_button2
                buttonText: "Cancel"
                buttonColor: "red"
                buttonWidth: 300 * app.scaleFactor
                buttonHeight: buttonWidth/6
                buttonFill: false
                anchors {
                    //left: parent.left
                    //right: parent.right
                    bottom: parent.bottom
                    //top:page4_button1.bottom
                    topMargin: 10*app.scaleFactor
                    horizontalCenter: parent.horizontalCenter
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        next("welcome")
                    }
                }
            }
        }

        function onAttributeUpdate(f_name, f_value){
            console.log("Got: ", f_name, f_value, typeof(f_value));
            for(var i=0; i<theFeatureAttributesModel.count; i++) {
                var item = theFeatureAttributesModel.get(i);
                if(item["fieldName"] == f_name) {
                    item["fieldValue"] = f_value;
                }
            }
        }
    }

//    CalendarWindow {
//        id: calenderWindow
//        visible: false
//    }

    Component {
        id: editControl
        EditControl{}
    }

    Component {
        id: cvdControl
        Domain_CodedValue {}
    }

    Component {
        id: subTypeCvdControl
        SubType_CodedValue {}
    }

    Component {
        id: rangeControl
        Domain_Range {}
    }

    Component {
        id: dateControl
        DateControl {}
    }
}
