import QtQuick 2.2
import QtQuick.Controls 1.1
import QtPositioning 5.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

import "Helper.js" as Helper

ListView {
    id: resultsListView

    property WebMapSearch webMapSearch

    property color unselectedTextColor: app.darkTextColor
    property color selectedTextColor: "lightgrey"
    property color highlightColor: "#4c4c4c"
    property color resultsBackgroundColor: "#f0e5e6e7"
    property real delegateHeight: 40 * AppFramework.displayScaleFactor
    property int visibleRows: 5
    property alias currentIndex: resultsListView.currentIndex
    property alias currentItem: resultsListView.currentItem
    property var currentData: webMapSearch.resultsModel.get(currentIndex)

    signal clicked();
    signal doubleClicked()
    signal actionClicked(ImageButton button)
    signal moreClicked(var resultItem)

    
    model: webMapSearch.resultsModel
    highlightFollowsCurrentItem: true
    currentIndex: -1
    
    onCurrentIndexChanged: {
        updateLayer();
    }
    
    section {
        property: "category"
        criteria: ViewSection.FullString
        delegate: resultsSectionDelegate
        labelPositioning: ViewSection.InlineLabels + ViewSection.CurrentLabelAtStart + ViewSection.NextLabelAtEnd
    }
    
    delegate: resultItemDelegate
    highlight: resultHighlightDelegate

    //--------------------------------------------------------------------------

    function updateLayer() {
        if (currentIndex < 0) {
            return;
        }

        resultsLayer.removeAllGraphics();

        var result = model.get(currentIndex);

        resultsLayer.clearCurrent();

        if (result) {
            if (result.geometry) {
                var graphic = ArcGISRuntime.createObject("Graphic",
                                                     { json: {
                                                             geometry: result.geometry
                                                         }
                                                     });
                webMapSearch.webMap.panTo(graphic.geometry);
                resultsLayer.setCurrent(graphic);
            }
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: webMapSearch

        onResultsReady: {
            currentIndex = -1;
            //            resultsListView.currentIndex = 0;
        }

        onResultUpdated: {
            if (currentIndex == index) {
                currentIndex = -1;
                currentIndex = index;
            } else {
                updateLayer();
            }

            clicked();
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: resultsSectionDelegate

        Rectangle {
            width: resultsListView.width
            height: childrenRect.height
            color: "#7f8183"


            Image {
                id: categoryImage

                anchors {
                    left: parent.left
                    top: parent.top
                }

                source: categoryImageSource(section)
                height: delegateHeight * 0.65
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
        case webMapSearch.categoryPlaces:
            return "images/address.png"

        case webMapSearch.categorySuggestions:
            return "images/suggestions.png"

        case webMapSearch.categoryRecentSearches:
            return "images/recentSearches.png"
        }

        return "";

//        var searchInfo = webMap.searchInfo.layers[category];
//        var layer = webMap.layerByIndex(searchInfo.id);
        // var subLayer = layer.subLayerById(searchInfo.subLayer);
    }

    function categoryText(section) {
        var category = Number(section);

        switch (category) {
        case webMapSearch.categoryPlaces:
            return qsTr("Places")

        case webMapSearch.categorySuggestions:
            return qsTr("Suggestions")

        case webMapSearch.categoryRecentSearches:
            return qsTr("Recent searches")

        case -3:
            return "Collection";
        }

        if (!webMap.searchInfo) {
            return "Category:" + category.toString();
        }

        var searchInfo = webMap.searchInfo.layers[category];
        if (!searchInfo) {
            return "No searchinfo:" + category.toString();
        }


        var layer = webMap.layerByName(searchInfo.id.toString());
        if (layer) {
            if (Object(searchInfo).hasOwnProperty("subLayer")) {
                var subLayer = layer.subLayerById(Number(searchInfo.subLayer));
                if (subLayer) {
                    return subLayer.name;
                }
            }
        }

        var opLayer = webMap.findOperationalLayer(searchInfo.id);
        if (opLayer) {
            return opLayer.title;
        }

        return category.toString() + ":" + searchInfo.id.toString();
    }

    //--------------------------------------------------------------------------

    Component {
        id: resultHighlightDelegate

        Rectangle {
            width: resultsListView.width
            height: ListView.view && ListView.view.currentItem ? ListView.view.currentItem.height : 0; // delegateHeight
            color: highlightColor
            radius: 3
            y: ListView.view && ListView.view.currentItem ? ListView.view.currentItem.y : 0;
            Behavior on y {
                //SpringAnimation { spring: 2; damping: 0.1 }
                SmoothedAnimation {
                    duration: 200
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: resultItemDelegate

        Item {
            width: parent.width
            height: Math.max(resultsListView.delegateHeight + 5, itemColumn.height)


            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (resultsListView.currentIndex == index) {
                        resultsListView.currentIndex = -1;
                    }

                    resultsListView.currentIndex = index;
                    resultsListView.clicked();
                }

                onDoubleClicked: {
                    mouse.accepted = true;

                    if (resultsListView.currentIndex == index) {
                        resultsListView.currentIndex = -1;
                    }

                    resultsListView.currentIndex = index;
                    resultsListView.doubleClicked();
                }
            }

            ImageButton {
                id: actionButton

                anchors {
                    left: parent.left
                    top: parent.top
                    margins: 3
                }

                visible: false // TODO implement later

                height: resultsListView.delegateHeight
                width: height / 2
                source: resultsListView.currentIndex == index && currentData
                        ? ((currentData.geometry && currentData.geometry.x && currentData.geometry.y) ? "images/listActions.png" : "")
                        : ""

                onClicked: {
                    currentIndex = index;
                    resultsListView.actionClicked(this);
                }
            }

            Column {
                id: itemColumn

                anchors {
                    left: actionButton.right
                    leftMargin: 3
                    right: parent.right
                }

                spacing: 2

                Row {
                    id: itemRow

                    width: parent.width

                    spacing: 2

                    Image {
                        id: resultIcon

                        source: icon
                        height: resultsListView.delegateHeight
                        width: source > "" ? height : 0
                        fillMode: Image.PreserveAspectFit
                    }

                    Column {
                        spacing: 3

                        width: parent.width - resultIcon.width - parent.spacing - moreIcon.width

                        Text {
                            id: resultText

                            width: parent.width
                            text: displayText
                            color: resultsListView.currentIndex == index ? selectedTextColor : unselectedTextColor
                            font {
                                pointSize: 16
                            }
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideNone

                            onLinkActivated: {
                                Qt.openUrlExternally(link);
                            }
                        }

                        Text {
                            id: distanceText

                            width: parent.width
                            text: Helper.niceDistance(distance)
                            visible: text > ""
                            color: resultText.color
                            font {
                                pointSize: 11
                                italic: true
                            }
                        }
                    }

                    ImageButton {
                        id: moreIcon

                        source: "images/right2.png"
                        height: resultsListView.delegateHeight
                        width: visible > "" ? height : 0
                        visible: hasPopup(index)

                        function hasPopup(i) {
                            if (i < 0) {
                                return false;
                            }

                            var item = resultsListView.model.get(i);

                            return item.info.hasOwnProperty("popupInfo");
                        }

                        onClicked: {
                            currentIndex = index;
                            moreClicked(resultsListView.model.get(index));
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
    }

    //--------------------------------------------------------------------------
}
