import QtQuick 2.2
import QtQuick.Controls 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "Helper.js" as Helper

Rectangle {
    signal signInClicked()
    signal infoClicked()

    color: app.info.propertyValue("startBackgroundColor", "#e0e0df")

    Image {
        anchors.fill: parent
        source: app.folder.fileUrl(app.info.propertyValue("startBackground", "assets/startBackground.png"))
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.fill: parent
        color: app.info.propertyValue("startForegroundColor", "transparent")
    }

    Flickable {
        anchors.fill: parent

        flickableDirection: Flickable.HorizontalFlick

        rebound: Transition {
        }

        onFlickEnded: {
            signInClicked();
        }

        Item {
            anchors.fill: parent

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: signInButton.top
                }

                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    spacing: 10

                    Text {
                        id: titleText

                        width: parent.width
                        text: app.info.title
                        font {
                            pointSize: 45
                        }
                        color: "#4c4c4c"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        id: subtitleText

                        width: parent.width
                        text: app.info.snippet
                        font {
                            pointSize: 18
                        }
                        color: "#005e95"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }

            ImageButton {
                id: signInButton

                anchors {
                    centerIn: parent
                }

                width: 160 * AppFramework.displayScaleFactor
                height: 80 * AppFramework.displayScaleFactor
                source: AppFramework.network.isOnline
                        ? app.folder.fileUrl(app.info.propertyValue("startButton", "assets/startButton.png"))
                        : "images/networkOffline.png"
                hoverColor: app.hoverColor
                pressedColor: app.pressedColor
                enabled: AppFramework.network.isOnline

                onClicked: {
                    signInClicked();
                }
            }

            ImageButton {
                id: logoButton

                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    margins: 5
                }

                hoverColor: app.hoverColor
                pressedColor: app.pressedColor

                visible: app.info.propertyValue("startShowLogo", true);
                height: 80 * AppFramework.displayScaleFactor
                width: height

                source: app.folder.fileUrl(app.info.propertyValue("logoImage", "assets/logo-esri.png"))

                onClicked: {
                    Qt.openUrlExternally(app.info.propertyValue("companyUrl", "http://www.esri.com"));
                }
            }

            ImageButton {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: 10
                }

                hoverColor: app.hoverColor
                pressedColor: app.pressedColor

                height: 30 * AppFramework.displayScaleFactor
                width: height

                source: "images/info1.png"

                onClicked: {
                    infoClicked();
                }
            }
        }
    }
}
