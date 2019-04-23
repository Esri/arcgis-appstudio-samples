import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import QtGraphicalEffects 1.0

Popup {
    id: root

    width: app.width
    height: app.height

    x: 0
    y: 0

    visible: false

    closePolicy: Popup.NoAutoClose

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
    }

    property string title: ""
    property string description: ""
    property string acceptText: ""
    property string rejectText: ""

    property color acceptTextColor: colors.white
    property color rejectTextColor: colors.white

    property var accept: function() {}
    property var reject: function() {}

    background: Rectangle {
        anchors.fill: parent
        color: colors.black
        opacity: 0.54
    }

    contentItem: Item {
        anchors.fill: parent

        Pane {
            width: 280 * constants.scaleFactor
            height: columnLayout.height
            anchors.centerIn: parent
            Material.elevation: 24
            padding: 0

            background: Rectangle {
                anchors.fill: parent
                radius: 2 * constants.scaleFactor
                color: colors.white
            }

            ColumnLayout {
                id: columnLayout

                width: parent.width
                spacing: 0

                Label {
                    Layout.fillWidth: true

                    background: Rectangle {
                        anchors.fill: parent
                        color: colors.transparent
                    }

                    text: title
                    font.pixelSize: 20 * constants.scaleFactor
                    font.family: fonts.avenirNextDemi
                    color: colors.black
                    wrapMode: Text.Wrap
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 28 * constants.scaleFactor

                    topPadding: 21 * constants.scaleFactor
                    leftPadding: 24 * constants.scaleFactor
                    rightPadding: this.leftPadding
                    horizontalAlignment: appManager.isRTL ? Label.AlignRight : Label.AlignLeft

                    visible: title > "" ? true : false
                }

                Label {
                    Layout.fillWidth: true

                    background: Rectangle {
                        anchors.fill: parent
                        color: colors.transparent
                    }

                    text: description
                    font.pixelSize: 16 * constants.scaleFactor
                    font.family: fonts.avenirNextDemi
                    color: colors.black
                    opacity: 0.54
                    wrapMode: Text.Wrap
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 24 * constants.scaleFactor

                    topPadding: title > "" ? 12 * constants.scaleFactor : 21 * constants.scaleFactor
                    bottomPadding: 16 * constants.scaleFactor
                    leftPadding: 24 * constants.scaleFactor
                    rightPadding: this.leftPadding
                    horizontalAlignment: appManager.isRTL ? Label.AlignRight : Label.AlignLeft
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52 * constants.scaleFactor

                    RowLayout {
                        anchors.fill: parent
                        layoutDirection: appManager.isRTL ? Qt.LeftToRight : Qt.RightToLeft
                        spacing: 0

                        Item {
                            Layout.preferredWidth: rejectText > "" ? 8 * constants.scaleFactor : 16 * constants.scaleFactor
                            Layout.fillHeight: true
                        }

                        Button {
                            id: acceptButton

                            Layout.preferredWidth: Math.min(this.implicitWidth, parent.width / 2)
                            Layout.alignment: Qt.AlignVCenter

                            Material.foreground: acceptTextColor
                            Material.background: colors.black

                            text: acceptText
                            font.pixelSize: 14 * constants.scaleFactor
                            font.family: fonts.avenirNextDemi
                            flat: true

                            onClicked: {
                                acceptButton.enabled = false;

                                accept();
                            }
                        }

                        Item {
                            Layout.preferredWidth: 8 * constants.scaleFactor
                            Layout.fillHeight: true
                            visible: rejectText > ""
                        }

                        Button {
                            id: rejectButton

                            Layout.preferredWidth: Math.min(this.implicitWidth, parent.width / 2)
                            Layout.alignment: Qt.AlignVCenter

                            Material.foreground: rejectTextColor
                            Material.background: colors.black

                            text: rejectText
                            font.pixelSize: 14 * constants.scaleFactor
                            font.family: fonts.avenirNextDemi
                            flat: true

                            visible: rejectText > ""

                            onClicked: {
                                rejectButton.enabled = false;

                                reject();
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }

    function reset() {
        title = "";
        description = "";
        acceptText = "";
        rejectText = "";
        acceptTextColor = colors.white;
        rejectTextColor = colors.white;

        accept = function() {};
        reject = function() {};

        acceptButton.enabled = true;
        rejectButton.enabled = true;
    }

    function display(title, description, acceptText, rejectText, acceptTextColor, rejectTextColor, acceptFunction, rejectFunction) {
        reset();

        root.title = title;
        root.description = description;
        root.acceptText = acceptText;
        root.rejectText = rejectText;
        root.acceptTextColor = acceptTextColor;
        root.rejectTextColor = rejectTextColor;
        root.accept = acceptFunction;
        root.reject = rejectFunction;

        root.open();
    }
}
