import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import Esri.ArcGISRuntime 100.7

import "../controls" as Controls

Controls.CustomDialog {
    id: loginDialog

    property string description: qsTr("")

    defaultMargin: app.defaultMargin
    pageHeaderHeight: app.headerHeight
    Material.primary: app.primaryColor
    Material.accent: app.accentColor
    flickable: false
    title: qsTr("Sign In")
    height: app.units(306)

    header: Controls.SubtitleText {
        visible: text > ""
        topPadding: defaultMargin
        rightPadding: loginDialog.rightPadding
        leftPadding: loginDialog.leftPadding
        color: baseTextColor
        bottomPadding: 0
        text: loginDialog.title
        maximumLineCount: 1
        elide: Text.ElideRight
        font.bold: true
    }
    
    content: ColumnLayout {

        Controls.BaseText {
            id: desc

            Layout.preferredWidth: parent.width
            Layout.topMargin: app.defaultMargin
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 3
            text: loginDialog.description

            states: [
                State {
                    name: "ERROR"
                    PropertyChanges {
                        target: desc
                        color: "red"
                    }
                }
            ]
        }
        
        TextField {
            id: username
            Layout.topMargin: app.defaultMargin
            Layout.preferredWidth: parent.width
            placeholderText: qsTr("Username")

            onAccepted: {
                if (authChallenge) {
                    authChallenge.continueWithUsernamePassword(username.text, password.text)
                }
                close()
            }
        }
        
        TextField {
            id: password
            Layout.preferredWidth: parent.width
            placeholderText: qsTr("Password")
            echoMode: TextInput.Password

            onAccepted: {
                if (authChallenge) {
                    authChallenge.continueWithUsernamePassword(username.text, password.text)
                }
                close()
            }
        }
    }

    property var authChallenge
    QtObject {
        id: challengeCount

        property int usernamePassword: 0
        property int oAuth: 0
        property int clientCertificate: 0
        property int sslHandshake: 0
    }

    Connections {
        target: AuthenticationManager

        onAuthenticationChallenge: {
            authChallenge = challenge;

            if (Number(challenge.authenticationChallengeType) === Enums.AuthenticationChallengeTypeUsernamePassword) {
                // ArcGIS token, HTTP Basic/Digest, IWA
                challengeCount.usernamePassword += 1
                if (challengeCount.usernamePassword > 1) {
                    desc.state = "ERROR"
                    loginDialog.show(qsTr("Invalid username and password combination!"))
                } else {
                    desc.state = ""
                    loginDialog.show(qsTr("You need to sign in to access the resource at '%1'").arg(authChallenge.authenticatingHost))
                }
            } else if (Number(challenge.authenticationChallengeType) === Enums.AuthenticationChallengeTypeOAuth) {
                // OAuth 2
            } else if (Number(challenge.authenticationChallengeType) === Enums.AuthenticationChallengeTypeClientCertificate) {
                // Client Certificate
            } else if (Number(challenge.authenticationChallengeType) === Enums.AuthenticationChallengeTypeSslHandshake) {
                // SSL Handshake - Self-signed certificate
            }
        }
    }

    standardButtons: StandardButton.Ok | StandardButton.Cancel

    onRejected: {
        if (authChallenge) {
            authChallenge.cancel()
        }
        clearText()
    }

    onAccepted: {
        if (authChallenge) {
            authChallenge.continueWithUsernamePassword(username.text, password.text)
        }
        close()
    }

    function clearText () {
        username.text = ""
        password.text = ""
    }
    
    function show (desc) {
        if (!desc) desc = qsTr("Authentication required")
        loginDialog.description = desc
        loginDialog.open()
    }
    
    function hide () {
        loginDialog.description = ""
        loginDialog.close()
    }
}
