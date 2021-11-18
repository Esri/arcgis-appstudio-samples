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


import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import QtQuick.Dialogs 1.2

import Esri.ArcGISRuntime 100.12

import ArcGIS.AppFramework 1.0

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736

    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int  baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)
    property url  qmlfile
    property string sampleName
    property string descriptionText
    property string currentFeatureName: ""
    property string currentSectionName: ""
    property var poisInRange: []
    property var descriptionMap: ({})
    property var imageUrlMap: ({})
    property var featuresMap: ({})
    property ArcGISFeature feature: null
    property Attachment imageAttachment: null
    property AttachmentListModel attachmentListModel: null
    property double positionAccuracy: -1
    property var locale: Qt.locale()
    property var localeMeasurementSystem: locale.measurementSystem
    property int appstate: Qt.application.state


    Page {
        anchors.fill: parent
        anchors.bottomMargin: batteryConsumptionStatusBar.currentBatteryState === "Discharging" ? batteryConsumptionStatusBar.batteryBarHeight : 0
        header: ToolBar {
            id: header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }
        //Sample starts here
        contentItem: Rectangle{
            id: loader
            anchors.top:header.bottom
            Loader{
                height: app.height - header.height
                width: app.width
                source: qmlfile
            }
        }

        //If app is not into foreground, stop timer to conserve battery.
        Connections {
            target: Qt.application
            function onStateChanged() {
                if(appstate !== 4){
                    batteryConsumptionStatusBar.timerRunning = false;
                } else {
                    batteryConsumptionStatusBar.timerRunning = true;
                }
            }
        }
    }

    // Functions
    function getFeatureInformation(featureName) {
        sfeatureInfoPane.featureName = featureName;
        sfeatureInfoPane.description = descriptionMap[featureName];

        // If image has already been fetched, retrieve it from memory
        if (featureName in imageUrlMap) {
            sfeatureInfoPane.imageSourceUrl = imageUrlMap[featureName];
            return
        }

        sfeatureInfoPane.imageSourceUrl = "";

        // Otherwise fetch the attachment from the feature's AttachmentListModel
        feature = featuresMap[featureName];
        attachmentListModel = feature.attachments;

        attachmentListModel.onFetchAttachmentsStatusChanged.connect(getImageAttachmentUrl);
    }

    function getImageAttachmentUrl() {
        if (attachmentListModel.fetchAttachmentsStatus === Enums.TaskStatusCompleted) {
            imageAttachment = attachmentListModel.get(0);
            imageAttachment.onFetchDataStatusChanged.connect(() => {
                                                                 if (imageAttachment.fetchDataStatus === Enums.TaskStatusCompleted)
                                                                 sfeatureInfoPane.imageSourceUrl = imageUrlMap[currentFeatureName] = imageAttachment.attachmentUrl;
                                                             });

            imageAttachment.fetchData();
        }
    }

    Controls.DescriptionPage{
        id:descPage
        visible: false
    }

    // The FeatureInfoPane displays the name, description, and image retrieved from a fence feature.
    Controls.SimulatedFeatureInfoPane {
        id: sfeatureInfoPane
    }

    Controls.CurrentDeviceFeatureInfoPane{
        id: aboutCurrentDeviceFeaturePane
    }

    //For displaying battery consumption status bar
    Controls.BatteryConsumptionBar {
        id: batteryConsumptionStatusBar
        enabled: true
    }

    //For choosing between samples
    Controls.FloatActionButton{
        id:switchBtn
        visible: sfeatureInfoPane.visible || aboutCurrentDeviceFeaturePane.visible || descPage.visible ? false : true
    }

    Controls.PopUpPage{
        id:popUp
        visible:false
    }

}

