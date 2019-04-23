import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import QtGraphicalEffects 1.0

import "../../Widgets" as Widgets

Drawer {
    id: root

    edge: appManager.isRTL ? Qt.LeftEdge : Qt.RightEdge

    interactive: this.visible

    background: Rectangle {
        anchors.fill: parent
        color: colors.view_background
    }

    property alias gridView: gridView

    signal clicked(var viewpoint)

    onOpened: {
        this.forceActiveFocus();
    }

    onClosed: {
        app.forceActiveFocus();
    }

    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 56 * constants.scaleFactor

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 56 * constants.scaleFactor
                        Layout.fillHeight: true

                        Widgets.IconImage {
                            width: 24 * constants.scaleFactor
                            height: this.width
                            anchors.centerIn: parent
                            source: images.book_marks_icon
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        text: strings.bookmarks
                        clip: true
                        elide: Text.ElideRight

                        font.family: fonts.avenirNextDemi
                        font.pixelSize: 16 * constants.scaleFactor
                        color: colors.white

                        horizontalAlignment: Label.AlignLeft
                        verticalAlignment: Label.AlignVCenter
                    }

                    Item {
                        Layout.preferredWidth: 16 * constants.scaleFactor
                        Layout.fillHeight: true
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item {
                        Layout.preferredWidth: 4 * constants.scaleFactor
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        GridView {
                            id: gridView

                            anchors.fill: parent

                            model: ListModel {}

                            cellWidth: delegateWidth
                            cellHeight: delegateHeight

                            flow: GridView.FlowLeftToRight
                            boundsBehavior: Flickable.StopAtBounds
                            clip: true

                            visible: this.model.count > 0

                            property int columnNumber: appManager.isCompactCanvas ? 1 : (appManager.isRegularCanvas ? 2 : 3)

                            property real delegateWidth: this.width / columnNumber
                            property real delegateHeight: delegateWidth / 3

                            header: Item {
                                width: parent.width
                                height: 4 * constants.scaleFactor
                            }

                            footer: Item {
                                width: parent.width
                                height: 4 * constants.scaleFactor
                            }

                            delegate: Item {
                                id: delegate

                                width: gridView.cellWidth
                                height: gridView.cellHeight

                                Widgets.TouchGestureArea {
                                    anchors.fill: parent
                                    anchors.margins: 4 * constants.scaleFactor

                                    color: colors.black

                                    onClicked: {
                                        root.clicked(itemViewpoint);
                                    }

                                    ColumnLayout {
                                        anchors.fill: parent
                                        spacing: 0

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 8 * constants.scaleFactor
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            clip: true

                                            RowLayout {
                                                anchors.fill: parent
                                                spacing: 0

                                                Item {
                                                    Layout.preferredWidth: 8 * constants.scaleFactor
                                                    Layout.fillHeight: true
                                                }

                                                Item {
                                                    Layout.preferredWidth: this.height / 62 * 114
                                                    Layout.fillHeight: true

                                                    Image {
                                                        anchors.fill: parent

                                                        source: itemThumbnail.url

                                                        fillMode: Image.PreserveAspectFit
                                                    }
                                                }

                                                Label {
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true

                                                    text: itemTitle.text
                                                    wrapMode: Label.Wrap
                                                    maximumLineCount: 2
                                                    clip: true
                                                    elide: Text.ElideRight

                                                    font.family: fonts.avenirNextDemi
                                                    font.pixelSize: 12 * constants.scaleFactor
                                                    color: colors.white

                                                    horizontalAlignment: Label.AlignHCenter
                                                    verticalAlignment: Label.AlignVCenter

                                                    leftPadding: 8 * constants.scaleFactor
                                                    rightPadding: this.leftPadding
                                                }

                                                Item {
                                                    Layout.preferredWidth: 8 * constants.scaleFactor
                                                    Layout.fillHeight: true
                                                }
                                            }
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 8 * constants.scaleFactor
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 4 * constants.scaleFactor
                        Layout.fillHeight: true
                    }
                }

                Label {
                    anchors.fill: parent

                    text: strings.empty_state_no_bookmarks
                    clip: true
                    elide: Text.ElideRight

                    font.family: fonts.avenirNextDemi
                    font.pixelSize: 16 * constants.scaleFactor
                    color: colors.white

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                    leftPadding: 16 * constants.scaleFactor
                    rightPadding: 16 * constants.scaleFactor

                    visible: gridView.model.count === 0
                }
            }
        }
    }
}
