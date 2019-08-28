import QtQuick 2.9
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import "../Widgets"

Drawer {
    id: root

    modal: false
    interactive: false
    dim: false
    Material.elevation: appManager.isSmall? 4: 0

    ColumnLayout {
        anchors.fill: parent
        ToolBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 56 * app.scaleFactor
            Material.elevation: 0
            Material.background: app.toolbarColor
            RowLayout {
                width: parent.width
                height: 56 * app.scaleFactor
                CustomizedToolButton {
                    Layout.preferredWidth: parent.height
                    Layout.preferredHeight: parent.height
                    imageSource: sources.closeIcon
                    onClicked: {
                        infoDrawer.close();
                    }
                }
                Label {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: strings.aboutTheApp
                    font.pixelSize: 18 * app.scaleFactor
                    font.bold: true
                    verticalAlignment: Label.AlignVCenter
                }
            }
        }
        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Item {
                anchors.fill: parent
                anchors.margins: 16 * app.scaleFactor
                ColumnLayout {
                    anchors.fill: parent
                    Label {
                        Layout.fillWidth: true
                        text: strings.description
                        color: colors.subTextColor
                    }
                    Label {
                        Layout.fillWidth: true
                        text: qsTr(app.info.description)
                        wrapMode: Label.WordWrap
                        linkColor: app.primaryColor
                        onLinkActivated: {
                            infoDrawer.close();
                            geocodeView.openBrowserView(link);
                        }
                    }
                    Label {
                        visible: licenseInfo.text > ""
                        Layout.fillWidth: true
                        text: strings.accessConstraints
                        color: colors.subTextColor
                    }
                    Label {
                        id: licenseInfo

                        Layout.fillWidth: true
                        text: app.info.itemInfo.licenseInfo
                        wrapMode: Label.WordWrap
                    }

                    Label {
                        Layout.fillWidth: true
                        text: strings.appVersion
                        color: colors.subTextColor
                    }

                    Label {
                        Layout.fillWidth: true
                        text: app.info.version
                        wrapMode: Label.WordWrap
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20 * app.scaleFactor
                    }

                    Label {
                        Layout.fillWidth: true
                        text: strings.about
                        color: colors.subTextColor
                    }

                    Label {
                        Layout.fillWidth: true
                        text: strings.credits
                        wrapMode: Label.WordWrap
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
