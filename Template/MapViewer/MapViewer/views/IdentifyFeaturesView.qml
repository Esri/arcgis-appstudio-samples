import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import Esri.ArcGISRuntime 100.7

import "../controls" as Controls

ListView {
    id: identifyFeaturesView

    property string layerName: ""
    property real minDelegateHeight: 2 * app.units(56)
    property real headerHeight: count > 0 ? 0.8 * app.headerHeight : 0

    clip: true
    spacing: 0
    //headerPositioning: ListView.OverlayHeader
    //cacheBuffer: count * (delegateHeight + spacing)

    header: Item {
        width: parent.width
        height: headerColumn.height
        visible: count > 0 && headerText.text > ""

        ColumnLayout {
            id: headerColumn

            width: parent.width
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: headerHeight
                Layout.leftMargin: app.defaultMargin
                Layout.rightMargin: app.defaultMargin

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        id: layerIcon
                        Layout.preferredHeight: Math.min(parent.height - app.defaultMargin, app.iconSize)
                        Layout.preferredWidth: Layout.preferredHeight

                        Image {
                            id: lyr
                            source: "../images/layers.png"
                            anchors.fill: parent
                        }

                        ColorOverlay {
                            id: layerMask
                            anchors {
                                fill: lyr
                            }
                            source: lyr
                            color: "#6E6E6E"
                        }
                    }

                    Item {
                        Layout.preferredWidth: app.defaultMargin
                        Layout.fillHeight: true
                    }

                    Controls.SubtitleText {
                        id: headerText

                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        visible: text > ""
                        text: typeof layerName !== "undefined" ? (layerName ? layerName : "") : ""
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: app.units(1)
                color: app.separatorColor
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: app.units(8)
            }
        }
    }

    footer:Rectangle{
        height:100 * scaleFactor
        width:identifyFeaturesView.width
        color:"transparent"
    }
    delegate: Pane {
        id: delegateContent

        visible: (lbl.text > "" && desc.text > "")
        width: parent ? parent.width : 0
        height: this.visible ? contentItem.height : 0
        padding: 0
        spacing: 0
        clip: true

        contentItem: Item {
            width: parent.width
            height: contentColumn.height

            ColumnLayout {
                id: contentColumn

                width: parent.width
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.units(6)
                }

                Controls.SubtitleText {
                    id: lbl

                    objectName: "label"
                    visible: (lbl.text > "" && desc.text > "")
                    text: typeof label !== "undefined" ? (label ? label : "") : ""
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight
                    Layout.leftMargin: app.defaultMargin
                    Layout.rightMargin: app.defaultMargin
                    elide: Text.ElideMiddle
                    wrapMode: Text.WrapAnywhere
                }

                Controls.BaseText {
                    id: desc

                    objectName: "description"
                    visible: (lbl.text > "" && desc.text > "")

                    Layout.fillWidth: true
                    Layout.preferredHeight: this.implicitHeight
                    Layout.leftMargin: app.defaultMargin
                    Layout.rightMargin: app.defaultMargin

                    wrapMode: Text.WordWrap
                    textFormat: Text.StyledText
                    Material.accent: app.accentColor
                    onLinkActivated: {
                        app.openUrlInternally(link)
                    }

                    Component.onCompleted: {
                        text = (typeof formattedValue !== "undefined" ? (formattedValue ? formattedValue : "") : (typeof fieldValue !== "undefined" ? (fieldValue ? fieldValue : "") : "")).replace(/(http:\/\/[^\s]+)/gi , '<a href="$1">$1</a>').replace(/(https:\/\/[^\s]+)/gi , '<a href="$1">$1</a>');

                        if (!fullView) {
                            maximumLineCount = 3;
                            elide = Text.ElideRight;
                        } else {
                            elide = Text.ElideLeft;
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.units(6)
                }
            }
        }
    }

    Controls.BaseText {
        id: message

        visible: (count <= 0 && text > "" && !busyIndicator.visible) || (identifyFeaturesView.contentHeight <= headerHeight && !busyIndicator.visible)
        maximumLineCount: 5
        elide: Text.ElideRight
        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("There are no features.")
    }

    BusyIndicator {
        id: busyIndicator

        width: app.iconSize
        visible: mapView.identifyProperties.featuresCount && !count
        height: width
        anchors.centerIn: parent
        Material.primary: app.primaryColor
        Material.accent: app.accentColor

        Timer {
            id: timeOut

            interval: 3000
            running: true
            repeat: false
            onTriggered: {
                busyIndicator.visible = false
            }
        }
    }
}
