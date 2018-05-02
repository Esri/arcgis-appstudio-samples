import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1


import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Page {
    id: descPage
    width: parent.width
    height: parent.height
    anchors.fill:parent

    header: ToolBar {
        height: 52 * scaleFactor
        width: parent.width
        Material.elevation: 6
        Material.background: primaryColor

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item{
                Layout.preferredWidth: 0.2 * app.scaleFactor
                Layout.fillHeight: true
            }

            ToolButton {
                Layout.preferredHeight: 42 * scaleFactor
                Layout.preferredWidth: 42 * scaleFactor

                indicator: Image {
                    id: image
                    anchors.fill: parent
                    anchors.centerIn: parent
                    source: "../image/left.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true

                }

                onClicked: {
                    descPage.visible = 0
                }
            }

            Text {
                id: aboutApp
                text:qsTr("About")
                color:"white"
                font.pixelSize: app.baseFontSize * 1.1
                font.bold: true
                anchors.centerIn: parent
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }
    }

    ColumnLayout{
        anchors.fill:parent
        spacing: 0
        clip:true

        Rectangle{
            color:"white"
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Flickable {
                anchors.fill:parent
                contentHeight: descText.height
                clip:true
                
                Text{
                    id: descText
                    text: app.info.description
                    y: 30 * scaleFactor
                    textFormat: Text.StyledText
                    anchors.horizontalCenterOffset: 0
                    color:"black"
                    width: 0.85 * parent.width
                    horizontalAlignment: Text.AlignLeft
                    linkColor: "#e5e6e7"
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    anchors.horizontalCenter: parent.horizontalCenter
                    font {
                        pixelSize: app.baseFontSize
                    }
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
        }
    }
}






