import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0


Rectangle {
    id: disclaimerPage

    property StackView stackView
    property alias dontShowAgain: dontShowCheckBox.checked

    signal continueClicked()

    color: "#f7f8f8"

    //--------------------------------------------------------------------------

    TitleBar {
        id: titleBar

        title: app.info.itemInfo.title

        backButton {
            visible: true

            onClicked: {
                stackView.pop();
            }
        }
    }

    //--------------------------------------------------------------------------

    Flickable {
        id: flickable

        anchors {
            left: parent.left
            right: parent.right
            top: titleBar.bottom
            bottom: footerColumn.top
            margins: 10
        }

        contentWidth: contentColumn.width
        contentHeight: contentColumn.height
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Column {
            id: contentColumn

            width: flickable.width
            spacing: 10

            AboutInfoText {
                headingText: qsTr("Access and Use Constraints")
                text: app.info.itemInfo.licenseInfo
                html: true
            }

            AboutInfoText {
                headingText: qsTr("Credits")
                text: app.info.itemInfo.accessInformation
            }
        }
    }

    Column {
        id: footerColumn

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 5
        }

        spacing: 5
        SeparatorLine {
        }

        CheckBox {
            id: conditionsCheckBox

            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("I understand the terms and conditions")
            checked: false
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter

            text: qsTr("Continue")
            enabled: conditionsCheckBox.checked

            onClicked: {
                continueClicked();
                if (dontShowAgain) {
                    app.settings.setValue("dontShowDisclaimer", dontShowAgain);
                }
            }
        }

        CheckBox {
            id: dontShowCheckBox

            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Don't show this page again")
            checked: false
        }
    }

    //--------------------------------------------------------------------------
}
