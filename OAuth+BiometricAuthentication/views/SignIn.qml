
import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2


import ArcGIS.AppFramework.SecureStorage 1.0
import ArcGIS.AppFramework.Authentication 1.0

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.11

import "../controls" as Controls

Rectangle {

    signal next();

    id: signInPage
    color: primaryColor

    Image {
        id: infoIcon
        source: "../image/info.png"
        mipmap: true
        width: 36 * scaleFactor
        height: width
        anchors.left: parent.left
        anchors.leftMargin: 10 * scaleFactor
        anchors.top: parent.top
        anchors.topMargin: 10 * scaleFactor

        MouseArea {
            anchors.fill: parent
            onClicked: {
                descPage.visible = 1
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.7
        height: parent.height * 0.7
        spacing: 0

        Image {
            id: profileImage
            source: "../image/profile.png"
            mipmap: true
            width: 165 * scaleFactor
            height: width
            Layout.alignment: Qt.AlignHCenter
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    BiometricAuthenticator.authenticate()
                }
            }
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Label.WrapAtWordBoundaryOrAnywhere
            Layout.alignment: Qt.AlignHCenter
            font.bold: true
            color: "white"
            elide: Label.ElideRight
            text:qsTr("Welcome")
            font.pixelSize: 17 * scaleFactor
            horizontalAlignment: Label.AlignHCenter
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 170 * scaleFactor
        }

        Button {
            id: signinButton
            Layout.preferredWidth: 150 * scaleFactor
            Layout.preferredHeight: 50 * scaleFactor
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Sign In")
            Material.background: "white"
            Material.foreground: primaryColor

            onClicked: {
                next();
                loadPortal();
            }
        }
    }
}

