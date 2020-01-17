import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Material 2.2

import "../GNSSPlugin"

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ConnectionsPage {
            Layout.fillHeight: true
            Layout.fillWidth: true

            sources: app.sources
            controller: app.controller

            foregroundColor: app.greyTextColor
            secondaryForegroundColor: app.primaryColor
            backgroundColor: app.navBarColor
            secondaryBackgroundColor: app.backgroundColor
            connectedColor: primaryColor
            Material.accent: primaryColor

            onShowInternalChanged: {
                if (showInternal) {
                    clear();
                }
            }

            onIsConnectedChanged: {
                if (isConnected) {
                    textToSpeech.say(connectedText);
                    clear();
                    showLocationPage();
                } else {
                    clear();
                    textToSpeech.say(disconnectedText);
                }
            }
        }
    }
}
