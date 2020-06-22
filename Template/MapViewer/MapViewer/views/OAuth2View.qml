import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1

import Esri.ArcGISRuntime 100.7

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.WebView 1.0

import "../controls" as Controls

Controls.PopupPage {
    id: root

    property Portal portal // Takes a secured portal i.e. A portal that has a Credential object. This is the only way an authentication challenge is created
    property var authChallenge
    property real headerHeight: 56
    property real iconSize: 48
    property bool isSignedIn: portal ? portal.loadStatus === Enums.LoadStatusLoaded && portal.credential.token > "" : false
    property bool closeButtonClicked: false

    property LocaleInfo localeInfo: AppFramework.localeInfo(Qt.locale().uiLanguages[0])

    signal signInInitiated ()

    contentItem: Controls.BasePage {
        id: content

        header: ToolBar {
            id: pageHeader

            height: headerHeight

            RowLayout {
                anchors.fill: parent

                Controls.Icon {
                    imageSource: "../images/close.png"
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: app.widthOffset

                    onClicked: {
                        root.close()
                        root.closeButtonClicked = true
                    }
                }
            }
        }

        contentItem: Pane {
            id: pageContent

            clip: true
            anchors {
                top: pageHeader.bottom
                left: root.left
                right: root.right
                bottom: root.bottom
            }
            padding: 0

            focus: true
            Keys.onReleased: {
                if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape){
                    event.accepted = true
                    root.close()
                }
            }
        }
    }

    Component {
        id: webViewComponent

        WebView {
            id: webItem

            url: {
                if (portal) {
                    var portalUrl = portal.url.toString().replace("http://", "https://")
                    return (authChallenge ? authChallenge.authorizationUrl + "&hidecancel=true&locale=" + localeInfo.esriName : "").replace("https://www.arcgis.com", portalUrl)
                } else {
                    return authChallenge ? authChallenge.authorizationUrl + "&hidecancel=true&locale=" + localeInfo.esriName : ""
                }
            }

            clip: true
            visible: false
            onLoadingChanged: {
                busyIndicator.visible = loadRequest.status === WebView.LoadStartedStatus
                visible = true
                if (loadRequest.status === WebView.LoadSucceededStatus) {
                    if (title.indexOf("SUCCESS code=") > -1) {
                        var authCode = title.replace("SUCCESS code=", "")
                        if (authChallenge) {
                            authChallenge.continueWithOAuthAuthorizationCode(authCode)
                            signInInitiated()
                        }
                    } else if (title.indexOf("Denied error=") > -1) {
                        if (authChallenge) {
                            authChallenge.cancel()
                        }
                    }
                }
            }
        }
    }

    BusyIndicator {
        id: busyIndicator

        anchors.centerIn: parent
        width: iconSize
        height: width
    }

    onSignInInitiated: {
        busyIndicator.visible = true
        pageContent.contentItem.visible = false
    }

    onIsSignedInChanged: {
        if (isSignedIn) {
            close()
        }
    }

    Connections {
        target: AuthenticationManager

        onAuthenticationChallenge: {
            switch (challenge.authenticationChallengeType) {
            case (Enums.AuthenticationChallengeTypeOAuth):
                authChallenge = challenge
                break
            case (Enums.AuthenticationChallengeTypeSslHandshake):
                challenge.continueWithSslHandshake(true, true)
                break
            }
        }
    }

    onCloseButtonClickedChanged: {
        if (closeButtonClicked) {
            if (typeof authChallenge !== "undefined") {
                authChallenge.cancel()
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            busyIndicator.visible = true
            closeButtonClicked = false
            pageContent.contentItem = webViewComponent.createObject(null)
        }
    }
}
