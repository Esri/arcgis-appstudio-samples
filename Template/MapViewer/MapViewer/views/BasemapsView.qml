import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import "../controls" as Controls

GridView {
    id: basemapsView
    footer:Rectangle{
        height:100 * scaleFactor
        width:basemapsView.width
        color:"transparent"
    }

    signal basemapSelected (int index)

    property real columns: app.isLarge ? 2 : 3

    cellWidth: width/columns
    cellHeight: cellWidth
    flow: GridView.FlowLeftToRight
    clip: true

    delegate: Pane {

        height: GridView.view.cellWidth
        width: GridView.view.cellHeight
        topPadding: app.defaultMargin
        bottomPadding: 0
        leftPadding: 0 //app.baseUnit
        rightPadding: 0 //app.baseUnit
        //Controls.Debug{}

        contentItem: Item{
            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Image {
                    id: thumbnailImg

                    source: thumbnailUrl
                    Layout.preferredHeight: 0.60 * parent.height
                    Layout.preferredWidth: parent.width
                    Layout.bottomMargin: 0
                    fillMode: Image.PreserveAspectFit
                    BusyIndicator {
                        anchors.centerIn: parent
                        running: thumbnailImg.status === Image.Loading
                    }

                }

                Controls.BaseText {
                    text: title
                    maximumLineCount: 2
                    font.pointSize: app.textFontSize
                    color: app.subTitleTextColor
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: contentHeight
                    Layout.preferredWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }


            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    basemapSelected(index)
                }
            }
        }
    }
}
