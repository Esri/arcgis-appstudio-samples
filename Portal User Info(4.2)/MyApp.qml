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
import Esri.ArcGISRuntime 100.7
import Esri.ArcGISRuntime.Toolkit.Controls 100.7
import Esri.ArcGISRuntime.Toolkit.Dialogs 100.1

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736

    Material.accent: "#8f499c"
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)
    property var user: portal.portalUser
    property var detailNames: ["Full name", "Username", "Email", "Who can see your profile?", "ArcGIS Runtime License"]
    property var detailValue: ["fullName", "username", "email", "access", "license"]

    property var infoLabels: ["Description", "Can Find External Content", "Can Share Items Externally"]
    property var infoValues: ["organizationDescription", "canSearchPublic", "canSharePublic"]

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
            BusyIndicator {
                id: loadingIndicator
                anchors.centerIn: parent
                running: portal.loadStatus !== Enums.LoadStatusLoaded
            }

            Column {
                id: userDetailsColumn
                visible: portal.loadStatus === Enums.LoadStatusLoaded
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 10 * scaleFactor
                }
                spacing: 10 * scaleFactor

                Text {
                    text: user ? user.fullName + " Profile" : ("????")
                    font.bold: true
                    font.pointSize: 15
                    maximumLineCount: 3
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    width: parent.width * 0.9
                }

                Image {
                    source : user && user.thumbnailUrl.toString().length > 0 ? user.thumbnailUrl : "./assets/placeholder_img.png"
                    height: 32 * scaleFactor
                    width: 32 * scaleFactor
                }
            }

            ListView {
                id: userList
                visible: portal.loadStatus === Enums.LoadStatusLoaded
                height: parent.height * 0.28
                anchors {
                    top: userDetailsColumn.bottom;
                    left: parent.left;
                    right: parent.right;
                    margins: 10 * scaleFactor
                }
                spacing: 8 * scaleFactor
                clip: true
                model: detailNames.length

                delegate: Column {
                    width: parent.width
                    Text {
                        text: detailNames[index]
                        font.bold: true
                        maximumLineCount: 3

                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        width: parent.width * 0.9
                    }

                    Text {
                        text: {
                            if (!user)
                                return "????";

                            if(detailValue[index] !== "access" && detailValue[index] !== "license")
                            {return user[detailValue[index]];}
                            else if(detailValue[index] === "access")
                            {
                                switch(user.access) {
                                case Enums.PortalAccessOrganization:
                                    return "Organization";

                                case Enums.PortalAccessPrivate:
                                    return "Only you";

                                case Enums.PortalAccessPublic:
                                    return "Everyone";

                                case Enums.PortalAccessShared:
                                    return "Shared Groups";

                                default:
                                    return "????";
                                }
                            }
                            else {
                                if (portal.fetchLicenseInfoStatus === Enums.TaskStatusCompleted) {
                                    ArcGISRuntimeEnvironment.setLicense(portal.fetchLicenseInfoResult);
                                    switch(ArcGISRuntimeEnvironment.license.licenseLevel) {
                                    case Enums.LicenseLevelLite:
                                        return "Lite";

                                    case Enums.LicenseLevelBasic:
                                        return "Basic";

                                    case Enums.LicenseLevelStandard:
                                        return "Standard";

                                    case Enums.LicenseLevelAdvanced:
                                        return "Advanced";

                                    case Enums.LicenseLevelDeveloper:
                                        return "Developer";

                                    default:
                                        return "Unknown";
                                    }
                                }
                                else {return "????";}

                            }
                        }
                        color: "grey"
                        maximumLineCount: 3
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        width: parent.width * 0.9
                    }
                }
            }

            Rectangle{
                id: webmapIdArea
                anchors{
                    top: userList.bottom
                    bottom: midLine.top
                    margins: 5 * scaleFactor
                    left: parent.left
                    right: parent.right
                }
                border.color: "grey"


                Text {
                    id: webmapIdTitle
                    text: "Please enter your public/private web map id"
                    font.bold: true
                    maximumLineCount: 3
                    anchors{
                        leftMargin: 5 * scaleFactor
                        left: parent.left
                        right: parent.right
                    }
                    topPadding: 5 * scaleFactor
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    width: parent.width * 0.9
                    height: 15
                }

                TextField{
                    id: webmapId
                    anchors{
                        top: webmapIdTitle.bottom
                        margins: 5 * scaleFactor
                        left: parent.left
                        bottomMargin:0
                        bottom: parent.bottom
                    }
                    width: parent.width*0.7
                    selectByMouse: true
                    placeholderText: "Enter webmap id"
                    font{pointSize:baseFontSize *0.7}
                    opacity: 1

                }

                Button{
                    id: loadPrivateWebmap
                    anchors{
                        left: webmapId.right
                        right: parent.right
                        margins: 10 * scaleFactor
                        verticalCenter: parent.verticalCenter
                    }
                    text:"Show Map"
                    onClicked: {
                        var portalItem = ArcGISRuntimeEnvironment.createObject("PortalItem",{
                                                                                   portal: portal,
                                                                                   itemId: webmapId.text
                                                                               });
                        var newMap = ArcGISRuntimeEnvironment.createObject("Map",{item:portalItem})
                        mapView.map = newMap;
                    }
                }

            }

            Rectangle {
                id: midLine
                anchors {
                    verticalCenter: parent.verticalCenter
                    margins: 8 * scaleFactor
                    left: parent.left
                    right: parent.right
                }
                height: 4 * scaleFactor
                visible: portal.loadStatus === Enums.LoadStatusLoaded
                color: "lightgrey"
            }

            MapView {
                id:mapView
                anchors {
                    top: midLine.bottom
                    left: parent.left
                    right: parent.right
                    margins: 10 * scaleFactor
                    bottom: parent.bottom
                }



                Map {
                    id: map
                    item: PortalItem {
                        portal: portal
                        itemId: "2d6fa24b357d427f9c737774e7b0f977"
                    }
                }

            }

            //! [PortalUserInfo create portal]
            Portal {
                id: portal
                credential: Credential {
                    oAuthClientInfo: OAuthClientInfo {
                        oAuthMode: Enums.OAuthModeUser
                        clientId: "T3Gjh6a2d0MK14ke"
                    }
                }

                Component.onCompleted: {load();
                    fetchLicenseInfo();}

                onLoadStatusChanged: {
                    if (loadStatus === Enums.LoadStatusFailedToLoad)
                        retryLoad();
                }
            }

            AuthenticationView {
                id: authView
                authenticationManager: AuthenticationManager
            }
            //! [PortalUserInfo create portal]

        }
    }

    // sample ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}

