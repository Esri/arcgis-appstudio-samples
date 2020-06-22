import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import "../controls" as Controls

ListView {
    id: mapunitsView

    signal mapunitSelected (int index)
    signal currentSelectionUpdated ()

    clip: true
    currentIndex: 0
    footer:Rectangle{
        height:100 * scaleFactor
        width:mapunitsView.width
        color:"transparent"
    }

    header: Pane {

        z: app.baseUnit
        padding: 0
        height: 0.7 * app.headerHeight
        anchors {
            left: parent ? parent.left : undefined
            right: parent ? parent.right : undefined
        }

        RowLayout {
            anchors.fill: parent
            width: parent.width
            height: app.units(2)
            anchors {
                leftMargin: 15 * app.units(1)
                rightMargin: 15 * app.units(1)
            }
            Controls.BaseText {
                id: headerText

                visible: text > ""
                text: qsTr("Show Map Units")
                verticalAlignment: Text.AlignVCenter
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width - mapUnitsSwitch.width
                elide: Text.ElideMiddle
                wrapMode: Text.NoWrap
            }

            Switch {
                id: mapUnitsSwitch

                checked: true
                Layout.preferredHeight: 0.8 * app.iconSize
                Layout.preferredWidth: 0.8 * app.iconSize
                Layout.alignment: Qt.AlignVCenter
                Material.primary: app.primaryColor
                Material.accent: app.accentColor

                onCheckedChanged: {
                    app.showMapUnits = checked
                }
            }
        }

        Rectangle {
            color: app.separatorColor
            anchors {
                bottom: parent.bottom
            }
            width: parent.width
            height: app.units(1)
        }
    }

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
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width

                    Controls.SubtitleText {
                        id: lbl

                        objectName: "label"
                        visible: text.length > 0
                        text: name
                        Layout.topMargin: app.baseUnit
                        Layout.leftMargin: 0//app.baseUnit
                        Layout.rightMargin: app.defaultMargin
                        Layout.preferredWidth: container.width - radioButton.width - Layout.rightMargin
                        Layout.preferredHeight: 0.40 * container.height
                        elide: Text.ElideMiddle
                        wrapMode: Text.NoWrap
                    }

                    Controls.BaseText {
                        id: val

                        objectName: "value"
                        visible: text.length > 0
                        text: value
                        Layout.bottomMargin: app.baseUnit
                        Layout.leftMargin: 0//app.baseUnit
                        Layout.rightMargin: app.defaultMargin
                        Layout.preferredWidth: container.width - radioButton.width - Layout.rightMargin
                        Layout.preferredHeight: 0.40 * container.height
                        elide: Text.ElideMiddle
                        wrapMode: Text.NoWrap
                    }
                }
            }
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    mapunitsView.currentIndex = index
                    mapunitsView.mapunitSelected(index)
                    mapunitsView.updateCurrentSelection(index)
                }
            }

        }


    }

    function updateCurrentSelection (index) {
        for (var i=0; i<mapunitsView.model.count; i++) {
            if (i === index) {
                mapunitsView.model.setProperty(i, "isChecked", true)
            } else {
                mapunitsView.model.setProperty(i, "isChecked", false)
            }
        }
        currentSelectionUpdated()
    }
}
