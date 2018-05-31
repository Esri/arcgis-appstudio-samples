import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.WebView 1.0

import "../Widgets"

Page {
    id: webSignInPage

    property int mode: 1

    property string tag: "websigninpage"
    property var portal: mode === 1 ? portalA: portalB
    property string portalUrl: portal ? portal.portalUrl : ""
    property string clientID: portal.clientID
    readonly property string redirect_url: "urn:ietf:wg:oauth:2.0:oob"
    property string authorizationCode: ""
    readonly property string authorizationEndpoint: portalUrl + "/sharing/rest/oauth2/authorize/"
    readonly property string authorizationUrl: authorizationEndpoint + "?hidecancel=true&client_id=" + clientID + "&grant_type=code&response_type=code&expiration=-1&redirect_uri=" + redirect_url + "&locale=" + Qt.locale().uiLanguages[0]

    // Header
    header: ToolBar {
        height: 56 * scaleFactor
        Material.primary: colors.primary_color
        Material.elevation: 4

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.preferredWidth: 56 * scaleFactor
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignLeft

                SmartToolButton {
                    imageSource: sources.close

                    onClicked: {
                        stackView.pop(StackView.Immediate);
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: mode === 1 ? strings.source_account : strings.dest_account

                font {
                    weight: Font.Medium
                    pixelSize: 20 * scaleFactor
                }
                color: colors.white_100

                horizontalAlignment: Label.AlignLeft
                verticalAlignment: Label.AlignVCenter

                clip: true
                elide: Text.ElideRight
            }
        }

        Rectangle {
            width: webSignInPageWebView.loadProgress / 100 * parent.width
            height: 3 * scaleFactor
            anchors.bottom: parent.bottom
            color: "#FAD817"
            visible: webSignInPageWebView.loadProgress < 100 ? true : false
        }
    }

    // Web view
    WebView {
        id: webSignInPageWebView
        anchors.fill: parent
        url: authorizationUrl
        visible: AppFramework.network.isOnline

        onLoadingChanged: {
            if (title.indexOf("SUCCESS code=") > -1) {
                var authCode = title.replace("SUCCESS code=", "");
                authorizationCode = authCode;
                visible = false;
                portal.getTokenFromCode(clientID, redirect_url, authorizationCode);

            } else if (title.indexOf("error=public_account_access_denied") > -1) {
                console.log("Error: public_account_access_denied")
            }
        }
    }

    // Busy indicator
    BusyIndicator {
        anchors.centerIn: parent
        running: webSignInPageWebView.loading
        Material.accent: colors.primary_color
    }

    function refresh() {
        app.forceActiveFocus();
        webSignInPageWebView.reload();
    }
}
