import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import "../controls" as Controls

ListView {
    id: graticulesView

    signal gridSelected (int index)
    signal currentSelectionUpdated ()

    clip: true
    currentIndex: 0

    delegate: Pane {
        id: container

        padding: 0
        height: app.units(48)
        width: parent.width

        contentItem: Item{
            RowLayout {
                spacing: 0
                anchors {
                    fill: parent
                    leftMargin: 0 //0.5 * app.defaultMargin
                    rightMargin: 0.5 * app.defaultMargin
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: app.iconSize

                    RadioButton {
                        id: radioButton

                        anchors.centerIn: parent
                        checkable: true
                        checked: isChecked
                        Material.primary: app.primaryColor
                        Material.accent: app.accentColor
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Controls.SubtitleText {
                            id: lbl
                            objectName: "label"

                            Layout.preferredWidth: container.width - radioButton.width - Layout.rightMargin
                            Layout.fillHeight: true
                            Layout.rightMargin: app.defaultMargin

                            visible: text.length > 0

                            text: name
                            verticalAlignment: Text.AlignVCenter
                            color: radioButton.checked ? app.baseTextColor : app.subTitleTextColor
                            elide: Text.ElideMiddle
                            wrapMode: Text.NoWrap
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    graticulesView.currentIndex = index
                    graticulesView.gridSelected(index)
                    graticulesView.updateCurrentSelection(index)
                }
            }
        }





    }

    function updateCurrentSelection (index) {
        for (var i=0; i<graticules.model.count; i++) {
            if (i === index) {
                graticulesView.model.setProperty(i, "isChecked", true)
            } else {
                graticulesView.model.setProperty(i, "isChecked", false)
            }
        }
        currentSelectionUpdated()
    }
}
