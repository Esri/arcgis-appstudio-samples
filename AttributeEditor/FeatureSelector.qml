/* ******************************************
Copyright 2015 Esri

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and limitations under the License.​
******************************************* */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Rectangle {
    property alias rListView: listView

    id: rectFeatures
    width: parent.width
    height: 60*app.scaleFactor
    y:app.height

    color: "lightgray"

    Behavior on y {
        id: behaviorOnYFeatures
        NumberAnimation {duration: 400}
        enabled: false
    }

    ListView {
        id: listView
        width: parent.width - 40*app.scaleFactor
        height: parent.height
        anchors.centerIn: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        delegate: featurePicker
        model: queriedFeaturesModel
        currentIndex: -1

        onCurrentItemChanged: {
            currentIndex = indexAt(contentX, contentY)
            selectedId = listView.model.get(currentIndex).id
            console.log("currentIndex",currentIndex)
            //Show features rectangle
            rectFeatures.y = app.height - rectFeatures.height
            //Select first feature in model
            console.log(selectedId)
            selectFeature("changed")
        }

        onFlickEnded: {
            currentIndex = indexAt(contentX, contentY)
            console.log("flickIndex", currentIndex)
            // Clear features
            featureLayer.clearSelection();

            // Select feature geometry corresponding to current feature in model
            selectFeature("flicked")
            console.log(selectedId)

            if (rectAttributes.visible == true)
                rectAttributes.rRepeater.model = listView.model.get(listView.currentIndex).fields
        }

        //SELECT THE CLICKED OR FLICKED FEATURE
        function selectFeature(x) {
            console.log(x)
            featureLayer.clearSelection();

            // Automatically open the attribute viewer if a feature is added
            if (featureAdded == true){
                console.log("featureAdded")
                rectAttributes.rRepeater.model = listView.model.get(listView.currentIndex).fields
                rectAttributes.rFlickableValuesList.contentY = 0
                rectAttributes.visible = true
                rectAttributes.y = 0
            }
            selectedId = listView.model.get(currentIndex).id
            featureLayer.selectFeature(selectedId)
            console.log("sel", selectedId)

            featureSelected = true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                rectAttributes.rRepeater.model = listView.model.get(listView.currentIndex).fields
                //rectAttributes.rFlickableValuesList.contentY = 0
                rectAttributes.visible = true
                rectAttributes.y = 0
            }
        }
    }
}
