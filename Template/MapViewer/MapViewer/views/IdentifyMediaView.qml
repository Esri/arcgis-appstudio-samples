import QtQuick 2.7
import QtCharts 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0

import QtQuick.Controls.Material 2.1

import Esri.ArcGISRuntime 100.7

import "../controls" as Controls

ListView {
    id: identifyMediaView

    property var media: []
    property var fields: []
    property var attributes: Object
    property string layerName: ""
    property real defaultContentHeight: parent.height
    footer:Rectangle{
        height:100 * scaleFactor
        width:identifyMediaView.width
        color:"transparent"
    }

    clip: true
    spacing: app.defaultMargin/2
    Material.background: app.backgroundColor

    onMediaChanged: {
        mediaModel.clear()
        for (var i=0; i<media.length; i++) {
            if (isValid(media[i])) {
                mediaModel.append({ "popupMediaType": media[i].popupMediaType,
                                      "caption": media[i].caption,
                                      "title": media[i].title
                                  })
            }
        }
    }

    model: ListModel {
        id: mediaModel
    }

    header: Pane {
        id: header

        visible: media.length > 0 && headerText.text > ""
        height: media.length > 0 ? 0.8 * app.headerHeight : 0
        Material.background: "transparent"
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
                Layout.preferredWidth: parent.width - layerIcon.width - app.defaultMargin
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

    delegate: ColumnLayout {
        anchors {
            margins: app.defaultMargin
            left: parent.left
            right: parent.right
        }
        //height: titleTxt.height + captionTxt.height + chart.height + app.defaultMargin
        Component.onCompleted: height = titleTxt.height + captionTxt.height + chart.height + app.defaultMargin
        spacing: 0

        Controls.SubtitleText {
            id: titleTxt
            Layout.preferredWidth: parent.width
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            text: replaceVariables(decodeURIComponent(title), attributes)
        }

        Controls.BaseText {
            id: captionTxt
            Layout.preferredWidth: parent.width
            Layout.bottomMargin: app.defaultMargin/4
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            text: typeof caption !== "undefined" ? replaceVariables(decodeURIComponent(caption), attributes) : ""
            font.pointSize: app.textFontSize
            maximumLineCount: 2
            textFormat: Text.StyledText
            onLinkActivated: {
                app.openUrlInternally(link)
            }
        }

        Rectangle {
            id: chart

            Layout.preferredWidth: parent.width
            Layout.preferredHeight: Layout.preferredWidth
            Layout.bottomMargin: app.defaultMargin
            Layout.alignment: Qt.AlignHCenter

            property real pointSize: Qt.platform.os === "windows" ? 0.8 * app.textFontSize : app.textFontSize

            visible: {
                return popupMediaType === Enums.PopupMediaTypePieChart ||
                        popupMediaType === Enums.PopupMediaTypeBarChart ||
                        popupMediaType === Enums.PopupMediaTypeColumnChart ||
                        popupMediaType === Enums.PopupMediaTypeLineChart ||
                        popupMediaType === Enums.PopupMediaTypeImage
            }

            border {
                color: popupMediaType === Enums.PopupMediaTypeImage ? "transparent" :  Qt.darker(app.backgroundColor, 1.1)
            }

            Item {
                id: pieChart

                visible: popupMediaType === Enums.PopupMediaTypePieChart
                anchors.fill: parent
                ChartView {
                    id: pieChartView

                    antialiasing: true
                    anchors.fill: parent
                    legend.visible: pieSeries.count < 4
                    titleFont.pointSize: chart.pointSize
                    margins {
                        top: app.defaultMargin
                        left: 0
                        right: 0
                        bottom: 0
                    }

                    PieSeries {
                        id: pieSeries

                        onHovered: {
                            toolTip.text = "%1: %2".arg(slice.label).arg(slice.value.toString())
                            toolTip.visible = state
                        }

                        MouseArea {
                            anchors.fill: parent

                            onPressed: {
                                toolTip.visible = true
                            }

                            onReleased: {
                                toolTip.visible = false
                            }
                        }
                    }

                    Component.onCompleted: {
                        var value = media[index].value
                        for (var i=0; i<value.fieldNames.length; i++) {
                            var mediaFieldName = value.fieldNames[i]
                            if (mediaFieldName in attributes) {
                                if(!attributes[mediaFieldName]) {
                                    attributes[mediaFieldName] = 0
                                }
                                var label = getLabel(mediaFieldName)
                                pieSeries.append(label, attributes[mediaFieldName])
                            }
                        }
                    }
                }
            }

            Item {
                id: barChart

                visible: popupMediaType === Enums.PopupMediaTypeBarChart
                enabled: popupMediaType === Enums.PopupMediaTypeBarChart
                anchors.fill: parent

                ChartView {
                    id: barChartView

                    anchors.fill: parent
                    antialiasing: true
                    legend.visible: false
                    titleFont.pointSize: chart.pointSize
                    margins {
                        top: app.defaultMargin
                        left: 0
                        right: 0
                        bottom: 0
                    }

                    HorizontalBarSeries {
                        id: horbarSeries

                        labelsVisible: false
                        axisY: BarCategoryAxis {
                            id: horbarcatergoryAxis
                            labelsFont.pointSize: chart.pointSize
                        }

                        onHovered: {
                            toolTip.text = "%1: %2".arg(horbarcatergoryAxis.categories[index]).arg(barset.values[index].toString())
                            toolTip.visible = status
                        }

                        MouseArea {
                            anchors.fill: parent

                            onPressed: {
                                toolTip.visible = true
                            }

                            onReleased: {
                                toolTip.visible = false
                            }
                        }
                    }

                    Component.onCompleted: {
                        if(!barChart.enabled) {
                            return
                        }

                        var dataArray = [],
                                categoriesArray = [],
                                value = media[index].value

                        for (var i=0; i<value.fieldNames.length; i++){
                            var mediaFieldName = value.fieldNames[i]
                            if (mediaFieldName in attributes) {
                                if(!attributes[mediaFieldName]) {
                                    attributes[mediaFieldName] = 0
                                }
                                dataArray.push(attributes[mediaFieldName])
                            }
                            for (var f in fields) {
                                if (fields[f].fieldName === mediaFieldName) {
                                    categoriesArray.push(fields[f].label)
                                }
                            }
                        }
                        horbarSeries.append("fieldValues", dataArray)
                        horbarcatergoryAxis.categories = categoriesArray
                        var returnMax = Math.ceil(Math.max.apply(null, dataArray))
                        horbarSeries.axisX.labelsAngle = 90
                        horbarSeries.axisX.max = returnMax
                        horbarSeries.axisX.labelsFont.pointSize = Qt.binding(function() { return chart.pointSize })
                    }
                }
            }

            Item {
                id: columnChart

                anchors.fill: parent
                anchors.margins: 3

                visible: popupMediaType === Enums.PopupMediaTypeColumnChart
                enabled: popupMediaType === Enums.PopupMediaTypeColumnChart

                ChartView {
                    id: columnChartView

                    anchors.fill: parent
                    antialiasing: true
                    legend.visible: false
                    margins {
                        top: app.defaultMargin
                        left: 0
                        right: 0
                        bottom: 0
                    }

                    BarSeries {
                        id: barSeries

                        axisX: BarCategoryAxis {
                            id: barcategoryAxis
                            labelsVisible: false
                            labelsFont.pointSize: chart.pointSize
                        }

                        onHovered: {
                            toolTip.text = "%1: %2".arg(barcategoryAxis.categories[index]).arg(barset.values[index].toString())
                            toolTip.visible = status
                        }

                        MouseArea {
                            anchors.fill: parent

                            onPressed: {
                                toolTip.visible = true
                            }

                            onReleased: {
                                toolTip.visible = false
                            }
                        }
                    }

                    Component.onCompleted: {
                        if(!columnChart.enabled) {
                            return
                        }

                        var dataArray = [],
                                categoriesArray = [],
                                value = media[index].value

                        for (var i=0; i<value.fieldNames.length; i++){
                            var mediaFieldName = value.fieldNames[i]
                            if (mediaFieldName in attributes) {
                                if(!attributes[mediaFieldName]) {
                                    attributes[mediaFieldName] = 0
                                }
                                dataArray.push(attributes[mediaFieldName])
                            }

                            for (var f in fields){
                                if (fields[f].fieldName === mediaFieldName) {
                                    categoriesArray.push(fields[f].label)
                                }
                            }
                        }
                        barSeries.append("fieldValues", dataArray)
                        barcategoryAxis.categories = categoriesArray

                        var returnMax = Math.ceil(Math.max.apply(null, dataArray))
                        barSeries.axisY.max = returnMax
                        barSeries.axisY.labelsFont.pointSize = Qt.binding(function() { return chart.pointSize })
                    }
                }
            }

            Item {
                id: lineChart

                anchors.fill: parent
                anchors.margins: 3
                visible: popupMediaType === Enums.PopupMediaTypeLineChart
                enabled: popupMediaType === Enums.PopupMediaTypeLineChart

                ChartView {
                    id: lineChartView
                    anchors.fill: parent
                    antialiasing: true
                    legend.visible: false
                    margins {
                        top: app.defaultMargin
                        left: 0
                        right: 0
                        bottom: 0
                    }

                    property var fieldsArray: []

                    LineSeries {
                        id: lineSeries
                        axisX: BarCategoryAxis {
                            id: linecatergoryAxis
                            labelsVisible: false
                            labelsFont.pointSize: chart.pointSize
                        }
                        pointsVisible: true

                        onHovered: {
                            toolTip.text = "(%1, %2)".arg(point.x).arg(point.y)
                            toolTip.visible = state
                        }

                        MouseArea {
                            anchors.fill: parent

                            onPressed: {
                                toolTip.visible = true
                            }

                            onReleased: {
                                toolTip.visible = false
                            }
                        }
                    }

                    Component.onCompleted: {

                        var dataArray = [],
                                categoriesArray = []

                        if(!lineChart.enabled) {
                            return
                        }

                        var value = media[index].value
                        for (var i=0; i<value.fieldNames.length; i++){
                            var mediaFieldName = value.fieldNames[i]
                            if (mediaFieldName in attributes) {
                                if(!attributes[mediaFieldName]) {
                                    attributes[mediaFieldName] = 0
                                }
                                dataArray.push(attributes[mediaFieldName])
                                fieldsArray.push(i)
                                lineSeries.append(i, attributes[mediaFieldName])
                            }

                            for (var f in fields){
                                if (fields[f].fieldName === mediaFieldName) {
                                    categoriesArray.push(fields[f].label)
                                }
                            }
                        }

                        linecatergoryAxis.categories = categoriesArray

                        var returnMax = Math.ceil(Math.max.apply(null, dataArray))
                        lineSeries.axisY.max = returnMax
                        lineSeries.axisY.labelsFont.pointSize = Qt.binding(function() { return chart.pointSize })
                    }
                }
            }

            Image {
                id: img

                width: parent.width
                height: width
                visible: (popupMediaType === Enums.PopupMediaTypeImage) && source
                source: {
                    try {
                        var value = media[index].value
                        return visible && typeof value !== "undefined" ? (value ? replaceVariables(decodeURIComponent(value.sourceUrl), attributes) : "") : ""
                    } catch (err) {
                        return ""
                    }
                }
                fillMode: Image.PreserveAspectFit
            }

            Controls.BaseText {
                id: toolTip

                width: parent.width
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    margins: app.defaultMargin/4
                }
                font.pointSize: chart.pointSize
                color: "#FFFFFF"
                visible: false
                background: Rectangle {
                    width: parent.width
                    height: parent.height
                    anchors.centerIn: parent
                    opacity: 0.8
                    radius: 2
                    color: "#424242"
                }

                leftPadding: app.defaultMargin
                rightPadding: app.defaultMargin
            }
        }
    }

    Controls.BaseText {
        id: message

        visible: (media.length <= 0 && text > "" && !busyIndicator.visible) || (identifyMediaView.contentHeight <= app.headerHeight && !busyIndicator.visible)
        maximumLineCount: 5
        elide: Text.ElideRight
        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("There are no media.")
    }

    property alias busyIndicator: busyIndicator
    BusyIndicator {
        id: busyIndicator

        width: app.iconSize
        visible: mapView.identifyProperties.popupManagersCount && !media.length
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

            interval: 500
            running: true
            repeat: false
            onTriggered: {
                busyIndicator.visible = false
            }
        }
    }

    function isValid (item) {
        if (typeof item.value === "undefined") return false
        if (item.value === null) return false
        switch (item.popupMediaType) {
        case Enums.PopupMediaTypePieChart:
            break
        case Enums.PopupMediaTypeBarChart:
            break
        case Enums.PopupMediaTypeColumnChart:
            break
        case Enums.PopupMediaTypeLineChart:
            break
        case Enums.PopupMediaTypeImage:
            if (typeof item.value.sourceUrl === "undefined") return
            if (!replaceVariables(decodeURIComponent(item.value.sourceUrl))) return
        }
        return true
    }

    function getLabel (fieldName) {
        for (var i=0; i<fields.length; i++) {
            if (fields[i].fieldName === fieldName) {
                return fields[i].label
            }
        }
        return fieldName
    }

    function replaceVariables(text, attributes) {
        if (!text && !attributes) return ""

        if(text && attributes)
        {
            var keys = Object.keys(attributes)

            for (var i = 0; i < keys.length; i++) {
                var key = keys[i]
                text = text.replace("{%1}".arg(key), attributes[key])
            }
        }

        return text
    }

}
