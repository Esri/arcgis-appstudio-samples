import QtQuick 2.2
import QtQuick.Controls 1.1
import QtPositioning 5.2
import QtQuick.Window 2.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "Helper.js" as Helper


DockPanel {
    id: popupPanel

    property WebMapIdentify webMapIdentify
    property ListModel popupModel
    //    property alias popupModel: webMapIdentify.popupModel //popupModel

    property Point refPoint
    property Point refPosition
    property var refDistance
    property string refLabel: ""
    property int visibleRows: 5
    property real delegateHeight: 25 * AppFramework.displayScaleFactor
    property real iconSize: delegateHeight * 1.2

    leftEdge: parent.left
    rightEdge: parent.right
    topEdge: banner.bottom
    bottomEdge: parent.bottom
    lockRight: false

    show: refPoint != null && (popupModel.count > 0 || webMapIdentify.tasksCount > 0)
    fullScreen: landscape && app.width * app.sidePanelRatio < app.sidePanelWidth //app.compactLayout ||
    landscape: (app.width > app.height) || app.width > app.sidePanelWidth * 2

    visibleHeight: delegateHeight * Math.min(popupModel.count * 2, visibleRows) +  14 + iconSize + tasksBusyIndicator.height
    visibleWidth: Math.min(app.width * app.sidePanelRatio, app.sidePanelWidth)

    color: "#f0e5e6e7"
    border {
        width: 1
        color: "lightgrey"
    }

    //----------------------------------------------------------------------

    function clear() {
        popupStackView.pop(null);
        refPoint = null;
        refPosition = null;
        refDistance = null;
        popupModel.clear();
    }

    //----------------------------------------------------------------------

    function setLocation(mousePoint, position) {
        refPoint = mousePoint.mapPoint;
        if (position) {
            refPosition = position;
        }
        refDistance = refPosition ? refPosition.distance(refPoint) : null;

        popupStackView.pop(null);
        //        popupModel.clear();

        resultsLayer.removeAllGraphics();

        var graphic = ArcGISRuntime.createObject("Graphic",
                                                 { json: {
                                                         geometry: {
                                                             x: refPoint.x,
                                                             y: refPoint.y
                                                         }
                                                     }
                                                 });
        graphic.symbol = identifyMarkerSymbol;

        resultsLayer.addGraphic(graphic);

        //map.panTo(refPoint);

        webMapIdentify.identify(mousePoint);
    }

    //--------------------------------------------------------------------------

    function highlightFeature(index) {
        resultsLayer.clearCurrent();

        var popupItem = popupModel.get(index);
        if (!popupItem.geometry) {
            return;
        }

        var graphic = ArcGISRuntime.createObject("Graphic",
                                                 { json: {
                                                         geometry: popupItem.geometry
                                                     }
                                                 });

        resultsLayer.setCurrent(graphic);
    }

    //--------------------------------------------------------------------------

    function showFeaturePopup(index) {
        highlightFeature(index);

        var popupItem = popupModel.get(index);

        var popup = featurePopup.createObject(null, { "index": index });

        if (app.compactLayout) {
            stackView.push(popup);
        } else {
            popupStackView.push(popup);
        }
    }

    Component {
        id: featurePopup

        Item {
            property int index
            property var popupItem: popupModel.get(index)

            property var attributes: popupItem ? popupItem.attributes : {}
            property var popupInfo: popupItem ? popupItem.popupInfo : {}

            WebMapPopupActionsBar {
                id: popupActionsBar

                property int previousIndex: findPrevious(parent.index)
                property int nextIndex: findNext(parent.index)
                property int popupsCount: countPopups(popupModel)

                height: (app.compactLayout ? 60 : 40) * AppFramework.displayScaleFactor

                title: popupsCount > 1 ? (parent.index + 1).toString() + " of " + popupsCount.toString() + " features" : (app.compactLayout ? popupView.title : "")
                previousVisible: previousIndex >= 0
                nextVisible: nextIndex >= 0
                backText: app.compactLayout ? "" : "List"
                backImage: app.compactLayout ? "images/left2.png" : "images/back.png"

                onPreviousClicked: {
                    parent.index = previousIndex;
                    highlightFeature(parent.index);
                }

                onNextClicked: {
                    parent.index = nextIndex;
                    highlightFeature(parent.index);
                }

                onBackClicked: {
                    parent.parent.pop();
                }


                function countPopups(model) {
                    var count = 0;

                    for (var i = 0; i < model.count; i++) {
                        if (isPopup(i)) {
                            count++;
                        }
                    }

                    return count;
                }

                function findPrevious(i) {
                    while (--i >= 0) {
                        if (isPopup(i)) {
                            return i;
                        }
                    }

                    return -1;
                }

                function findNext(i) {
                    while (++i < popupModel.count) {
                        if (isPopup(i)) {
                            return i;
                        }
                    }

                    return -1;
                }

                function isPopup(i) {
                    var item = popupModel.get(i);
                    return item.popup;
                }

            }

            WebMapPopupView {
                id: popupView

                anchors {
                    top: popupActionsBar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                attributes: parent.attributes
                popupInfo: parent.popupInfo
                linkText: "More info"
                color: app.featurePopupBackgroundColor
                titleVisible: popupActionsBar.popupsCount > 1 || !app.compactLayout
            }

            Rectangle {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }

                visible: !app.compactLayout
                width: 1
                color: "darkgrey"
            }
        }
    }

    //--------------------------------------------------------------------------

    MouseArea {
        anchors {
            fill: parent
        }

        onClicked: {
            popupPanel.clear();
        }
    }

    //--------------------------------------------------------------------------

    StackView {
        id: popupStackView

        anchors {
            fill: parent
        }

        clip: true

        initialItem: Item {
            Item {
                anchors {
                    fill: parent
                    margins: 5
                }

                Rectangle {
                    id: identifyHeader

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: -4
                    }

                    height: popupPanel.iconSize + 8
                    color: "#e04c4c4c"

                    ImageButton {
                        id: markerImageButton

                        anchors {
                            left: parent.left
                            top: parent.top
                            margins: 5
                        }

                        width: popupPanel.iconSize
                        height: width

                        source:  identifyMarkerSymbol.swatchImage
                        hoverColor: app.hoverColor
                        pressedColor: app.pressedColor

                        onClicked: {
                            map.panTo(popupPanel.refPoint);
                        }

                        onDoubleClicked: {
                            map.zoomToScale(10000, popupPanel.refPoint);
                        }
                    }

                    ImageButton {
                        id: closeButton

                        source: "images/close.png"
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                            margins: 5
                        }

                        width: height
                        hoverColor: app.hoverColor
                        pressedColor: app.pressedColor

                        onClicked: {
                            popupPanel.clear();
                        }
                    }

                    Text {
                        id: popupLabel

                        anchors {
                            left: markerImageButton.right
                            right: closeButton.left
                            top: parent.top
                            margins: 5
                        }

                        height: popupPanel.refLabel > "" ? paintedHeight: 0

                        text: popupPanel.refLabel
                        color: app.lightTextColor
                        font {
                            pointSize: 24
                        }
                    }

                    Text {
                        id: popupDistanceText

                        anchors {
                            left: popupLabel.left
                            right: closeButton.left
                            top: popupLabel.bottom
                            topMargin: 2
                        }

                        text: popupPanel.refDistance ? Helper.niceDistance(popupPanel.refDistance) : ""
                        color: app.lightTextColor
                        font {
                            pointSize: 11
                            italic: true
                        }
                    }
                }

                BusyIndicator {
                    id: tasksBusyIndicator

                    anchors {
                        top: identifyHeader.bottom
                        topMargin: 2
                        left: identifyHeader.left
                    }

                    running: webMapIdentify.tasksCount > 0
                    visible: running
                    width: 40 * AppFramework.displayScaleFactor
                    height: width
                }

                Text {
                    id: tasksBusyText

                    anchors {
                        top: tasksBusyIndicator.top
                        left: tasksBusyIndicator.right
                        leftMargin: 2
                        right: parent.right
                    }

                    height: tasksBusyIndicator.running ? tasksBusyIndicator.height : 0

                    text: "Searching... (" + webMapIdentify.tasksCount.toString() + ")"
                    font {
                        pointSize: 14
                        italic: true
                    }
                    elide: Text.ElideRight
                    color: app.darkTextColor
                    verticalAlignment: Text.AlignVCenter
                }

                ListView {
                    id: popupListView

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: tasksBusyText.bottom // popupDistanceText.bottom
                        topMargin: 2
                        bottom: parent.bottom
                    }
                    clip: true

                    model: popupModel

                    section {
                        property: "category"
                        criteria: ViewSection.FullString
                        delegate: sectionDelegate
                        labelPositioning: ViewSection.InlineLabels + ViewSection.CurrentLabelAtStart + ViewSection.NextLabelAtEnd
                    }


                    delegate: Item {
                        id: popupListDelegate

                        width: popupListView.width
                        height: itemColumn.height

                        MouseArea {
                            anchors {
                                fill: parent
                            }

                            hoverEnabled: true

                            onClicked: {
                                if (popup) {
                                    showFeaturePopup(index);
                                }
                                //                        popupPanel.clear();
                            }

                            Rectangle {
                                anchors.fill: parent
                                visible: popup && (parent.pressed || parent.containsMouse)
                                color: "lightgrey"
                            }
                        }

                        Column {
                            id: itemColumn

                            width: parent.width
                            spacing: 2

                            Row {
                                id: itemRow

                                width: parent.width
                                spacing: 2

                                Image {
                                    id: resultIcon

                                    anchors.verticalCenter: parent.verticalCenter
                                    source: icon
                                    height: popupPanel.delegateHeight
                                    width: source > "" ? height : 0
                                }

                                Text {
                                    id: popupLabelText

                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - resultIcon.width - parent.spacing * 2 - resultDetailsButton.width
                                    text: label
                                    wrapMode: Text.WordWrap
                                    font  {
                                        pointSize: 17
                                    }

                                    color: app.darkTextColor //index == popupListView.currentIndex ? "#4c4c4c" : "#f7f8f8"

                                    onLinkActivated: {
                                        Qt.openUrlExternally(link);
                                    }
                                }

                                ImageButton {
                                    id: resultDetailsButton

                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: popup
                                    source: "images/right2.png"
                                    height: 40 * AppFramework.displayScaleFactor
                                    width: visible > "" ? height : 0

                                    onClicked: {
                                        showFeaturePopup(index);
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: "#304c4c4c"
                            }
                        }
                    }

                    /*
                    highlight: Rectangle {
                        width: popupListView.width
                        height: popupPanel.delegateHeight
                        color: "#80f7f8f8"
                        radius: 3
                        y: ListView.view ? ListView.view.currentItem.y : 0;
                        Behavior on y {
                            SmoothedAnimation {
                                duration: 200
                            }
                        }
                    }
                */
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: sectionDelegate

        Rectangle {
            width: popupListView.width
            height: childrenRect.height
            color: "#7f8183"


            Image {
                id: categoryImage

                anchors {
                    left: parent.left
                    top: parent.top
                }

                source: categoryImageSource(section)
                height: delegateHeight * 0.80
                width: height
                fillMode: Image.PreserveAspectFit
            }

            Text {
                anchors {
                    left: categoryImage.right
                    leftMargin: 2
                    right: parent.right
                    top: parent.top
                }

                text: categoryText(section)
                color: app.lightTextColor
                font {
                    pixelSize: categoryImage.height * 0.75
                    bold: true
                }
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
            }
        }
    }

    function categoryImageSource(section) {
        var category = Number(section);

        switch (category) {
        case webMapIdentify.categoryAddress:
            return "images/address.png"
        }

        return "";
    }

    function categoryText(section) {
        var category = Number(section);

        switch (category) {
        case webMapIdentify.categoryAddress:
            return qsTr("Address")
        }

        var layerIndex = Math.floor(category / 1000);
        var subLayerIndex = category - layerIndex * 1000;

        var opLayer = webMapIdentify.webMap.webMapInfo.operationalLayers[layerIndex];
        if (!opLayer) {
            return "No layer:" + section;
        }

        if (!opLayer.layers) {
            return opLayer.title;
        }

        var opSubLayer = opLayer.layers[subLayerIndex];

        console.log("categoryText", opLayer.id);
        var layer = webMapIdentify.webMap.layerByName(opLayer.id);
        var subLayer = layer.subLayerById(Number(opSubLayer.id));

        return subLayer.name;
    }
}
