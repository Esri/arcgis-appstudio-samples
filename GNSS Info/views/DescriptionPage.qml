import QtQuick 2.9
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    id: descPage

    width: parent.width
    height: parent.height

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        clip: true

        Rectangle {
            id: descPageheader

            Layout.fillWidth: true
            Layout.preferredHeight: 50 * scaleFactor
            color: primaryColor

            Text {
                id: aboutApp

                anchors.centerIn: parent

                text: qsTr("About")
                font.pixelSize: app.baseFontSize * 1.1
                font.bold: true
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                color: "white"
            }

            ImageButton {
                source: "../assets/clear.png"

                height: 30 * scaleFactor
                width: 30 * scaleFactor
                anchors.right: parent.right
                anchors.rightMargin: 10 * scaleFactor
                anchors.verticalCenter: parent.verticalCenter

                checkedColor: "transparent"
                pressedColor: "transparent"
                hoverColor: "transparent"
                glowColor: "transparent"

                onClicked: descPage.visible = false
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "black"

            Flickable {
                anchors.fill: parent
                contentHeight: descText.height
                clip: true

                Text {
                    id: descText

                    y: 30 * scaleFactor
                    width: 0.85 * parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 0

                    text: app.info.description
                    font.pixelSize: app.baseFontSize
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    linkColor: "#e5e6e7"
                    color: "white"

                    onLinkActivated: Qt.openUrlExternally(link)
                }

                RowLayout {
                    id: appRow

                    anchors.top: descText.bottom
                    anchors.topMargin: 20 * scaleFactor
                    anchors.left: descText.left

                    Text {
                        id: appVersion

                        text: qsTr("App Version: ")
                        font.pixelSize: app.baseFontSize
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        color: "white"
                    }

                    Text {
                        id: appVersionNumber

                        text: app.info.version
                        font.pixelSize: app.baseFontSize
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        color: "white"
                    }
                }

                RowLayout {
                    anchors.top: appRow.bottom
                    anchors.topMargin: 10 * scaleFactor
                    anchors.left: appRow.left

                    Text {
                        id: frameworkVersion

                        text: qsTr("AppFramework Version: ")
                        font.pixelSize: app.baseFontSize
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        color: "white"
                    }

                    Text {
                        id: frameworkVersionNumber

                        text: AppFramework.version
                        font.pixelSize: app.baseFontSize
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        color: "white"
                    }
                }
            }
        }
    }
}
