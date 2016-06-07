/* Copyright 2015 Esri
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


import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQml.Models 2.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

App {
    id: app
    width: 400
    height: 640

    property bool switchLayout: app.width > app.height

    // ---- Data model -------
    ListModel {
        id: samples

        ListElement {
            name: "Sathya"
            place: "Redlands, CA"
            job: "GIS Developer"
        }

        ListElement {
            name: "Chris"
            place: "Redlands, CA"
            job: "Product Guru"
        }
    }

    // ------------ Component to be used as Delegate -----------
    Component {
        id: rowLayout
        Rectangle {
            color: "#CECECE"
            width: parent.width
            height: 50

            RowLayout {

                Text {
                    anchors.margins: 10
                    text: "My name is " + name
                }

                Text {
                    anchors.margins: 10
                    text: "My job is " + job
                }
            }
        }
    }

    // ------------ Component to be used as Delegate -----------
    Component {
        id: columnLayout
        Rectangle {
            color: "#CECECE"
            width: parent.width
            height: 50

            ColumnLayout {

                Text {
                    anchors.margins: 10
                    text: "My name is " + name
                }

                Text {
                    anchors.margins: 10
                    text: "My job is " + job
                }
            }
        }
    }


    //----------------------

    ListView {
        spacing: 10
        anchors.fill: parent
        model: samples
        delegate: switchLayout ? rowLayout : columnLayout

        Component.onCompleted: {
            //add data to model on load of this component ListView
            addData("Chris", "Georgia", "Dev")
        }
    }

    //--------------------

    Button {
        anchors.centerIn: parent
        text: "Add Data"
        onClicked: {
            //call javascript function to add data
            addData("Tom", "Noblesville, IN", "GIS Dev")
        }
    }

    //javascript function to add data into model
    function addData(name, place, job) {
        samples.append({
                           name: name,
                           place: place,
                           job: job
                       })
    }

}

