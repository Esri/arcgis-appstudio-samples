import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtMultimedia 5.2
import Qt.labs.folderlistmodel 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Rectangle {
    width: parent.width
    height: parent.height
    color: app.pageBackgroundColor
    signal next(string message)
    signal previous(string message)

    property bool isBusy: false
    property bool allDone: false

    property date calendarDate: new Date()

    property string domainFieldName: ""

    property bool backToPreviousPage: true

    Component.onCompleted: {
        if ( hasSubtypes ) {
            console.log("this has subtypes. lets load the form...")
            loader.source = "SubTypePicker.qml";
        }
        else {
            loader.source = "AttributesPage.qml";
            console.log("this DOES NOT have subtypes. lets load the attributes...")
        }
    }

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: createPage_headerBar
            Layout.alignment: Qt.AlignTop
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
                    console.log("Back button from Add Details page clicked")
                    if ( backToPreviousPage ) {
                        previous("")
                    }
                    else {
                        loader.source = "SubTypePicker.qml"
                        backToPreviousPage = true;
                    }
                }
            }

            Text {
                id: createPage_titleText
                text: "Add Details"
                textFormat: Text.StyledText
                anchors.centerIn: parent
                font {
                    pointSize: app.baseFontSize * 1.1
                }
                color: app.headerTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
            }
        }
        Loader {
            id: loader
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - createPage_headerBar.height
        }
    }

}

