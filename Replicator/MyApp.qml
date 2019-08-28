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
import QtQuick.Controls 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "./Assets" as Assets
import "./Components"
import "./Views"

App {
    id: app
    width: 380
    height: 640

    readonly property real scaleFactor: AppFramework.displayScaleFactor
    readonly property int maximumScreenWidth: 568 * scaleFactor
    property bool isIphoneX: false

    property bool isUserLoggedInPortalA: false
    property bool isUserLoggedInPortalB: false
    readonly property string appClientId: app.info.json.deployment.clientId
    readonly property string appPortalUrl: "https://www.arcgis.com"

    property var tempStackViewItem

    /*--------------------------------------------------------------------------*/

    Component.onCompleted: {
        init();
    }

    /*--------------------------------------------------------------------------*/

    function init(){
        // check if iphone x
        if (Qt.platform.os === "ios" && AppFramework.systemInformation.hasOwnProperty("unixMachine")) {
            if (AppFramework.systemInformation.unixMachine === "iPhone10,3" || AppFramework.systemInformation.unixMachine === "iPhone10,6") {
                isIphoneX = true;
            }
        }

        initPortal("portalA");
        initPortal("portalB");
    }

    function initPortal(portalName) {
        var status = app.settings.value(portalName+"/isloggedIn");
        console.log("status", status)
        var refreshToken = app.settings.value(portalName+"/refreshToken");
        var _appClientId = "", _appPortalUrl = "";

        // first time log in
        if (status === undefined) {
            _appClientId = app.settings.setValue("appClientId", appClientId);
            _appPortalUrl = app.settings.setValue(portalName + "/appPortalUrl", appPortalUrl);
        }
        // not the first time
        else {
            _appClientId = app.settings.value("appClientId");
            // case sensitive doesn't matter
            _appPortalUrl = app.settings.value(portalName+"/appPortalUrl");

            if (status === true && refreshToken > "") {
                if(portalName === "portalA") {
                    isUserLoggedInPortalA = status;
                } else {
                    isUserLoggedInPortalB = status;
                }
            }
        }

        console.log("portal A auto sign in", isUserLoggedInPortalA)

        // if user has changed either clientId or portal url
        if (appClientId !== _appClientId) {
            // set to false and clear the state
            if(portalName === "portalA") {
                isUserLoggedInPortalA = false;
            } else {
                isUserLoggedInPortalB = false;
            }

            app.settings.setValue("appClientId", appClientId);
            app.settings.setValue(portalName+"/appPortalUrl", appPortalUrl);
            clearSettings(portalName);
        }

        console.log("portal A auto sign in", isUserLoggedInPortalA)

        if(AppFramework.network.isOnline){
            if(portalName === "portalA") {
                if(isUserLoggedInPortalA) {
                    portalA.autoSignIn();
                }
            } else {
                if(isUserLoggedInPortalB) {
                    portalB.autoSignIn();
                }
            }
        }
    }

    function clearSettings(portalName) {
        app.settings.setValue(portalName+"/isloggedIn", false);

        if(portalName === "portalA") {
            isUserLoggedInPortalA = false;
            portalA.clearSignedInState();
            portalA.signOut();
        } else {
            isUserLoggedInPortalB = false;
            portalB.clearSignedInState();
            portalB.signOut();
        }
    }

    /*--------------------------------------------------------------------------*/

    Assets.Fonts {
        id: fonts
    }

    Assets.Colors {
        id: colors
    }

    Assets.Strings {
        id: strings
    }

    Assets.Sources {
        id: sources
    }

    /*--------------------------------------------------------------------------*/

    // Component for copying an app from portal A to portal B
    TransferManager {
        id: transferManager

        sourcePortal: portalA
        destPortal: portalB
    }

    /*--------------------------------------------------------------------------*/

    NetworkManager {
        id: networkManager
    }

    /*--------------------------------------------------------------------------*/

    Portal {
        id: portalA
        tag: "portalA"
        clientID: app.appClientId
        settings: app.settings

        onSignedInChanged: {
            if (signedIn) {
                portalA.writeSignedInState();
                app.settings.setValue("portalA/isloggedIn", true);
                if(typeof stackView.currentItem.tag !== "undefined" && stackView.currentItem.tag === "websigninpage") stackView.pop(tempStackViewItem);
            }
        }
    }

    Portal {
        id: portalB
        tag: "portalB"
        clientID: app.appClientId
        settings: app.settings

        onSignedInChanged: {
            if (signedIn) {
                console.log("portalB signed in")
                portalB.writeSignedInState();
                app.settings.setValue("portalB/isloggedIn", true);
                if(typeof stackView.currentItem.tag !== "undefined" && stackView.currentItem.tag === "websigninpage") stackView.pop(tempStackViewItem);
            }
        }
    }

    /*--------------------------------------------------------------------------*/

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homepage
    }

    Component {
        id: homepage
        HomePage {
            onStart: {
                stackView.push(portalsChooserPage);
            }
        }
    }

    // Page for choosing portals
    Component {
        id: portalsChooserPage

        PortalsChooserPage {
            onNext: {
                stackView.push(contentPage)
            }

            onBack: {
                stackView.pop();
            }
        }
    }

    // Page for choosing content from portal A
    Component {
        id: contentPage

        ContentPage {
            onNext: {
                stackView.push(confirmPage, {itemDetails: itemDetails})
            }

            onBack: {
                stackView.pop();
            }
        }
    }

    // Page for confirming the copy operation
    Component {
        id: confirmPage

        ConfirmPage {
            onNext: {
                stackView.push(resultPage, {itemId: itemDetails.id});
            }

            onBack: {
                stackView.pop();
            }
        }
    }

    Component {
        id: portalTypePage
        PortalTypePage {

        }
    }

    Component {
        id: portalURLSettingsPage
        PortalURLSettingsPage {

        }
    }

    Component {
        id: webSignInPage
        WebSignInPage {

        }
    }


    // Page for loading
    Component {
        id: resultPage
        ResultPage {

        }
    }
}

