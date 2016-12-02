import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0


DockPanel {
    id: bookmarksPanel

    property WebMap webMap
    property alias view: bookmarksView

    leftEdge: parent.left
    rightEdge: parent.right
    topEdge: banner.bottom
    bottomEdge: parent.bottom
    lockRight: false
    landscape: true
    show: false

    visibleHeight: parent.height
    visibleWidth: Math.min(app.width * 0.5, app.sidePanelWidth)

    color: "#f7f8f8"
    border {
        width: 1
        color: "lightgrey"
    }

    onVisibleChanged: {
        if (visible) {
            bookmarksView.currentIndex = -1;
//            console.log(JSON.stringify(webMap.webMapInfo.bookmarks, undefined, 2));
        }
    }

    //--------------------------------------------------------------------------

    function hide() {
        show = false;
    }

    //--------------------------------------------------------------------------

    TitleBar {
        id: titleBar

        height: 40 * AppFramework.displayScaleFactor
        title: qsTr("Bookmarks")

        closeButton {
            visible: true

            onClicked: {
                hide();
            }
        }
    }

    //--------------------------------------------------------------------------

    BookmarksView {
        id: bookmarksView

        anchors {
            left: parent.left
            right: parent.right
            top: titleBar.bottom
            bottom: parent.bottom
            margins: 4
        }

        webMap: bookmarksPanel.webMap
    }

    //--------------------------------------------------------------------------
}
