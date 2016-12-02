import QtQuick 2.2


MouseArea {
    property point dragOrigin
    property real dragThrehsold: 5

    signal dragging(int x, int y)
    signal dragged(int x, int y)

    onPressed: {
        drag.axis = Drag.XAndYAxis
        dragOrigin = Qt.point(mouse.x, mouse.y)
    }

    onPositionChanged: {
        switch (drag.axis) {
        case Drag.XAndYAxis:
            if (Math.abs(mouse.x - dragOrigin.x) > dragThrehsold) {
                drag.axis = Drag.XAxis
            }
            else if (Math.abs(mouse.y - dragOrigin.y) > dragThrehsold) {
                drag.axis = Drag.YAxis
            }
            break

        case Drag.XAxis:
            dragging(mouse.x - dragOrigin.x, 0)
            break

        case Drag.YAxis:
            dragging(0, mouse.y - dragOrigin.y)
            break
        }
    }

    onReleased: {
        switch (drag.axis) {
        case Drag.XAndYAxis:
            canceled(mouse)
            break
        case Drag.XAxis:
            dragged(mouse.x - dragOrigin.x, 0)
            break
        case Drag.YAxis:
            dragged(0, mouse.y - dragOrigin.y < 0)
            break
        }
    }
}
