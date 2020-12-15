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
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2


import Esri.ArcGISRuntime 100.2
import Esri.ArcGISRuntime.Toolkit.Dialogs 100.2
import ArcGIS.AppFramework 1.0

import ArcGIS.AppFramework.SecureStorage 1.0
import ArcGIS.AppFramework.Authentication 1.0
import QtWebView 1.1

import "./controls" as Controls
import "./views" as Views

App {
    id: app
    width: 400 * scaleFactor
    height: 640 * scaleFactor

    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < 400 * scaleFactor

    property color primaryColor: "#7461A8"
    property alias stackView: stackView

    property var rtCreate: ArcGISRuntimeEnvironment.createObject
    property Portal portal
    property Portal securityPortal

    property bool isIPhoneX: false
    property bool isAutoSignIn: true
    property bool isBioAuth: false
    property bool canUseBioAuth: BiometricAuthenticator.supported && BiometricAuthenticator.activated
    readonly property string enable_auto_sign_in_toast:qsTr("Auto sign in enabled!")
    readonly property string disable_auto_sign_in_toast: qsTr("Auto sign in disabled!")
    readonly property string enable_touchID_toast: qsTr("Touch ID enabled!")
    readonly property string disable_touchID_toast: qsTr("Touch ID disabled!")
    readonly property string enable_fingerprint_toast: qsTr("Fingerprint authentication enabled!")
    readonly property string disable_fingerprint_toast: qsTr("Fingerprint authentication disabled!")
    readonly property string enable_faceid_toast: qsTr("Face ID enabled!")
    readonly property string disable_faceid_toast: qsTr("Face ID disabled!")
    readonly property string app_description: qsTr("This sample app demonstrates how to use ArcGIS online OAuth authentication in conjunction with biometric authentication. It also shows you how token is stored in system's secure storage using Secure Storage plug-in.")

    StackView {
        id:stackView
        anchors.fill: parent
        initialItem: signInPage
    }

    Component {
        id: signInPage

        Views.SignIn {
            onNext: {
                stackView.push(profilePage)
            }
        }
    }

    Component {
        id: profilePage

        Views.Profile {

            onBack: {
                stackView.pop();
            }
        }
    }

    Controls.SecureStorageHelper {
        id: secureStorage
    }

    Connections {
        target: securityPortal

        onLoadStatusChanged: {
            if (securityPortal.loadStatus === Enums.LoadStatusLoaded) {
                secureStorage.setContent("oAuthRefreshToken", securityPortal.credential.oAuthRefreshToken );
                secureStorage.setContent("tokenServiceUrl", securityPortal.credential.tokenServiceUrl);
            }
        }
    }

    function loadPortal() {
        var oauthInfo = rtCreate("OAuthClientInfo", {oAuthMode: Enums.OAuthModeUser, clientId: "hDdoYVKttzPsYtAV"})
        var credential = rtCreate("Credential", {
                                      oAuthClientInfo: oauthInfo,
                                      oAuthRefreshToken: secureStorage.getContent("oAuthRefreshToken"),
                                      tokenServiceUrl:"http://www.arcgis.com/sharing/rest/oauth2/token"
                                  });
        app.securityPortal = rtCreate("Portal", { url: "http://arcgis.com", credential: credential});
        if (securityPortal.loadStatus === 1) {
            securityPortal.retryLoad()

        }
        securityPortal.load();
        console.log(secureStorage.getContent("tokenServiceUrl"))
    }

    function appInitialization() {
        if (Qt.platform.os === "ios" && AppFramework.systemInformation.hasOwnProperty("unixMachine")) {
            if (AppFramework.systemInformation.unixMachine === "iPhone10,3" || AppFramework.systemInformation.unixMachine === "iPhone10,6") {
                isIPhoneX = true;
            }
        }

        isAutoSignIn = app.settings.value("appAutoSignIn",true);
        isBioAuth = app.settings.value("appBioAuth",true);

        if (isAutoSignIn) {
            if (isBioAuth && canUseBioAuth  ) {
                BiometricAuthenticator.message = qsTr("authenticate to proceed")
                BiometricAuthenticator.authenticate()
            } else {
                loadPortal()
                stackView.push(profilePage)
            }
        }
    }

    Connections {
        target: BiometricAuthenticator
        onAccepted: {
            loadPortal()
            stackView.push(profilePage)
        }
    }

    Component.onCompleted: {
        appInitialization()
    }

    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}







