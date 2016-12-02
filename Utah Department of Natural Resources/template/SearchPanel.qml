import QtQuick 2.2
import QtQuick.Controls 1.1
import QtPositioning 5.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

DockPanel {
    id: searchPanel

    property WebMapSearch webMapSearch

    property alias resultsView: searchView.resultsView

    //--------------------------------------------------------------------------

    color: resultsView.resultsBackgroundColor
    clip: true
    border {
        color: "darkgrey"
        width: 1
    }

    visibleHeight: calcHeight(webMapSearch.resultsModel.count)
    visibleWidth: app.width * 0.35

    function calcHeight(rows) {
        return resultsView.delegateHeight * Math.min(rows, resultsView.visibleRows) + 6;
    }

    Behavior on height {
        SmoothedAnimation {
            duration: 250
        }
    }

    //--------------------------------------------------------------------------

    StackView {

        anchors {
            fill: parent
        }

        initialItem: SearchView {
            id: searchView

            webMapSearch: searchPanel.webMapSearch
            fullScreen: false
            popupsStackView: parent
        }
    }
}
