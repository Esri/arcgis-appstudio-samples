import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {
    focus: true

    ListView {
        clip: true
        spacing: 20*app.scaleFactor
        width: 300*app.scaleFactor
        height: parent.height
        anchors.topMargin: 20*app.scaleFactor
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        model: theFeatureTypesModel

                header: Text {
                    text: app.pickListCaption // "Pick a Type"
                    height: text > "" ? 50*app.scaleFactor: 0
                    textFormat: Text.StyledText
                    anchors.horizontalCenter: parent.horizontalCenter
                    //anchors.verticalCenter: parent.verticalCenter
                    anchors.topMargin: 20*app.scaleFactor
                    anchors.bottomMargin: 20*app.scaleFactor
                    font {
                        pointSize: app.baseFontSize * 0.9
                    }
                    color: app.textColor
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

        delegate: Component {

            id: issueListViewDelegate

            Rectangle{
                width: 300*app.scaleFactor
                height: 50*app.scaleFactor
                color: app.pageBackgroundColor
                anchors.margins: 10*app.scaleFactor
                anchors.horizontalCenter: parent.horizontalCenter
                objectName: value
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height-parent.anchors.margins
                    Image{
                        source: imageUrl
                        height : parent.height
                        width: height
                        fillMode: Image.PreserveAspectFit
                        enabled: status == Image.Error ? false : true
                        visible: enabled
                        onStatusChanged: if (status == Image.Error) source = "images/item_thumbnail_square.png"
                    }

                    Text {
                        text: label
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        anchors.leftMargin: 20*app.scaleFactor
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 10*app.scaleFactor
                        font {
                            pointSize: app.baseFontSize * 0.8
                        }
                        color: app.textColor
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        getProtoTypeAndSubTypeDomains(index);
                    }
                }
            }
        }
    }

    function getProtoTypeAndSubTypeDomains(pickedIndex) {
        console.log("Prototypes length", app.featureTypes.length)
        //var featureType = app.featureTypes[pickedIndex];
        featureType = app.featureTypes[pickedIndex];
        //selectedFeatureType = app.featureTypes[pickedIndex];

        console.log("!!!", JSON.stringify(featureType.templates[0].prototype, undefined, 2));

//        var prototype = featureType.templates[0].prototype;
        var domains = featureType.domains;

        for ( var j = 0; j < fields.length; j++ ) {
//            console.log("working on", fields[j].name, "...");

//            if ( prototype.hasOwnProperty(fields[j].name) ) {
//                var defaultValue;

//                if ( !prototype[fields[j].name] ) {
//                    defaultValue = "";
//                }
//                else {
//                    defaultValue = prototype[fields[j].name];
//                }

//                console.log(j, "of", fields.length, "the default value for", fields[j].name, "is", prototype[fields[j].name], typeof(prototype[fields[j].name]));
//                //if ( fields[j].fieldType === Enums.FieldTypeInteger) {
//                if ( typeof(defaultValue) === "number" ) {
//                    theFeatureAttributesModel.setProperty(j, "defaultNumber", parseInt(defaultValue));
//                }
//                else {
//                    theFeatureAttributesModel.setProperty(j, "fieldValue", defaultValue);
//                }
//            }

//            console.log(fields[j].name, "===", theFeatureServiceTable.typeIdField)

            if ( fields[j].name === theFeatureServiceTable.typeIdField ) {
                theFeatureAttributesModel.setProperty(j, "isSubTypeField", true);
//                console.log(fields[j].name, theFeatureAttributesModel.get(j).isSubTypeField)
            }

//            if ( domains.hasOwnProperty(fields[j].name) ) {
////                console.log(fields[j].name, "Lets go and get the domain information...");
//                theFeatureAttributesModel.setProperty(j, "hasSubTypeDomain", true);

//                //                for ( var domainInfo in domains ){

//                //                    if ( domains[domainInfo].hasOwnProperty("codedValues") ) {

//                //                        for ( var s in domains[domainInfo]["codedValues"] ) {
//                //                            console.log(" > ", s, domains[domainInfo]["codedValues"][s]["value"] );
//                //                            subTypeValueArray.push( domains[domainInfo]["codedValues"][s]["value"] );
//                //                            subTypeCodeArray.push( s );
//                //                        }
//                ////                        theFeatureAttributesModel.setProperty(j, "domainValues", domainArray);
//                //                        console.log("array length:", subTypeValueArray.length)
//                //                    }
//                //                }
//            }
        }
        pickListIndex = pickedIndex;
        backToPreviousPage = false;

        loader.source = "AttributesPage.qml"

    }
}

