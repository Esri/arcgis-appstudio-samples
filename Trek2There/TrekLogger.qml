/* Copyright 2016 Esri
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

import QtQuick 2.0
import QtQuick.LocalStorage 2.0

/*  Database Schema

    timestamp INTEGER,
    pos_lat TEXT,
    pos_long TEXT,
    pos_dir TEXT,
    klat TEXT,
    klong TEXT,
    az_to TEXT,
    dist_to TEXT,
    degrees_off TEXT

*/

QtObject {

    // PROPERTIES //////////////////////////////////////////////////////////////

    property string dbTitle: "trek2there"
    property string dbVersion: "1.0"
    property string dbDescription: "Trek2There Trek Logger"
    property int dbEstimatedSize: 1000000
    property string trekTableName: ""
    property var db

    // METHODS /////////////////////////////////////////////////////////////////

    function open() {
        if (!db) {
            db = LocalStorage.openDatabaseSync(
                        dbTitle,
                        dbVersion,
                        dbDescription,
                        dbEstimatedSize);
        }

        return db;
    }

    //--------------------------------------------------------------------------

    function startRecordingTrek(){

        open();

        if(logTreks){
            if(trekTableName !== ""){
                trekTableName = "";
            }

            trekTableName = "trek" + Date.now().valueOf().toString();

            db.transaction(
                function(tx){
                    try{
                        tx.executeSql('CREATE TABLE IF NOT EXISTS log(trekId TEXT)')
                        tx.executeSql('INSERT INTO log (trekId) VALUES(?)', [trekTableName]);
                        tx.executeSql('CREATE TABLE IF NOT EXISTS ' + trekTableName +'(timestamp INTEGER, pos_lat TEXT, pos_long TEXT, pos_dir TEXT, klat TEXT, klong TEXT, az_to TEXT, dist_to TEXT, degrees_off TEXT)')
                    }
                    catch(e){
                        console.log(e);
                    }
                });
        }

    }

    //--------------------------------------------------------------------------

    function recordPosition(positionInfo /* array */){

        // positionInfo: [timestamp, pos_lat, pos_long, pos_dir, klat, klong, az_to, dist_to, degrees_off]

        if(logTreks){
            db.transaction(
                function(tx){
                    try{
                        tx.executeSql('INSERT INTO ' + trekTableName +' (timestamp, pos_lat, pos_long, pos_dir, klat, klong, az_to, dist_to, degrees_off) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)', positionInfo);
                    }
                    catch(e){
                        console.log(e);
                    }
            });
        }

    }

    //--------------------------------------------------------------------------

    function stopRecordingTrek(){

        if(logTreks){
            trekTableName = "";
        }

    }

    //--------------------------------------------------------------------------

    function deleteAllLogs(){

        db.transaction(
            function(tx){
                try{

                    var rs = tx.executeSql('SELECT name FROM sqlite_master WHERE type="table" AND name LIKE "trek%"');
                    for(var i = 0; i < rs.rows.length; i++) {
                       deleteTrek(rs.rows.item(i).name);
                    }
                }
                catch(e){
                    console.log(e);
                }
            });
    }

    //--------------------------------------------------------------------------

    function deleteTrek(id){

        db.transaction(
            function(tx){
                try{
                    tx.executeSql('DROP TABLE ' + id);
                }
                catch(e){
                    console.log(e);
                }
            });
    }

    //--------------------------------------------------------------------------

    function queryTrek(id){

        db.transaction(
            function(tx){
                try{
                    var rs = tx.executeSql('SELECT * FROM ' + id);
                }
                catch(e){
                    console.log(e);
                }
            });
    }

}
