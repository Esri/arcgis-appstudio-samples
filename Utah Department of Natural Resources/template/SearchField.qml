import QtQuick 2.3
import QtQuick.Controls 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

InputField {
    property WebMapSearch webMapSearch

    placeholderText: webMapSearch.info ? webMapSearch.info.hintText : qsTr("Find address or place")

    property alias searchTimeout: searchTimer.interval

    font {
        pixelSize: height * 0.72
    }

    leftButton {
        source:  "images/search.png"
        visible: true
        enabled: text > ""

        onClicked: {
            webMapSearch.executeSearch(text, webMapSearch.queryResults);
        }
    }

    onEditingFinished: {
        if (!webMapSearch.queryResults) {
            search();
        }
    }

    onTextChanged: {
        webMapSearch.clear();

        if (text > "") {
            if (webMapSearch.canSearchPlaces) {
                webMapSearch.suggest(text);
            }

            if (searchTimeout) {
                searchTimer.restart();
            }
        } else {
            searchTimer.running = false;
            webMapSearch.addRecentSearches();
        }
    }

    onCleared: {
        searchTimer.running = false;
        webMapSearch.clear();
        webMapSearch.addRecentSearches();
    }

    function search() {
        if (text > "") {
            webMapSearch.executeSearch(text, webMapSearch.queryResults);
        }
    }

    Timer {
        id: searchTimer

        interval: 3000
        running: false
        repeat: false

        onTriggered: {
            console.log("Search timer triggered");
            if (!webMapSearch.queryResults) {
                search();
            }
        }
    }

    BusyIndicator {
        visible: webMapSearch.searching
        running: visible
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: height
    }
}
