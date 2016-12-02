import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Dialogs 1.2

Dialog {
    id: dialog
    title: "Choose a date"
    standardButtons: StandardButton.Ok | StandardButton.Cancel

    modality: Qt.ApplicationModal

    property alias minDate : calendar.minimumDate
    property alias maxDate : calendar.maximumDate
    property alias selectedDate: calendar.selectedDate
    property real dateMilliseconds: selectedDate.valueOf()

    contentItem: Calendar {
        id: calendar

        anchors.centerIn: parent

        onClicked: {
            dialog.visible = false;
        }

    }
}

