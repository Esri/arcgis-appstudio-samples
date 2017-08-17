import QtQuick 2.8
import QtQuick.Controls 1.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0

Item{
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        spacing: 10

        Label {
            text: qsTr("Select SQL");
        }

        ComboBox {
            id: statements
            readonly property var _model: model
            Layout.fillWidth: true
            onCurrentTextChanged: queryTextArea.text = currentText
        }

        Label {
            text: qsTr("SQL")
        }

        TextArea {
            id: queryTextArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            selectByMouse: true
            wrapMode: TextEdit.WrapAnywhere
            onTextChanged: run()


            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                color: "transparent"
                border.color: "black"
            }
        }

        Label {
            text: qsTr("Results")
        }

        TableView {
            id: tableView
            readonly property var _model: model
            Layout.fillWidth: true
            Layout.preferredHeight: 100 * AppFramework.displayScaleFactor
        }

    }

    FileFolder {
        id: scriptsFolder
        url: "scripts"
    }

    SqlDatabase {
        id: db
        databaseName: ":memory:"

        SqlScalarFunction {
            name: "toDegrees"
            method: toDegrees
        }

        SqlAggregateFunction {
            name: "average"
            initialize: average_initialize
            iterate: average_iterate
            finalize: average_finalize
        }
    }

    function toDegrees(radians) {
        return radians * 180.0 / Math.PI;
    }

    function average_initialize() {
        var context = {
            sum: 0,
            count: 0
        }
        return context;
    }

    function average_iterate(context, value) {
        context.sum += value;
        context.count++;
    }

    function average_finalize(context) {
        return context.count ? context.sum / context.count : Number.NaN;
    }

    function execute(sql) {
        var query = db.query(sql);
        if (query.error) {
            throw new Error(query.error);
        }

        var ok = query.first();
        while (ok) {
            console.log(JSON.stringify(query.values));
            ok = query.next();
        }
        query.finish();
    }

    function uncomment(sql) {
        return sql.replace(/--[^\n]*/g, "")
        .replace(/\/\*(.|\s)*?\*\//g, "");
    }

    function getQueries(txt) {
        return txt.match(/(--.*|\s*)+[^;]*;/g)
        .map(function (sql) {
            return sql.replace(/(^\s+|\s+$)/g, "");
        } );
    }

    function tableView_removeAllColumns(tableView) {
        while (tableView.columnCount) {
            tableView.removeColumn(tableView.columnCount - 1);
        }
    }

    function tableView_addColumns(tableView, model) {
        model.roleNames.forEach(function (role) {
            tableView.addColumn(tableViewColumn.createObject(tableView, { title: role, role: role } ) );
        } );
    }

    function run() {
        var sql = uncomment(queryTextArea.text);
        tableView_removeAllColumns(tableView);
        execute(sql);
        var queryModel = db.queryModel(sql);
        if (!queryModel) {
            return;
        }
        tableView_addColumns(tableView, queryModel);
        tableView.model = queryModel;
        tableView.resizeColumnsToContents();
    }

    Component {
        id: tableViewColumn

        TableViewColumn {
            title: role
            width: 100 * AppFramework.displayScaleFactor
        }
    }

    Component.onCompleted: {
        db.open();

        var txt = scriptsFolder.readTextFile("initdb.sql");

        getQueries(txt).forEach(function (sql) {
            console.log("sql: ", sql);
            execute(sql);
        } );

        statements.model = getQueries(scriptsFolder.readTextFile("statements.sql"));
    }
}

