import QtQuick 2.7

SearchView {
    id: searchFeaturesView

    objectName: "searchFeaturesView"
    defaultSearchViewTitleText: qsTr("Search for features")
    searchViewTitleText: defaultSearchViewTitleText
    sectionPropertyAttr: "layerName"

    listView.delegate: SearchResultsDelegate {
        title: typeof search_attr !== "undefined" ? search_attr : ""

        onClicked: {
            listView.model.currentIndex = initialIndex
            searchResultSelected(listView.model.features[initialIndex], initialIndex, sizeState === "")
        }
    }
}
