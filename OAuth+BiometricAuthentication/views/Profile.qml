import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.WebView 1.0
import ArcGIS.AppFramework.Authentication 1.0

import Esri.ArcGISRuntime 100.11
import Esri.ArcGISRuntime.Toolkit 100.11


import QtGraphicalEffects 1.0

import "../controls" as Controls

Page {
    id: profilePage

    property var user: securityPortal ? securityPortal.portalUser : ""
    property Portal myportal: portal
    property LocaleInfo localeInfo: AppFramework.localeInfo(Qt.locale().uiLanguages[0])

    signal back();
    signal next();

    header: ToolBar {
        height: 52 * scaleFactor
        width: parent.width
        Material.elevation: 4
        Material.background: primaryColor

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item{
                Layout.preferredWidth: 0.2 * app.scaleFactor
                Layout.fillHeight: true
            }

            ToolButton {
                Layout.preferredHeight: 42 * scaleFactor
                Layout.preferredWidth: 42 * scaleFactor

                indicator: Image {
                    id: image
                    anchors.fill: parent
                    anchors.centerIn: parent
                    source: "../image/left.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true

                }

                onClicked: {
                    back();
                    authenticationView.authChallenge.cancel();
                    securityPortal.cancelLoad();
                }
            }
        }
    }

    ColumnLayout {
        id: userDetailsColumn
        width: parent.width
        visible: securityPortal && securityPortal.loadStatus === Enums.LoadStatusLoaded
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        Label {
            id: profileLabel
            Layout.fillWidth: true
            Layout.preferredHeight: 40 * scaleFactor
            Layout.topMargin: 8 * scaleFactor
            background: Rectangle {
                anchors.fill: parent
                color:"#00000000"
            }
            text: qsTr("Profile")
            horizontalAlignment: Label.AlignLeft
            verticalAlignment: Label.AlignVCenter
            leftPadding: 16 * scaleFactor
            rightPadding: 16 * scaleFactor
            clip: true
            elide: Text.ElideRight
            color:"black"
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56 * scaleFactor

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.preferredWidth: 10 * scaleFactor
                    Layout.fillHeight: true
                }

                Item {
                    Layout.preferredHeight: 40 * scaleFactor
                    Layout.preferredWidth: 40 * scaleFactor

                    Image {
                        id: profileImage
                        smooth: true
                        visible: false
                        sourceSize: Qt.size(parent.width, parent.height)
                        source: user ? user.thumbnailUrl : ""
                    }

                    Rectangle {
                        id:mask
                        height: 40  * scaleFactor
                        width: 40 * scaleFactor
                        radius: 5
                    }

                    OpacityMask {
                        anchors.fill: profileImage
                        source: profileImage
                        maskSource: mask
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Label {
                    text: user ? user.fullName : ""
                    font.pixelSize: 16
                    rightPadding: 25 * scaleFactor
                    color:"#444444"
                }
            }
        }

        Label {
            id: settingsLabel
            Layout.fillWidth: true
            Layout.preferredHeight: 40 * scaleFactor
            Layout.topMargin: 8 * scaleFactor
            background: Rectangle {
                anchors.fill: parent
                color:"#00000000"
            }
            text: qsTr("Settings")
            horizontalAlignment: Label.AlignLeft
            verticalAlignment: Label.AlignVCenter
            leftPadding: 16 * scaleFactor
            rightPadding: 16 * scaleFactor
            clip: true
            elide: Text.ElideRight
            color:"black"
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56 * scaleFactor

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Label {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("Auto Sign In Using Secure Storage")
                    font.pixelSize: 16 * scaleFactor
                    verticalAlignment: Label.AlignVCenter
                    leftPadding: 16 * scaleFactor
                    clip: true
                    elide: Text.ElideRight
                    color:"#444444"

                }

                Switch {
                    id: autoSignInSwitch
                    Material.accent: app.primaryColor
                    checked: isAutoSignIn
                    onToggled: {
                        isAutoSignIn =! isAutoSignIn
                        app.settings.setValue("appAutoSignIn",app.isAutoSignIn);
                        if (isAutoSignIn) {
                            toastMessage.displayToast(enable_auto_sign_in_toast);
                        } else {
                            toastMessage.displayToast(disable_auto_sign_in_toast);
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56 * scaleFactor
            visible: BiometricAuthenticator.supported

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Label {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: app.isIphoneX ? qsTr("Face ID") : (Qt.platform.os === "ios" || Qt.platform.os === "osx" ? qsTr("Touch ID") : qsTr("Fingerprint"))
                    font.pixelSize: 16 * scaleFactor
                    verticalAlignment: Label.AlignVCenter
                    leftPadding: 16 * scaleFactor
                    clip: true
                    elide: Text.ElideRight
                    color:"#444444"
                }

                Switch {
                    id: fingerprintSwitch
                    Material.accent: app.primaryColor
                    checked: isBioAuth
                    enabled: canUseBioAuth && app.isAutoSignIn

                    onToggled: {
                        isBioAuth =!isBioAuth
                        app.settings.setValue("appBioAuth", isBioAuth)
                        if (isBioAuth) {
                            toastMessage.displayToast(isIphoneX ? enable_faceid_toast : ((Qt.platform.os === "ios" || Qt.platform.os === "osx") ? enable_touchID_toast : enable_fingerprint_toast));
                        } else {
                            toastMessage.displayToast(isIphoneX ? disable_faceid_toast : ((Qt.platform.os === "ios" || Qt.platform.os === "osx") ? disable_touchID_toast : disable_fingerprint_toast));
                        }
                    }
                }
            }
        }

        Item {
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 40 * scaleFactor
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56 * scaleFactor

            Label {
                id: signOutLabel
                anchors.fill: parent
                font.pixelSize: 16 * scaleFactor
                verticalAlignment: Label.AlignVCenter
                horizontalAlignment: Label.AlignHCenter
                clip: true
                elide: Text.ElideRight
                color:"#444444"
                text: qsTr("Sign Out")
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    back()
                    securityPortal.destroy();
                    AuthenticationManager.credentialCache.removeAllCredentials();
                    secureStorage.setContent("oAuthRefreshToken", "")
                }
            }
        }
    }

    AuthenticationView {
        id: authenticationView
        anchors.fill: parent
    }

    BusyIndicator {
        anchors.centerIn: parent
        Material.accent: primaryColor
        running: securityPortal && securityPortal.loadStatus === Enums.LoadStatusLoading
    }

    Controls.ToastMessage {
        id: toastMessage
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
