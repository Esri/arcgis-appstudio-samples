
import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    id: descPage
    width: parent.width
    height: parent.height

    Rectangle{
        anchors.fill:parent
        ColumnLayout{

            anchors.fill:parent
            spacing: 0
            clip:true

            //Add DescriptionPage header
            Rectangle{
                id:descPageheader
                color:"#8f499c"
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 50 * scaleFactor

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mouse.accepted = false
                    }
                }
                // Add clear icon
                ImageButton {
                    source: "assets/clear.png"
                    height: 30 * scaleFactor
                    width: 30 * scaleFactor
                    checkedColor : "transparent"
                    pressedColor : "transparent"
                    hoverColor : "transparent"
                    glowColor : "transparent"
                    anchors {
                        right: parent.right
                        rightMargin: 10 * scaleFactor
                        verticalCenter: parent.verticalCenter
                    }
                    onClicked: {
                        descPage.visible = 0
                    }
                }

                Text {
                    id: aboutApp
                    text:"About the Sample"
                    color:"white"
                    font.pointSize: 14
                    font.bold:true
                    anchors.centerIn: parent
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
            }

            Rectangle{
                color:"black"
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignBottom

                Flickable {
                    anchors.fill:parent
                    contentHeight: descText.height
                    clip:true

                    Text{
                        id: descText
                        y: 30 * scaleFactor
                        text:app.info.description
                        anchors.horizontalCenterOffset: 0
                        color:"white"
                        width: 0.85 * parent.width
                        horizontalAlignment: Text.AlignLeft
                        linkColor: "#e5e6e7"
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 15 * scaleFactor
                        onLinkActivated: Qt.openUrlExternally(link)
                    }
                }
            }
        }
    }
}





