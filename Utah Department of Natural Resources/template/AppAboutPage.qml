import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0


Rectangle {
    id: aboutPage

    property StackView stackView

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
            bottom: parent.bottom
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
                headingText: qsTr("Description")
                text: app.info.itemInfo.description
                html: true
            }

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

    //--------------------------------------------------------------------------
}
