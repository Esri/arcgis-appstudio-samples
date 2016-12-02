import QtQuick 2.3
import QtQuick.Controls 1.2

Rectangle {
    width: Math.min(parent.width-20*app.scaleFactor, 400*app.scaleFactor)
    height: 50*app.scaleFactor
    anchors.topMargin: 20 * app.scaleFactor
    anchors.bottomMargin: 20 * app.scaleFactor
    anchors.horizontalCenter: parent.horizontalCenter
    color: "transparent"

    Label {
        id: fieldAliasLabel

        font.italic: true
        opacity: 0.8
        //anchors.margins: 5*app.scaleFactor
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height*0.4
        width: parent.width
        anchors.bottomMargin: 5*app.scaleFactor
        fontSizeMode: Text.HorizontalFit
        //maximumLineCount: 2
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        color: app.textColor
    }
    TextField {
        id: attributeTextField

        property variant validBottom
        property variant validTop

        //enabled: domain
        visible: enabled

        height: parent.height * 0.6
        width: parent.width
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        focus: true
        inputMethodHints: (function(){

            var placeHolderTextArray = {
                "esriFieldTypeInteger": "Enter a number",
                "esriFieldTypeSmallInteger": "Enter a number",
                "esriFieldTypeDouble": "Enter a number",
                "esriFieldTypeDate": "Enter a date",
                "esriFieldTypeString": "Enter some text"

            };

            var inputMethodsArray = {
                "esriFieldTypeInteger": Qt.ImhDigitsOnly,
                "esriFieldTypeSmallInteger": Qt.ImhDigitsOnly,
                "esriFieldTypeDouble": Qt.ImhFormattedNumbersOnly,
                "esriFieldTypeDate": Qt.ImhDate,
                "esriFieldTypeString": Qt.ImhNone

            };


            placeholderText = placeHolderTextArray[fieldType];
            return  inputMethodsArray[fieldType];

        })()



        Keys.onEnterPressed: {
            attributesListView.onAttributeUpdate(objectName, text)
        }

        Keys.onReturnPressed: {
            attributesListView.onAttributeUpdate(objectName, text)
            Qt.inputMethod.hide();
        }

        //width: parent.width
        //height: 30*app.scaleFactor
        //anchors.fill: parent
        //anchors.margins: 5*app.scaleFactor
        text: fieldValue
        maximumLength: 100
        //placeholderText: "Enter " + (fieldType == "esriFieldTypeInteger"? "a number" : "some text")
        objectName: fieldName

        opacity: readOnly ? 0.5: 1

        readOnly: (function(){
            //return fieldName == theFeatureServiceTable.typeIdField || fieldType == "esriFieldTypeDate"
            return fieldName == theFeatureServiceTable.typeIdField
        })()

        //fieldType == "esriFieldTypeDate" ? false : false

        Component.onCompleted: {
            console.log("Completed: ", fieldType);

            if (domainType === "RangeDomain"){
                for ( var a = 0; a < domainRangeArray.length; a++ ){
                    if (domainRangeArray[a][0] === fieldName){
                        fieldAliasLabel.text = fieldAlias + ": (" + domainRangeArray[a][1] + " - "+ domainRangeArray[a][2] + ")";
                    }

                    if (fieldType == "esriFieldTypeDouble"){
                        if (domainRangeArray[a][0] === fieldName){
                            dblValidator.bottom = domainRangeArray[a][1];
                            dblValidator.top = domainRangeArray[a][2];

                            validBottom = domainRangeArray[a][1];
                            validTop = domainRangeArray[a][2];

                            validator = dblValidator;

                        }
                    }

                    if (fieldType == "esriFieldTypeInteger"){
                        if (domainRangeArray[a][0] === fieldName){
                            intValidator.bottom = domainRangeArray[a][1];
                            intValidator.top = domainRangeArray[a][2];

                            validBottom = domainRangeArray[a][1];
                            validTop = domainRangeArray[a][2];

                            validator = intValidator;
                        }
                    }
                }
            }
            else{
                fieldAliasLabel.text = fieldAlias + ":"
            }

            attributesListView.onAttributeUpdate(objectName, text);
        }

        onTextChanged: {
            if (validator){
                if (text >= validBottom && text <= validTop){
                    fieldAliasLabel.color = "green"
                }
                else {
                    fieldAliasLabel.color ="red"
                }
            }
        }

        onAccepted: {
            console.log("input accepted: ", objectName, text)
            attributesListView.onAttributeUpdate(objectName, text)
        }

        onEditingFinished: {
            console.log("editing finished for: ", objectName, text)
            attributesListView.onAttributeUpdate(objectName, text)
        }

        onFocusChanged: {
            console.log("FocusChanged: fieldType is ", fieldType, objectName)

        }

        onActiveFocusChanged: {
            console.log("ActiveFocusChanged: fieldType is ", fieldType)
            if(fieldType == "esriFieldTypeDate") {
                //calendarWindow.visible = true
                //text = calendarDate.toDateString()
                //fieldValue = calendarDate.toDateString()
            }
            attributesListView.onAttributeUpdate(objectName, text)
        }


        Binding on text {
            when: fieldType == "esriFieldTypeDate"
            value: calendarDate.toDateString()
        }

        Binding {
            target: parent.parent
            property: objectName
            value: parent.text
        }
    }

}

