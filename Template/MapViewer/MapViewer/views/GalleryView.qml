import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1

import QtQuick.Controls.Material 2.1

import "../controls" as Controls

SwipeView {
    id: galleryView

    property bool isDownloading: false
    property bool showDownloadableMmpks: app.skipMmpkLogin || app.showPublishedMmpksOnly

    signal itemSelected (int index, string type)


    
    anchors {
        fill: parent
        //margins: 0.5 * app.defaultMargin
        horizontalCenter: parent.horizontalCenter
    }

    bottomPadding: app.heightOffset

    clip: true
    currentIndex: tabBar.currentIndex
    interactive: false

    property TabBar tabBar: TabBar {}
    property QtObject currentView
    Repeater {
        id: galleryViewDelegate

        model: tabBar.tabView.model.length
        Loader {
            active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
            visible: SwipeView.isCurrentItem
            sourceComponent: galleryView.currentView
        }
    }

    onCurrentIndexChanged: {
        galleryView.isDownloading = false
        addDataToSwipeView (galleryView.currentIndex)
    }

    Component.onCompleted: {
        addDataToSwipeView (galleryView.currentIndex)
    }

    function deleteMapArea(mapid,mapareaId,title)
    {

        app.messageDialog.width = messageDialog.units(300)
        app.messageDialog.standardButtons = Dialog.Cancel | Dialog.Ok

        //app.messageDialog.addButton(qsTr("Remove"), DialogButtonBox.AcceptRole, "red")


        app.messageDialog.show(qsTr("Remove offline area"),qsTr("This will remove the downloaded offline map area %1 from the device. Would you like to continue?").arg(title))

        app.messageDialog.connectToAccepted(function () {


            app.deleteOfflineMapArea(mapid,mapareaId)



        })
    }

    function deleteMMPK(id,needsUnpacking)
    {

        app.messageDialog.width = messageDialog.units(300)
        app.messageDialog.standardButtons = Dialog.Cancel | Dialog.Ok

        //addButton(qsTr("CANCEL"), DialogButtonBox.RejectRole, app.accentColor)
        //app.messageDialog.addButton(qsTr("Remove"), DialogButtonBox.AcceptRole, "red")


        app.messageDialog.show(qsTr("Remove offline map"),qsTr("This will remove the downloaded map  %1 from the device. Would you like to continue?").arg(title))

        app.messageDialog.connectToAccepted(function () {


            deleteMapInfo(id)
            var initialCount = app.localMapPackages.count
            mmpkManager.deleteOfflineMap(function () {
                if (mmpkManager.hasOfflineMap()) {
                    app.offlineCache.flagForDeletion(mmpkManager.itemName)
                }
                refresh(initialCount)
            })
            if (needsUnpacking) {
                var success = mmpkManager.fileFolder.removeFolder(mmpkManager.itemId, true)
                if (!success) {
                    app.offlineCache.flagForDeletion(mmpkManager.itemId)
                    refresh(initialCount)
                }
            }



        })

    }
    function refresh (initialCount) {
        app.portalSearch.refresh()
        if (initialCount === 1 && (!app.onlineMapPackages.count)) {
            tabBar.currentIndex = 0
        }
    }


        function deleteMapInfo (id) {
            var fileName = "mapinfos.json"
            var currentContent = offlineCache.fileFolder.readJsonFile(fileName)
            var newContent =  {"results": []}

            for (var i=0; i<currentContent.results.length; i++) {
                if (currentContent.results[i].id !== id) {
                    newContent.results.push(currentContent.results[i])
                } else {
                    offlineCache.clearCache(currentContent.results[i].thumbnailUrl)
                }
            }

            if (newContent.results.length) {
                offlineCache.fileFolder.writeJsonFile(fileName, newContent)
            } else {
                offlineCache.clearAllCache()
            }


        }


    function addDataToSwipeView (index) {
        switch (tabBar.tabView.model[index]) {
        case kFirstTab:
            galleryView.currentView = null
            galleryView.currentView = firstTabComponent // web maps
            break
        case kSecondTab:
            galleryView.currentView = null
            galleryView.currentView = secondTabComponent // map packages
            break
        }
    }

    Component {
        id: firstTabComponent

        GridView {
            id: webMapsView

            property int columns: app.isCompact ? 1 : (app.isMidsized ? 2 : 3)
            property real preferredItemWidth: app.units(296)
            property real preferredItemHeight: app.units(112)
            property real itemAspectRatio: preferredItemWidth/preferredItemHeight
            property real itemWidth: webMapsView.width/webMapsView.columns
            property real itemHeight: (1/webMapsView.itemAspectRatio) * itemWidth

            header: Rectangle {
                // transparent top margin
                width: parent.width
                height: 0.5 * app.defaultMargin
                color: "transparent"
            }

            footer: Rectangle {
                // transparent bottom margin
                width: parent.width
                height: 0.5 * app.defaultMargin
                color: "transparent"
            }

            currentIndex: -1
            clip: true
            cellWidth: itemWidth
            cellHeight: itemHeight
            focus: true
            model: app.webMapsModel
            anchors {
                fill: parent
                leftMargin: app.isIphoneX ? app.widthOffset + 0.5 * app.defaultMargin : 0.5 * app.defaultMargin
                rightMargin: app.isIphoneX ? app.widthOffset + 0.5 * app.defaultMargin : 0.5 * app.defaultMargin
            }

            delegate: GalleryDelegate {

                width: webMapsView.itemWidth
                height: webMapsView.itemHeight

                onClicked: {
                    if (webMapsView.currentIndex !== index) {
                        webMapsView.currentIndex = index
                    }
                    galleryView.itemSelected(index, type)
                }

                onEntered: {
                    if (entered) {
                        webMapsView.currentIndex = index
                    }
                }
            }

            ColumnLayout {
                id: noMaps

                spacing: 0
                visible: !busyIndicator.visible && !count
                width: 30 * app.baseUnit
                height: width + noMapsText.heigth
                anchors.centerIn: parent

                Image {
                    source: "../images/no-maps.png"
                    fillMode: Image.PreserveAspectFit
                    Layout.preferredWidth: parent.width
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredHeight: 0.6 * parent.width
                    mipmap: true
                }

                Controls.BaseText {
                    id: noMapsText

                    text: qsTr("No maps available.")
                    color: app.subTitleTextColor
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }


        }

    }

    Component {
        id: secondTabComponent

        ColumnLayout {
            id: mapPackagesView

            property int headerHeight: showDownloadableMmpks ? 0.8 * app.headerHeight : 0

            anchors.fill: parent
            spacing: 0

            ColumnLayout {
                id: onlineContainer

                visible: showDownloadableMmpks
                Layout.preferredHeight: onlineHeader.height
                Layout.fillWidth: true
                spacing: 0
                state: "EXPANDED"

                states:  [
                    State {
                        name: "EXPANDED"
                        PropertyChanges {
                            target: expandOnlineIcon
                            rotation: 180
                        }
                        PropertyChanges {
                            target: online
                            Layout.preferredHeight: parent ? parent.height  - 2 * headerHeight : 0
                        }
                        PropertyChanges {
                            target: onlineContainer
                            Layout.preferredHeight: parent ? parent.height - headerHeight : 0
                        }
                    }
                ]

                transitions: [
                    Transition {
                        NumberAnimation {
                            property: "Layout.preferredHeight"
                            duration: 200
                        }
                    }
                ]

                Rectangle {
                    id: onlineHeader

                    Layout.preferredHeight: headerHeight
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    color: Qt.darker(app.backgroundColor, 1.1)

                    RowLayout {
                        anchors {
                            fill: parent
                            rightMargin: app.widthOffset
                            leftMargin: app.widthOffset
                        }

                        Controls.Icon {
                            id: expandOnlineIcon

                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: app.iconSize
                            Layout.preferredHeight: Layout.preferredWidth
                            maskColor: app.baseTextColor
                            imageSource: "../images/arrowDown.png"

                            onClicked: {
                                onlineContainer.toggle()
                            }
                        }

                        Controls.BaseText {
                            text: qsTr("Download")
                            Layout.alignment: Qt.AlignLeft

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    onlineContainer.toggle()
                                }
                            }
                        }

                        Controls.SpaceFiller {}

                        Rectangle {
                            color: Qt.darker(app.backgroundColor, 1.2)
                            border.color: Qt.darker(app.backgroundColor, 1.2)
                            Layout.preferredWidth: app.fontScale * 0.7 * app.iconSize
                            Layout.preferredHeight: Layout.preferredWidth
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: app.defaultMargin
                            radius: Layout.preferredWidth/2

                            Controls.BaseText {
                                id: onlineMmpksCount

                                text: app.onlineMapPackages.count
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    onlineContainer.toggle()
                                }
                            }
                        }
                    }
                }

                GridView {
                    id: online

                    property int columns: app.isCompact ? 1 : (app.isMidsized ? 2 : 3)
                    property real preferredItemWidth: app.units(296)
                    property real preferredItemHeight: app.units(112)
                    property real itemAspectRatio: preferredItemWidth/preferredItemHeight
                    property real itemWidth: online.width/online.columns
                    property real itemHeight: (1/online.itemAspectRatio) * itemWidth

                    currentIndex: -1
                    clip: true
                    cellWidth: itemWidth
                    cellHeight: itemHeight
                    focus: true
                    model: app.onlineMapPackages

                    header: Rectangle {
                        // transparent top margin
                        width: parent.width
                        height: 0.5 * app.defaultMargin
                        color: "transparent"
                    }

                    footer: Rectangle {
                        // transparent bottom margin
                        width: parent.width
                        height: 0.5 * app.defaultMargin
                        color: "transparent"
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: 0
                    Layout.leftMargin: app.isIphoneX ? app.widthOffset + 0.5 * app.defaultMargin : 0.5 * app.defaultMargin
                    Layout.rightMargin: app.isIphoneX ? app.widthOffset + 0.5 * app.defaultMargin : 0.5 * app.defaultMargin

                    delegate: GalleryDelegate {

                        width: online.itemWidth
                        height: online.itemHeight

                        onClicked: {
                            if (online.currentIndex !== index) {
                                online.currentIndex = index
                            }
                            galleryView.itemSelected(index, type)
                        }

                        onEntered: {
                            if (entered) {
                                online.currentIndex = index
                            }
                        }
                    }

                    ColumnLayout {
                        id: noMaps

                        spacing: 0
                        visible: !busyIndicator.visible && !app.onlineMapPackages.count
                        width: 30 * app.baseUnit
                        height: width + noMapsText.heigth
                        x: 0.5 * (parent.width - width)
                        y: 0.5 * (parent.height - height - headerHeight)

                        Image {
                            source: "../images/no-maps.png"
                            fillMode: Image.PreserveAspectFit
                            Layout.preferredWidth: parent.width
                            Layout.alignment: Qt.AlignTop
                            Layout.preferredHeight: 0.6 * parent.width
                            mipmap: true
                        }

                        Controls.BaseText {
                            id: noMapsText

                            text: qsTr("No maps available.")
                            color: app.subTitleTextColor
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                function expand () {
                    state = "EXPANDED"
                    offlineContainer.state = ""
                }

                function collapse () {
                    state = ""
                    offlineContainer.state = "EXPANDED"
                }

                function toggle () {
                    if (state === "") {
                        expand()
                    } else {
                        collapse()
                    }
                }
            }

            //-----------------------------------------------------------------------------
            Rectangle {
                id: separator
                visible: !busyIndicator.visible && (app.localMapPackages.count || app.onlineMapPackages.count)
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 1
                Layout.alignment: Qt.AlignBottom
                color: app.separatorColor
            }
            //-----------------------------------------------------------------------------

            ColumnLayout {
                id: offlineContainer

                Layout.preferredHeight: showDownloadableMmpks ? offlineHeader.height : 0
                Layout.fillWidth: true
                spacing: 0

                states:  [
                    State {
                        name: "EXPANDED"
                        PropertyChanges {
                            target: expandOfflineIcon
                            rotation: 180
                        }
                        PropertyChanges {
                            target: offline
                            Layout.preferredHeight: parent ? parent.height - mapPackagesView.headerHeight : 0
                        }
                        PropertyChanges {
                            target: offlineContainer
                            Layout.preferredHeight: parent ? parent.height - mapPackagesView.headerHeight : 0
                        }
                    }
                ]

                transitions: [
                    Transition {
                        NumberAnimation {
                            property: "Layout.preferredHeight"
                            duration: 200
                        }
                    }
                ]

                Rectangle {
                    id: offlineHeader

                    visible: showDownloadableMmpks
                    Layout.preferredHeight: headerHeight
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    color: Qt.darker(app.backgroundColor, 1.1)

                    RowLayout {
                        anchors {
                            fill: parent
                            rightMargin: app.widthOffset
                            leftMargin: app.widthOffset
                        }

                        Controls.Icon {
                            id: expandOfflineIcon

                            Layout.alignment: Qt.AlignVCenter
                            maskColor: app.baseTextColor
                            imageSource: "../images/arrowDown.png"

                            onClicked: {
                                offlineContainer.toggle()
                            }
                        }

                        Controls.BaseText {
                            text: qsTr("On Device")
                            Layout.alignment: Qt.AlignLeft

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    offlineContainer.toggle()
                                }
                            }
                        }

                        Controls.SpaceFiller {}

                        Rectangle {
                            color: Qt.darker(app.backgroundColor, 1.2)
                            border.color: Qt.darker(app.backgroundColor, 1.2)
                            Layout.preferredWidth: app.fontScale * 0.7 * app.iconSize
                            Layout.preferredHeight: Layout.preferredWidth
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: app.defaultMargin
                            radius: Layout.preferredWidth/2

                            Controls.BaseText {
                                id: localMapsCount

                                text: app.localMapPackages.count
                                anchors.centerIn: parent
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    offlineContainer.toggle()
                                }
                            }
                        }
                    }
                }

                GridView {
                    id: offline

                    property int columns: app.isCompact ? 1 : (app.isMidsized ? 2 : 3)
                    property real preferredItemWidth: app.units(296)
                    property real preferredItemHeight: app.units(112)
                    property real itemAspectRatio: preferredItemWidth/preferredItemHeight
                    property real itemWidth: offline.width/offline.columns
                    property real itemHeight: (1/offline.itemAspectRatio) * itemWidth
                    // signal deleteMyMapArea()


                    currentIndex: -1
                    clip: true
                    cellWidth: itemWidth
                    cellHeight: itemHeight
                    focus: true
                    model: app.localMapPackages

                    header: Rectangle {
                        // transparent top margin
                        width: parent.width
                        height: 0.5 * app.defaultMargin
                        color: "transparent"
                    }

                    footer: Rectangle {
                        // transparent bottom margin
                        width: parent.width
                        height: 0.5 * app.defaultMargin
                        color: "transparent"
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: 0
                    Layout.leftMargin: app.isIphoneX ? app.widthOffset + 0.5 * app.defaultMargin : 0.5 * app.defaultMargin
                    Layout.rightMargin: app.isIphoneX ? app.widthOffset + 0.5 * app.defaultMargin : 0.5 * app.defaultMargin

                    delegate: GalleryDelegate {

                        width: offline.itemWidth
                        height: offline.itemHeight
                        isDownloaded:true

                        onClicked: {
                            if (offline.currentIndex !== index) {
                                offline.currentIndex = index
                            }
                            galleryView.itemSelected(currentIndex, type)
                        }

                        onEntered: {
                            if (entered) {
                                offline.currentIndex = index
                            }
                        }
                        onRemoveOfflineMap: {

                            deleteMMPK(id,needsUnpacking)

                        }

                        onRemoveMapArea: {
                            galleryView.deleteMapArea(mapid,mapareaId,title)

                        }



                    }

                    ColumnLayout {
                        id: noOfflineMaps

                        spacing: 0
                        visible: !busyIndicator.visible && !app.localMapPackages.count
                        width: 30 * app.baseUnit
                        height: Math.max(width, noOfflineMapsText.heigth)
                        x: 0.5 * (parent.width - width)
                        y: 0.5 * (parent.height - height - headerHeight)

                        Image {
                            source: "../images/no-maps.png"
                            fillMode: Image.PreserveAspectFit
                            Layout.preferredWidth: parent.width
                            Layout.alignment: Qt.AlignTop
                            Layout.preferredHeight: 0.6 * parent.width
                            mipmap: true
                        }

                        Controls.BaseText {
                            id: noOfflineMapsText

                            visible: !app.localMapPackages.count
                            text: qsTr("No maps available.")
                            color: app.subTitleTextColor
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    onCountChanged: {
                        if (count) {
                            offlineContainer.expand()
                        } else {
                            if (showDownloadableMmpks) {
                                offlineContainer.collapse()
                            }
                        }
                    }

                }




                function expand () {
                    state = "EXPANDED"
                    onlineContainer.state = ""
                }

                function collapse () {
                    state = ""
                    onlineContainer.state = "EXPANDED"
                }

                function toggle () {
                    if (state === "") {
                        expand()
                    } else {
                        collapse()
                    }
                }
            }
        }
    }
}
