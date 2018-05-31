import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    property string itemId: ""

    property int resultState: 1 //0 = default, 1 = loading, 2 = error, 3 = done

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        visible: resultState === 1

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 170 * scaleFactor
        }

        Item {
            Layout.preferredWidth: 120 * scaleFactor
            Layout.preferredHeight: 120 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            AnimatedImage {
                width: 100 * scaleFactor
                height: width
                source: sources.loading_image
                playing: visible
                anchors.centerIn: parent
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 26 * scaleFactor
        }

        Label {
            Layout.preferredWidth: parent.width - 32 * scaleFactor
            text: transferManager._action
            leftPadding: rightPadding
            rightPadding: 0
            horizontalAlignment: Label.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font {
                weight: Font.Medium
                pixelSize: 16 * scaleFactor
            }
            color: colors.primary_color
            wrapMode: Label.Wrap
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8 * scaleFactor
        }

        Label {
            Layout.preferredWidth: parent.width - 32 * scaleFactor
            text: transferManager.requestProgress
            leftPadding: rightPadding
            rightPadding: 0
            horizontalAlignment: Label.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font {
                weight: Font.Medium
                pixelSize: 16 * scaleFactor
            }
            color: colors.primary_color
            wrapMode: Label.Wrap
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        visible: resultState === 2 || resultState === 3

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 64 * scaleFactor
        }

        Label {
            text: resultState === 3 ? strings.step4_success : strings.step4_failed
            horizontalAlignment: Label.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font {
                weight: Font.Normal
                pixelSize: 24 * scaleFactor
            }
            color: resultState === 3 ? colors.primary_color: Material.Red
            wrapMode: Label.Wrap
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16 * scaleFactor
        }

        Image {
            Layout.preferredWidth: Math.min(parent.width - 104 * scaleFactor, 256 * scaleFactor)
            Layout.preferredHeight: Math.min(parent.width - 104 * scaleFactor, 256 * scaleFactor)
            source: resultState === 3 ? sources.success_image : sources.failed_image
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Button {
            Layout.preferredWidth: 192 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 9 * scaleFactor
            bottomPadding: topPadding
            rightPadding: 24 * scaleFactor
            leftPadding: rightPadding
            visible: resultState === 3

            text: strings.share_app
            Material.foreground: colors.white_100
            Material.background: colors.primary_color

            font {
                weight: Font.Medium
                pixelSize: 14 * scaleFactor
            }

            onClicked: {
                var webURL = portalB.url + "/home/item.html?id=" + transferManager._destItemId;
                AppFramework.clipboard.share(webURL);
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8 * scaleFactor
            visible: resultState === 3
        }

        Button {
            Layout.preferredWidth: 192 * scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 9 * scaleFactor
            bottomPadding: topPadding
            rightPadding: 24 * scaleFactor
            leftPadding: rightPadding

            text: resultState === 3 ? strings.done : strings.try_again
            Material.foreground: colors.white_100
            Material.background: colors.primary_color

            font {
                weight: Font.Medium
                pixelSize: 14 * scaleFactor
            }

            onClicked: {
                if(resultState === 3) {
                    var item = stackView.get(1);
                    stackView.pop(item);
                } else {
                    makeCopy();
                }
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 79 * scaleFactor
        }
    }

    function makeCopy(){
        resultState = 1;
        transferManager.errorHandler = function(){
            resultState = 2;
        }

        transferManager.transfer(itemId, function(){
            resultState = 3;
        });
    }

    Component.onCompleted: {
        makeCopy();
    }
}
