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

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework.Runtime 1.0

ListView {
    id: listView

    property string query: "tags:Map Tour"

    function getQueryString(portal) {
        var query = app.portalQueryItemTypes;
        if(portal.portalInfo && portal.portalInfo.organizationId) {
            query = query + " orgid:" + portal.portalInfo.organizationId
        }

        if(app.queryString && app.queryString.length>1) {
            query = query + " " + app.queryString;
        }

        return query;
    }

    property int searchPageSize: 10
    property string orderBy: app.sortField || "created"
    property string sortOrder: app.sortOrder ||  "desc"
    property Portal portal
    property PortalItemInfo currentTour: currentIndex >= 0 ? model[currentIndex] : null

    signal clicked(PortalItemInfo itemInfo)
    signal doubleClicked(PortalItemInfo itemInfo)
    signal searchCompleted()

    model: portalSearch.results
    highlightFollowsCurrentItem: true
    focus: true

    highlight: Rectangle {
        id: rectangle

        width: parent.width
        height: 100

        color: "#000000"
        radius: 4
        opacity: 0.5

        y: rectangle.ListView.view ? rectangle.ListView.view.currentItem.y : 0

        Behavior on y {
            SpringAnimation {
                spring: 3
                damping: 0.2
            }
        }
    }

    footer: Rectangle {
        height:60*app.scaleFactor
        color: "transparent"
        width: parent.width
        visible: portalSearch.results.length > 0
        Text {
            anchors.centerIn: parent
            font.family: app.customTextFont.name
            text: qsTr("Click on a Tour to get started")
            font {
                pointSize: app.baseFontSize * 0.5
                italic: true
            }
            color: "#f7f8f8"
            wrapMode: Text.Wrap
        }
    }

    function refresh() {

        var json = portalSearchParameters.json;
        json.sortOrder = sortOrder;

        portalSearchParameters.json = json;

        //var params = ArcGISRuntime.createObject("PortalSearchParameters");
        //params.json = json;

        console.log(JSON.stringify(portalSearchParameters.json));

        portalSearch.searchItems(portalSearchParameters);


    }


    onQueryChanged: {
        refresh();
    }



    PortalSearchItems {
        id: portalSearch
        portal: listView.portal

        onResultsChanged: {
            console.log("Total resutls from portal: ", portalSearch.totalResults);
            if(portalSearch.totalResults == 0) {
                busyIndicator2.visible = false
                galleryMessageBox.visible = true
                galleryMessageBox.text = "Sorry! No items from portal to display";
            } else {
                listView.searchCompleted();
            }
        }

        onError: {
            console.log(error.desciption);
            busyIndicator2.visible = false
            galleryMessageBox.visible = true
            galleryMessageBox.text = error.desciption;
        }
    }

    PortalSearchParameters {
        id: portalSearchParameters
        sortField: orderBy
        start: 1
        limit: searchPageSize
        query: getQueryString(portal)
    }
}
