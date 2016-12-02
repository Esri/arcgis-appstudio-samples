import QtQuick 2.2
import QtQuick.Controls 1.1
import QtPositioning 5.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Rectangle {
    id: searchView

    property WebMapSearch webMapSearch
    property alias resultsView: resultsListView
    property alias searchField: actionsBar.searchField
    property bool fullScreen: false
    property StackView popupsStackView

    color: "transparent"

    function forceFocus() {
        actionsBar.searchField.forceActiveFocus();
    }

    onVisibleChanged: {
        actionSelect.hide();

        if (visible) {
            forceFocus();
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
        }
    }

    SearchActionsBar {
        id: actionsBar
        
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        
        height: (fullScreen ? 60 : 40) * AppFramework.displayScaleFactor
        inputMargin: fullScreen ? 10 : 5
        
        webMapSearch: searchView.webMapSearch
        
        backButton {
            visible: fullScreen

            onClicked: {
                hideSearch();
            }
        }
        
        closeButton {
            visible: false
        }
    }
    
    SearchResultsView {
        id: resultsListView
        
        anchors {
            left: parent.left
            right: parent.right
            top: actionsBar.bottom
            bottom: parent.bottom
            margins: 3
        }
        
        webMapSearch: searchView.webMapSearch

        clip: true

        onClicked: {
            if (currentData) {
                switch (currentData.category) {
                case webMapSearch.categoryRecentSearches:
                    searchField.text = currentData.displayText;
                    searchField.search();
                    currentIndex = -1;
                    break;

                case webMapSearch.categorySuggestions:
                    if (!isGeometry(currentData.geometry)) {
                        webMapSearch.updateSuggestion(currentData.displayText, currentData.info.magicKey);
                    } else if (fullScreen) {
                        hideSearch();
                    }
                    break;

                default:
                    if (fullScreen && isGeometry(currentData.geometry)) {
                        hideSearch();
                    }
                }
            }
        }

        onDoubleClicked: {
            if (zoomScale > 0) {
                webMapSearch.webMap.zoomToScale(zoomScale);
            }

            hideSearch();
        }

        onActionClicked: {
            actionSelect.button = button;
            actionSelect.currentData = currentData;
            actionSelect.visible = true;
            /*
            if (zoomScale > 0) {
                webMapSearch.webMap.zoomToScale(zoomScale);
            }

            if (fullScreen) {
                hideSearch();
            }

            if (isGeometry(currentData.geometry)) {
                var graphic = {
                    "geometry": currentData.geometry
                };

                droppedPinsLayer.addGraphic(graphic);
            }
            */
        }

        onMoreClicked: {
            var popup = resultPopup.createObject(null, { "resultItem": resultItem });
            popupsStackView.push(popup);
        }
    }

    function isGeometry(g) {
        return g && g.x && g.y;
    }

    Component {
        id: resultPopup

        Rectangle {
            property int index
            property var resultItem
            property var attributes: resultItem.info.feature.attributes
            property var popupInfo: resultItem.info.popupInfo

            color: app.featurePopupBackgroundColor

            WebMapPopupActionsBar {
                id: popupActionsBar

                height: (fullScreen ? 60 : 30) * AppFramework.displayScaleFactor

                title: fullScreen ? popupView.title : ""
                previousVisible: false
                nextVisible: false
                backText: fullScreen ? "" : "Search"
                backImage: fullScreen ? "images/left2.png" : "images/back.png"

                onBackClicked: {
                    parent.parent.pop();
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
                titleVisible: !fullScreen
            }

            Rectangle {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }

                visible: !fullScreen
                width: 1
                color: "darkgrey"
            }
        }
    }

    Rectangle {
        id: actionSelect

        property ImageButton button
        property rect buttonRect
        property var currentData

        anchors.fill: parent
        visible: false
        color: "transparent"

        onVisibleChanged: {
            if (!visible) {
                return;
            }

            buttonRect = button.mapToItem(this, button.x, button.y, button.width, button.height);
        }

        function hide() {
            visible = false;
        }


        MouseArea {
            anchors.fill: parent

            onClicked: {
                actionSelect.hide();
            }

            onWheel: {

            }
        }

        CalloutRectangle {
            originX: actionSelect.buttonRect.x + actionSelect.buttonRect.width / 2
            originY: actionSelect.buttonRect.y + actionSelect.buttonRect.height / 2

            anchors {
                left: parent.left
                leftMargin: 30
                top: parent.top
                topMargin: actionSelect.buttonRect.y - 10
            }

            height: actionsColumn.height + 10
            width: actionsColumn.width + 10
            color: "#80ffffff"

            Column {
                id: actionsColumn
                anchors {
                    centerIn: parent
                }

                spacing: 5

                Button {
                    text: "Drop pin"
                    iconSource: "images/pin_star_orange.png"

                    onClicked: {
                        if (zoomScale > 0) {
                            webMapSearch.webMap.zoomToScale(zoomScale);
                        }

                        if (fullScreen) {
                            hideSearch();
                        }

                        if (isGeometry(actionSelect.currentData.geometry)) {
                            var graphic = {
                                "geometry": actionSelect.currentData.geometry
                            };

                            droppedPinsLayer.addGraphic(graphic);
                            actionSelect.hide();
                        }
                    }
                }
            }
        }
    }
}
