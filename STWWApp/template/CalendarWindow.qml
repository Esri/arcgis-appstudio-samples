import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

//Thanks to
//http://doc.qt.digia.com/qtquick-components-symbian-1.1/demos-symbian-musicplayer-qml-filepickerpage-qml.html

Item {
    id: calendarWindow

//    width: parent.width
//    height: parent.height

    width: app.width
    height: app.height

    //z: 88

    property string title: "Date Picker"

    //visible: false

    property date currentDate : new Date()

    signal select(date dateSelected)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerBar
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: app.headerBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 50 * app.scaleFactor

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Text {
                id: titleText
                text: title
                textFormat: Text.StyledText
                //anchors.centerIn: parent
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
                anchors.leftMargin: 10
            }

            ImageButton {
                source: "images/back-left.png"
                rotation: -90
                height: 30 * app.scaleFactor
                width: 30 * app.scaleFactor
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    console.log(currentDate.toDateString())
                    select(currentDate)
                    calendarWindow.visible = false
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            color: app.pageBackgroundColor
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - headerBar.height

            Calendar {
                //width: parent.width*0.8
                anchors.horizontalCenter: parent.horizontalCenter
                selectedDate: new Date()
                onSelectedDateChanged: {
                    currentDate = selectedDate
                    console.log("!", selectedDate.getDate(), currentDate.toISOString() )
                    select(currentDate);
                    calendarWindow.visible = false;
                    console.log(currentDate.format("dd-mm-yy"))
                }
            }
        }


    }

}
