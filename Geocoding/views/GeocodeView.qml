import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1

import QtPositioning 5.3
import QtSensors 5.3

import "../controls"

Item {
    id: geocodeView
    property var currentPoint
    property bool isShowBackground: false
    property bool isSuggestion: true

    property string currentLocatorTaskId: ""
    property string currentQueryTaskId:""
    property alias searchText: searchTextField.text

    signal resultSelected(var point)

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
            resultListModel.clear();
            geocodeAddress();
        }
    }

    ColumnLayout{
        width: Math.min(600*app.scaleFactor, parent.width)-16*app.scaleFactor
        height: parent.height-32*app.scaleFactor
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
                    imageSource: isShowBackground? "../images/ic_arrow_back_black_48dp.png" : "../images/ic_search_black_48dp.png"
                    onClicked: {
                        isShowBackground = false;
                    }
                }
                TextField {
                    id: searchTextField
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Material.accent: app.primaryColor
                    placeholderText: qsTr("Search Address")
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
                            if(searchTextField.text>""){
                                isShowBackground = true;
                            }
                        }
                    }
                    onTextChanged: {
                        if(text>"" && !isShowBackground) isShowBackground = true;
                        isSuggestion = true;
                    }
                }

                CustomizedToolButton {
                    Layout.fillHeight: true
                    Layout.preferredHeight: parent.height
                    opacity: parent.searchBarControlsOpacity
                    visible: searchTextField.text>""
                    imageSource: "../images/ic_close_black_48dp.png"
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
            visible: locatorTask.suggestions.count>0 && isShowBackground
            padding: 0

            ListView{
                id: searchResultListView
                anchors.fill: parent
                clip: true
                model: isSuggestion? locatorTask.suggestions:resultListModel
                spacing: 0
                delegate: Item {
                    width: parent.width
                    height: 50*app.scaleFactor
                    Item {
                        anchors.fill: parent
                        visible: isSuggestion
                        Item{
                            width: parent.height
                            height: parent.height
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            Image{
                                anchors.fill: parent
                                anchors.margins: parent.width*0.30
                                anchors.centerIn: parent
                                source: "../images/ic_search_black_48dp.png"
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
                            text: isSuggestion? (locatorTask.suggestions && locatorTask.suggestions.get(index)? locatorTask.suggestions.get(index).label : ""):""
                            opacity: 0.9
                        }

                        Ink{
                            anchors.fill: parent
                            onClicked: {
                                Qt.inputMethod.hide();
                                searchTextField.focus = false;
                                searchTextField.text = locatorTask.suggestions.get(index).label;
                                resultListModel.clear();
                                isSuggestion = false;
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
                    Item {
                        anchors.fill: parent
                        visible: !isSuggestion
                        Item{
                            width: parent.height
                            height: parent.height
                            anchors.left: parent.left
                            Image{
                                id: image
                                width: parent.width*0.40
                                height: width
                                anchors.top: parent.top
                                anchors.topMargin: parent.width*0.15
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: "../images/map-marker.png"
                                mipmap: true
                                opacity: 0.4
                            }
                            Label{
                                width: parent.width
                                height: parent.height*0.30
                                anchors.top: image.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                horizontalAlignment: Label.AlignHCenter
                                text: !isSuggestion? distanceText:""
                                font.pixelSize: titleLabel.font.pixelSize*0.85
                                opacity: 0.4
                            }
                        }

                        Label{
                            id: titleLabel
                            width: parent.width
                            height: parent.height*0.45
                            anchors.top: parent.top
                            anchors.topMargin: parent.height*0.10
                            padding: 0
                            font.pixelSize: 13*app.scaleFactor
                            verticalAlignment: Label.AlignVCenter
                            elide: Label.ElideRight
                            clip: true
                            leftPadding: 55*app.scaleFactor
                            rightPadding: 40*app.scaleFactor
                            text: !isSuggestion? name:""
                            opacity: 0.9
                        }

                        Label{
                            width: parent.width
                            height: parent.height*0.4
                            anchors.top: titleLabel.bottom
                            verticalAlignment: Label.AlignTop
                            elide: Label.ElideRight
                            clip: true
                            font.pixelSize: titleLabel.font.pixelSize*0.85
                            padding: 0
                            leftPadding: 55*app.scaleFactor
                            rightPadding: 40*app.scaleFactor
                            text: !isSuggestion? address:""
                            opacity: 0.6
                        }

                        Ink{
                            anchors.fill: parent
                            onClicked: {
                                Qt.inputMethod.hide();
                                searchTextField.focus = false;
                                var point = ArcGISRuntimeEnvironment.createObject("Point", JSON.parse(geometryJson));
                                isShowBackground = false;
                                resultSelected(point);
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

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !searchResultsListviewContainer.visible
        }
    }

    GeocodeParameters {
        id: geocodeParameters
        minScore: 75
        maxResults: 10
        preferredSearchLocation: currentPoint
        resultAttributeNames: ["Place_addr", "Match_addr", "Postal", "Region"]
    }

    LocatorTask {
        id: locatorTask
        url: "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
        suggestions.suggestParameters: SuggestParameters{
            maxResults: 10
            preferredSearchLocation: currentPoint
        }
        suggestions.searchText: searchTextField.text
        onGeocodeStatusChanged: {
            if (geocodeStatus === Enums.TaskStatusCompleted) {
                if(geocodeResults.length>0){
                    for(var i in geocodeResults) {
                        var e = geocodeResults[i];
                        var point = e.displayLocation;
                        point = GeometryEngine.project(point, currentPoint.spatialReference);
                        var pointJson = JSON.stringify(point.json);
                        var distance = GeometryEngine.distance(point, currentPoint);
                        var distanceInMile = (distance/1609.34);
                        distanceInMile = distanceInMile<10? distanceInMile.toFixed(2):distanceInMile.toFixed(0);
                        var distanceInFeet = (distance/0.3048).toFixed(0);
                        var distanceText = "";
                        if(distanceInMile<1000)distanceText = distanceInFeet < 528 ? distanceInFeet+qsTr(" ft") : distanceInMile+qsTr(" mi");
                        var name = e.label;
                        var address = e.attributes.Place_addr;
                        resultListModel.append({"name": name, "distanceText": distanceText, "address": address, "geometryJson": pointJson});
                    }
                }
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: locatorTask.loadStatus === Enums.LoadStatusLoading || locatorTask.geocodeStatus === Enums.TaskStatusInProgress
        Material.accent: "steelblue"
    }

    ListModel{
        id: resultListModel
    }

    function geocodeAddress() {
        if(currentLocatorTaskId > "" && locatorTask.loadStatus === Enums.LoadStatusLoading) locatorTask.cancelTask(currentLocatorTaskId);
        currentLocatorTaskId = locatorTask.geocodeWithParameters(searchTextField.text, geocodeParameters);
    }
}
