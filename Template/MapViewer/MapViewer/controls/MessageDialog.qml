import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0

Dialog {
    id: messageDialog

    property string text
    property real pageHeaderHeight: messageDialog.units(56)
    property real defaultMargin: app.defaultMargin
    property var acceptedSlot: []

    signal closeCompleted ()

    modal: true

    x: 0.5 * (parent.width - width)
    y: 0.5 * (parent.height - height - messageDialog.pageHeaderHeight)
    width: Math.min(0.8 * parent.width, messageDialog.units(400))

    closePolicy: Popup.NoAutoClose

    header: SubtitleText {
        visible: text > ""
        topPadding: defaultMargin
        rightPadding: messageDialog.rightPadding
        leftPadding: messageDialog.leftPadding
        color: baseTextColor
        bottomPadding: 0
        text: messageDialog.title
        maximumLineCount: 2
        elide: Text.ElideRight
        font.bold: true
    }

    contentItem: Pane {
        id: contentContainer

        padding: 0
        Material.background: "transparent"
        topPadding: messageDialog.units(8)
        //height: message.height

        BaseText {
            id: message

            text: messageDialog.text
            maximumLineCount: 15
            anchors.centerIn: parent
            elide: Text.ElideRight
            width: parent.width
            clip: true
        }
    }

    standardButtons: Dialog.Ok

    footer: DialogButtonBox {

    }

    Component {
        id: buttonComponent

        Button {
            id: btn
            property color textColor: app.primaryColor
            Material.background: "transparent"
            contentItem: BaseText {
                text: btn.text
                font.pointSize: app.textFontSize
                color: textColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    onClosed: {
        messageDialog.title = ""
        messageDialog.text = ""
        standardButtons = Dialog.Ok
        disconnectAllFromAccepted()
    }

    function addButton (text, role, textColor) {
        if (!textColor) textColor = app.primaryColor
        if (!role) role = DialogButtonBox.AcceptRole
        if (!text) text = ""
        var btn = buttonComponent.createObject(footer, {"text": text, "DialogButtonBox.buttonRole": role, "textColor": textColor})
    }

    function disconnectAllFromAccepted () {
        for (var i=0; i<acceptedSlot.length; i++) {
            onAccepted.disconnect(acceptedSlot[i])
        }
        closeCompleted()
    }

    function connectToAccepted (method) {
        acceptedSlot.push(method)
        onAccepted.connect(acceptedSlot[acceptedSlot.length - 1])
    }

    function show (title, description) {
        if (title) messageDialog.title = title
        if (description) messageDialog.text = description
        messageDialog.open()
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}
