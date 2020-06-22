import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import "../controls" as Controls

ListView {
    id: offlineMapsView

    signal mapSelected (int index)
    signal currentSelectionUpdated ()

    clip: true

    delegate: Pane {
        id: container

        padding: 0
        height: app.units(48)
        width: parent.width

        contentItem: RowLayout {

            spacing: 0
            anchors {
                fill: parent
                leftMargin: 0
                rightMargin: 0.5 * app.defaultMargin
            }

            RadioButton {
                id: radioButton

                checkable: true
                checked: isChecked
                Material.primary: app.primaryColor
                Material.accent: app.accentColor
                Layout.preferredHeight: app.iconSize
                Layout.preferredWidth: app.iconSize
            }

            ColumnLayout {

                spacing: 0
                Layout.preferredHeight: app.iconSize
                Layout.preferredWidth: parent.width

                Controls.SubtitleText {
                    id: lbl

                    objectName: "label"
                    visible: text.length > 0
                    text: name
                    color: radioButton.checked ? app.baseTextColor : app.subTitleTextColor
                    Layout.topMargin: app.baseUnit
                    Layout.leftMargin: 0//app.baseUnit
                    Layout.rightMargin: app.defaultMargin
                    Layout.preferredWidth: container.width - radioButton.width - Layout.rightMargin
                    Layout.fillHeight: true
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                updateCurrentSelection(index)
                mapSelected(index)
            }
        }
    }

    Controls.BaseText {
        id: message

        visible: model.count <= 0 && text > ""
        maximumLineCount: 5
        elide: Text.ElideRight
        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("There are no offline maps.")
    }

    function updateCurrentSelection (index) {
        for (var i=0; i<offlineMapsView.model.count; i++) {
            if (i === index) {
                offlineMapsView.model.setProperty(i, "isChecked", true)
            } else {
                offlineMapsView.model.setProperty(i, "isChecked", false)
            }
        }
        currentSelectionUpdated()
    }
}
