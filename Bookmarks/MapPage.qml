import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

import "components"

Item {

    Rectangle {
        id: titleRect
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 60*app.scaleFactor
        color: app.themeColor
        MouseArea {
            anchors.fill: parent
            onClicked: {
                mouse.accepted = false
            }
        }

        Text {
            id: titleText
            anchors.centerIn: parent
            text: "My Map"
            color: "white"
            font.pointSize: 22*app.scaleFactor
            font.family: app.fontSourceSansProReg.name
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: rectBookmark
            width: 50*app.scaleFactor
            height: parent.height
            color: "transparent"
            anchors {
                right: parent.right
                rightMargin: 20*app.scaleFactor
                verticalCenter: parent.verticalCenter
            }

            Image {
                id: imgBookmark
                width: 35*app.scaleFactor
                height: 45*app.scaleFactor
                source: "assets/images/Bookmark.png"
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Show bookmark selector
                    if (bookmarksManager.visible !== true) {
                        // Show bookmarks dialog
                        bookmarksManager.show()
                    }
                }
            }
        }
    }

    Envelope {
        id: envelope
    }

    Map {
        id: map
        anchors {
            left: parent.left
            right: parent.right
            top: titleRect.bottom
            bottom: parent.bottom
        }
        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        zoomByPinchingEnabled: true

        positionDisplay {
            positionSource: PositionSource {
            }
        }

        ArcGISTiledMapServiceLayer {
            url: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"
        }

        NorthArrow {
            anchors {
                right: parent.right
                top: parent.top
                margins: 10
            }
            visible: map.mapRotation != 0
        }

        ZoomButtons {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 10*app.scaleFactor
            }
        }
    }

    BookmarksManager {
        id: bookmarksManager
        bookmarksDialogHeaderColor: app.themeColor
        fontName: app.fontSourceSansProReg.name

        onBookmarkClicked: {
            // Get extent of bookmarkSelected
            envelope.xMin = jsonBookmarkExtent.xmin
            envelope.yMin = jsonBookmarkExtent.ymin
            envelope.xMax = jsonBookmarkExtent.xmax
            envelope.yMax = jsonBookmarkExtent.ymax

            // Zoom to bookmark extent
            map.zoomTo(envelope)

            // Hide bookmark window
            hide()
        }

        onBookmarkAdded: {
            var extent = map.extent
            var newBookmark = JSON.stringify(extent.json)
            saveBookmark(bookmarkName, newBookmark)
        }
    }
}

