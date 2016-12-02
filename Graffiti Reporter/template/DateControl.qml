import QtQuick 2.3
import QtQuick.Controls 1.2

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
        //maximumLineCount: 2
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        color: app.textColor
    }
    TextField {

        anchors {
            left: parent.left
            right: parent.right
        }

        placeholderText: "this will be a calendar picker"
        //placeholderText: fieldType == "esriFieldTypeInteger" ? "Enter a number" : "Enter some text"
        //text:
        inputMethodHints: fieldType == "esriFieldTypeInteger" ? Qt.ImhFormattedNumbersOnly : Qt.ImhDigitsOnly
    }
    CalendarWindow {

    }
}
