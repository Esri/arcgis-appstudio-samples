import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

Item {
    id: _root
    anchors.fill: parent
    visible: false

    // Configurable variables
    property string databaseName: "BookmarksComponent"
    property string tableName: "bookmarks"
    property color bookmarksDialogHeaderColor: "blue"
    property color bookmarkNameColor: "black"
    property string fontName: ""
    signal bookmarkClicked(var jsonBookmarkExtent)
    signal closeSelectBookmarkDialog()
    signal bookmarksDeleted(var bookmarkNames)
    signal bookmarkAdded(string bookmarkName)


    // Non-configurable variables
    property double scaleFactor: AppFramework.displayScaleFactor
    property var bookmarksModel: bookmarksModel
    ListModel {
        id: bookmarksModel
    }
    property var db: null
    property bool select: false
    property var selectedBookmarks: []
    property int numSelected: 0

    Component.onCompleted: {
        localStorage.initalizeDatabase(databaseName);
        localStorage.createTable(tableName);
    }

    Item {
        id: localStorage
        property var db : null

        function initalizeDatabase(dataBaseName) {
            db = LocalStorage.openDatabaseSync(dataBaseName, "0.1", "SQLite database", 100000);
            console.log("Database ", databaseName , " is Ready!");
        }

        function createTable(tableName) {
            try {
                db.transaction(function(tx){
                    tx.executeSql('CREATE TABLE IF NOT EXISTS ' + tableName + '(key TEXT UNIQUE, value TEXT)');
                });
            } catch (err) {
                console.log("Error creating table in database: " + err);
            };
        }

        function remove(tableName, key) {
            db.transaction(function(tx) {
                var rs = tx.executeSql('DELETE FROM ' + tableName + ' WHERE key IN ' + key + ';');
            });
        }

        function removeAll() {
            db.transaction(function(tx) {
                var rs = tx.executeSql('DELETE * FROM bookmarks');
            });
        }

        function insert(tableName, key, value) {
            db.transaction( function(tx){
                tx.executeSql('INSERT OR REPLACE INTO ' + tableName + ' VALUES(?, ?)', [key, value]);
            });
        }

        function queryAllValues(tableName) {
            var rs = null;
            db.transaction(function(tx) {
                rs = tx.executeSql('SELECT key, value FROM ' + tableName + ';')
            });
            return rs;
        }

        function queryByKey(tableName, key) {
            console.log("QuerybyKey : ", key)
            var res = null;
            db.transaction(function(tx) {
                var rs = tx.executeSql('SELECT value FROM ' + tableName + ' WHERE key=?;', [key]);
                console.log(JSON.stringify(rs));
                res = rs.rows.item(0).value;
            });
            return res;
        }
    }


    function show() {
        // Clear model contents
        bookmarksModel.clear()
        // Get all bookmarks
        getAllBookmarks()
        // Show bookmarks dialog
        visible = true

        if(bookmarksModel.count == 0) {
            rectAddBookmark.visible = true
        }
    }

    function hide() {
        // Hide bookmarks dialog
        visible = false
    }

    function saveBookmark(key, value) {       
        localStorage.insert(tableName, key, value)
    }

    function getBookmarkExtent(key) {      
        return localStorage.queryByKey(tableName,key)
    }

    function deleteBookmarks(key) {       
        localStorage.remove(tableName, key);
    }

    function getAllBookmarks() {       
        var rs = localStorage.queryAllValues(tableName);
        var numBookmarks = rs.rows.length;
        for (var i=0; i < numBookmarks; i++) {
            bookmarksModel.append({"name": rs.rows.item(i).key, "extent": rs.rows.item(i).value})
        }       
    }

    Rectangle {
        id: rectGetBookmark
        width: Math.min(350*scaleFactor, 0.9*parent.width)
        height: Math.min(350*scaleFactor, 0.8*parent.height)
        color: "white"
        anchors.centerIn: parent
        border.width: 1*scaleFactor
        border.color: "gray"
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: {
                mouse.accepted = false
            }
        }

        Rectangle {
            id: rectGetBookmarkHeader
            width: parent.width
            height: 50*scaleFactor
            color: bookmarksDialogHeaderColor
            Text {
                id: txtGetBookMarkHeader
                color: "white"
                text: qsTr("Bookmarks")
                font.pointSize: 16*scaleFactor
                font.family: fontName
                style: Text.Raised
                anchors.centerIn: parent
            }

            Rectangle {
                id: rectEdit
                width: txtSelect.implicitWidth + 10*scaleFactor
                height: parent.height
                color: "transparent"
                visible: bookmarksModel.count > 0
                anchors {
                    left: parent.left
                    leftMargin: 10*scaleFactor
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    id: txtSelect
                    color: "white"
                    text: select === false ? "Edit" : "Cancel"
                    font.pointSize: 13*scaleFactor
                    font.family: fontName
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        select = !select

                        // Ensure Add Bookmark dialog is closed
                        rectAddBookmark.visible = false
                    }
                }
            }

            Rectangle {
                id: rectAdd
                width: txtAdd.implicitWidth + 10*scaleFactor
                height: parent.height
                color: "transparent"
                visible: select === false
                anchors {
                    right: rectClose.left
                    rightMargin: 8*scaleFactor
                    verticalCenter: parent.verticalCenter
                }
                Text {
                    id: txtAdd
                    color: "white"
                    text: qsTr("Add")
                    font.pointSize: 13*scaleFactor
                    font.family: fontName
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        rectAddBookmark.visible = true
                    }
                }
            }

            Rectangle {
                id: rectClose
                width: 30*scaleFactor
                height: parent.height
                color: "transparent"
                anchors {
                    right: parent.right
                    rightMargin: 5*scaleFactor
                    verticalCenter: parent.verticalCenter
                }
                Image {
                    id: imgClose
                    width: 25*scaleFactor
                    height: width
                    anchors.centerIn: parent
                    source: "images/close.png"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Set select bool to false
                        select = false

                        // Close dialog
                        _root.visible = false

                        // Empty list of selected bookmarks
                        selectedBookmarks = []

                        // Set the number of selected bookmarks to 0
                        numSelected = 0

                        // Close signal
                        closeSelectBookmarkDialog()

                        // Ensure Add Bookmark dialog is closed
                        rectAddBookmark.visible = false
                    }
                }
            }
        }

        //-----------------------------

        ListView {
            id: listBookmarks
            width: parent.width - (10*scaleFactor)
            height: select ? parent.height - rectGetBookmarkHeader.height - (45*scaleFactor) : parent.height - rectGetBookmarkHeader.height - (1*scaleFactor)
            anchors {
                top: rectGetBookmarkHeader.bottom
                horizontalCenter: parent.horizontalCenter
            }
            orientation: ListView.Vertical
            clip: true
            delegate: bookmarksDelegate
            model: bookmarksModel            
        }

        Component {
            id: bookmarksDelegate
            Rectangle {
                id: rectBookmarkComponent
                width: listBookmarks.width
                height: Math.max(35*app.scaleFactor, (txtName.implicitHeight + (5*scaleFactor)))

                Text {
                    id: txtName
                    width: select ? parent.width - (35*scaleFactor) : parent.width - (5*scaleFactor)
                    text: name
                    color: "black"
                    font.pointSize: 12*scaleFactor
                    font.family: fontName
                    anchors.verticalCenter: parent.verticalCenter
                    wrapMode: text.indexOf(" ") > -1 ? Text.WordWrap : Text.WrapAnywhere
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (!select) {
                            var jsonBookmarkExtent = JSON.parse(getBookmarkExtent(name))
                            bookmarkClicked(jsonBookmarkExtent)
                        }else {
                            if (selectedBookmarks.indexOf(name) === -1) {
                                imgSelect.source = "images/check_enabled.png"
                                selectedBookmarks.push(name)
                                numSelected = selectedBookmarks.length
                            }else {
                                var index = selectedBookmarks.indexOf(name)
                                imgSelect.source = "images/check_disabled.png"
                                selectedBookmarks.splice(index, 1)
                                numSelected = selectedBookmarks.length
                            }
                        }
                        // Ensure Add Bookmark dialog is closed
                        rectAddBookmark.visible = false
                    }
                }

                Image {
                    id: imgSelect
                    width: 22*scaleFactor
                    height: 22*scaleFactor
                    source: "images/check_disabled.png"
                    visible: select
                    anchors {
                        right: parent.right
                        rightMargin: 15*scaleFactor
                        verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    width: rectGetBookmark.width
                    height: 1*scaleFactor
                    color: "lightgray"
                }
            }
        }

        //---------------------------------------

        Rectangle {
            id: rectBookmarkOptions
            width: parent.width
            height: 45*scaleFactor
            color: "white"
            border.width: 1*scaleFactor
            border.color: "gray"
            opacity: numSelected > 0 ? 1 : 0.5
            anchors {
                top: listBookmarks.bottom
                horizontalCenter: parent.horizontalCenter
            }
            visible: select

            Rectangle {
                id: rectDelete
                width: parent.height
                height: parent.height
                anchors.centerIn: parent
                color: "transparent"

                Image {
                    id: imgDelete
                    width: 25*scaleFactor
                    height: width
                    source: "images/delete.png"
                    anchors.centerIn: parent
                }
                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        if (numSelected > 0) {
                            // Create string for sql where clause
                            var sqlStatementIn = "('" + selectedBookmarks.join("','") + "')"
                            // Delete selected bookmarks
                            deleteBookmarks(sqlStatementIn)

                            // Refresh model to refresh list view
                            bookmarksModel.clear()
                            getAllBookmarks()

                            // Delete bookmark signal
                            bookmarksDeleted(selectedBookmarks)
                            selectedBookmarks = []

                            // Set select to false so the Select command is visible and cancel is not
                            select = false

                            // Update number selected to force delete icon to look disabled
                            numSelected = 0
                        }
                    }
                }
            }
        }

        // Add bookmark dialog
        Rectangle {
            id: rectAddBookmark
            width: 250*scaleFactor
            height: 100*scaleFactor
            color: "white"
            anchors.centerIn: parent
            border.width: 1*scaleFactor
            border.color: "gray"
            radius: 4*scaleFactor
            focus: true
            visible: false

            Text {
                id: txtAddBookmarkHeader
                width: parent.width
                height: 30*scaleFactor
                text: qsTr("Add Bookmark")
                color: "black"
                font.pointSize: 14*scaleFactor
                font.family: fontName
                font.bold: true
                anchors {
                    top: parent.top
                    topMargin: 8*scaleFactor
                    horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
            }

            TextField {
                id: txtAddBookmark
                anchors.centerIn: parent
                width: parent.width
                height: 30*scaleFactor
                text: ""
                style: TextFieldStyle {
                    placeholderTextColor: "#A3A199"
                    background: Rectangle {
                        height: 30*scaleFactor
                        smooth: true
                        color: "white"
                        border.color: "gray"
                        border.width: 1*scaleFactor
                    }
                }
                font.pointSize: 14*scaleFactor
                font.family: fontName
                textColor: "black"
                placeholderText: qsTr("Bookmark Name")
                readOnly: false
                focus: true
            }

            Rectangle {
                id: rectCancel
                color: "transparent"
                width: parent.width/2
                height: parent.height - txtAddBookmarkHeader.height - txtAddBookmark.height - (10*scaleFactor)
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                }
                Text {
                    id: txtCancel
                    text: qsTr("Cancel")
                    color: "blue"
                    font.pointSize: 12*scaleFactor
                    font.family: fontName
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Close Add Bookmark Dialog
                        rectAddBookmark.visible = false
                    }
                }
            }

            Rectangle {
                id: rectOK
                color: "transparent"
                width: parent.width/2
                height: parent.height - txtAddBookmarkHeader.height - txtAddBookmark.height - (10*scaleFactor)
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                Text {
                    id: txtOK
                    text: qsTr("OK")
                    color: "blue"
                    font.pointSize: 12*scaleFactor
                    font.family: fontName
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (txtAddBookmark.text.length > 0) {
                            // Save bookmark
                            bookmarkAdded(txtAddBookmark.text)

                            // Refresh bookmark list
                            bookmarksModel.clear()
                            getAllBookmarks()

                            // Empty list of selected bookmarks
                            selectedBookmarks = []
                            // Set number of selected bookmarks to 0
                            numSelected = 0

                            // Clear text
                            txtAddBookmark.text = ""

                            // Close Add Bookmark Dialog
                            rectAddBookmark.visible = false
                        }
                    }
                }
            }

            Rectangle {
                color: "gray"
                width: 1*scaleFactor
                height: parent.height - txtAddBookmarkHeader.height - txtAddBookmark.height - (5*scaleFactor)
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
