import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

Column {
    id: column
    spacing: 3
    anchors {
        left: parent.left
        right: parent.right
    }
    Label {
        text: fieldAlias
        font.italic: true
        opacity: 0.8
        fontSizeMode: Text.HorizontalFit
        anchors {
            left: parent.left
            right: parent.right
        }
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        color: app.textColor
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
        inputMethodHints: fieldType > 0 && fieldType < 5 ? Qt.ImhDigitsOnly : null
        //enabled: fieldType == Enums.FieldTypeDate ? false : true

        onTextChanged: {
            attributesArray[fieldName] = text;
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


    CalendarDialog {
        id: calendarPicker

        onVisibleChanged: {
            if (!visible) {
                textField.text = selectedDate.toLocaleDateString(Qt.locale(), app.dateTimeFormat);
                attributesArray[fieldName] = dateMilliseconds;
                console.log("///", selectedDate);
            }
        }
    }
}
