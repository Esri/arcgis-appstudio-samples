import QtQuick 2.0

Rectangle {
    id: gv_

    width: 460
    height: 640
    color: "black"

    property bool menu_shown: false

    /* this rectangle contains the "menu" */
    Rectangle {
        id: menu_view_
        anchors.fill: parent
        color: "#303030";
        opacity: gv_.menu_shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        /* this is my sample menu content (TODO: replace with your own)  */
        ListView {
            anchors { fill: parent; margins: 22 }
            model: 8
            delegate: Item { height: 80; width: parent.width;
                Text { anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                    color: "white"; font.pixelSize: 32; text: "This is menu #" + index  }
                Rectangle { height: 2; width: parent.width * 0.7; color: "gray"; anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom } }
            }
        }
    }

    /* this rectangle contains the "normal" view in your app */
    Rectangle {
        id: normal_view_
        anchors.fill: parent
        color: "white"

        /* this is what moves the normal view aside */
        transform: Translate {
            id: game_translate_
            x: 0
            Behavior on x { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
        }

        /* this is the menu shadow */
        BorderImage {
            id: menu_shadow_
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: -10
            z: -1 /* this will place it below normal_view_ */
            visible: gv_.menu_shown
            source: "shadow.png"
            border { left: 12; top: 12; right: 12; bottom: 12 }
        }

        /* quick and dirty menu "button" for this demo (TODO: replace with your own) */
        Rectangle {
            id: menu_bar_
            anchors.top: parent.top
            width: parent.width; height: 100; color: "darkBlue"
           Rectangle {
                id: menu_button_
                anchors {left: parent.left; verticalCenter: parent.verticalCenter; margins: 24 }
                color: "white"; width: 64; height: 64; smooth: true
                scale: ma_.pressed ? 1.2 : 1
                Text { anchors.centerIn: parent; font.pixelSize: 48; text: "!" }
                MouseArea { id: ma_; anchors.fill: parent; onClicked: gv_.onMenu(); }
            }
        }


        /* this is my sample "normal" contant (TODO: replace with your own)  */
        GridView {
            anchors { top: menu_bar_.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: 30 }
            clip: true; model : 20;
            delegate: Rectangle { width: 80; height: 80; color: Qt.rgba( Math.random(), Math.random(), Math.random(), 1) }
        }

        /* put this last to "steal" touch on the normal window when menu is shown */
        MouseArea {
            anchors.fill: parent
            enabled: gv_.menu_shown
            onClicked: gv_.onMenu();
        }
    }

    /* this functions toggles the menu and starts the animation */
    function onMenu()
    {
        game_translate_.x = gv_.menu_shown ? 0 : gv_.width * 0.9
        gv_.menu_shown = !gv_.menu_shown;
    }
}

