import QtQuick 2.12

Item {
    id: appToast

    width: toastText.width + 20
    height: toastText.height + 20

    property alias background: toastFrame.color
    property alias color: toastText.color
    property alias font: toastText.font
    property alias duration: toastTimer.duration

    Rectangle {
        id: toastFrame

        anchors.fill: parent
        color: "black"
        radius: 5
        opacity: getOpacity( toastTimer.remaining )
        visible: false
    }

    Text {
        id: toastText

        anchors.centerIn: parent
        color: "white"
        opacity: getOpacity( toastTimer.remaining )
        visible: false
    }

    Timer {
        id: toastTimer

        property var startTime: Date.now()
        property int duration: 1500
        property var now: Date.now()
        property var remaining: startTime + duration - now

        repeat: true
        interval: 100

        onTriggered: {
            now = Date.now();
            if ( remaining < 0.0 )
            {
                toastFrame.visible = false;
                toastText.visible = false;
                stop();
                return;
            }
        }
    }

    function show( message, duration )
    {
        toastFrame.visible = true;

        toastText.text = message;
        toastText.visible = true;

        toastTimer.startTime = toastTimer.now = Date.now();
        toastTimer.start();

    }

    function getOpacity( remaining )
    {
        if ( remaining >= 1000 )
        {
            return 1.0;
        }

        if ( remaining <= 0 )
        {
            return 0;
        }

        return remaining / 1000.0;
    }
}
