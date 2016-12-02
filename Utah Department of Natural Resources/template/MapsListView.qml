/*******************************************************************************
 * Copyright 2012-2014 Esri
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 ******************************************************************************/

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework.Runtime 1.0

ListView {
    id: listView

    property int searchPageSize: 100
    property Portal portal
    property PortalItemInfo currentTour: currentIndex >= 0 ? model[currentIndex] : null
    property string searchQuery: ""

    signal clicked(PortalItemInfo itemInfo)
    signal doubleClicked(PortalItemInfo itemInfo)
    signal searchCompleted();

    model: portalSearch.results
    focus: true

    function refresh() {
        portalSearchParameters.query = 'type:"Web Map"' + (searchQuery > "" ? "AND " + searchQuery : "");
        console.log("Query", portalSearchParameters.query);
        portalSearch.searchItems(portalSearchParameters);
    }

    PortalSearchItems {
        id: portalSearch
        portal: listView.portal

        onRequestStatusChanged: {
            if (requestStatus === Enums.PortalRequestStatusComplete) {
                listView.searchCompleted();
            }
        }
    }

    PortalSearchParameters {
        id: portalSearchParameters
        start: 1
        limit: searchPageSize
        query: listView.query
    }
}
