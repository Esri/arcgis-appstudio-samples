import QtQuick 2.8
import QtQuick.Controls 1.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

TableView {
    id: tableView
    readonly property var _model: model
    property int rowHeight: 30

    onModelChanged: {
        removeAllColumns();
        if (model) {
            addColumns(model);
        }
    }

    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOn

    headerDelegate: Rectangle {
        height: tableView.rowHeight
        border.color: "#c0c0c0"
        LinearGradient {
            anchors.fill: parent
            anchors.margins: 1
            start: Qt.point(0, 0)
            end: Qt.point(0, tableView.rowHeight)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "white" }
                GradientStop { position: 1.0; color: "#e0e0e0" }
            }
        }

        Text {
            id: headerText
            width: parent.width - 10
            x: 5
            y: 5
            text: styleData.value

            Component.onCompleted: {
                if (styleData.column === 0) {
                    tableView.rowHeight = headerText.height + 10;
                }
            }
        }
    }

    rowDelegate: Rectangle {
        color: styleData.row & 1 ? "white" : "#f0f0f0"
        height: tableView.rowHeight
    }

    itemDelegate: Item {
        Text {
            id: itemText
            width: parent.width - 10
            x: 5
            y: 5
            text: styleData.value
            clip: true
            elide: Text.ElideRight
        }
    }

    flickableItem.flickableDirection: Flickable.HorizontalAndVerticalFlick

    function removeAllColumns() {
        while (columnCount) {
            removeColumn(tableView.columnCount - 1);
        }
    }

    function addColumns(model) {
        model.roleNames.forEach(function (role) {
            addColumn(tableViewColumn.createObject(tableView, { title: role, role: role } ) );
        } );
    }

    Component {
        id: tableViewColumn

        TableViewColumn {
            title: role
            width: 100 * AppFramework.displayScaleFactor
        }
    }
}
