import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import "../controls" as Controls

Flickable {
    id: infoView

    property string titleText
    property string ownerText
    property string modifiedDateText

    property string snippetText
    property string descriptionText
    property real minContentHeight: 0

    clip: true
    contentHeight: content.height + 150 * scaleFactor

    ColumnLayout {
        id: content

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: app.defaultMargin
        }
        spacing: app.baseUnit

        Controls.BaseText {
            id: itemTitle

            text: titleText
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: false
            Layout.preferredHeight: itemTitle.contentHeight
            Layout.fillWidth: true
            font.weight: Font.Bold
        }
        Controls.BaseText {
            id: itemOwner
            visible: ownerText > ""
            text: "Owner: "+ ownerText
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: false
            Layout.preferredHeight: itemOwner.contentHeight
            Layout.fillWidth: true
            font.weight: Font.Bold
        }
        Controls.BaseText {
            id: itemModifiedDate
            visible:modifiedDateText > ""

            text: "Modified Date: "+ modifiedDateText
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: false
            Layout.preferredHeight: itemModifiedDate.contentHeight
            Layout.fillWidth: true
            font.weight: Font.Bold
        }

        Controls.BaseText {
            id: itemSnippet

            visible: text > ""
            text: infoView.snippetText
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: false
            Layout.preferredHeight: itemSnippet.contentHeight
            Layout.fillWidth: true
            font.pointSize: app.textFontSize
            opacity: 0.9
            textFormat: Text.StyledText
            onLinkActivated: {
                app.openUrlInternally(link)
            }
        }

        Controls.BaseText {
            id: itemDescription

            text: infoView.descriptionText
            Layout.alignment: Qt.AlignTop
            //Layout.fillHeight: true
            Layout.preferredHeight: itemDescription.contentHeight
            Layout.fillWidth: true
            font.pointSize: app.textFontSize
            opacity: 0.8
            textFormat: Text.StyledText
            onLinkActivated: {
                app.openUrlInternally(link)
            }
            //Component.onCompleted: {
            //    console.log(infoView.descriptionText)
            //}
        }
    }
}
