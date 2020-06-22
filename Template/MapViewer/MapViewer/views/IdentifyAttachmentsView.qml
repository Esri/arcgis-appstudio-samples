import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import Esri.ArcGISRuntime 100.7

import "../controls" as Controls

ListView {
    id: identifyAttachmentsView

    property string layerName: ""
    property real delegateHeight: app.headerHeight
    property real headerHeight: count > 0 ? 0.8 * app.headerHeight : 0
    spacing: app.baseUnit

    clip: true
    footer:Rectangle{
        height:100 * scaleFactor
        width:identifyAttachmentsView.width
        color:"transparent"
    }

    //headerPositioning: ListView.OverlayHeader
    header: Pane {

        visible: count > 0 && headerText.text > ""
        height: headerHeight
        z: app.baseUnit
        padding: 0
        anchors {
            left: parent.left
            right: parent.right
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0
            anchors {
                leftMargin: app.defaultMargin
                rightMargin: app.defaultMargin
            }

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

                visible: text > ""
                text: typeof layerName !== "undefined" ? (layerName ? layerName : "") : ""
                verticalAlignment: Text.AlignVCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
                elide: Text.ElideRight
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

    delegate: Item{

        height: (lbl.text > "") ? delegateHeight : 0
        visible: (lbl.text > "")
        width: parent ? parent.width : 0
        clip: true

        RowLayout {
            spacing: 0

            anchors {
                fill: parent
            }

            Rectangle {
                clip: true
                color: "transparent" //app.backgroundColor
                Layout.preferredWidth: Math.min(parent.height, 0.6*app.iconSize)
                Layout.preferredHeight: parent.height
                Layout.leftMargin: app.defaultMargin

                Image {
                    id: img

                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: {
                        if (typeof contentType === "undefined") {
                            return ""
                        } else if (!contentType) {
                            return "../images/file.png"
                        } else if (contentType.split("/")[0] === "image") {
                            return "../images/image.png"
                        } else if (contentType.split("/")[0] === "text") {
                            return "../images/note.png"
                        } else if (contentType.endsWith(".sheet")) {
                            return "../images/excel.png"
                        } else if (contentType.endsWith(".pdf")) {
                            return "../images/excel.pdf"
                        }
                        return "../images/file.png"
                    }
                }

                ColorOverlay {
                    id: mask

                    anchors.fill: img
                    source: img
                    color: app.primaryColor
                }
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.rightMargin: app.defaultMargin
                Layout.leftMargin: app.defaultMargin
                Layout.preferredWidth: parent.width - img.width - 2 * app.defaultMargin

                Controls.SpaceFiller {}

                Controls.BaseText {
                    id: lbl

                    objectName: "label"
                    visible: (lbl.text > "")
                    text: typeof name !== "undefined" ? (name ? name : "") : ""
                    Layout.preferredHeight: contentHeight
                    Layout.preferredWidth: parent.width
                    verticalAlignment: sz.text > "" ? Text.AlignBottom : Text.AlignVCenter
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                }

                Controls.BaseText {
                    id: sz

                    property bool isDefined: (typeof size !== "undefined" && lbl.text > "")
                    visible: isDefined
                    text: isDefined ? "%1 KB".arg((size/1000).toFixed(1)) : ""
                    color: app.subTitleTextColor
                    Layout.preferredHeight: contentHeight
                    Layout.preferredWidth: parent.width
                    verticalAlignment: Text.AlignTop
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                }

                Controls.SpaceFiller {}
            }
        }

        Controls.Ink {
            anchors.fill: parent

            onClicked: {
                if (attachmentUrl > "") {
                    var aUrl = contentType.endsWith(".pdf") ? "http://drive.google.com/viewerng/viewer?embedded=true&url=%1".arg(attachmentUrl) : attachmentUrl
                    if (isBrowserFriendly(contentType)) {
                        app.openUrlInternallyWithWebView(aUrl)
                    } else {
                        app.openUrlInternallyWithWebView(aUrl)
                    }
                }
            }
        }
    }

    Controls.BaseText {
        id: message

        visible: (count <= 0 && text > "" && !busyIndicator.visible) || (identifyAttachmentsView.contentHeight <= headerHeight && !busyIndicator.visible)
        maximumLineCount: 5
        elide: Text.ElideRight
        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("There are no attachments.")
    }

    property alias busyIndicator: busyIndicator
    BusyIndicator {
        id: busyIndicator

        width: app.iconSize
        visible: mapView.identifyProperties.popupManagersCount && !count
        height: width
        anchors.centerIn: parent
        Material.primary: app.primaryColor
        Material.accent: app.accentColor

        onVisibleChanged: {
            if (visible && !timeOut.running) {
                timeOut.start()
            }
        }

        Timer {
            id: timeOut

            interval: 1000
            running: true
            repeat: false
            onTriggered: {
                busyIndicator.visible = false
            }
        }
    }

    function isBrowserFriendly (contentType) {
        var contentTypeSplit = contentType.split("/"),
                mimeType = contentTypeSplit[contentTypeSplit.length - 1],
                friendlyTypes = ["jpg", "jpeg", "pjpeg", "gif", "pdf", "html", "txt", "mp4", "mp3"]

        if (friendlyTypes.indexOf(mimeType) > -1) {
            return true
        }

        return false
    }
}
