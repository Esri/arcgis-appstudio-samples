import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0

import "../Widgets"

Page {
    id: root

    property string selectedItemId: ""

    property var itemDetails

    property int nextStart: 1
    property bool isPageLoading: false
    property bool isNextPageLoading: false
    property int totalResultCount: 0
    property bool isMyApps: true

    signal next()
    signal back()

    ColumnLayout {
        id: bodyColumnLayout
        width: Math.min(parent.width, maximumScreenWidth)
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        Item {
            Layout.preferredWidth: parent.width - 32 * scaleFactor
            Layout.preferredHeight: 25 * scaleFactor
        }

        Label {
            Layout.preferredWidth: parent.width - 32 * scaleFactor
            Layout.alignment:Qt.AlignHCenter
            text: strings.step_no.arg(2)
            font {
                weight: Font.Normal
                pixelSize: 24 * scaleFactor
            }
            color: colors.primary_color
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 8 * scaleFactor
        }

        Label {
            Layout.preferredWidth: parent.width - 32 * scaleFactor
            Layout.alignment: Qt.AlignHCenter
            text: strings.step2_description
            font {
                weight: Font.Normal
                pixelSize: 14 * scaleFactor
            }
            color: colors.black_54
            wrapMode: Label.Wrap
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16 * scaleFactor
        }

        Rectangle {
            id: contentInfo

            Layout.fillWidth: true
            Layout.preferredHeight: 48 * scaleFactor

            color: colors.default_content_color

            RowLayout {
                width: parent.width - 32 * scaleFactor
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 0

                Label {
                    text: strings.step2_showing.arg(contentModel.count).arg(totalResultCount)
                    visible: totalResultCount > 0 && contentModel.count > 0
                    font {
                        weight: Font.Normal
                        pixelSize: 12 * scaleFactor
                    }
                    color: colors.black_54
                    wrapMode: Label.Wrap
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: container.width

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            optionMenu.x = contentInfo.x + contentInfo.width - optionMenu.width - 16 * scaleFactor;
                            optionMenu.y = contentInfo.y + 12 * scaleFactor;
                            optionMenu.open();
                        }
                    }

                    RowLayout {
                        id: container

                        height: parent.height

                        Label {
                            text: isMyApps ? strings.step2_myapps : strings.step2_allapps
                            font {
                                weight: Font.Medium
                                pixelSize: 14 * scaleFactor
                            }
                            color: colors.black_87
                            wrapMode: Label.Wrap
                        }

                        Item {
                            Layout.preferredWidth: 4 * scaleFactor
                            Layout.fillHeight: true
                        }

                        IconImage {
                            Layout.preferredWidth: 15 * scaleFactor
                            Layout.preferredHeight: 15 * scaleFactor
                            source: sources.arrow_left
                            color: "#007472"
                            rotation: 270
                        }
                    }
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            clip: true

            model: contentModel

            BusyIndicator {
                visible: running
                running: isPageLoading && !isNextPageLoading
                anchors.centerIn: parent
                Material.accent: colors.primary_color
            }

            footer: Item {
                width: parent.width
                height: 56 * scaleFactor
                visible: isNextPageLoading

                BusyIndicator {
                    anchors.centerIn: parent
                    running: isNextPageLoading
                    Material.accent: colors.primary_color
                }
            }

            onAtYEndChanged: {
                if(atYEnd && contentY > 0 && !isNextPageLoading && model.count < totalResultCount) {
                    isNextPageLoading = true;
                    getContents(nextStart);
                }
            }

            delegate: Item {
                width: parent.width
                height: 84 * scaleFactor

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectedItemId = itemId;
                        itemDetails = details;
                    }
                }

                Rectangle {
                    width: Math.min(parent.width, maximumScreenWidth - 32 * scaleFactor)
                    height: 1
                    color: "#1F000000"
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                RowLayout {
                    width: parent.width - 32 * scaleFactor
                    height: 52 * scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Image {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 78 * scaleFactor
                        source: thumbnail > "" && status != Image.Error ? thumbnail : sources.placeholder
                        fillMode: Image.PreserveAspectFit
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 16 * scaleFactor
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        ColumnLayout {
                            width: parent.width
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0

                            Label {
                                Layout.fillWidth: true
                                text: title
                                leftPadding: rightPadding
                                rightPadding: 0
                                font {
                                    weight: Font.Normal
                                    pixelSize: 14 * scaleFactor
                                }
                                color: colors.black_87
                                clip: true
                                elide: Label.ElideRight
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 4 * scaleFactor
                            }

                            Label {
                                Layout.fillWidth: true
                                text: owner
                                leftPadding: rightPadding
                                rightPadding: 0
                                font {
                                    weight: Font.Normal
                                    pixelSize: 12 * scaleFactor
                                }
                                color: colors.black_54
                                clip: true
                                elide: Label.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                text: modified
                                leftPadding: rightPadding
                                rightPadding: 0
                                font {
                                    weight: Font.Normal
                                    pixelSize: 12 * scaleFactor
                                }
                                color: colors.black_54
                                clip: true
                                elide: Label.ElideRight
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 16 * scaleFactor
                    }

                    IconImage {
                        Layout.preferredWidth: 21 * scaleFactor
                        Layout.preferredHeight: 21 * scaleFactor
                        Layout.alignment: Qt.AlignVCenter
                        color: colors.primary_color
                        source: itemId === selectedItemId ? sources.radio_checked : sources.radio_unchecked
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 4 * scaleFactor
                    }
                }
            }
        }
    }

    footer: NavigatorFooter {
        id: navigatorFooter

        isNextEnabled: selectedItemId > ""

        onBack: {
            root.back();
        }

        onNext: {
            root.next();
        }
    }

    ListModel {
        id: contentModel
    }

    function refresh(){
        nextStart = 1;
        isPageLoading = false;
        isNextPageLoading = false;
        contentModel.clear();

        getContents(nextStart);
    }

    function getContents(start){
        networkManager.getApps(start, isMyApps, function(response){
            nextStart = response.nextStart;
            totalResultCount = response.total;

            if (response.hasOwnProperty("results")) {
                var results = response.results;

                if(results.length > 0) {
                    var result;

                    for(var i in results) {
                        result = results[i];

                        var thumbnail = "", itemId = "", modified = "", owner = "", title = "";

                        if(result.hasOwnProperty("id") && result.id !== null) itemId = result.id;
                        if(result.hasOwnProperty("modified") && result.modified !== null) {
                            modified = timeConvert(result.modified);
                            result.modified = modified;
                        }
                        if(result.hasOwnProperty("owner") && result.owner !== null) owner = result.owner;
                        if(result.hasOwnProperty("title") && result.title !== null) title = result.title;
                        if(result.hasOwnProperty("thumbnail") && result.thumbnail !== null) {
                            var thumbnailId = result.thumbnail;

                            if(thumbnailId > "") {
                                thumbnail = networkManager.rootUrl + "/sharing/rest/content/items/"
                                        + itemId + "/info/" + thumbnailId + "?token=" + networkManager.token;
                                result.thumbnail = thumbnail;
                            }
                        }

                        contentModel.append({itemId: itemId, modified: modified, owner: owner, title: title, thumbnail: thumbnail, details: result});
                    }

                    isNextPageLoading = false;
                }
            }

            isPageLoading = false;
        })
    }

    function timeConvert(unixTime) {
        var modifiedDate = "";

        var currentTime = new Date().getTime();

        if (currentTime >= unixTime) {
            var timeDifference = currentTime - unixTime;
            var minuteDifference = Math.floor(timeDifference / 60 / 1000);
            var hourDifference = Math.floor(timeDifference / 60 / 60 / 1000);
            var dayDifference = Math.floor(timeDifference / 60 / 60 / 24 / 1000);
            var weekDifference = Math.floor(timeDifference / 60 / 60 / 24 / 7 / 1000);

            // if less than a day
            if (dayDifference < 1) {
                if (minuteDifference < 1) {
                    modifiedDate = strings.just_now;
                } else if (hourDifference < 1) {
                    if (minuteDifference < 2) {
                        modifiedDate = strings.single_minute;
                    } else {
                        modifiedDate = strings.multi_minutes.arg(minuteDifference);
                    }
                } else {
                    if (hourDifference < 2) {
                        modifiedDate = strings.single_hour;
                    } else {
                        modifiedDate = strings.multi_hours.arg(hourDifference);
                    }
                }
            } else if (dayDifference < 7) {
                if (dayDifference < 2) {
                    modifiedDate = strings.single_day;
                } else {
                    modifiedDate = strings.multi_days.arg(dayDifference);
                }
            } else if (weekDifference <= 4) {
                if (weekDifference < 2) {
                    modifiedDate = strings.single_week;
                } else {
                    modifiedDate = strings.multi_weeks.arg(weekDifference);
                }
            } else {
                modifiedDate = formatDate(unixTime);
            }
        } else {
            modifiedDate = formatDate(unixTime);
        }

        return modifiedDate;
    }

    // Format the date
    function formatDate(unixTime) {
        var date = new Date(unixTime);

        var modifiedDate = date.toLocaleDateString(Qt.locale(), Locale.ShortFormat);

        return modifiedDate;
    }

    Menu {
        id: optionMenu
        width: 192 * scaleFactor
        padding: 0

        MenuItem {
            contentItem: Label {
                Layout.fillWidth: true
                text: strings.step2_myapps
                font {
                    weight: Font.Normal
                    pixelSize: 16 * scaleFactor
                }
                color: colors.black_87
                clip: true
                elide: Label.ElideRight
            }

            onTriggered: {
                isMyApps = true;
            }
        }

        MenuItem {
            contentItem: Label {
                Layout.fillWidth: true
                text: strings.step2_allapps
                font {
                    weight: Font.Normal
                    pixelSize: 16 * scaleFactor
                }
                color: colors.black_87
                clip: true
                elide: Label.ElideRight
            }

            onTriggered: {
                isMyApps = false;
            }
        }
    }

    onIsMyAppsChanged: {
        refresh();
    }

    Component.onCompleted: {
        isPageLoading = true;
        getContents(nextStart)
    }
}
