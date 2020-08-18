import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0

import "../Widgets"

Rectangle {
    property var portal
    property var username: portal.userFullName
    property var portal_name: portal.portalName
    property var portal_url: portal.portalUrl
    property var thumbnail: portal.userThumbnailUrl
    property bool isSignedIn: portal.signedIn
    property int mode: 1
    property bool editEnabled: true

    signal openSignInPage()

    Layout.fillWidth: true
    Layout.preferredHeight: isSignedIn ? 132 * scaleFactor : 112 * scaleFactor
    width: parent.width
    height: isSignedIn ? 132 * scaleFactor : 112 * scaleFactor

    color: colors.card_background
    border.width: 1
    border.color: colors.card_border
    radius: 2 * scaleFactor
    clip: true

    ColumnLayout {
        width: parent.width - 32 * scaleFactor
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        visible: isSignedIn

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16 * scaleFactor
        }

        Label {
            Layout.fillWidth: true
            text: mode == 1 ? strings.source_account : strings.dest_account
            font {
                weight: Font.Medium
                pixelSize: 12 * scaleFactor
            }
            color: colors.black_54
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16 * scaleFactor
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                spacing: 0

                RoundedImage {
                    Layout.preferredHeight: 48 * scaleFactor
                    Layout.preferredWidth: 48 * scaleFactor
                    imageSource: thumbnail > "" ? thumbnail : sources.placeholder
                    fillMode: Image.PreserveAspectCrop
                    mipmap: true
                    Layout.alignment:Qt.AlignTop
                    radius: 24 * scaleFactor
                    clip: true
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 16 * scaleFactor
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Label {
                            Layout.fillWidth: true
                            text: username
                            font {
                                weight: Font.Normal
                                pixelSize: 14 * scaleFactor
                            }
                            color: colors.black_87
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 4 * scaleFactor
                        }

                        Label {
                            Layout.fillWidth: true
                            text: portal_name
                            font {
                                weight: Font.Normal
                                pixelSize: 12 * scaleFactor
                            }
                            color: colors.black_54
                            elide: Label.ElideRight
                        }

                        Label {
                            Layout.fillWidth: true
                            text: extractHostname(portal_url+"")
                            font {
                                weight: Font.Normal
                                pixelSize: 12 * scaleFactor
                            }
                            color: colors.black_54
                            elide: Label.ElideRight
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 16 * scaleFactor
                }

                IconImage {
                    Layout.preferredHeight: 22 * scaleFactor
                    Layout.preferredWidth: 22 * scaleFactor
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: 15 * scaleFactor
                    source: sources.editImage
                    color: colors.primary_color
                    visible: editEnabled

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            portal.signOut();
                            app.clearSettings(mode === 1 ? "portalA" : "portalB");
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 0 * scaleFactor
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 6 * scaleFactor
        }
    }

    RowLayout {
        width: parent.width - 32 * scaleFactor
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !isSignedIn
        spacing: 0

        Label {
            Layout.fillWidth: true
            text: mode == 1 ? strings.source_account : strings.dest_account
            font {
                weight: Font.Normal
                pixelSize: 16 * scaleFactor
            }
            color: colors.black_87
            elide: Label.ElideRight
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Button {
            topPadding: 9 * scaleFactor
            bottomPadding: topPadding
            rightPadding: 24 * scaleFactor
            leftPadding: rightPadding

            text: strings.sign_in
            Material.foreground: colors.white_100
            Material.background: colors.primary_color

            font {
                weight: Font.Medium
                pixelSize: 14 * scaleFactor
            }

            onClicked: {
                openSignInPage()
            }

        }
    }

    function extractHostname(url) {
        var hostname;

        if (url.indexOf("://") > -1) {
            hostname = url.split('/')[2];
        }
        else {
            hostname = url.split('/')[0];
        }

        hostname = hostname.split(':')[0];
        hostname = hostname.split('?')[0];

        return hostname;
    }
}
