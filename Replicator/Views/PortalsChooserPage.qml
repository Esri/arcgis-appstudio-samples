import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0

import "../Widgets"

Page {
    id: root

    signal next()
    signal back()

    Flickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: bodyColumnLayout.height

        ColumnLayout {
            id: bodyColumnLayout
            width: Math.min(parent.width - 32 * scaleFactor, maximumScreenWidth)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 25 * scaleFactor
            }

            Label {
                Layout.fillWidth: true
                text: strings.step_no.arg(1)
                font {
                    weight: Font.Normal
                    pixelSize: 24 * scaleFactor
                }
                color: colors.primary_color
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 8 * scaleFactor
            }

            Label {
                Layout.fillWidth: true
                text: strings.step1_description
                font {
                    weight: Font.Normal
                    pixelSize: 14 * scaleFactor
                }
                color: colors.black_54
                wrapMode: Label.Wrap
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 24 * scaleFactor
            }

            PortalCard {
                id: portalCard_A

                portal: portalA
                mode: 1

                Layout.fillWidth: true
                Layout.preferredHeight: height

                onOpenSignInPage: {
                    tempStackViewItem = stackView.currentItem;
                    stackView.push(portalTypePage, {"mode": 1}, StackView.Immediate);
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 16 * scaleFactor
            }

            PortalCard {
                id: portalCard_B

                portal: portalB
                mode: 2

                Layout.fillWidth: true
                Layout.preferredHeight: height

                onOpenSignInPage: {
                    tempStackViewItem = stackView.currentItem;
                    stackView.push(portalTypePage, {"mode": 2}, StackView.Immediate);
                }
            }
        }

    }

    footer: NavigatorFooter {
        id: navigatorFooter

        isNextEnabled: portalCard_A.isSignedIn && portalCard_B.isSignedIn

        onBack: {
            root.back();
        }

        onNext: {
            root.next();
        }
    }
}
