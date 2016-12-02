import QtQuick 2.2
import QtPositioning 5.2


import ArcGIS.AppFramework 1.0

//------------------------------------------------------------------------------

Rectangle {
    id: panel

    property real visibleWidth: 200 * AppFramework.displayScaleFactor
    property real visibleHeight: 200 * AppFramework.displayScaleFactor
    property bool landscape: app.width > app.height
    property bool fullScreen: false

    property var leftEdge
    property var rightEdge
    property var topEdge
    property var bottomEdge

    property bool lockRight: true
    property bool lockBottom: true
    property bool show: true

    color: "#e04c4c4c"
    border {
        width: 1
        color: "#323232"
    }

    Component.onCompleted: {
        reAnchor();
        reSize();
    }

    onLandscapeChanged: {
        reAnchor();
        reSize();
    }

    onFullScreenChanged: {
        reAnchor();
        reSize();
    }

    onShowChanged: {
        reSize();
    }

    onVisibleWidthChanged: {
        reSize();
    }

    onVisibleHeightChanged: {
        reSize();
    }

    visible: show && (landscape ? width > 0 : height > 0)

    function reSize() {
        if (fullScreen) {

        } else if (landscape) {
            width = show ? visibleWidth : 0
        } else {
            height = show ? visibleHeight : 0
        }
    }

    function reAnchor() {
        if (fullScreen) {
            anchors.left = leftEdge;
            anchors.right = rightEdge;
            anchors.top = topEdge;
            anchors.bottom = bottomEdge;
        } else if (landscape) {
            anchors.top = topEdge;
            anchors.bottom = bottomEdge;

            if (lockRight) {
                anchors.left = undefined;
                anchors.right = rightEdge;
            } else {
                anchors.left = leftEdge;
                anchors.right = undefined;
            }
        } else {
            anchors.left = leftEdge;
            anchors.right = rightEdge;

            if (lockBottom) {
                anchors.top = undefined;
                anchors.bottom = bottomEdge;
            } else {
                anchors.top = topEdge;
                anchors.bottom = undefined;
            }
        }
    }

    Behavior on height {
        SmoothedAnimation {
            duration: 200
        }
    }

    Behavior on width {
        SmoothedAnimation {
            duration: 200
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {}
        onDoubleClicked: {}
        onPressAndHold: {}
        onWheel: {}
    }
}
