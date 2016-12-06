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
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0

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
        url: "https://www.arcgis.com"
        credentials: oAuthCredentials

        Component.onCompleted: {
             signIn();
        }
    }

    UserCredentials {
        id: oAuthCredentials
        oAuthClientInfo: OAuthClientInfo {
            clientId: "2A5iPKnxUzZjOQPN"
            oAuthMode: Enums.OAuthModeUser
        }
    }

    Connections {
        target: ArcGISRuntime.identityManager

        onOAuthCodeRequired: {
            authUrl = authorizationUrl;
            console.log(authUrl)
            webViewContainer.webView.url = authorizationUrl;
            webViewContainer.visible = true;
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

            Text {
                width: app.width
                font.pixelSize: 14 * scaleFactor
                wrapMode: Text.WordWrap
                text: portal.signedIn ? "Full name: " + portal.user.fullName : ""
            }

            Text {
                width: app.width
                font.pixelSize: 14 * scaleFactor
                wrapMode: Text.WordWrap
                text: portal.signedIn ? "Created on: " + portal.user.created : ""
            }

            Text {
                width: app.width
                font.pixelSize: 14 * scaleFactor
                wrapMode: Text.WordWrap
                text: portal.signedIn ? "Modified on: " + portal.user.modified: ""
            }

            Text {
                width: app.width
                font.pixelSize: 14 * scaleFactor
                wrapMode: Text.WordWrap
                text: portal.signedIn ? "Organization Id: " + portal.portalInfo.organizationId : ""
            }

            Text {
                width: app.width - app.width/10
                wrapMode: Text.WrapAnywhere
                font.pixelSize: 14 * scaleFactor
                text: portal.signedIn ?  "License string: " + portal.portalInfo.licenseInfo.json["licenseString"] : ""
            }
        }
    }
    
    WebViewContainer {
        id: webViewContainer
        anchors.fill: parent
        visible: false
    }

    Connections {
        target: webViewContainer.webView

        onLoadingChanged: {
            console.log("webView.title", webViewContainer.webView.title);

            if (webViewContainer.webView.title.indexOf("SUCCESS code=") > -1) {
                var authCode = webViewContainer.webView.title.replace("SUCCESS code=", "");
                ArcGISRuntime.identityManager.setOAuthCodeForUrl(authUrl, authCode);
                webViewContainer.visible = false;
            } else if (webViewContainer.webView.title === "Denied error=access_denied") { // Cancel pressed
                console.log("User denied request")
            }
        }
    }
}
