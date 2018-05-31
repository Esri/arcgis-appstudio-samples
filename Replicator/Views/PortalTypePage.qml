import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "../Widgets"

Page {
    property int mode: 1
    property var portal: mode === 1 ? portalA : portalB

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
    }

    Item {
        anchors.fill: parent

        ColumnLayout {
            width: Math.min(parent.width - 32 * scaleFactor, maximumScreenWidth)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 24 * scaleFactor
            }

            Label {
                Layout.fillWidth: true
                text: strings.select_account_type
                font {
                    weight: Font.Medium
                    pixelSize: 14 * scaleFactor
                }
                color: colors.black_87
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16 * scaleFactor
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.width * 0.49

                RowLayout {
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 0

                    Rectangle {
                        Layout.preferredWidth: parent.height
                        Layout.fillHeight: true

                        color: colors.card_background
                        border.width: 1
                        border.color: colors.card_border
                        radius: 2 * scaleFactor
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 0
                            anchors.centerIn: parent

                            IconImage {
                                Layout.preferredWidth: parent.width * 0.31
                                Layout.preferredHeight: parent.width * 0.31
                                source: sources.ago_portal
                                color: colors.primary_color
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: parent.width * 0.08
                            }

                            Label {
                                text: strings.arcgis_online
                                font {
                                    weight: Font.Normal
                                    pixelSize: 14 * scaleFactor
                                }
                                color: colors.black_87
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                portal.url = "https://www.arcgis.com"
                                stackView.push(webSignInPage, {"mode": mode}, StackView.Immediate);
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: parent.width * 0.02
                        Layout.fillHeight: true
                    }

                    Rectangle {
                        Layout.preferredWidth: parent.height
                        Layout.fillHeight: true

                        color: colors.card_background
                        border.width: 1
                        border.color: colors.card_border
                        radius: 2 * scaleFactor
                        clip: true

                        ColumnLayout {
                            width: parent.width
                            spacing: 0
                            anchors.centerIn: parent

                            IconImage {
                                Layout.preferredWidth: parent.width * 0.31
                                Layout.preferredHeight: parent.width * 0.31
                                source: sources.enterpise_portal
                                color: colors.primary_color
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: parent.width * 0.08
                            }

                            Label {
                                text: strings.arcgis_enterprise
                                font {
                                    weight: Font.Normal
                                    pixelSize: 14 * scaleFactor
                                }
                                color: colors.black_87
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                stackView.push(portalURLSettingsPage, {"mode": mode}, StackView.Immediate);
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
