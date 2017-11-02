/* Copyright 2017 Esri
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
import ArcGIS.AppFramework.Authentication 1.0


App {
    id: app
    width: 400
    height: 750
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property bool isSmallScreen: (width || height) < units(400)
    property real scaleFactor: AppFramework.displayScaleFactor
    property bool isBiometricActivited: BiometricAuthenticator.activated
    property bool isBiometricSupported: BiometricAuthenticator.supported
    property string successMessage: qsTr ("Success!")
    property string errorMessageText: BiometricAuthenticator.errorMessage
    property string errorMessageDialogText
    property color successColor: Material.color(Material.Teal)
    property color errorColor: Material.color(Material.DeepOrange)

    property string turnPasscodeonMessage: qsTr("To continue, go to <b>Settings > Touch ID & Passcode</b> and <b>Turn Passcode on</b>")
    property string addFingerprintMessage: Qt.platform.os === "ios" ? qsTr("To continue, go to <b>Settings > Touch ID & Passcode</b> and <b>Add a Fingerprint</b>") : qsTr("To continue, go to <b>System Preferences > Touch ID </b> and <b>Add a Fingerprint</b>")

    Rectangle {

        // If biometric authentication is activated, show successColor (teal), otherwise, show errorColor (DeepOrange)

        color: isBiometricActivited ? successColor : errorColor
        anchors.fill: parent

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10 * scaleFactor

            Item {
                Layout.fillWidth: true
                height: 80 * scaleFactor
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Fingerprint Authentication")
                font.pixelSize: 20 * scaleFactor
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }

            //Show error message

            Label {
                id: supportedmessage
                Layout.fillWidth: true
                text: errorMessageText
                font.pixelSize: 16 * scaleFactor
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                visible: errorMessageText !== "No Error"
            }

            Item {
                Layout.fillWidth: true
                height: 100 * scaleFactor
            }

            ColumnLayout {
                anchors.centerIn: parent

                Image {
                    id: image
                    horizontalAlignment: Image.AlignHCenter
                    source: "ic_fingerprint.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                    smooth: true
                }

                Label {
                    id: touchID
                    text: isBiometricSupported ? qsTr("Touch ID Login") : ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    font.bold: true
                }

                // Tab on fingerprint image to displays a native fingerprint authentication dialog box

                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                        // Specify authentication dialog message

                        BiometricAuthenticator.message = "Authenticate to log into your account"
                        BiometricAuthenticator.authenticate()
                    }
                }


                Component.onCompleted:  {

                    if (errorMessageText !== "No Error") {

                        if (errorMessageText === "Passcode not activated") {
                            errorMessageDialogText = turnPasscodeonMessage;
                        }

                        if (errorMessageText === "Biometric not activated") {
                            errorMessageDialogText = addFingerprintMessage;
                        }

                        else {
                            messageDialog.visible = false
                        }
                    }
                    else {
                        messageDialog.visible = false
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                height: 30 * scaleFactor
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10 * scaleFactor

                Image {
                    id: icon
                    width: 30 * scaleFactor
                    height: 30 * scaleFactor
                }

                Label {
                    id: statusMessage
                    color: "white"
                    font.bold: true
                    font.pointSize: 20 * scaleFactor
                    anchors.verticalCenter: icon.verticalCenter
                }
            }

            Item {
                Layout.fillWidth: true
                height: 40 * scaleFactor
            }
        }
    }

    // When the authentication is successful, show successMessage ("Success!"). when the authentication has failed, show reason
    Connections {
        target: BiometricAuthenticator

        onAccepted : {
            icon.source = "ic_action_check_circle.png"
            statusMessage.text = successMessage
        }

        onRejected : {
            icon.source = "ic_action_error.png"
            statusMessage.text = constructMessage(reason)
        }
    }

    function constructMessage(reason) {
        var result = "";
        switch (reason)
        {
        case BiometricAuthenticator.CancelledByUser:
            result = qsTr("Cancelled By User");
            break;
        case BiometricAuthenticator.InValidCredentials:
            result = qsTr("Invalid Credentials");
            break;
        case BiometricAuthenticator.BiometricNotConfigured:
            result = qsTr("Not Configured");
            break;
        case BiometricAuthenticator.UserFallback:
            result = qsTr("User Fallback");
            break;
        case BiometricAuthenticator.PermissionDenied:
            result = qsTr("Permission Denied");
            break;
        case BiometricAuthenticator.BiometricNotSupported:
            result = qsTr("Biometric Not Supported");
            break;
        case BiometricAuthenticator.BadCapture:
            result = qsTr("Bad Capture");
            break;
        case BiometricAuthenticator.PlatformNotSupported:
            result = qsTr("Platform Not Supported");
            break;
        default:
            result = qsTr("Unknown");
        }
        return result;
    }

    Dialog {
        id: messageDialog
        Material.accent: errorColor
        title: errorMessageText
        width: !isSmallScreen ? 300 * scaleFactor : parent.width * 0.8
        height: !isSmallScreen ? 200 * scaleFactor : parent.height * 0.35
        x: (parent.width - width)/2
        y: (parent.height - height)/2
        Material.theme: Material.Light
        closePolicy: Popup.NoAutoClose
        modal: true
        font.pointSize: 14 * scaleFactor
        standardButtons: Dialog.Ok
        visible: true
        // visible: errorMessageText === "Passcode not activated" && "Biometric not activated" ? true : false

        Label {
            id: message
            text: errorMessageDialogText
            opacity: 0.9
            wrapMode: Label.Wrap
            width: parent.width
            height: implicitHeight
            font.pointSize: 12 * scaleFactor
        }
    }
}
