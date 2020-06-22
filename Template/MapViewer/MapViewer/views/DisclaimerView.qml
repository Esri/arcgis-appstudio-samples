import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

import "../controls" as Controls

Controls.CustomDialog {
    id: disclaimerDialog
    
    Material.primary: app.primaryColor
    Material.accent: app.accentColor
    pageHeaderHeight: app.headerHeight
    height: Math.min(content.height + footer.height + 2 * app.defaultMargin +  headerContent.height, width)
    modal: Qt.WindowModal

    header: Pane {
        id: headerContent

        height: 0.8 * app.headerHeight
        leftPadding: disclaimerDialog.leftPadding
        topPadding: app.defaultMargin
        Material.background: "#FFFFFF"
        Controls.SubtitleText {
            text: qsTr("Access and Use Constraints")//qsTr("Disclaimer")
            visible: accessAndUse.text > ""
            verticalAlignment: Qt.AlignVCenter
            color: app.baseTextColor
            font.bold: true
            anchors.fill: parent
            textFormat: Text.StyledText
        }
    }

    content: ColumnLayout {
        id: contentItem

//        Controls.SubtitleText {
//            id: accessAndUseTitle
//            text: qsTr("Access and Use Constraints")
//            visible: accessAndUse.text > ""
//            Layout.preferredWidth: parent.width
//            textFormat: Text.StyledText
//        }
        Controls.BaseText {
            id: accessAndUse

            visible: accessAndUse.text > ""
            text: app.info.itemInfo.licenseInfo || ""
            Layout.preferredWidth: parent.width
            Layout.topMargin: app.defaultMargin
            textFormat: Text.StyledText
            onLinkActivated: {
                app.openUrlInternally(link)
            }
        }

//        Controls.SubtitleText {
//            id: creditsTitle
//            text: qsTr("Credits")
//            visible: credits.text > ""
//            Layout.preferredWidth: parent.width
//            textFormat: Text.StyledText
//        }
//        Controls.BaseText {
//            id: credits

//            visible: credits.text > ""
//            text: app.info.itemInfo.accessInformation || ""
//            Layout.preferredWidth: parent.width
//            textFormat: Text.StyledText
//            onLinkActivated: {
//                app.openUrlInternally(link)
//            }
//        }
    }

//    footer: Pane {
//        id: footerItem

//        leftPadding: app.defaultMargin
//        rightPadding: app.defaultMargin
//        Material.background: "#FFFFFF"
//        height: app.units(88)
//        width: parent.width
//        ColumnLayout {
//            id: footerContent

//            anchors.fill: parent
//            spacing: 0

//            RowLayout {
//                Layout.fillWidth: true
//                Layout.preferredHeight: parent.height - okBtn.height

//                CheckBox {
//                    id: chkbox
//                    checked: false
//                }

//                Controls.BaseText {
//                    id: label

//                    objectName: "label"
//                    visible: label.text.length > 0
//                    text: qsTr("Do not show again.")
//                    Layout.preferredWidth: footerContent.width
//                    Layout.preferredHeight: contentHeight
//                    elide: Text.ElideRight
//                    wrapMode: Text.WordWrap
//                    MouseArea {
//                        anchors.fill: parent
//                        onClicked: chkbox.checked = !chkbox.checked
//                    }
//                }
//            }

//            Button {
//                id: okBtn
//                text: qsTr("OK")
//                Material.background: "#FFFFFF"
//                Material.elevation: 0

//                contentItem: Controls.BaseText {
//                    id: txt

//                    text: okBtn.text
//                    opacity: enabled ? 1.0 : 0.3
//                    color: app.accentColor
//                    horizontalAlignment: Text.AlignHCenter
//                    verticalAlignment: Text.AlignVCenter
//                    elide: Text.ElideRight
//                }

//                background: Rectangle {
//                    id: bck

//                    implicitWidth: txt.contentWidth + 1.5 * defaultMargin
//                    implicitHeight: txt.contentHeight
//                    color: (okBtn.down || okBtn.hovered) ?  "#F4F4F4" : "#FFFFFF"
//                    opacity: okBtn.enabled ? 1 : 0.3
//                }

//                anchors {
//                    right: parent.right
//                }

//                Controls.Ink {
//                    anchors.fill: parent
//                    onClicked: {
//                        if (chkbox.checked) {
//                            app.settings.setValue("disableDisclaimer", chkbox.checked)
//                        }
//                        disclaimerDialog.close()
//                    }
//                }
//            }
//        }
//    }


    standardButtons: StandardButton.Ok

    onAccepted: {
        app.settings.setValue("disableDisclaimer", true)
        disclaimerDialog.close()
    }
}
