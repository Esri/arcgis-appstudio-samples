import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0

import "../controls" as Controls

Popup {
    id: root

    property int defaultMargin: units(16)
    property color textColor: "#FFFFFF"

    Material.background: "#323232"

    y: parent.height - (body.text > ""?units(76):units(56))
    x: (parent.width - root.width)/2


    padding: 0
    width: Math.min(units(568), parent.width)
    height: body.text > ""?units(76):units(56) //message.lineCount * units(56)
    visible: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    Item{
        width:parent.width
        height:toastcol.height

        anchors.centerIn: parent


        ColumnLayout{
            id:toastcol

            width:parent.width

            spacing:units(4)


            BaseText {
                id: message
                Layout.preferredWidth: parent.width - units(16)
                Layout.leftMargin: units(16)

                color: textColor

                Layout.alignment: Qt.AlignLeft

                elide: Text.ElideRight
                maximumLineCount: 1

            }
            BaseText {
                id: body
                visible:text > ""
                text:""
                Layout.preferredWidth: parent.width
                Layout.leftMargin: units(16)
                Layout.rightMargin: units(16)


                color: textColor
                Layout.alignment: Qt.AlignLeft
               // horizontalAlignment: Text.AlignLeft


                elide: Text.ElideRight
                maximumLineCount: 1

            }


        }
    }

    Timer {
        id: timer

        interval: 4000
        running: false
        repeat: false

        onTriggered: {
            close()
        }
    }

    onVisibleChanged: {
        if (!visible) {
            message.text = ""
        }
    }

    Behavior on y {
        NumberAnimation {
            id: transitionAnimation
            duration: 200
        }
    }

    Timer {
        id: hide

        repeat: false
        running: false
        interval: transitionAnimation.duration + 1
        onTriggered: {
            visible = false
        }
    }

    function open (pos, duration) {
        visible = true
        timer.interval = duration ? duration : 4000
        if (!pos) pos = parent.height - root.height
        // y = pos
    }

    function close (pos) {
        if (!pos) pos = parent.height
        //y = pos
        hide.start()
    }

    function show (text, pos, duration) {
        message.text = text
        root.open(pos, duration)
        timer.start()
    }
    function display (title,messageBody) {
        message.text = title
        body.text = messageBody

        root.open()

        timer.start()

    }


    function hide () {
        close()
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}
