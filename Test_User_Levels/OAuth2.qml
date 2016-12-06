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
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0
import QtWebView 1.1

App {
    id: app
    clip : true
    width: 800 * scaleFactor
    height: 600 * scaleFactor

    property double scaleFactor: AppFramework.displayScaleFactor
    property string authUrl
    property string clientID: app.info.value("deployment").clientId

    Portal {
        id: portal
        credentials: oAuthCredentials

        onSignInComplete: fillText()

        function portalSignIn() {
            if (portalCombo.currentIndex !== 0) {
                url = portalCombo.currentText
                signIn()
            } else if (portalURLTF.text.length > 0) {
                url = portalURLTF.text
                signIn()
            } else {
                url = ""
            }

        }

        function fillText() {
            fullNameText.text = portal.signedIn ? "Full name: " + portal.user.fullName : ""
            createdOnText.text = portal.signedIn ? "Created on: " + portal.user.created : ""
            modifiedOnText.text = portal.signedIn ? "Modified on: " + portal.user.modified: ""
            organizationIDText.text = portal.signedIn ? "Organization Id: " + portal.portalInfo.organizationId : ""
            licenseStringText.text = portal.signedIn ?  "License string: " + portal.portalInfo.licenseInfo.json["licenseString"] : ""
            levelText.text=portal.signedIn ? "Level: " + portal.user.json.level: ""
        }

        function clearText() {
            signOut()
            fullNameText.text = ""
            createdOnText.text = ""
            modifiedOnText.text = ""
            organizationIDText.text = ""
            licenseStringText.text = ""
            levelText.text = ""
        }
    }

    UserCredentials {
        id: oAuthCredentials
        oAuthClientInfo: OAuthClientInfo {
            //clientId: "2A5iPKnxUzZjOQPN"
            clientId: "appstudioplayer"
            oAuthMode: Enums.OAuthModeUser
        }
    }

    Connections {
        target: ArcGISRuntime.identityManager

        onOAuthCodeRequired: {
            authUrl = authorizationUrl;
            console.log("authUrl : " + authUrl)
            webView.url = authorizationUrl;
            webView.visible = true;
        }
    }

    Item {
        Column {
            anchors {
                fill: parent
                margins: 10 * scaleFactor
            }
            spacing: 10 * scaleFactor

            Image {
                width: 50 * scaleFactor
                height: 50 * scaleFactor
                fillMode: Image.PreserveAspectFit
                source: portal.signedIn ? portal.user.thumbnailUrl : ""
                visible : {
                    if (portal.signedIn) {
                        if (portal.user.thumbnailUrl)
                            visible = true;
                    } else {
                        visible = false;
                    }
                }
            }

            ComboBox {
                id:portalCombo
                currentIndex: 0
                width:400
                model: ["Select Portal","https://www.arcgis.com","https://devext.arcgis.com", "https://portalhostds.ags.esri.com/gis", "https://portaliwads.ags.esri.com/gis"]
            }

            TextField {
                id:portalURLTF
                width:400
                placeholderText : qsTr("Enter Portal URL")
            }

            Button {
                id:signInButton
                text: portal.signedIn ? "Sign Out" : "Sign In"
                MouseArea{
                        anchors.fill: parent
                        onClicked: portal.signedIn ? portal.clearText() : portal.portalSignIn()
                    }
            }

            Text {
                id:levelText
                width: app.width
                font.pixelSize: 18 * scaleFactor
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Text {
                id: fullNameText
                width: app.width
                font.pixelSize: 14 * scaleFactor
                wrapMode: Text.WordWrap
            }

            Text {
                id: createdOnText
                width: app.width
                font.pixelSize: 14 * scaleFactor
                wrapMode: Text.WordWrap
            }

            Text {
                id: modifiedOnText
                width: app.width
                font.pixelSize: 14 * scaleFactor
                wrapMode: Text.WordWrap
            }

            Text {
                id: organizationIDText
                width: app.width
                font.pixelSize: 14 * scaleFactor
                wrapMode: Text.WordWrap
            }

            Text {
                id: licenseStringText
                width: app.width - app.width/10
                wrapMode: Text.WrapAnywhere
                font.pixelSize: 14 * scaleFactor
            }

        }
    }

    WebView {
        id: webView
        anchors.fill: parent
        visible: false

        onLoadingChanged: {
            console.log("webView.title", title);

            if (/*(loadProgress === 100) &&*/
                title.indexOf("SUCCESS code=") > -1) {
                var authCode = title.replace("SUCCESS code=", "");
                console.log("authCode: ", authCode);
                ArcGISRuntime.identityManager.setOAuthCodeForUrl(authUrl, authCode);
                visible = false;
            } else if (title === "Denied error=access_denied") { // Cancel pressed
                console.log("User denied request")
            }
        }
    }
}
