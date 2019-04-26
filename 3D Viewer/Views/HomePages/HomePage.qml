import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "../../Widgets" as Widgets

Page {
    id: homePage

    Material.background: colors.view_background

    property int total: 0
    property int nextStart: 1

    property bool isPageLoading: false
    property bool isNextPageLoading: false

    signal back()

    header: ToolBar {
        height: 56 * constants.scaleFactor
        Material.primary: colors.black
        Material.elevation: 0

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Label {
                    anchors.fill: parent

                    text: strings.web_scenes
                    color: colors.white
                    font.family: fonts.avenirNextDemi
                    font.pixelSize: 20 * constants.scaleFactor
                    elide: Text.ElideRight
                    clip: true

                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter

                    leftPadding: 16 * constants.scaleFactor
                    rightPadding: 16 * constants.scaleFactor
                }
            }

            Item {
                Layout.preferredWidth: 56 * constants.scaleFactor
                Layout.fillHeight: true

                visible: false

                Widgets.RoundedButton {
                    width: 40 * constants.scaleFactor
                    height: this.width
                    anchors.centerIn: parent

                    color: colors.transparent

                    source: images.settings_icon
                    iconColor: colors.white

                    isEnabled: false

                    onClicked: {
                        var settingsPage = components.settingsPageComponent.createObject(null);

                        stackView.push(settingsPage);
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16 * constants.scaleFactor
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView

                anchors.fill: parent
                spacing: 16 * constants.scaleFactor
                clip: true
                model: ListModel {}

                delegate: SceneDelegate {
                    id: delegate

                    width: Math.min(parent.width, appManager.maximumScreenWidth) - 32 * constants.scaleFactor
                    height: 104 * constants.scaleFactor

                    anchors.horizontalCenter: parent.horizontalCenter

                    defaultThumbnail: images.default_scene_icon

                    color: colors.black

                    onClicked: {
                        var infoPage = infoPageComponent.createObject(
                                    null,
                                    {
                                        sceneTitle: itemTitle,
                                        sceneUrl: appManager.schema.portalUrl + "/home/item.html?id=" + itemId
                                    });
                        infoPage.onClosed.connect(function() {
                            locationManager.stop();

                            infoPage.resetSceneView();

                            stackView.pop();
                        })
                        stackView.push(infoPage);
                    }
                }

                footer: Widgets.ProgressIndicator {
                    width: parent.width
                    height: 56 * constants.scaleFactor
                    visible: isNextPageLoading
                }

                onAtYEndChanged: {
                    if (atYEnd && contentY > 0 && !isNextPageLoading && listView.model.count < total) {
                        isNextPageLoading = true;

                        populateList();
                    }
                }
            }

            Label {
                anchors.fill: parent

                text: strings.empty_state_no_result
                clip: true
                elide: Text.ElideRight

                font.family: fonts.avenirNextDemi
                font.pixelSize: 16 * constants.scaleFactor
                color: colors.white

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                leftPadding: 16 * constants.scaleFactor
                rightPadding: 16 * constants.scaleFactor

                visible: listView.count === 0 && !isPageLoading
            }
        }
    }

    Widgets.ProgressIndicator {
        anchors.fill: parent
        visible: isPageLoading
    }

    Component.onCompleted: {
        initialize();
    }

    function initialize() {
        isPageLoading = true;

        populateList();
    }

    function populateList() {
        var _q = "type:web scene " + constants.q_filter + " %1".arg(appManager.schema.galleryWebSceneQuery);
        var _num = constants.loadingNumber;
        var _sortField = "modified";
        var _sortOrder = "desc";

        var _promise = new Promise(function(resolve, reject) {
            networkManager.requestWebScenes(_q, _num, nextStart, _sortField, _sortOrder, function(response) {
                try {
                    if (!homePage)
                        return;

                    var _results = [];

                    if (response.hasOwnProperty("total"))
                        total = response.total;

                    if (response.hasOwnProperty("results"))
                        _results = response.results;

                    if (response.hasOwnProperty("nextStart"))
                        nextStart = response.nextStart;

                    for (var i in _results) {
                        var _temp = _results[i];

                        var _itemId = "";
                        var _itemOwner = "";
                        var _itemTitle = "";
                        var _itemThumbnail = "";
                        var _itemType = "";

                        if (_temp.hasOwnProperty("type"))
                            _itemType = _temp.type;

                        if (_itemType === "Web Scene") {
                            if (_temp.hasOwnProperty("id"))
                                _itemId = _temp.id;

                            if (_temp.hasOwnProperty("owner"))
                                _itemOwner = _temp.owner;

                            if (_temp.hasOwnProperty("title"))
                                _itemTitle = _temp.title;

                            if (_temp.hasOwnProperty("thumbnail"))
                                _itemThumbnail = networkManager.rootUrl + "/content/items/" + _itemId + "/info/" + _temp.thumbnail;

                            var _obj = {
                                itemId: _itemId,
                                itemOwner: _itemOwner,
                                itemTitle: _itemTitle,
                                itemThumbnail: _itemThumbnail,
                                itemType: _itemType
                            }

                            listView.model.append(_obj);
                        }
                    }

                    resolve();
                } catch (e) {
                    reject("Error in  HomePage populateList::requestWebScenes: " + e);
                }
            })
        })

        _promise.then(function() {
            isPageLoading = false;
            isNextPageLoading = false;
        }).catch(function(e) {
            console.error(e);
        })
    }
}
