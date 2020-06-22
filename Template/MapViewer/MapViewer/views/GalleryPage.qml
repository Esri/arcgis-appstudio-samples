/* Copyright 2019 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import Esri.ArcGISRuntime 100.7

import "../controls" as Controls

Controls.BasePage {
    id: galleryPage

    property bool hasMapPackages: app.localMapPackages.count || app.onlineMapPackages.count
    property color tabBarAccentColor: "#F2D530"

    property string kFirstTab: qsTr("Web Maps")
    property string kSecondTab: qsTr("Offline Maps")

    property string kDownloadSuccessful: qsTr("Download completed. Offline map ready to use on device.")
    //signal populateTab()

    header: ToolBar {
        id: toolBar

        property int tabBarHeight: 0.8 * app.headerHeight

        height: toolBarColumn.height

        ColumnLayout {
            id: toolBarColumn

            width: parent.width
            spacing: 0

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: headerRow.height

                RowLayout {
                    id: headerRow

                    height: app.headerHeight
                    spacing: 0

                    Controls.Icon {
                        imageSource: "../images/menu.png"
                        Layout.leftMargin: app.widthOffset
                        Layout.alignment: Qt.AlignVCenter

                        onClicked: {
                            sideMenu.toggle()
                        }
                    }

                    Controls.BaseText {
                        text: qsTr("Gallery")
                        color: "#FFFFFF"
                        font.pointSize: app.subtitleFontSize
                    }

                    Controls.SpaceFiller {}
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: tabBar.height
                visible: hasMapPackages && !app.showOfflineMapsOnly

                TabBar {
                    id: tabBar

                    width: parent.width
                    height: toolBar.tabBarHeight

                    padding: 0
                    Material.background: app.primaryColor // Qt.darker(app.primaryColor, 1.3)
                    Material.accent: tabBarAccentColor
                    currentIndex: app.isOnline ? gallery.currentIndex : 0
                    position: TabBar.Header

                    property alias tabView: tabView

                    Repeater {
                        id: tabView

                        model: app.showOfflineMapsOnly ? [kSecondTab] : [kFirstTab, kSecondTab]

                        TabButton {
                            id: tabButton

                            height: parent.height

                            contentItem: Controls.BaseText {
                                text: modelData
                                color: app.titleTextColor
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                opacity: tabButton.checked ? 1 : 0.6
                            }
                            padding: 0
                            background.height: height
                        }
                    }
                }
            }
        }
    }

    contentItem: Rectangle {
        id: pageView

        color: app.backgroundColor
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        GalleryView {
            id: gallery

            tabBar: tabBar
            onItemSelected: {
                switch (type) {
                case "Web Map":
                    var item = app.webMapsModel.get(index)
                    app.openMap(item)
                    break
                case "Mobile Map Package":
                    //NB: This has been handled at the delegate level
                    break
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    MenuPage {
        id: sideMenu

        property string userThumbnail: ""

        title: app.isSignedIn ? (app.securedPortal.credential ? app.securedPortal.credential.username : "") : app.info.title
        bannerImage: app.isSignedIn ? (userThumbnail > "" ? userThumbnail : "../images/user.png") : app.startBackground

        Connections {
            target: app

            onIsSignedInChanged: {
                sideMenu.updateHeaderContent()
            }
        }

        onOpened: {
            updateHeaderContent()
            refreshClearCacheItem()
        }

        onCacheCleared: {
            toastMessage.show(qsTr("Cache successfully cleared."))
        }

        onErrorClearingCache: {
            toastMessage.show(qsTr("An error occurred while trying to clear the cache."))
        }

        function updateHeaderContent () {
            if (app.isSignedIn) {
                title = app.securedPortal.credential ? app.securedPortal.credential.username : ""
                getUserThumbnail(app.securedPortal)
            } else {
                title = app.info.title
            }
        }

        function getUserThumbnail (portal) {
            // Checks if no thumbnail name exists after the url section 'info', and before the '?' sign
            sideMenu.userThumbnail = portal.portalUser.thumbnailUrl.toString().indexOf("/info/?") === -1 ? portal.portalUser.thumbnailUrl : ""
        }
    }

    //--------------------------------------------------------------------------

    BusyIndicator {
        id: busyIndicator

        anchors.centerIn: parent
        visible: app.portalSearch.isBusy || sideMenu.isClearingCache //app.portal ? (app.portal.findItemsStatus === Enums.TaskStatusInProgress) : false
        Material.primary: app.primaryColor
        Material.accent: app.accentColor
    }

    //--------------------------------------------------------------------------

    Connections {
        target: app

        onIsSignedInChanged: {
            if (!app.isSignedIn && !app.localMapPackages.count && tabBar.currentIndex && !app.refreshTokenTimer.isRefreshing) {
                tabBar.currentIndex = 0
            }
        }

        onBackButtonPressed: {
            if (app.stackView.currentItem.objectName === "galleryPage" &&
                    !app.aboutAppPage.visible && !hasVisibleSignInPage()) {
                if (app.messageDialog.visible) {
                    app.messageDialog.close()
                } else if (tabBar.visible && tabBar.currentIndex) {
                    tabBar.currentIndex = 0
                }
            }
        }

        onPopulateGalleryTab:{
            gallery.addDataToSwipeView (gallery.currentIndex)

        }
        onRefreshGallery:{
            var initialCount = app.localMapPackages.count

            app.portalSearch.refresh()
            if (initialCount === 0 && (app.onlineMapPackages.count === 0)) {

               gallery.tabBar.currentIndex = 0
            }
        }

    }


}
