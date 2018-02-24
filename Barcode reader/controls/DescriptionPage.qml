import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    id: descPage

    width: parent.width
    height: parent.height

    Rectangle {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent

            spacing: 0
            clip: true

            Rectangle {
                id: descPageheader

                Layout.preferredWidth: parent.width
                Layout.preferredHeight: units(50)

                color: "#8f499c"

                ImageButton {
                    anchors {
                        right: parent.right
                        rightMargin: units(10)
                        verticalCenter: parent.verticalCenter
                    }
                    width: units(30)
                    height: units(30)

                    source: "../assets/clear.png"

                    checkedColor : "transparent"
                    pressedColor : "transparent"
                    hoverColor : "transparent"
                    glowColor : "transparent"

                    onClicked: {
                        descPage.visible = 0
                    }
                }

                Text {
                    id: aboutApp

                    anchors.centerIn: parent

                    text: qsTr("About")
                    color: "white"
                    font.pixelSize: app.baseFontSize * 1.1
                    font.bold: true
                    maximumLineCount: 2
                    elide: Text.ElideRight
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

                        y: units(30)
                        anchors.horizontalCenterOffset: 0
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: app.info.description
                        color: "white"
                        width: 0.85 * parent.width
                        horizontalAlignment: Text.AlignLeft
                        linkColor: "#e5e6e7"
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        font {
                            pixelSize: app.baseFontSize
                        }

                        onLinkActivated: Qt.openUrlExternally(link)
                    }
                }
            }
        }
    }
}

