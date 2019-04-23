import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "../../Widgets" as Widgets

Widgets.TouchGestureArea {
    id: root

    property url defaultThumbnail: ""

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16 * constants.scaleFactor
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Item {
                    Layout.preferredWidth: 16 * constants.scaleFactor
                    Layout.fillHeight: true
                }

                Item {
                    Layout.preferredWidth: 108 * constants.scaleFactor
                    Layout.fillHeight: true

                    Widgets.IconImage {
                        id: thumbnail

                        anchors.fill: parent
                        source: itemThumbnail

                        visible: itemThumbnail > ""
                    }

                    Widgets.IconImage {
                        anchors.fill: parent
                        source: defaultThumbnail

                        visible: thumbnail.status === Image.Error || itemThumbnail === ""
                    }
                }

                Item {
                    Layout.preferredWidth: 16 * constants.scaleFactor
                    Layout.fillHeight: true
                }

                Label {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: itemTitle
                    elide: Label.ElideRight
                    wrapMode: Label.Wrap
                    maximumLineCount: 2
                    clip: true

                    font.family: fonts.avenirNextDemi
                    font.pixelSize: 14 * constants.scaleFactor
                    color: colors.white

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                }

                Item {
                    Layout.preferredWidth: 56 * constants.scaleFactor
                    Layout.fillHeight: true

                    Widgets.IconImage {
                        width: 24 * constants.scaleFactor
                        height: this.width
                        source: images.right_arrow_icon
                        anchors.centerIn: parent
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16 * constants.scaleFactor
        }
    }
}
