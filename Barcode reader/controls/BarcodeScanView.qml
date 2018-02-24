import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Barcodes 1.0
import ArcGIS.AppFramework.Controls 1.0



Rectangle {
    property bool debugUI: true
    property real defaultZoom: 2.0
    property double currentTime: -1
    property double decodedTime: -1
    property string decodedBarcode: ""
    property int decodedBarcodeType: 0
    property string decodedBarcodeTypeString: ""
    property string deviceId: ""
    property int cameraIndex: -1

    implicitWidth: 100
    implicitHeight: 100

    color: "black"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        spacing: 10

        //--------------------------------------------------------------------------

        VideoOutput {
            id: videoOutput

            Layout.fillWidth: true
            Layout.fillHeight: true

            source: camera
            autoOrientation: true
            filters: [ barcodeFilter ]

            Rectangle {
                id: frameRect

                property int maxWidth: videoOutput.contentRect.width * 0.95
                property int maxHeight: videoOutput.contentRect.height * 0.95
                property double aspect: 1.0

                anchors.centerIn: parent

                width: Math.min(maxWidth, maxHeight * aspect)
                height: width / aspect

                color: "transparent"

                border.color: Material.color(Material.Green)
                border.width: units(8)
                radius: units(10)
                opacity: 0.8
            }

            PinchArea {
                property real pinchInitialZoom: 1.0
                property real pinchScale: 1.0

                anchors {
                    fill: parent
                }

                onPinchStarted: {
                    pinchInitialZoom = camera.zoom;
                    pinchScale = 1.0;
                }

                onPinchUpdated: {
                    pinchScale = pinch.scale;
                    camera.setZoom(pinchInitialZoom * pinchScale);
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            spacing: 10

            Image {
                id: cameraIcon
                Layout.preferredHeight: 35 * app.scaleFactor
                Layout.preferredWidth: Layout.preferredHeight
                mipmap: true

                source: "../assets/camera-switch.png"
                fillMode: Image.PreserveAspectFit
                visible: debugUI || (QtMultimedia.availableCameras.length > 1)

                MouseArea {
                    anchors.fill: parent
                    onClicked: switchCamera()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: cameraIcon.height
                visible: debugUI || (camera.maximumZoom > 1.0)
                color: "transparent"
                border.color: "grey"

                Slider {
                    anchors.fill: parent
                    from: 1.0
                    to: 4.0
                    value: camera.zoom
                    onValueChanged: {
                        camera.setZoom(value)
                        value = Qt.binding(function () { return camera.zoom; } );
                    }
                }
            }

            Text {
                visible: debugUI || (camera.maximumZoom > 1.0)
                text: qsTr("%1x").arg(camera.zoom)
                color: "#DEA7FD"
            }


            Image {
                Layout.preferredHeight: 40 * app.scaleFactor
                Layout.preferredWidth: Layout.preferredHeight
                id: barcodeIcon
                source: "../assets/barcode.png"
                mipmap: true
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    onClicked: barcodesPopup.open()
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Popup {
        id: barcodesPopup

        width: parent.width
        height: parent.height

        background: Rectangle {
            color: "black"
        }

        ColumnLayout {
            anchors.fill: parent

            spacing: units(10)
            clip: true

            RowLayout {
                Layout.fillWidth: true

                Image {
                    Layout.preferredHeight: 35 * app.scaleFactor
                    Layout.preferredWidth: Layout.preferredHeight
                    source: "../assets/back.png"
                    mipmap: true
                    fillMode: Image.PreserveAspectFit
                    MouseArea {
                        anchors.fill: parent
                        onClicked: barcodesPopup.close()
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            GridView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                model: barcodeModel
                cellWidth: units(64 + 10)
                height: units(80 + 10)

                delegate: Item {
                    property bool selected: (barcodeFilter.decodeHints & decodeHint) !== 0

                    width: units(64)
                    height: units(80)

                    Rectangle {
                        id: icon

                        anchors.horizontalCenter: parent.horizontalCenter
                        width: units(64)
                        height: units(64)

                        color: selected ? "white" : "grey"

                        Image {
                            source: "../assets/codes/%1.png".arg(codeName)
                        }
                    }

                    Text {
                        anchors.top: icon.bottom
                        width: parent.width

                        text: codeName
                        color: selected ? "yellow" : "grey"
                        horizontalAlignment: Qt.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (selected) {
                                barcodeFilter.decodeHints &= ~decodeHint;
                            } else {
                                barcodeFilter.decodeHints |= decodeHint;
                            }
                            saveSettings();
                            recomputeAspect();
                        }
                    }
                }
            }

        }
    }

    //--------------------------------------------------------------------------

    Popup {
        id: resultPopup

        width: parent.width
        height: parent.height

        background: Rectangle {
            color: "black"
        }

        ColumnLayout {
            anchors.fill: parent

            spacing: units(10)

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "X"

                    onClicked: resultPopup.close()
                }
            }

            TextField {
                Layout.fillWidth: true

                text: qsTr("Scanned %1").arg(getElapsedString(currentTime - decodedTime))
                readOnly: true
                selectByMouse: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: "grey"
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: units(10)

                ColumnLayout {
                    Layout.preferredWidth: units(64)
                    Layout.preferredHeight: units(80)

                    Rectangle {
                        Layout.preferredWidth: units(64)
                        Layout.preferredHeight: units(64)

                        color: "white"

                        Image {
                            width: units(64)
                            height: units(64)

                            source: "../assets/codes/%1.png".arg(decodedBarcodeTypeString)
                        }
                    }

                    Text {
                        Layout.preferredWidth: units(64)
                        text: decodedBarcodeTypeString
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: "yellow"
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }

                TextField {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    verticalAlignment: Text.AlignTop
                    text: decodedBarcode
                    selectByMouse: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    readOnly: true
                    color: "white"
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Audio {
        id: beepAudio

        source: "../assets/beep.mp3"
    }

    //--------------------------------------------------------------------------

    Camera {
        id: camera

        property real zoom: opticalZoom * digitalZoom
        property real maximumZoom: maximumOpticalZoom * maximumDigitalZoom

        cameraState: Camera.CaptureStillImage

        focus {
            focusMode: Camera.FocusContinuous
        }

        exposure {
            exposureCompensation: Camera.ExposureAuto
        }

        viewfinder.resolution: Qt.size(640, 480)

        Component.onCompleted: {
            setZoom(defaultZoom);
        }

        function setZoom(newZoom) {
            newZoom = Math.max(Math.min(newZoom, maximumZoom), 1.0);

            var newOpticalZoom = 1.0;
            var newDigitalZoom = 1.0;

            if (newZoom > camera.maximumOpticalZoom) {
                newOpticalZoom = camera.maximumOpticalZoom;
                newDigitalZoom = newZoom / camera.maximumOpticalZoom;
            } else {
                newOpticalZoom = newZoom;
                newDigitalZoom = 1.0;
            }

            if (camera.maximumOpticalZoom > 1.0) {
                camera.opticalZoom = newOpticalZoom;
            }

            if (camera.maximumDigitalZoom > 1.0) {
                camera.digitalZoom = newDigitalZoom;
            }
        }
    }

    //--------------------------------------------------------------------------

    BarcodeFilter {
        id: barcodeFilter

        decodeHints: BarcodeDecoder.DecodeHintUPC_A
                     | BarcodeDecoder.DecodeHintUPC_E
                     | BarcodeDecoder.DecodeHintEAN_8
                     | BarcodeDecoder.DecodeHintEAN_13
                     | BarcodeDecoder.DecodeHintUPC_EAN_EXTENSION
                     | BarcodeDecoder.DecodeHintCODE_39
                     | BarcodeDecoder.DecodeHintCODE_93
                     | BarcodeDecoder.DecodeHintQR_CODE
                     | BarcodeDecoder.DecodeHintCODE_128
                     | BarcodeDecoder.DecodeHintTryHarder

        orientation: videoOutput.orientation

        onDecoded: {
            currentTime = decodedTime = (new Date()).getTime();
            decodedBarcode = barcode;
            decodedBarcodeType = barcodeType;
            decodedBarcodeTypeString = barcodeTypeString;

            beepAudio.play()

            resultPopup.open()
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: currentTime = (new Date()).getTime()
    }

    //--------------------------------------------------------------------------

    ListModel {
        id: barcodeModel

        Component.onCompleted: {
            append( { codeName: "CODE_39", decodeHint: BarcodeDecoder.DecodeHintCODE_39, aspect: 1.333 } );
            append( { codeName: "CODE_93", decodeHint: BarcodeDecoder.DecodeHintCODE_93, aspect: 1.333 } );
            append( { codeName: "CODE_128", decodeHint: BarcodeDecoder.DecodeHintCODE_128, aspect: 1.333 } );
            append( { codeName: "EAN_8", decodeHint: BarcodeDecoder.DecodeHintEAN_8, aspect: 1.333 } );
            append( { codeName: "EAN_13", decodeHint: BarcodeDecoder.DecodeHintEAN_13, aspect: 1.333 } );
            append( { codeName: "UPC_A", decodeHint: BarcodeDecoder.DecodeHintUPC_A, aspect: 1.333 } );
            append( { codeName: "UPC_E", decodeHint: BarcodeDecoder.DecodeHintUPC_E, aspect: 1.333 } );
            append( { codeName: "UPC_EAN_EXTENSION", decodeHint: BarcodeDecoder.DecodeHintUPC_EAN_EXTENSION, aspect: 1.333 } );
            append( { codeName: "CODABAR", decodeHint: BarcodeDecoder.DecodeHintCODABAR, aspect: 1.0} );
            append( { codeName: "RSS_14", decodeHint: BarcodeDecoder.DecodeHintRSS_14, aspect: 1.0} );
            append( { codeName: "RSS_EXPANDED", decodeHint: BarcodeDecoder.DecodeHintRSS_EXPANDED, aspect: 1.0} );
            append( { codeName: "ITF", decodeHint: BarcodeDecoder.DecodeHintITF, aspect: 1.0} );
            append( { codeName: "QR_CODE", decodeHint: BarcodeDecoder.DecodeHintQR_CODE, aspect: 1.0} );
            append( { codeName: "AZTEC", decodeHint: BarcodeDecoder.DecodeHintAZTEC, aspect: 1.0} );
            append( { codeName: "DATA_MATRIX", decodeHint: BarcodeDecoder.DecodeHintDATA_MATRIX, aspect: 1.0} );
            append( { codeName: "MAXICODE", decodeHint: BarcodeDecoder.DecodeHintMAXICODE, aspect: 1.0} );
            append( { codeName: "PDF_417", decodeHint: BarcodeDecoder.DecodeHintPDF_417, aspect: 4.0 } );

            recomputeAspect();
        }
    }

    //--------------------------------------------------------------------------

    function getElapsedString(timeDiff) {
        var s = Math.round(timeDiff / 1000.0);
        if (s < 60.0) {
            return qsTr("%1 seconds ago").arg(s);
        }
        if (s < 3600.0) {
            return qsTr("%1 minutes ago").arg(Math.round(s / 60.0));
        }
        return qsTr("%1 hours ago").arg(Math.round(s / 3600.0));
    }

    //--------------------------------------------------------------------------

    function recomputeAspect() {
        var aspect = 1.333;
        for (var i = 0; i < barcodeModel.count; i++) {
            var item = barcodeModel.get(i);
            if (!(barcodeFilter.decodeHints & item.decodeHint)) continue;
            aspect = item.aspect;
        }
        frameRect.aspect = aspect;
    }

    //--------------------------------------------------------------------------

    function loadSettings() {
        barcodeFilter.decodeHints = app.settings.value("decodeHints") || barcodeFilter.decodeHints;
        deviceId = app.settings.value("deviceId") || "";
    }

    //--------------------------------------------------------------------------

    function saveSettings() {
        app.settings.setValue("decodeHints", barcodeFilter.decodeHints);
    }

    function switchCamera() {
        if (!QtMultimedia.availableCameras.length) return;
        camera.stop();
        cameraIndex = (cameraIndex + 1) % QtMultimedia.availableCameras.length;
        console.log("cameraIndex: ", cameraIndex);
        deviceId = QtMultimedia.availableCameras[cameraIndex].deviceId;
        app.settings.setValue("deviceId", deviceId);
        camera.deviceId = deviceId;
        camera.start();
    }

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        loadSettings();

        cameraIndex = -1;

        if (QtMultimedia.availableCameras.length > 0) {
            for (var i = 0; i < QtMultimedia.availableCameras.length; i++) {
                if (QtMultimedia.availableCameras[i].deviceId === deviceId) {
                    cameraIndex = i;
                    console.log("camera device found:", i, camera.deviceId);
                    break;
                }
            }

            if (cameraIndex === -1) {
                for (var i = 0; i < QtMultimedia.availableCameras.length; i++) {
                    if (QtMultimedia.availableCameras[i].position === Camera.BackFace) {
                        cameraIndex = i;
                        deviceId = QtMultimedia.availableCameras[i].deviceId;
                        app.settings.setValue("deviceId", deviceId);
                        break;
                    }
                }
            }

            if (cameraIndex === -1) {
                cameraIndex = 0;
                deviceId = QtMultimedia.availableCameras[0].deviceId;
                app.settings.setValue("deviceId", deviceId);
            }

            if (deviceId) {
                camera.deviceId = deviceId;
                camera.start();
            }
        }

        Qt.inputMethod.hide();
    }

    //--------------------------------------------------------------------------

    Component.onDestruction: {
        camera.stop();
    }

}
