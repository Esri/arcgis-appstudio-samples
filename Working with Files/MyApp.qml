/* Copyright 2020 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */


// You can run your app in Qt Creator by pressing Alt+Shift+R.
// Alternatively, you can run apps through UI using Tools > External > AppStudio > Run.
// AppStudio users frequently use the Ctrl+A and Ctrl+I commands to
// automatically indent the entirety of the .qml file.


import QtQuick 2.6
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0
import ArcGIS.AppFramework.Platform 1.0

import "controls" as Controls

//------------------------------------------------------------------------------

App {
    id: app
    width: 414
    height: 736

    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    Page{
        anchors.fill: parent
        clip: true

        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------

        SwipeView {
            id: swipeView
            //currentIndex: bar.currentIndex
            onCurrentIndexChanged: tabBar.currentIndex = currentIndex
            anchors.fill: parent

            FilePage {
                id: filePage
            }

            DatabasePage {
                id: dbpage
            }
        }

        footer: TabBar{
            id: tabBar
            padding: 0
            onCurrentIndexChanged: swipeView.currentIndex = currentIndex
            Repeater {
                model: ListModel{
                    ListElement { name: qsTr("Select File"); }
                    ListElement { name: qsTr("Database"); }
                }
                TabButton {
                    font.pointSize: 14
                    text: name
                }
            }
        }

    }

    Controls.DescriptionPage{
        id:descPage
        visible: false
    }

    SqlDatabase {
        id: db
        databaseName: dbFileFolder.filePath("WorkingWithFiles.db")
    }

    FileFolder {
        id: dbFileFolder
        path: "~/ArcGIS/AppStudio/Data"
    }

    Component.onCompleted: {
        dbFileFolder.makeFolder();
        db.open();
        dbCreateSchema(db);
        updateDBView();
    }

    // database related functions ------------------------------------------------------------------

    function dbExec( db, sql, ...params ) {
        console.log( sql, JSON.stringify( params ) );

        let dbQuery = db.query( sql, ...params );
        if ( dbQuery.error ) {
            throw dbError( dbQuery.error );
        }

        let ok = dbQuery.first();
        while ( ok ) {
            console.log( JSON.stringify( dbQuery.values ) );
            ok = dbQuery.next();
        }
        dbQuery.finish();
    }

    function dbError( dbError ) {
        return new Error( "Error %1 (Type %2)\n%3\n%4\n"
                         .arg( dbError.nativeErrorCode )
                         .arg( dbError.type )
                         .arg( dbError.driverText )
                         .arg( dbError.databaseText ) );
    }

    function dbCreateSchema( db ) {
        db.beginTransaction();

        dbExec( db,
                "CREATE TABLE IF NOT EXISTS File (FileID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, FileName TEXT, FileSuffix TEXT, FileSize INT, FileData BLOB)"
                );
        db.commitTransaction();
    }

    function dbInsertFile( db, fileName, fileSuffix, fileSize, fileData )
    {
        db.beginTransaction();

        dbExec(db,
               "INSERT INTO File ( FileName, FileSuffix, FileSize, FileData ) VALUES ( :fileName, :fileSuffix, :fileSize, :fileData ) ",
               { fileName, fileSuffix, fileSize, fileData }
              );
        db.commitTransaction();
    }

    function dbDeleteFile( db, fileID) {
        db.beginTransaction();

        dbExec(db, "DELETE FROM File WHERE FileID = :fileID", { fileID } );

        db.commitTransaction();
    }

    function updateDBView() {
        var queryModel = db.queryModel("SELECT * FROM File");
        dbpage.repeater.model = queryModel;
    }

    function clearDBView() {
        dbpage.repeater.model = null;
    }
}

//------------------------------------------------------------------------------
