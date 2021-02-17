import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.10
Item {

    property real scaleFactor: AppFramework.displayScaleFactor

    // Create MapView that contains a Map
    MapView {
        id: mapView
        anchors.fill: parent

        Map {
            id: map
            // Set the initial basemap to Imagery with Labels
            BasemapImageryWithLabels {}
            onLoadStatusChanged: {
                // Once the map is loaded, add in the initial bookmarks
                if (loadStatus === Enums.LoadStatusLoaded) {
                    createBookmark("Grand Prismatic Spring", springViewpoint);
                    createBookmark("Mysterious Desert Pattern", desertViewpoint);
                    createBookmark("Strange Symbol", symbolViewpoint);
                    createBookmark("Guitar Shaped Forest", guitarViewpoint);

                }
            }

            // helper function for creating bookmarks
            function createBookmark(bookmarkName,bookmarkViewpoint) {
                // create a bookmark object and assign the name and viewpoint
                var bookmark = ArcGISRuntimeEnvironment.createObject("Bookmark");
                bookmark.name = bookmarkName;
                bookmark.viewpoint = bookmarkViewpoint;
                // append the bookmark to the map's BookmarkListModel
                map.bookmarks.append(bookmark);
            }
        }

        // Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#8f499c"
            visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
        }
    }

    // Create Viewpoints for the 4 initial bookmarks
    ViewpointExtent {
        id: desertViewpoint
        extent: Envelope {
            xMin: 3742993.127298778
            xMax: 3744795.1333054285
            yMin: 3170396.4675719286
            yMax: 3171745.88077
            spatialReference: SpatialReference { wkid: 102100 }
        }
    }

    ViewpointExtent {
        id: symbolViewpoint
        extent: Envelope {
            xMin: -13009913.860076642
            xMax: -13009442.089218518
            yMin: 4495026.9307899885
            yMax: 4495404.031910696
            spatialReference: SpatialReference { wkid: 102100 }
        }
    }

    ViewpointExtent {
        id: guitarViewpoint
        extent: Envelope {
            xMin: -7124497.45137465
            xMax: -7121131.417429369
            yMin: -4012221.6124684606
            yMax: -4009697.0870095
            spatialReference: SpatialReference { wkid: 102100 }
        }
    }

    ViewpointExtent {
        id: springViewpoint
        extent: Envelope {
            xMin: -12338668.348591767
            xMax: -12338247.594362013
            yMin: 5546908.424239618
            yMax: 5547223.989911933
            spatialReference: SpatialReference { wkid: 102100 }
        }
    }

    // Create a combo box that allows for switching between bookmarks
    ComboBox {
        id: bookmarks
        anchors.left:  parent.left
        anchors.top:  parent.top
        anchors.margins: 10 * scaleFactor
        width: 200 * scaleFactor
        height: 30 * scaleFactor
        clip:true
        Material.accent:"#8f499c"
        currentIndex: 0
        background: Rectangle {
            radius: 6 * scaleFactor
            border.color: "darkgrey"
            width: 200 * scaleFactor
            height: 30 * scaleFactor
        }

        // The bookmarks property on the map returns a BookmarkListModel, which
        // can be directly fed into views such as a combo box
        model: map.bookmarks
        onCurrentTextChanged: {
            mapView.setViewpoint(map.bookmarks.get(bookmarks.currentIndex).viewpoint);
        }

    }

    // Create the add button so new bookmarks can be added
    Rectangle {
        id: addButton
        property bool pressed: false
        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: 20 * scaleFactor
            bottomMargin: 40 * scaleFactor
        }

        width: 45 * scaleFactor
        height: width
        color: pressed ? "#959595" : "#D6D6D6"
        radius: 100
        border {
            color: "#585858"
            width: 1 * scaleFactor
        }

        Image {
            anchors.centerIn: parent
            rotation: 45
            width: 45 * scaleFactor
            height: width
            source: app.folder.fileUrl("./assets/add.png")
        }

        MouseArea {
            anchors.fill: parent
            onPressed: addButton.pressed = true
            onReleased: addButton.pressed = false
            onClicked: {
                // Show the add window when it is clicked
                addWindow.visible = true;
            }
        }
    }

    // Create a window so names for new bookmarks can be specified
    Rectangle {
        id: addWindow
        anchors.centerIn: parent
        width: 225 * scaleFactor
        height: 130 * scaleFactor
        visible: false
        color: "lightgrey"
        opacity: .9
        radius: 5
        border {
            color: "#4D4D4D"
            width: 1
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse.accepted = true;
        }

        Column {
            anchors.centerIn: parent
            spacing: 5
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: qsTr("Provide the bookmark name")
                    font.pixelSize: 12 * scaleFactor
                }
            }

            TextField {
                id: textField
                width: 180 * scaleFactor
                placeholderText: qsTr("ex: Grand Canyon")
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5
                Button {
                    width: (textField.width / 2) - (2.5 * scaleFactor)
                    text: "Cancel"
                    onClicked: addWindow.visible = false;
                }
                Button {
                    width: (textField.width / 2) - (2.5 * scaleFactor)
                    text: qsTr("Done")
                    onClicked: {
                        // Create the new bookmark by getting the current viewpoint and using the
                        // user's input bookmark name
                        var viewpoint = mapView.currentViewpointExtent;
                        map.createBookmark(textField.text,viewpoint);
                        bookmarks.currentIndex = map.bookmarks.count -1;
                        textField.text = "";
                        addWindow.visible = false;
                    }
                }
            }
        }
    }
}
