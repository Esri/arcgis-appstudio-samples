import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.WebView 1.0
import Esri.ArcGISRuntime 100.2

import QtPositioning 5.3
import QtSensors 5.3

import "../Controls"
import "../Assets"
import "../Widgets"

Item {
    id: geocodeView
    property var currentPoint
    property bool isShowBackground: false
    property bool isSuggestion: true
    property alias searchText: searchTextField.text
    property int selectedIndex
    signal resultSelected(var result)

    onSearchTextChanged:  {
        if(mapArea.currentLocatorTask !== null) mapArea.currentLocatorTask.suggestions.searchText = searchText;
    }

    onResultSelected: {
        mapArea.geocodeSuggestion(result);
    }

    Rectangle{
        id: background
        anchors.fill: parent
        color: "#ededed"
        opacity: isShowBackground? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }

    onIsSuggestionChanged: {
        if(!isSuggestion) {
            mapArea.geocodeAddress();
        }
    }

    ColumnLayout{
        width: Math.min(600 * app.scaleFactor, parent.width) - 16 * app.scaleFactor
        height: parent.height - 32 * app.scaleFactor
        anchors.centerIn: parent

        CustomizedPane{
            Layout.fillWidth: true
            Layout.preferredHeight: 48*app.scaleFactor
            Material.elevation: 2
            padding: 0

            RowLayout{
                anchors.fill: parent
                property double searchBarControlsOpacity: 0.6
                CustomizedToolButton {
                    Layout.fillHeight: true
                    Layout.preferredHeight: parent.height
                    opacity: parent.searchBarControlsOpacity
                    imageSource: isShowBackground? sources.backArrowIcon : sources.searchIcon
                    onClicked: {
                        if(isShowBackground) {
                            isShowBackground = false;
                        } else {
                            searchTextField.forceActiveFocus();
                        }
                    }
                }
                TextField {
                    id: searchTextField
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Material.accent: app.primaryColor
                    placeholderText: strings.search + " " + mapArea.mmpkName
                    focusReason: Qt.PopupFocusReason
                    bottomPadding: topPadding
                    background: Rectangle {
                        color: "transparent"
                        border.color: "transparent"
                    }
                    onAccepted: {
                        if(isSuggestion){
                            Qt.inputMethod.hide();
                            focus = false;
                            isSuggestion = false;
                        }
                    }
                    onFocusChanged: {
                        if(!focus){
                            Qt.inputMethod.hide();
                        } else {
                            if(searchTextField.text > ""){
                                isShowBackground = true;
                            }
                        }
                    }
                    onTextChanged: {
                        if(text > "" && !isShowBackground) isShowBackground = true;
                        isSuggestion = true;
                    }
                }

                CustomizedToolButton {
                    Layout.fillHeight: true
                    Layout.preferredHeight: parent.height
                    opacity: parent.searchBarControlsOpacity
                    visible: searchTextField.text > ""
                    imageSource: sources.clearIcon
                    onClicked: {
                        searchTextField.clear();
                    }
                }
            }
        }

        CustomizedPane{
            id: searchResultsListviewContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Material.elevation: 2
            visible: mapArea.currentLocatorTask !== null && mapArea.currentLocatorTask.suggestions.count>0 && isShowBackground
            padding: 0

            ListView{
                id: searchResultListView
                anchors.fill: parent
                clip: true
                model: isSuggestion && mapArea.currentLocatorTask !== null? mapArea.currentLocatorTask.suggestions:resultListModel
                spacing: 0
                delegate: Item {
                    width: parent.width
                    height: 50*app.scaleFactor
                    Item {
                        anchors.fill: parent
                        Item{
                            width: parent.height
                            height: parent.height
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            Image{
                                anchors.fill: parent
                                anchors.margins: parent.width*0.30
                                anchors.centerIn: parent
                                source: sources.searchIcon
                                mipmap: true
                                opacity: 0.4
                            }
                        }

                        Label{
                            anchors.fill: parent
                            verticalAlignment: Label.AlignVCenter
                            elide: Label.ElideRight
                            clip: true
                            font.pixelSize: 13*app.scaleFactor
                            leftPadding: 50*app.scaleFactor
                            rightPadding: 40*app.scaleFactor
                            text: isSuggestion? (mapArea.currentLocatorTask.suggestions && mapArea.currentLocatorTask.suggestions.get(index)? mapArea.currentLocatorTask.suggestions.get(index).label : ""):""
                            opacity: 0.9
                        }

                        RippleView{
                            anchors.fill: parent
                            onClicked: {
                                Qt.inputMethod.hide();
                                searchTextField.focus = false;
                                searchTextField.text = mapArea.currentLocatorTask.suggestions.get(index).label;
                                isShowBackground = true;
                                resultSelected(currentLocatorTask.suggestions.get(index));
                            }
                        }

                        Rectangle{
                            width: parent.width-50*app.scaleFactor
                            height: 1
                            color: "#19000000"
                            visible: index != mapArea.currentLocatorTask.suggestions.count-1
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !searchResultsListviewContainer.visible
        }
    }

    ListModel{
        id: resultListModel
    }

    BrowserView {
        id: browserView

        anchors.fill: parent
        primaryColor: app.primaryColor
        foregroundColor: app.secondaryColor
    }

    function openBrowserView (url) {
        browserView.url = url;
        browserView.show();
    }
}
