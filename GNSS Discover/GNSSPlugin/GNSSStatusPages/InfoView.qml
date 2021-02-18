/* Copyright 2021 Esri
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

import QtQuick 2.12

import ArcGIS.AppFramework 1.0

Column {
    property alias model: repeater.model

    property Component sectionDelegate
    property Component dataDelegate
    property Component dividerDelegate: divider

    //--------------------------------------------------------------------------

    spacing: 10 * AppFramework.displayScaleFactor
    
    //--------------------------------------------------------------------------

    Repeater {
        id: repeater

        delegate: Loader {
            width: parent.width
            
            property int modelIndex: index
            property var modelData: repeater.model[index]
            
            sourceComponent: modelData ? dataDelegate : dividerDelegate
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: divider

        Rectangle {
            color: "#40808080"
            implicitHeight: 1
        }
    }

    //--------------------------------------------------------------------------
}
