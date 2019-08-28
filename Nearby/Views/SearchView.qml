import QtQuick 2.9
import QtQuick.Controls 2.5 as NewControls
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Esri.ArcGISRuntime 100.5
import QtGraphicalEffects 1.0

import "../Widgets"

NewControls.Page {
    id: root

    property real selectedCategory: -1
    property bool isSuggestion: false
    property alias searchTextField: searchTextField
    property string currentSearchCategory: ""
    property string currentSearchCategoryLowercase: ""
    onIsSuggestionChanged: {
        if(!isSuggestion) {
            clearResults ();
            geocodeAddress();
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id:header

            property double searchBarControlsOpacity: 0.6
            color: app.toolbarColor;
            Layout.preferredHeight: 56 * app.scaleFactor
            Layout.fillWidth: true

            CustomTextField {
                id: customTextField
                height: parent.height - 16 * app.scaleFactor
                width: Math.min(600*app.scaleFactor, parent.width) - 16 * app.scaleFactor
                anchors.centerIn: parent

                RowLayout {
                    property double searchBarControlsOpacity: 0.6
                    anchors.fill: parent

                    CustomizedToolButton {
                        Layout.fillHeight: true
                        Layout.preferredHeight: parent.height
                        opacity: header.searchBarControlsOpacity
                        imageSource: "../Assets/images/ic_arrow_back_black_48dp.png"
                        onClicked: {
                            close();
                            searchTextField.text = "";
                        }
                    }

                    NewControls.TextField {
                        id: searchTextField

                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Material.accent: app.primaryColor
                        placeholderText: strings.searchPlaceHolder
                        bottomPadding: topPadding
                        color: app.textColor
                        background: Rectangle {
                            color: "transparent"
                            border.color: "transparent"
                        }

                        onAccepted: {
                            currentSearchCategory = "";
                            currentSearchCategoryLowercase = "";
                            Qt.inputMethod.hide();
                            searchTextField.focus = false;
                            close();
                            selectedCategory = -1;
                            isSuggestion = false;
                            clearResults();
                            geocodeParameters.categories = ["POI"];
                            if(!isInListMode) {
                                isShowBackground = false;
                            }
                            geocodeAddress();
                        }

                        onFocusChanged: {
                            if(!focus){
                                Qt.inputMethod.hide();
                            } else {
                                if(searchTextField.text>""){
                                    isShowBackground = true;
                                }
                            }
                        }

                        onTextChanged: {
                            isSuggestion = true;
                            selectedCategory = -1;
                        }
                    }

                    CustomizedToolButton {
                        Layout.fillHeight: true
                        Layout.preferredHeight: parent.height
                        opacity: header.searchBarControlsOpacity
                        imageSource: sources.closeBlackIcon
                        visible: searchTextField.text > ""

                        onClicked: {
                            searchTextField.text = "";
                            searchTextField.focus = true;
                        }
                    }
                }
            }
        }

        Item {
            Layout.preferredWidth: Math.min(600*app.scaleFactor, parent.width)
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter

            NewControls.Label {
                id: explore

                text: strings.tapOnCategory
                font.pixelSize: 22 * app.scaleFactor
                width: parent.width
                height: 16 * app.scaleFactor
                anchors.top: parent.top
                padding: 16 * app.scaleFactor
                horizontalAlignment: NewControls.Label.AlignLeft
                visible: locatorTask.suggestions.count === 0 && !(searchTextField.text > "")
            }

            RowLayout {
                id: row1

                anchors.top: explore.bottom
                width: parent.width
                height: 84 * app.scaleFactor
                visible: locatorTask.suggestions.count === 0 && !(searchTextField.text > "")

                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 64 * app.scaleFactor

                    SearchCategoryItem {
                        width: 56 * app.scaleFactor
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconColor: app.secondaryColor
                        backgroundColor: colors.foodColor
                        iconUrl: sources.restaurantIcon
                        title: strings.food

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchCategory ("Food", 0);
                                currentSearchCategory = strings.food;
                                currentSearchCategoryLowercase = strings.foodLowercase;
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 64 * app.scaleFactor

                    SearchCategoryItem {
                        width: 56 * app.scaleFactor
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconColor: app.secondaryColor
                        backgroundColor: colors.cinemaColor
                        iconUrl: sources.cinemaIcon
                        title: strings.cinema

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchCategory ("Cinema", 1);
                                currentSearchCategory = strings.cinema;
                                currentSearchCategoryLowercase = strings.cinemaLowercase;
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 64 * app.scaleFactor

                    SearchCategoryItem {
                        width: 56 * app.scaleFactor
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconColor: app.secondaryColor
                        backgroundColor: colors.hotelColor
                        iconUrl: sources.hotelIcon
                        title: strings.hotel

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchCategory ("Hotel", 2);
                                currentSearchCategory = strings.hotel;
                                currentSearchCategoryLowercase = strings.hotelLowercase;
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 64 * app.scaleFactor

                    SearchCategoryItem {
                        width: 56 * app.scaleFactor
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconColor: app.secondaryColor
                        backgroundColor: colors.libraryColor
                        iconUrl: sources.libraryIcon
                        title: strings.library

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchCategory ("Library", 3);
                                currentSearchCategory = strings.library;
                                currentSearchCategoryLowercase = strings.libraryLowercase;
                            }
                        }
                    }
                }
            }

            RowLayout {
                id: row2

                anchors.top: row1.bottom
                width: parent.width
                height: 84 * app.scaleFactor
                visible: locatorTask.suggestions.count === 0 && !(searchTextField.text > "")

                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 64 * app.scaleFactor

                    SearchCategoryItem {
                        width: 56 * app.scaleFactor
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconColor: app.secondaryColor
                        backgroundColor: colors.hospitalColor
                        iconUrl: sources.hospitalIcon
                        title: strings.hospital

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchCategory ("Hospital", 4);
                                currentSearchCategory = strings.hospital;
                                currentSearchCategoryLowercase = strings.hospitalLowercase;
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 64 * app.scaleFactor

                    SearchCategoryItem {
                        width: 56 * app.scaleFactor
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconColor: app.secondaryColor
                        backgroundColor: colors.bankColor
                        iconUrl: sources.atmIcon
                        title: strings.bank

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchCategory ("Bank", 5);
                                currentSearchCategory = strings.bank;
                                currentSearchCategoryLowercase = strings.bankLowercase;
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 64 * app.scaleFactor

                    SearchCategoryItem {
                        width: 56 * app.scaleFactor
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconColor: app.secondaryColor
                        backgroundColor: colors.shopColor
                        iconUrl: sources.shopsIcon
                        title: strings.shops

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchCategory ("Shops and Service", 6);
                                currentSearchCategory = strings.shopsAndServices;
                                currentSearchCategoryLowercase = strings.shopsAndServicesLowercase;
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 64 * app.scaleFactor

                    SearchCategoryItem {
                        width: 56 * app.scaleFactor
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        iconColor: app.secondaryColor
                        backgroundColor: colors.gasStationColor
                        iconUrl: sources.gasIcon
                        title: strings.gas

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                searchCategory ("Gas Station", 7);
                                currentSearchCategory = strings.gas;
                                currentSearchCategoryLowercase = strings.gasLowercase;
                            }
                        }
                    }
                }
            }

            ListView{
                id: searchSuggestionsListView

                anchors.top: row2.bottom
                visible: locatorTask.suggestions.count > 0
                anchors.fill: parent
                clip: true
                model: locatorTask.suggestions
                spacing: 0

                delegate: Item {
                    width: parent.width
                    height: 50 * app.scaleFactor

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
                                source: sources.searchBlackIcon
                                mipmap: true
                                opacity: 0.4
                            }
                        }

                        NewControls.Label{
                            anchors.fill: parent
                            verticalAlignment: NewControls.Label.AlignVCenter
                            elide: NewControls.Label.ElideRight
                            clip: true
                            font.pixelSize: 13*app.scaleFactor
                            leftPadding: 50*app.scaleFactor
                            rightPadding: 40*app.scaleFactor
                            text: locatorTask.suggestions && locatorTask.suggestions.get(index)? locatorTask.suggestions.get(index).label : ""
                            opacity: 0.9
                        }

                        Ink{
                            anchors.fill: parent
                            onClicked: {
                                Qt.inputMethod.hide();
                                searchTextField.focus = false;
                                searchTextField.text = locatorTask.suggestions.get(index).label;
                                close();
                                clearResults();
                                geocodeAddress();
                            }
                        }

                        Rectangle{
                            width: parent.width-50*app.scaleFactor
                            height: 1
                            color: "#19000000"
                            visible: index != locatorTask.suggestions.count-1
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                    }
                }
            }
        }
    }

    function searchCategory (category, index) {
        selectedCategory = index;
        geocodeParameters.categories = [category];
        Qt.inputMethod.hide();
        searchTextField.focus = false;
        searchTextField.text = "";
        mapView.removeAllGraphics();
        resultListModel.clear();
        close();
        geocodeAddress();
    }
     function close() {
        root.visible = false;
     }
     function open() {
        root.visible = true;
     }
}
