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
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0


ListView {
    id: legendView

    property Map map

    model: legendModel

    spacing: 3
    clip: true
    
    section {
        property: "layerName"
        criteria: ViewSection.FullString
        delegate: legendSectionDelegate
        labelPositioning: ViewSection.InlineLabels
    }
    
    
    delegate: legendItemDelegate

    //--------------------------------------------------------------------------

    Component {
        id: legendSectionDelegate

        Item {
            width: parent.width
            height: textControl.height

            Text {
                id: textControl

                anchors.verticalCenter: parent.verticalCenter
                text: section
                width: parent.width
                font {
                    pointSize: 10
                    bold: true
                }
                color: "#4c4c4c"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: legendItemDelegate

        Item {
            width: parent.width
            height: Math.max(legendImage.height, legendText.height)

            Image {
                id: legendImage
                anchors {
                    left: parent.left
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }

                source: image
                height: 30 * AppFramework.displayScaleFactor
                width: height
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: legendText

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: legendImage.right
                    leftMargin: 4
                    right: parent.right
                }

                text: label
                color: "#4c4c4c"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font {
                    pointSize: 10
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    ListModel {
        id: legendModel
    }

    function updateModel() {
        legendModel.clear();

        //console.log("Legend Layers", map.layerCount);

        for (var layerIndex = 0; layerIndex < map.layerCount; layerIndex++) {
            var layer = map.layerByIndex(layerIndex);
            if (!layer.visible) {
                continue;
            }

            switch (layer.type) {
            case Enums.LayerTypeArcGISTiledMapService :
                continue;

            default:
                break;
            }

            var legendInfos = layer.legend;

            //console.log("Legend Infos", legendInfos.length);

            for (var infoIndex = 0; infoIndex < legendInfos.length; infoIndex++) {
                var legendInfo = legendInfos[infoIndex];

                var legendItems = legendInfo.legendItems;
                //console.log("Legend Items", legendInfo.layerName, legendItems.length);

                for (var itemIndex = 0; itemIndex < legendItems.length; itemIndex++) {
                    var legendItem = legendItems[itemIndex];

                    legendModel.append(
                                {
                                    "layerName": legendInfo.layerName,
                                    "image": legendItem.image.toString(),
                                    "label": legendItem.label
                                });
                }
            }
        }
    }

    //--------------------------------------------------------------------------
}
