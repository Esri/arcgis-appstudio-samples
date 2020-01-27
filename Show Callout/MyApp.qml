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
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0


import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.2
import Esri.ArcGISRuntime.Toolkit.Controls 100.2
import Esri.ArcGISRuntime.Toolkit.Dialogs 100.2


import "controls" as Controls

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


    property Point calloutLocation
    property real xCoor
    property real yCoor

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
            // Map view UI presentation at top
            MapView {
                id: mapView
                anchors.fill: parent
                clip: true

                Map {
                    BasemapTopographic {}

                    // initial Viewpoint
                    ViewpointCenter {
                        Point {
                            x: -1.2e7
                            y: 5e6
                            spatialReference: SpatialReference.createWebMercator()
                        }
                        targetScale: 1e7
                    }
                }

                //! [show callout qml api snippet]
                // initialize Callout
                calloutData {
                    imageUrl: "./assets/RedShinyPin.png"
                    title: "Location"
                    location: calloutLocation
                    detail: "x: " + xCoor + " y: " + yCoor
                }

                Callout {
                    id: callout
                    calloutData: parent.calloutData
                }
                //! [show callout qml api snippet]

                // display callout on mouseClicked
                onMouseClicked: {
                    if (callout.calloutVisible)
                        callout.dismiss()
                    else
                    {
                        calloutLocation = mouse.mapPoint;
                        xCoor = mouse.mapPoint.x.toFixed(2);
                        yCoor = mouse.mapPoint.y.toFixed(2);
                        callout.accessoryButtonHidden = true;
                        callout.showCallout();
                    }
                }
            }
        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

