import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.InterAppCommunication 1.0

import "../controls" as Controls

Popup {
    id: screenShotsView

    property real headerOpacity: 0.8
    property int backgroundMargin: 0
    property alias screenShots: screenShots
    property alias listView: listView
    property string urlPrefix: "screenShot"
    property string urlFormat: urlPrefix + "%1.jpg"
    property color backgroundColor: "#000000"

    property QtObject mapView

    signal screenShotTaken ()
    signal screenShotDiscarded ()
    signal shareButtonClicked ()

    x: backgroundMargin
    y: backgroundMargin
    modal: true
    width: app.width - 2*backgroundMargin
    height: app.height - 2*backgroundMargin
    background: Rectangle {
        color: backgroundColor
    }

    contentItem: Controls.BasePage {

        padding: 0
        anchors.fill: parent
        header: ToolBar {
            id: pageHeader

            height: app.headerHeight
            width: app.width
            padding: 0
            Material.primary: app.primaryColor
            //opacity: headerOpacity

            RowLayout {
                anchors.fill: parent

                Controls.Icon {
                    imageSource: "../images/close.png"
                    Layout.leftMargin: app.widthOffset
                    onClicked: screenShotsView.close()
                }

                Controls.SpaceFiller {
                }

                Controls.Icon {
                    id: leftIcon
                    visible: screenShots.count > 1
                    imageSource: "../images/arrowDown.png"
                    Layout.alignment: Qt.AlignHCenter
                    rotation: 90
                    enabled: listView.currentIndex > 0
                    opacity: enabled ? 1 : 0.3
                    onClicked: {
                        if (enabled) listView.currentIndex -= 1
                    }
                }

                Controls.SubtitleText {
                    id: counterText
                    visible: screenShots.count > 1
                    Layout.alignment: Qt.AlignHCenter
                    color: "#FFFFFF"
                    text: qsTr("%L1 of %L2").arg(listView.currentIndex + 1).arg(screenShots.count)
                }

                Controls.Icon {
                    id: rightIcon
                    visible: screenShots.count > 1
                    Layout.alignment: Qt.AlignHCenter
                    imageSource: "../images/arrowDown.png"
                    rotation: -90
                    enabled: listView.currentIndex < screenShots.count - 1
                    opacity: enabled ? 1 : 0.3
                    onClicked: {
                        if (enabled) listView.currentIndex += 1
                    }
                }

                Controls.SpaceFiller {
                }

                Controls.Icon {
                    enabled: !screenShotToast.visible
                    opacity: enabled ? 1 : 0.3
                    Layout.alignment: Qt.AlignRight
                    imageSource: "../images/delete.png"

                    onClicked: {
                        var discard = discardDialog.createObject(app)
                        discard.connectToAccepted(function () {
                            var folders = screenShots.get(listView.currentIndex).url.split("/")
                            var file = folders[folders.length-1]
                            offlineCache.fileFolder.removeFile(file)
                            updateScreenShotsModel()
                        })
                        discard.connectToAccepted(function () {
                            screenShotDiscarded()
                        })
                        discard.show("", qsTr("Discard screenshot?"))
                    }
                }

                Controls.Icon {
                    Layout.alignment: Qt.AlignRight
                    imageSource: "../images/share.png"
                    Layout.rightMargin: app.widthOffset
                    onClicked: {
                        shareButtonClicked()
                    }
                }
            }
        }

        contentItem: ListView {
            id: listView

            anchors {
                top: pageHeader.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            orientation: Qt.Horizontal
            snapMode: ListView.SnapOneItem
            headerPositioning: ListView.OverlayHeader
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 200

            model: ListModel {
                id: screenShots
            }

            delegate: Rectangle {
                id: itemOuterBox

                width: listView.width
                height: listView.height

                Rectangle {
                    id: photoFrame

                    property bool supportsRotation: true

                    Behavior on scale { NumberAnimation { duration: 200 } }
                    Behavior on rotation { NumberAnimation { duration: 200 } }
                    Behavior on x { NumberAnimation { duration: 200 } }
                    Behavior on y { NumberAnimation { duration: 200 } }

                    width: parent.width
                    height: parent.height
                    color: "transparent"
                    scale: 1
                    smooth: true
                    antialiasing: true

                    Image {
                        id: itemImage
                        fillMode: Image.PreserveAspectFit
                        anchors {
                            fill: parent
                        }
                        source: url

                        PinchArea {
                            id: pinchArea

                            property real minScale: 1
                            property real maxScale: 4
                            property bool enableRotation: false

                            anchors.fill: parent
                            enabled: true
                            pinch.target: photoFrame
                            pinch.minimumRotation: enableRotation ? -360 : 0
                            pinch.maximumRotation: enableRotation ? 360 : 0
                            pinch.minimumScale: minScale
                            pinch.maximumScale: maxScale
                            pinch.dragAxis: Pinch.XAndYAxis
                            pinch.minimumX: -Math.abs(itemImage.width - photoFrame.scale * itemImage.width)/2
                            pinch.maximumX: +Math.abs(itemImage.width - photoFrame.scale * itemImage.width)/2
                            pinch.minimumY: -Math.abs(itemImage.height - photoFrame.scale * itemImage.height)/2
                            pinch.maximumY: +Math.abs(itemImage.height - photoFrame.scale * itemImage.height)/2

                            onSmartZoom: {
                                if (pinch.scale > 0) {
                                    photoFrame.rotation = 0;
                                    photoFrame.scale = Math.min(itemOuterBox.width, itemOuterBox.height) / Math.max(itemImage.sourceSize.width, itemImage.sourceSize.height) * 0.85
                                    photoFrame.x = itemOuterBox.x + (itemOuterBox.width - photoFrame.width) / 2
                                    photoFrame.y = itemOuterBox.y + (itemOuterBox.height - photoFrame.height) / 2
                                } else {
                                    photoFrame.rotation = pinch.previousAngle
                                    photoFrame.scale = pinch.previousScale
                                    photoFrame.x = pinch.previousCenter.x - photoFrame.width / 2
                                    photoFrame.y = pinch.previousCenter.y - photoFrame.height / 2
                                }
                            }

                            onPinchFinished: {
                                if(scale<minScale) photoFrame.scale=minScale;
                                photoFrame.rotation = Math.round(photoFrame.rotation/90)*90
                            }

                            Controls.SwipeArea {
                                id: swipeArea

                                enableDrag: (photoFrame.scale > pinchArea.minScale) || (photoFrame.x !== 0) || (photoFrame.y !== 0)

                                anchors.fill: parent
                                drag.target: photoFrame
                                drag.axis:  !enableDrag ? Drag.None : Drag.XAndYAxis
                                drag.minimumX: -Math.abs(itemImage.width - photoFrame.scale * itemImage.width)/2
                                drag.maximumX: +Math.abs(itemImage.width - photoFrame.scale * itemImage.width)/2
                                drag.minimumY: -Math.abs(itemImage.height - photoFrame.scale * itemImage.height)/2
                                drag.maximumY: +Math.abs(itemImage.height - photoFrame.scale * itemImage.height)/2
                                scrollGestureEnabled: false

                                onWheel: {
                                    if (wheel.modifiers & Qt.ControlModifier) {
                                        photoFrame.rotation += wheel.angleDelta.y / 120 * 5
                                        if (Math.abs(photoFrame.rotation) < 4)
                                            photoFrame.rotation = 0
                                    } else {
                                        photoFrame.rotation += wheel.angleDelta.x / 120;
                                        if (Math.abs(photoFrame.rotation) < 0.6)
                                            photoFrame.rotation = 0
                                        var scaleBefore = photoFrame.scale;
                                        var currentScale = photoFrame.scale + photoFrame.scale * wheel.angleDelta.y / 120 / 10
                                        if (currentScale > pinchArea.maxScale) {
                                            photoFrame.scale = pinchArea.maxScale
                                        } else if (currentScale < pinchArea.minScale) {
                                            photoFrame.scale = pinchArea.minScale
                                        } else {
                                            photoFrame.scale = currentScale
                                        }

                                    }
                                }

                                onDoubleClicked: {
                                    var midScale = (pinchArea.maxScale - pinchArea.minScale)/2
                                    if (photoFrame.scale < midScale) {
                                        photoFrame.scale = Math.min(photoFrame.scale + midScale/2, pinchArea.maxScale)
                                    } else {
                                        photoFrame.scale = pinchArea.minScale
                                    }
                                    photoFrame.x = 0
                                    photoFrame.y = 0
                                }

                                onReleased: {
                                    if(scale<pinchArea.minScale) photoFrame.scale=pinchArea.minScale;
                                    photoFrame.rotation = Math.round(photoFrame.rotation/90)*90
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: discardDialog

                Controls.MessageDialog {

                    standardButtons: DialogButtonBox.NoRole
                    Component.onCompleted: {
                        addButton(qsTr("CANCEL"), DialogButtonBox.RejectRole, app.accentColor)
                        addButton(qsTr("DISCARD"), DialogButtonBox.AcceptRole, app.accentColor)
                    }

                    onCloseCompleted: {
                        destroy()
                    }
                }
            }

            Rectangle {
                id: listViewFooter

                visible: false
                height: app.headerHeight
                width: app.width
                anchors.bottom: parent.bottom
                color: app.darkIconMask
                opacity: headerOpacity

                RowLayout {
                    anchors.fill: parent
                }
            }
        }

    }

    onScreenShotDiscarded: {
        if (!screenShots.count) {
            measureToast.show(qsTr("Screenshot discarded."), parent.height-measureToast.height-measurePanel.height, 1500)
        } else {
            screenShotToast.show(qsTr("Screenshot discarded."), null, 1500)
        }
    }

    Controls.ToastDialog {
        id: screenShotToast
        z: parent.z + 1
    }

    Connections {
        target: mapView

        onExportImageUrlChanged: {
            if (mapView.exportImageUrl) {
                updateScreenShotsModel(true)
            }
        }
    }

    BusyIndicator {
        id: busyIndicator

        visible: false
        anchors.centerIn: parent
        Material.accent: app.accentColor
        Material.primary: app.primaryColor
    }

    Timer {
        id: emailComposerLoading

        interval: 3000
        repeat: false
        onTriggered: {
            busyIndicator.visible = false
        }
    }

    EmailComposer {
        id: emailcomposer
        subject: qsTr("%1 screenshot").arg(app.info.title || "Map Viewer")
        body: ""
        html: true

        onComposeError: {
            switch (reason) {
            case EmailComposer.InValidAttachment:
                app.messageDialog.show("", qsTr("Invalid attachment."))
                break
            case EmailComposer.AttachmentFileNotFound:
                app.messageDialog.show("", qsTr("Cannot find attachment."))
                break
            case EmailComposer.MailClientOpenFailed:
                app.messageDialog.show("", qsTr("Cannot open mail client."))
                break
            case EmailComposer.MailServiceNotConfigured:
                app.messageDialog.show("", qsTr("Mail service not configured."))
                break
            case EmailComposer.PlatformNotSupported:
                app.messageDialog.show("", qsTr("Platform not supported."))
                break
            case EmailComposer.SendFailed:
                app.messageDialog.show("", qsTr("Failed to send email."))
                break
            case EmailComposer.SaveFailed:
                app.messageDialog.show("", qsTr("Failed to save email."))
                break;
            case EmailComposer.Cancelled:
                break
            default:
                app.messageDialog.show("", qsTr("Unknown error."))
            }
        }
    }

    Component.onCompleted: {
        updateScreenShotsModel()
    }

    onShareButtonClicked: {
        busyIndicator.visible = true
        emailComposerLoading.start()
        emailcomposer.attachments = AppFramework.urlInfo(screenShots.get(listView.currentIndex).url).localFile
        emailcomposer.show()
    }

    function updateScreenShotsModel (updateCurrentIndex) {
        var allScreenShots = offlineCache.fileFolder.fileNames("%1*.jpg".arg(urlPrefix), false).toString().split(",")
        screenShots.clear()
        for (var i=0; i<allScreenShots.length; i++) {
            if (allScreenShots[i]) {
                screenShots.append({"url": [offlineCache.fileFolder.url, allScreenShots[i]].join("/")})
            }
        }
        if (updateCurrentIndex && screenShots.count) {
            listView.currentIndex = screenShots.count - 1
        }

        if (!screenShots.count) {
            screenShotsView.close()
        }
    }

    function takeScreenShot () {
        var date = (new Date().getTime()).toString()
        var fileUrl = [offlineCache.fileFolder.url, urlFormat.arg(date)].join("/")
        mapView.exportImage(fileUrl)
        screenShotTaken()
    }
}
