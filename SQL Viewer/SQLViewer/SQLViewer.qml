import QtQuick 2.8
import QtQuick.Controls 1.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0

Item {
    TableView {
        id: tableView

        anchors.fill: parent

        TableViewColumn {
            role: "RoadID"
            title: "Road ID"
            width: 100 * AppFramework.displayScaleFactor
        }

        TableViewColumn {
            role: "RoadName"
            title: "Road Name"
            width: 200 * AppFramework.displayScaleFactor
        }

        TableViewColumn {
            role: "RoadType"
            title: "Road Type"
            width: 100 * AppFramework.displayScaleFactor
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

    Component.onCompleted: {
        dataFolder.makeFolder();
        db.open();

        var lines = scriptsFolder.readTextFile("initdb.sql").split(";");
        for (var i = 0; i < lines.length; i++) {
            var sql = lines[i];
            if (sql.match(/^\s*$/))
                continue;

            sql = sql.replace(/(^\s+|\s+$)/g, "");
            console.log(sql);

            var query = db.query(sql);
            if (query.error) {
                console.log(JSON.stringify(query.error, undefined, 2));
                continue;
            }

            var ok = query.first();
            while (ok) {
                console.log(JSON.stringify(query.values));
                ok = query.next();
            }
            query.finish();
        }

        var insert = db.query();
        insert.prepare("INSERT INTO Roads (RoadName, RoadType) VALUES (:name, :type)");
        insert.executePrepared( { "name": "Bank", "type": "St" } );
        console.log(insert.insertId);
        insert.executePrepared( { "name": "Dorcas", "type": "St" } );
        console.log(insert.insertId);

        var queryModel = db.queryModel("SELECT * FROM Roads");
        tableView.model = queryModel;
    }
}
