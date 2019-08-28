/* Copyright 2019 Esri
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
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2
import Esri.ArcGISRuntime.Toolkit.Dialogs 100.1
import QtWebView 1.1

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
    property var detailNames: ["Full name", "Username", "Email", "Bio", "Who can see your profile?"]
    property var detailValue: ["fullName", "username", "email", "userDescription", "access"]

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
                anchors {
                    top: userDetailsColumn.bottom;
                    bottom: midLine.top
                    left: parent.left;
                    right: parent.right;
                    margins: 10 * scaleFactor
                }
                spacing: 10 * scaleFactor
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

                            if(detailValue[index] !== "access")
                                return user[detailValue[index]];

                            if (user.access === Enums.PortalAccessOrganization)
                                return "Organization";
                            else if (user.access === Enums.PortalAccessPrivate)
                                return "Only you";
                            else if (user.access === Enums.PortalAccessPublic)
                                return "Everyone";
                            else if (user.access === Enums.PortalAccessShared)
                                return "Shared Groups";
                            return "????";
                        }
                        color: "grey"
                        maximumLineCount: 3
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        width: parent.width * 0.9
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

            Column {
                id: portalDetailsColumn
                visible: portal.loadStatus === Enums.LoadStatusLoaded
                anchors {
                    top: midLine.bottom
                    left: parent.left
                    right: parent.right
                    margins: 10 * scaleFactor
                }
                spacing: 10 * scaleFactor

                Text {
                    text: portal.portalInfo ? portal.portalInfo.organizationName : ""
                    font.bold: true
                    font.pointSize: 15
                    maximumLineCount: 3
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    width: parent.width * 0.9
                }

                Image {
                    source : portal.portalInfo ? portal.portalInfo.thumbnailUrl : ""
                    height: 32 * scaleFactor
                    width: 32 * scaleFactor
                }
            }

            ListView {
                id: infoList
                visible: portal.loadStatus === Enums.LoadStatusLoaded
                anchors {
                    top: portalDetailsColumn.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    margins: 10 * scaleFactor
                }
                spacing: 10 * scaleFactor
                clip: true
                model: infoValues.length

                delegate: Column {
                    width: parent.width
                    Text {
                        text: portal.portalInfo ? infoLabels[index] : ""
                        font.bold: true
                        maximumLineCount: 3
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        width: parent.width * 0.9
                    }

                    Text {
                        text: portal.portalInfo ? portal.portalInfo[infoValues[index]] : ""
                        color: "grey"
                        maximumLineCount: 3
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        width: parent.width * 0.9
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

                Component.onCompleted: load();

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

