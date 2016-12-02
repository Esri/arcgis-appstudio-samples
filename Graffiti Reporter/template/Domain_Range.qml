import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework.Runtime 1.0

Column {
    id: column

    property string rangeMinLabel //: fieldType == Enums.FieldTypeDate ? rangeArray[0].toLocaleDateString(Qt.locale(), app.dateTimeFormat) : rangeArray[0]
    property string rangeMaxLabel //: fieldType == Enums.FieldTypeDate ? rangeArray[1].toLocaleDateString(Qt.locale(), app.dateTimeFormat) : rangeArray[1]

    spacing: 3
    anchors {
        left: parent.left
        right: parent.right
    }

    Label {
        id: label
        text: fieldAlias + " (" + rangeMinLabel + " - " + rangeMaxLabel +")"
        font.italic: true
        opacity: textField.acceptableInput ? 0.8 : 1
        fontSizeMode: Text.HorizontalFit
        anchors {
            left: parent.left
            right: parent.right
        }
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        color: fieldType == Enums.FieldTypeDate ? app.textColor : textField.acceptableInput ? "green" : "red"
    }

    TextField {
        id: textField

        property date todaysDate : new Date()

        anchors {
            left: parent.left
            right: parent.right
        }


        placeholderText: fieldType == Enums.FieldTypeString ? "Enter some text" : fieldType == Enums.FieldTypeDate ? app.dateTimeFormat : "Enter a number"
        text: defaultValue ? defaultValue : fieldType == Enums.FieldTypeString ? "" : fieldType == Enums.FieldTypeDate ? todaysDate.toLocaleDateString(Qt.locale(), app.dateTimeFormat) : 0
        inputMethodHints: fieldType > 0 && fieldType < 5 ? Qt.ImhDigitsOnly : fieldType == Enums.FieldTypeDate ? Qt.ImhDate : null
        //enabled: fieldType == Enums.FieldTypeDate ? false : true

        validator:  fieldType == "esriFieldTypeDouble" ? dblValidator : intValidator

        onTextChanged: {
            if ( fieldType != Enums.FieldTypeDate) {
                console.log("Is the range value for", fieldName, "is acceptable?", acceptableInput);
                listView.canSubmit = acceptableInput;

                attributesArray[fieldName] = text;
            }
        }

        Button {
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            width: height

            visible: fieldType == Enums.FieldTypeDate ? true : false
            enabled: visible
            onClicked: {
                calendarPicker.visible = true;
            }

            Image {
                anchors.fill: parent
                anchors.margins: 1

                fillMode: Image.PreserveAspectFit
                source: "./images/calendar.png"
            }
        }

        Component.onCompleted: {
            //listView.onAttributeUpdate(objectName, text)
            attributesArray[fieldName] = text;

        }
    }

    
//    RowLayout {

//        anchors {
//            left: parent.left
//            right: parent.right
//        }
//        TextField {
//            id: textField
            
//            Layout.fillWidth: true

//            placeholderText: "range..."
//            text: defaultValue
//            inputMethodHints: fieldType == Enums.FieldTypeDate ? Qt.ImhDate : Qt.ImhDigitsOnly
//            activeFocusOnPress: true

//            enabled: fieldType == Enums.FieldTypeDate ? fasle : true

//            validator:  fieldType == "esriFieldTypeDouble" ? dblValidator : intValidator
            
//            onTextChanged: {
//                if ( fieldType != Enums.FieldTypeDate) {
//                    console.log("Is the range value for", fieldName, "is acceptable?", acceptableInput);
//                    listView.canSubmit = acceptableInput;

//                    attributesArray[fieldName] = text;
//                }
//            }
            
//            Component.onCompleted: {
//                attributesArray[fieldName] = text;
//            }
//        }
        
//        Button {
//            text: "..."
//            visible: fieldType == Enums.FieldTypeDate ? true : false
//            onClicked: calendarPicker.visible = true
//        }
//    }
    
    IntValidator {
        id: intValidator
        
        bottom: rangeArray[0]
        top: rangeArray[1]
    }
    
    DoubleValidator {
        id: dblValidator
        
        bottom: rangeArray[0]
        top: rangeArray[1]
    }
    
    
    CalendarDialog {
        id: calendarPicker

        onVisibleChanged: {
            if (!visible) {
                console.log("///", dateMilliseconds)
                textField.text = selectedDate.toLocaleDateString(Qt.locale(), app.dateTimeFormat);
                attributesArray[fieldName] = dateMilliseconds;
            }
        }
    }

    Component.onCompleted: {
        if ( fieldType == Enums.FieldTypeDate ) {
            var dMin = new Date(rangeArray[0]);
            var dMax = new Date(rangeArray[1]);

            rangeMinLabel = dMin.toLocaleDateString(Qt.locale(), app.dateTimeFormat);
            rangeMaxLabel = dMax.toLocaleDateString(Qt.locale(), app.dateTimeFormat);

            calendarPicker.minDate = dMin;
            calendarPicker.maxDate = dMax;
        }
        else {
            rangeMinLabel = rangeArray[0];
            rangeMaxLabel = rangeArray[1];
        }
    }

}
