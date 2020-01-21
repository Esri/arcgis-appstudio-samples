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

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1


import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Sql 1.0

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736

    Material.accent: "#8f499c"
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)


    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }
        // Sample Starts here -----------------------------------------------------------------------------------------------------------------------------
        Column {
            anchors.fill: parent
            anchors.margins: 10 * AppFramework.displayScaleFactor
            spacing: 10 * AppFramework.displayScaleFactor

            Label {
                text: qsTr("Select Country")
            }

            ComboBox {
                id: countryComboBox
                readonly property var _model: model
                width: parent.width
                textRole: "country"
                onCurrentTextChanged: refreshSubCountryComboBox()
            }

            Label {
                text: qsTr("Select Sub Country")
            }

            ComboBox {
                id: subcountryComboBox
                readonly property var _model: model
                width: parent.width
                textRole: "subcountry"
                onCurrentTextChanged: refreshCityComboBox()
            }

            Label {
                text: qsTr("Select City")
            }

            ComboBox {
                id: cityComboBox
                readonly property var _model: model
                width: parent.width
                textRole: "name"
            }

            Button {
                text: qsTr("Refresh")
                onClicked: refreshCountryComboBox()
            }
        }
    }

    SqlDatabase {
        id: db
        databaseName: ":memory:"
    }

    FileFolder {
        id: dataFolder
        url: "data"
    }

    function refreshCountryComboBox() {
        countryComboBox.model = db.queryModel(
                    "SELECT DISTINCT country "
                    + "FROM            world_cities "
                    + "ORDER BY        country "
                    );
    }

    function refreshSubCountryComboBox() {
        subcountryComboBox.model = db.queryModel(
                    "SELECT DISTINCT subcountry "
                    + "FROM            world_cities "
                    + "WHERE           country = :country "
                    + "ORDER BY        subcountry",
                    { country: countryComboBox.currentText }
                    );
    }

    function refreshCityComboBox() {
        cityComboBox.model = db.queryModel(
                    "SELECT    name "
                    + "FROM      world_cities "
                    + "WHERE     country = :country "
                    + "AND       subcountry = :subcountry "
                    + "ORDER BY  name",
                    {
                        country: countryComboBox.currentText,
                        subcountry: subcountryComboBox.currentText
                    }
                    );
    }

    Component.onCompleted: {
        var csvFilePath = dataFolder.filePath("world-cities.csv");

        db.open();

        var statements = [
                    "CREATE VIRTUAL TABLE world_cities_csv USING CSV ('" + csvFilePath + "')",
                    "CREATE TABLE world_cities AS SELECT * FROM world_cities_csv",
                    "CREATE INDEX IX_world_cities_001 ON world_cities (country, subcountry, name)"
                ];

        statements.forEach(function (sql) {
            console.log("sql: ", sql);

            var query = db.query(sql);
            if (query.error) {
                throw new Error(query.error);
            }
        } );

        refreshCountryComboBox();
    }





    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}


