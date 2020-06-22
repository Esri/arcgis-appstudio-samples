import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0

import "../controls" as Controls

Pane {
    id: measurePanel
    
    property real value: 0
    property real iconSize: app.iconSize
    property real defaultMargin: app.defaultMargin/2
    property real defaultHeight: 3*app.defaultMargin + app.heightOffset

    property var colorObject: {"colorName": "#F89927", "alpha": "#59F89927"}
    property bool isIdentifyMode: false
    property bool showSegmentLength: true
    property bool showFillColor: true

    signal copiedToClipboard (string text)
    signal cameraClicked ()
    signal measurementUnitChanged (int index)

    property alias mUnit: measurementUnit

    onCameraClicked: {
        settingsContent.close()
    }
    
    Item {
        id: screenSizeState

        states: [
            State {
                name: "LARGE"
                when: !app.isCompact

                PropertyChanges {
                    target: screenShotIcon
                    visible: true
                }
            }
        ]

        onStateChanged: {
            if (state === "LARGE") {
                settingsContent.removeMenuItem ("camera-button")
            } else {
                settingsContent.insertMenuItem (itemsListModel.count, "camera-button", "")
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            isIdentifyMode = false
        }
    }

    visible: height > 0
    padding: 0
    bottomPadding: app.heightOffset
    width: Math.min(app.units(568), app.width)
    height: showMeasureTool ? defaultHeight : 0
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    Behavior on height {
        NumberAnimation {
            duration: 100
        }
    }
    
    QtObject {
        id: distanceUnits
        
        readonly property string kMeters: qsTr("%L1 Meters")
        readonly property string kMiles: qsTr("%L1 Miles")
        readonly property string kKilometers: qsTr("%L1 Kilometers")
        readonly property string kFeet: qsTr("%L1 Feet")
        readonly property string kFeetUS: qsTr("%L1 Feet (US)")
        readonly property string kYards: qsTr("%L1 Yards")
        readonly property string kNauticalMiles: qsTr("%L1 Nautical Miles")
    }
    
    QtObject {
        id: areaUnits
        
        property string defaultUnit: kSqMeters
        property real defaultValue: 0
        readonly property string kSqMeters: qsTr("%L1 Sq Meters")
        readonly property string kAcres: qsTr("%L1 Acres")
        readonly property string kSqMiles: qsTr("%L1 Sq Miles")
        readonly property string kSqKilometers: qsTr("%L1 Sq Kilometers")
        readonly property string kHectares: qsTr("%L1 Hectares")
        readonly property string kSqYards: qsTr("%L1 Sq Yards")
        readonly property string kSqFeet: qsTr("%L1 Sq Feet")
        readonly property string kSqFeetUS: qsTr("%L1 Sq Feet (US)")
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        visible: measurePanel.height === measurePanel.defaultHeight

        Controls.Icon {
            id: closeIcon

            iconSize: measurePanel.iconSize
            Layout.alignment: Qt.AlignVCenter
            imageSource: "../images/close.png"
            checkable: true
            maskColor: app.darkIconMask

            onClicked: {
                showDiscardMeasurementsDialog(function () {
                    measureToolIcon.checked = false
                    mapView.resetMeasureTool()
                }, function () {})
            }
        }
        
        Controls.ComboBox {
            id: measurementLabel
            
            iconSize: measurePanel.iconSize
            defaultMargin: measurePanel.defaultMargin
            
            onLabelChanged: {
                if (label === kDistance) {
                    captureType = "line"
                    settingsContent.insertMenuItem(1, "show-length-switch", "switch", showSegmentLength)
                    settingsContent.removeMenuItem("show-fill-color-switch")
                } else {
                    captureType = "area"
                    settingsContent.removeMenuItem("show-length-switch")
                    settingsContent.insertMenuItem(1, "show-fill-color-switch", "switch", showFillColor)
                }
            }
            
            Component.onCompleted: {
                model.append({"itemLabel": kDistance})
                model.append({"itemLabel": kArea})
                updateLabel()
            }
        }
        
        Controls.SpaceFiller {
            id: spaceFiller
        }
        
        Controls.ComboBox {
            id: measurementUnit
            
            property real value: measurePanel.value

            Layout.alignment: Qt.AlignRight
            iconSize: measurePanel.iconSize
            maxLabelWidth: parent.width - measurementLabel.width - 2 * iconSize
            maxMenuWidth: app.units(168)
            menu.x: menu.parent.width-menu.width-defaultMargin
            
            Connections {
                target: measurementUnit.listView

                onCurrentIndexChanged: {
                    if (measurementUnit.listView.currentIndex >= 0) {
                        measurementUnitChanged (measurementUnit.listView.currentIndex)
                    }
                }
            }

            Connections {
                target: measurementLabel
                
                onLabelChanged: {
                    if (label === kDistance) {
                        measurementUnit.updateDistance(mapView.getDetailValue())
                    } else if (label === kArea) {
                        measurementUnit.updateArea(mapView.getDetailValue())
                    }
                }
            }
            
            onValueChanged: {
                if (captureType === "line") {
                    updateDistance(value)
                } else {
                    updateArea(value)
                }
            }
            
            function updateDistance (realValue) {
                if (!realValue) realValue = 0
                var index = measurementUnit.listView.currentIndex
                measurementUnit.model.clear()
                measurementUnit.model.append({itemLabel: distanceUnits.kMeters.arg(realValue<1000000? realValue.toFixed(0):realValue.toExponential(3)), unit: lengthUnits.meters})
                measurementUnit.model.append({itemLabel: distanceUnits.kMiles.arg((realValue*0.000621371)<1000000?(realValue*0.000621371).toFixed(2): (realValue*0.000621371).toExponential(3)), unit: lengthUnits.miles})
                measurementUnit.model.append({itemLabel: distanceUnits.kKilometers.arg((realValue*0.001)<10000000? (realValue*0.001).toFixed(2):(realValue*0.001).toExponential(3)), unit: lengthUnits.kilometers})
                measurementUnit.model.append({itemLabel: distanceUnits.kFeet.arg((realValue*3.28084)<1000000?(realValue*3.28084).toFixed(0):(realValue*3.28084).toExponential(3)), unit: lengthUnits.feet})
                measurementUnit.model.append({itemLabel: distanceUnits.kFeetUS.arg((realValue*3.28083)<1000000?(realValue*3.28083).toFixed(0):(realValue*3.28083).toExponential(3)), unit: lengthUnits.feetUS})
                measurementUnit.model.append({itemLabel: distanceUnits.kYards.arg((realValue*1.09361)<1000000?(realValue*1.09361).toFixed(1):(realValue*1.09361).toExponential(3)), unit: lengthUnits.yards})
                measurementUnit.model.append({itemLabel: distanceUnits.kNauticalMiles.arg((realValue*0.000539957)<1000000?(realValue*0.000539957).toFixed(1):(realValue*0.000539957).toExponential(3)), unit: lengthUnits.nauticalMiles})
                measurementUnit.listView.currentIndex = index < 0 ? 0 : index
                measurementUnit.updateLabel()
            }
            
            function updateArea (realValue) {
                if (!realValue) realValue = 0
                var index = measurementUnit.listView.currentIndex
                measurementUnit.model.clear()
                measurementUnit.model.append({itemLabel: areaUnits.kSqMeters.arg(realValue<1000000? realValue.toFixed(0):realValue.toExponential(3))})
                measurementUnit.model.append({itemLabel: areaUnits.kAcres.arg((realValue/4046.86)<1000000?(realValue/4046.86).toFixed(1):(realValue/4046.86).toExponential(3))})
                measurementUnit.model.append({itemLabel: areaUnits.kSqMiles.arg((realValue/2589990)<1000000?(realValue/2589990).toFixed(2):(realValue/2589990).toExponential(3))})
                measurementUnit.model.append({itemLabel: areaUnits.kSqKilometers.arg((realValue/1000000)<1000000?(realValue/1000000).toFixed(2):(realValue/1000000).toExponential(3))})
                measurementUnit.model.append({itemLabel: areaUnits.kHectares.arg((realValue/10000)<1000000?(realValue/10000).toFixed(1):(realValue/10000).toExponential(3))})
                measurementUnit.model.append({itemLabel: areaUnits.kSqYards.arg((realValue/0.836128)<1000000?(realValue/0.836128).toFixed(1):(realValue/0.836128).toExponential(3))})
                measurementUnit.model.append({itemLabel: areaUnits.kSqFeet.arg((realValue/0.092903)<1000000?(realValue/0.092903).toFixed(1):(realValue/0.092903).toExponential(3))})
                measurementUnit.model.append({itemLabel: areaUnits.kSqFeetUS.arg((realValue*10.7638)<1000000?(realValue*10.7638).toFixed(1):(realValue*10.7638).toExponential(3))})
                measurementUnit.listView.currentIndex = index < 0 ? 0 : index
                measurementUnit.updateLabel()
            }
        }

        Menu {
            id: settingsContent

            property real menuItemHeight: app.units(48)
            property real colorPaletteHeight: 1.4 * menuItemHeight

            modal: true
            width: app.units(240) * app.fontScale
            height: padding + (colorPaletteHeight + listView.spacing) + (listView.model.count) * (listView.spacing + menuItemHeight)
            x: parent.width-settingsContent.width-2*defaultMargin
            padding: 0
            bottomMargin: 2*defaultMargin

            property alias listView: listView

            contentItem: ListView {
                id: listView
                clip: true
                anchors.fill: parent
                headerPositioning: ListView.OverlayHeader
                spacing: app.baseUnit

                header: ToolBar {
                    z: 8
                    width: parent.width
                    height: settingsContent.menuItemHeight
                    Material.background: app.backgroundColor
                    Material.elevation: 1
                    padding: 0
                    leftPadding: app.defaultMargin
                    rightPadding: app.defaultMargin

                    Controls.BaseText {
                        text: qsTr("Measure Settings")
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                    }
                }

                delegate: Pane {
                    padding: 0
                    leftPadding: app.defaultMargin
                    rightPadding: app.defaultMargin
                    height: name === "color-palette" ? settingsContent.colorPaletteHeight : settingsContent.menuItemHeight
                    width: parent.width
                    Material.background: "transparent"

                    ColumnLayout {
                        id: colorPalette

                        visible: name === "color-palette"
                        anchors.fill: parent
                        spacing: 0

                        Controls.SpaceFiller {
                            Layout.preferredHeight: app.units(0.2)
                        }

                        Controls.BaseText {
                            text: qsTr("Color")
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            Layout.preferredHeight: parent.height/(2)
                        }

                        ListView {
                            id: colorPicker

                            //spacing: app.baseUnit
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            orientation: Qt.Horizontal
                            currentIndex: 1

                           onCurrentIndexChanged: {
                               if (currentIndex >= 0) {
                                   colorObject = colorModel.get(currentIndex)
                               } else {
                                   colorObject = {"colorName": "#F89927", "alpha": "#59F89927"}
                               }
                           }

                            model: ListModel {
                                id: colorModel

                                ListElement {
                                    colorName: "#FF0000"
                                    alpha: "#59FF0000"
                                    isChecked: false
                                }
                                ListElement {
                                    colorName: "#F89927"
                                    alpha: "#59F89927"
                                    isChecked: true
                                }
                                ListElement {
                                    colorName: "#FFFF00"
                                    alpha: "#59FFFF00"
                                    isChecked: false
                                }
                                ListElement {
                                    colorName: "#00FF00"
                                    alpha: "#5900FF00"
                                    isChecked: false
                                }
                                ListElement {
                                    colorName: "#0000FF"
                                    alpha: "#590000FF"
                                    isChecked: false
                                }
                                ListElement {
                                    colorName: "#7F00FF"
                                    alpha: "#597F00FF"
                                    isChecked: false
                                }
                            }

                            delegate: RadioDelegate {
                                id: radioButton
                                padding: 0
                                leftPadding: app.baseUnit/2
                                rightPadding: app.baseUnit/2
                                height: 0.9 * parent.height
                                width: (settingsContent.width - 2*app.defaultMargin)/(colorPicker.model.count)

                                indicator: Rectangle {
                                    anchors.centerIn: parent
                                    height: parent.height - app.baseUnit/2
                                    width: height
                                    radius: height/2
                                    color: colorName
                                    border.color: Qt.darker(color, 1.1)

                                    Image {
                                        id: image
                                        visible: radioButton.checked
                                        width: 0.8 * parent.width
                                        height: width
                                        anchors.centerIn: parent
                                        source: "../images/check.png"
                                    }

                                    ColorOverlay {
                                        id: mask

                                        visible: image.visible
                                        color: colorName === "#FFFF00" ? app.darkIconMask : "white"
                                        anchors.fill: image
                                        source: image
                                    }
                                }

                                onCheckedChanged: {
                                    colorPicker.currentIndex = index
                                }

                                Component.onCompleted: {
                                    checked = isChecked
                                }
                            }
                        }
                    }

                    RowLayout {
                        id: showLengthSwitch

                        visible: name === "show-length-switch"
                        anchors.fill: parent

                        Controls.BaseText {
                            text: qsTr("Show segment length")
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width - lengthSwitch.width
                            Layout.alignment: Qt.AlignVCenter
                            verticalAlignment: Text.AlignVCenter
                            maximumLineCount: 1
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                        }

                        Switch {
                            id: lengthSwitch
                            padding: 0
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: app.iconSize
                            Layout.alignment: Qt.AlignVCenter
                            Material.primary: app.primaryColor
                            Material.accent: app.accentColor

                            checked: isChecked ? isChecked : false
                            onCheckedChanged: {
                                showSegmentLength = checked
                            }
                        }
                    }

                    RowLayout {
                        id: showFillColorSwitch

                        visible: name === "show-fill-color-switch"
                        anchors.fill: parent

                        Controls.BaseText {
                            text: qsTr("Show fill color")
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width - fillColorSwitch.width
                            Layout.alignment: Qt.AlignVCenter
                            verticalAlignment: Text.AlignVCenter
                            maximumLineCount: 1
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                        }

                        Switch {
                            id: fillColorSwitch
                            padding: 0
                            Layout.preferredHeight: app.iconSize
                            Layout.preferredWidth: app.iconSize
                            Layout.alignment: Qt.AlignVCenter
                            Material.primary: app.primaryColor
                            Material.accent: app.accentColor

                            checked: isChecked ? isChecked : false
                            onCheckedChanged: {
                                showFillColor = checked
                            }
                        }
                    }

                    RowLayout {
                        id: cameraBtn

                        visible: name === "camera-button"
                        anchors.fill: parent
                        enabled: !measureToast.visible
                        opacity: enabled ? 1 : 0.3

                        Controls.BaseText {
                            text: qsTr("Capture screenshot")
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    cameraClicked()
                                }
                            }
                        }
                    }
                }

                model: ListModel {
                    id: itemsListModel
                    ListElement {
                        name: "color-palette"
                        control: "picker"
                        isChecked: false
                    }
                    ListElement {
                        name: "show-length-switch"
                        control: "switch"
                        isChecked: true
                    }
                    ListElement {
                        name: "show-fill-color-switch"
                        control: "switch"
                        isChecked: true
                    }
                    ListElement {
                        name: "camera-button"
                        control: ""
                        isChecked: false
                    }
                }
            }

            function removeMenuItem (name) {
                for (var i=0; i<itemsListModel.count; i++) {
                    if (itemsListModel.get(i).name === name) {
                        itemsListModel.remove(i)
                        break
                    }
                }
            }

            function insertMenuItem (index, name, control, isChecked) {
                if (!isChecked) isChecked = false
                var hasItem = false
                for (var i=0; i<itemsListModel.count; i++) {
                    if (itemsListModel.get(i).name === name) {
                        hasItem = true
                        break
                    }
                }
                if (!hasItem) {
                    itemsListModel.insert(index,
                    {"name": name, "control": control, "isChecked": isChecked})
                }
            }
        }
        
        Controls.Icon {
            id: screenShotIcon

            visible: false
            enabled: !measureToast.visible
            opacity: enabled ? 1 : 0.5
            Layout.alignment: Qt.AlignRight
            iconSize: measurePanel.iconSize
            imageSource: "../images/camera.png"
            maskColor: app.darkIconMask

            onClicked: {
                cameraClicked()
            }
        }

        Controls.Icon {
            id: settingsIcon
            
            Layout.alignment: Qt.AlignRight
            iconSize: measurePanel.iconSize
            imageSource: "../images/settings.png"
            maskColor: app.darkIconMask

            onClicked: {
                settingsContent.open()
            }
        }
    }
    
    background: Rectangle {
    }

    property alias lengthUnits: lengthUnits
    QtObject {
        id: lengthUnits

        property int meters: 0
        property int miles: 1
        property int kilometers: 3
        property int feet: 4
        property int feetUS: 5
        property int yards: 6
        property int nauticalMiles: 7
    }

    function convert (realValue, toUnit) {
        if (!toUnit) {
            var u = measurementUnit.model.get(measurementUnit.listView.currentIndex)
            toUnit = u ? u.unit : null
        }

        switch (toUnit) {
        case lengthUnits.meters:
            realValue = parseFloat(realValue)
            return realValue<1000000? realValue.toFixed(0):realValue.toExponential(3)
        case lengthUnits.miles:
            return (realValue*0.000621371)<1000000?(realValue*0.000621371).toFixed(2): (realValue*0.000621371).toExponential(3)
        case lengthUnits.kilometers:
            return (realValue*0.001)<10000000? (realValue*0.001).toFixed(2):(realValue*0.001).toExponential(3)
        case lengthUnits.feet:
            return (realValue*3.28084)<1000000?(realValue*3.28084).toFixed(0):(realValue*3.28084).toExponential(3)
        case lengthUnits.feetUS:
            return (realValue*3.28083)<1000000?(realValue*3.28083).toFixed(0):(realValue*3.28083).toExponential(3)
        case lengthUnits.yards:
            return (realValue*1.09361)<1000000?(realValue*1.09361).toFixed(1):(realValue*1.09361).toExponential(3)
        case lengthUnits.nauticalMiles:
            return (realValue*0.000539957)<1000000?(realValue*0.000539957).toFixed(1):(realValue*0.000539957).toExponential(3)
        default:
            return realValue
        }
    }

    function copyToClipBoard (text) {
        AppFramework.clipboard.copy(text)
        settingsContent.close()
        copiedToClipboard(text)
    }

    function setUnitByScale (scale) {
        if (Qt.locale().measurementSystem === Locale.MetricSystem) {
            switch (true) {
            case scale < 20000:
                measurementUnit.listView.currentIndex = 0 // meters
                break
            default:
                measurementUnit.listView.currentIndex = 2 // km
            }
        } else {
            switch (true) {
            case scale < 1000:
                measurementUnit.listView.currentIndex = 3 // feet
                break
            case 1000 <= scale && scale < 20000:
                measurementUnit.listView.currentIndex = 5 // yards
                break
            default:
                measurementUnit.listView.currentIndex = 1 // miles
            }
        }
    }
}
