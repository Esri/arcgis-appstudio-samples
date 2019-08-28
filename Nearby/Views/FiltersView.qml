import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import "../Widgets"

Drawer {
    id: root

    property real selectedDistance: 3
    edge: Qt.RightEdge
    modal: false
    interactive: true
    dim: false
    Material.elevation: appManager.isSmall? 4: 0

    Rectangle {
        id: settingsHeader

        height: 56 * app.scaleFactor
        width: parent.width
        color: app.toolbarColor;

        RowLayout {
            anchors.fill: parent
            spacing: 0

            CustomizedToolButton {
                Layout.alignment: Qt.AlignVCenter
                imageSource: sources.closeBlackIcon
                overlayColor: app.secondaryColor
                onClicked: {
                    close();
                }
            }
        }
    }

    Flickable {
        anchors.top: settingsHeader.bottom
        width: parent.width
        height: parent.height - settingsHeader.height
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Column {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                height: 56 * app.scaleFactor
                width: parent.width

                Label {
                    text: strings.searchDistance
                    anchors.fill: parent
                    background: Rectangle {
                        color: colors.lightGrey
                    }
                    color: app.textColor
                    verticalAlignment: Label.AlignVCenter
                    padding: 16 * app.scaleFactor
                }
            }

            CheckBox {
                text: app.deviceManager.localeInfoNameIsEn_US? "1 mile": "1 km"
                Material.accent: app.primaryColor
                checked: selectedDistance === 0
                onClicked: {
                    selectedDistance = 0;
                    setSearchDistance(0);
                }
            }

            CheckBox {
                text: app.deviceManager.localeInfoNameIsEn_US? "5 miles": "5 km"
                Material.accent: app.primaryColor
                checked: selectedDistance === 1
                onClicked: {
                    selectedDistance = 1;
                    setSearchDistance(1);
                }
            }

            CheckBox {
                text: app.deviceManager.localeInfoNameIsEn_US? "10 miles": "20 km"
                Material.accent: app.primaryColor
                checked: selectedDistance === 2
                onClicked: {
                    selectedDistance = 2;
                    setSearchDistance(2);
                }
            }

            CheckBox {
                text: app.deviceManager.localeInfoNameIsEn_US? "20 miles": "20 km"
                Material.accent: app.primaryColor
                checked: selectedDistance === 3
                onClicked: {
                    selectedDistance = 3;
                    setSearchDistance(3);
                }
            }

            CheckBox {
                text: app.deviceManager.localeInfoNameIsEn_US? "30 miles": "30 km"
                Material.accent: app.primaryColor
                checked: selectedDistance === 4
                onClicked: {
                    selectedDistance = 4;
                    setSearchDistance(4);
                }
            }
        }
    }

    function setSearchDistance(selection) {
        let distance = 0;
        switch(selection) {
        case 0:
            distance = 1;
            break;
        case 1:
            distance = 5;
            break;
        case 2:
            distance = 10;
            break;
        case 3:
            distance = 20;
            break;
        case 4:
            distance = 30;
            break;
        }
        distance = app.deviceManager.localeInfoNameIsEn_US? distance * app.milesToMeters: distance * app.kiloMetersToMeters;
        app.searchDistance = distance;
        close();
        clearResults();
        geocodeAddress();
    }
}
