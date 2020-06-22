import QtQuick 2.7
import QtGraphicalEffects 1.0
import ArcGIS.AppFramework 1.0
import "."

MouseArea {
    id: view

    clip: true
    //hoverEnabled: Device.hoverEnabled
    z: 2
//    anchors.fill: parent

    property int startRadius: circular ? width/10 : width/6
    property int endRadius

    property Item lastCircle
    property color color: "#190079c1"

    property bool circular: false
    property bool centered: false

    property int focusWidth: width - units(32)
    property bool focused
    property color focusColor: "transparent"

    property bool showFocus: true

    property bool isCircleCreated: false

    onPressed: {
        if(isCircleCreated==false){
            createTapCircle(mouse.x, mouse.y)
            isCircleCreated = true
        }
    }

    onCanceled: {
        if(lastCircle!=null)lastCircle.removeCircle();
    }

    onReleased: {
        if(lastCircle!=null)lastCircle.removeCircle();
    }

    function createTapCircle(x, y) {
        endRadius = centered ? width/2 : radius(x, y)
        showFocus = false

        lastCircle = tapCircle.createObject(view, {
                                                "circleX": centered ? width/2 : x,
                                                                      "circleY": centered ? height/2 : y
                                            });
    }

    function radius(x, y) {
        var dist1 = Math.max(dist(x, y, 0, 0), dist(x, y, width, height))
        var dist2 = Math.max(dist(x, y, width, 0), dist(x, y, 0, height))

        return Math.max(dist1, dist2)
    }

    function dist(x1, y1, x2, y2) {
        var xs = 0;
        var ys = 0;

        xs = x2 - x1;
        xs = xs * xs;

        ys = y2 - y1;
        ys = ys * ys;

        return Math.sqrt( xs + ys );
    }

    Rectangle {
        id: focusBackground

        anchors.fill: parent

        color: "#19007932"

        opacity: showFocus && focused ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }
    }

    Rectangle {
        id: focusCircle

        anchors.centerIn: parent

        width: focused
               ? focusedState ? focusWidth
                              : Math.min(parent.width - 8 , focusWidth + 12 )
        : parent.width/5
        height: width

        radius: width/2

        opacity: showFocus && focused ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }

        Behavior on width {
            NumberAnimation { duration: focusTimer.interval; }
        }

        color: focusColor.a === 0 ? Qt.rgba(1,1,1,0.4) : focusColor

        property bool focusedState

        Timer {
            id: focusTimer
            running: focused
            repeat: true
            interval: 800

            onTriggered: focusCircle.focusedState = !focusCircle.focusedState
        }
    }

    Component {
        id: tapCircle

        Item {
            id: circleItem

            anchors.fill: parent

            property bool done

            function removeCircle() {
                done = true

                if (fillSizeAnimation.running) {
                    fillOpacityAnimation.stop()
                    closeAnimation.start()

                    circleItem.destroy(500);
                } else {
                    showFocus = true
                    fadeAnimation.start();

                    circleItem.destroy(300);
                }
            }

            property real circleX
            property real circleY

            property bool closed

            Item {
                id: circleParent
                anchors.fill: parent
                visible: !circular

                Rectangle {
                    id: circleRectangle

                    x: circleItem.circleX - radius
                    y: circleItem.circleY - radius

                    width: radius * 2
                    height: radius * 2

                    opacity: 0
                    color: view.color

                    NumberAnimation {
                        id: fillSizeAnimation
                        running: true

                        target: circleRectangle; property: "radius"; duration: 500;
                        from: startRadius; to: endRadius; easing.type: Easing.InOutQuad

                        onStopped: {
                            if (done)
                                showFocus = true
                        }
                    }

                    NumberAnimation {
                        id: fillOpacityAnimation
                        running: true

                        target: circleRectangle; property: "opacity"; duration: 300;
                        from: 0; to: 1; easing.type: Easing.InOutQuad
                    }

                    NumberAnimation {
                        id: fadeAnimation

                        target: circleRectangle; property: "opacity"; duration: 300;
                        from: 1; to: 0; easing.type: Easing.InOutQuad

                        onStopped: {
                            isCircleCreated = false
                        }
                    }

                    SequentialAnimation {
                        id: closeAnimation

                        NumberAnimation {
                            target: circleRectangle; property: "opacity"; duration: 250;
                            to: 1; easing.type: Easing.InOutQuad
                        }

                        NumberAnimation {
                            target: circleRectangle; property: "opacity"; duration: 250;
                            from: 1; to: 0; easing.type: Easing.InOutQuad
                        }

                        onStopped: {
                            isCircleCreated = false
                        }
                    }
                }
            }

            Item {
                anchors.fill: parent
                visible: circular

                Rectangle {
                    id: circleMask_rect
                    anchors.fill: parent

                    smooth: true
                    visible: false

                    radius: Math.max(width/2, height/2)
                }

                OpacityMask {
                    id: mask

                    anchors.fill: parent
                    //maskSource: circleMask_rect
                    maskSource: circleParent
                }
            }
        }
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}
