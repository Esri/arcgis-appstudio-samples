import QtQuick 2.8
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0

Item {
    Flickable {
        id: flickable

        anchors.fill: parent
        anchors.margins: 10 * AppFramework.displayScaleFactor

        contentWidth: flow.width
        contentHeight: flow.height
        clip: true

        Flow {
            id: flow

            width: flickable.width

            spacing: 10 * AppFramework.displayScaleFactor
            clip: true

            Repeater {
                id: repeater

                Rectangle {
                    width: 130 * AppFramework.displayScaleFactor
                    height: 130 * AppFramework.displayScaleFactor

                    radius: 10 * AppFramework.displayScaleFactor
                    color: "orange"

                    Column {
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: 10 * AppFramework.displayScaleFactor

                        Text {
                            width: parent.width
                            text: RoadID
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            width: parent.width
                            text: qsTr("%1 %2").arg(RoadName).arg(RoadType)
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    SqlDatabase {
        id: db
        databaseName: dataFolder.filePath("roads.sqlite")
    }

    FileFolder {
        id: dataFolder
        path: "~/ArcGIS/Data/Sql"
    }

    FileFolder {
        id: scriptsFolder
        url: "scripts"
    }

    function db_exec_sql(sql) {
        if (sql.match(/^\s*$/)) {
            return;
        }

        sql = sql.replace(/(^\s+|\s+$)/g, "");
        console.log(sql);

        var query = db.query(sql);
        if (query.error) {
            console.log(JSON.stringify(query.error, undefined, 2));
            return;
        }

        var ok = query.first();
        while (ok) {
            console.log(JSON.stringify(query.values));
            ok = query.next();
        }
        query.finish();
    }

    function db_exec_sql_lines(lines) {
        for (var i = 0; i < lines.length; i++) {
            var sql = lines[i];
            db_exec_sql(sql);
        }
    }

    function db_exec_sql_textFile(textFile) {
        var lines = textFile.split(";");
        return db_exec_sql_lines(lines);
    }

    function db_exec_sql_fileName(fileName) {
        var textFile = scriptsFolder.readTextFile(fileName);
        return db_exec_sql_textFile(textFile);
    }

    Component.onCompleted: {
        dataFolder.makeFolder();
        db.open();

        db_exec_sql_fileName("initdb.sql");

        var insert = db.query();
        insert.prepare("INSERT INTO Roads (RoadName, RoadType) VALUES (:name, :type)");
        insert.executePrepared( { "name": "Bank", "type": "St" } );
        console.log(insert.insertId);
        insert.executePrepared( { "name": "Dorcas", "type": "St" } );
        console.log(insert.insertId);

        var queryModel = db.queryModel("SELECT * FROM Roads");
        repeater.model = queryModel;
    }
}
