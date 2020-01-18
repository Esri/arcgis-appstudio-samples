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
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.2
//import Esri.ArcGISRuntime.Toolkit.Dialogs 100.1
import QtWebView 1.1

import "controls" as Controls
import "Dialogs"

App {
    id: app
    width: 414
    height: 736
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

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle{
            anchors.top:header.bottom
            MapView {
                id: mapView
                anchors.fill: parent

                Map {
                    BasemapTopographic {}

                    // add a map service that is secured with token-based authentication
                    // username/password is user1/user1
                    ArcGISMapImageLayer {
                        url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/USA_secure_user1/MapServer"
                    }

                    ViewpointExtent {
                        Envelope {
                            json: {"spatialReference":{"latestWkid":3857,"wkid":102100},
                                "xmax":-3024411.4154897667,
                                        "xmin":-19221397.32591107,
                                        "ymax":11939432.83566906,
                                        "ymin":-208306.59714691807
                            }
                        }
                    }
                }
            }

            // Declare an AuthenticationView
            AuthenticationView {
                anchors.fill: parent
                authenticationManager: AuthenticationManager // set the authenticationManager property
            }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

