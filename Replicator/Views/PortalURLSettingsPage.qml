import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0

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
                text: strings.arcgis_enterprise_url
                font {
                    weight: Font.Medium
                    pixelSize: 14 * scaleFactor
                }
                color: colors.black_87
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 24 * scaleFactor
            }

            TextField {
                id: urlTextField

                Layout.fillWidth: true
                Material.accent: colors.primary_color
                inputMethodHints: Qt.ImhUrlCharactersOnly
                selectByMouse: true

                font {
                    weight: Font.Normal
                    pixelSize: 16 * scaleFactor
                }
                color: colors.black_87

                onAccepted: {
                    openWebSignInPage();
                }

                Component.onCompleted: {
                    this.forceActiveFocus();
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 32 * scaleFactor
            }

            Label {
                text: strings.goto_signin
                anchors.left: parent.left
                font {
                    weight: Font.Medium
                    pixelSize: 16 * scaleFactor
                }
                color: colors.primary_color
            }

            Button {
                anchors.right: parent.right
                topPadding: 9 * scaleFactor
                bottomPadding: topPadding
                rightPadding: 24 * scaleFactor
                leftPadding: rightPadding

                text: strings.next
                Material.foreground: colors.white_100
                Material.background: colors.primary_color

                font {
                    weight: Font.Normal
                    pixelSize: 16 * scaleFactor
                }

                onClicked: {
                    openWebSignInPage();
                }

            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

    function openWebSignInPage() {
        portal.url = urlTextField.text;
        stackView.push(webSignInPage, {"mode": mode}, StackView.Immediate);
    }
}
