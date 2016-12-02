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

import QtQuick 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {
    id: tourView

    property Portal portal
    property PortalItemInfo tourItemInfo
    property var tourInfo
    property alias tourFolder: tourFolder
    property alias tourMap: tourMap

    signal exit()

    //--------------------------------------------------------------------------

    function loadTour(itemInfo) {
        tourItemInfo = itemInfo;
        tourFolder.path = toursFolder.filePath(tourItemInfo.itemId);
        tourInfo = tourFolder.readJsonFile("mapTourInfo.json");
        //        console.log("Info", JSON.stringify(tourInfo, undefined, 2));
        tourMap.load(tourInfo.values.webmap);
    }

    //--------------------------------------------------------------------------



    //--------------------------------------------------------------------------

    WebMapHelper {
        id: tourMap

        portal: tourView.portal
        fileFolder: tourFolder
    }

    //--------------------------------------------------------------------------
}
