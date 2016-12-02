import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import "WebMap"


ListView {
    id: bookmarksView

    property WebMap webMap
    spacing: 3
    clip: true
    highlightFollowsCurrentItem: true
    model: null
    delegate: bookmarkItemDelegate
    highlight: bookmarkHighlightDelegate

    //--------------------------------------------------------------------------

    function zoomTo(index) {
        console.log(index, model.count);

        var bookmark = bookmarksView.model.get(index);
        //console.log(bookmark.name)
        //console.log(JSON.stringify(bookmark.extent))

        bookmarkEnvelope.json = bookmark.extent;
        webMap.zoomTo(bookmarkEnvelope.project(webMap.spatialReference));

        //console.log(JSON.stringify(bookmarkEnvelope.json, undefined, 2));
    }

    Envelope {
        id: bookmarkEnvelope
    }

    //--------------------------------------------------------------------------

    Component {
        id: bookmarkItemDelegate

        Item {
            width: parent.width
            height: bookmarkColumn.height

            Column {
                id: bookmarkColumn

                width: parent.width
                spacing: 5

                Item {
                    width: height
                    height: 3
                }

                Text {
                    width: parent.width
                    text: name
                    color: index == currentIndex ? "lightgrey" : "#4c4c4c"
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font {
                        pointSize: 16
                    }
                }

                Item {
                    width: height
                    height: 3
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#304c4c4c"
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    currentIndex = index;
                    zoomTo(index);
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: bookmarkHighlightDelegate

        Rectangle {
            width: bookmarksView.width
            height: ListView.view && ListView.view.currentItem ? ListView.view.currentItem.height : 0; // delegateHeight
            color: "#4c4c4c"
            //radius: 3
            y: ListView.view && ListView.view.currentItem ? ListView.view.currentItem.y : 0;
            Behavior on y {
                //SpringAnimation { spring: 2; damping: 0.1 }
                SmoothedAnimation {
                    duration: 100
                }
            }
        }
    }

    //--------------------------------------------------------------------------

}
