import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Platform 1.0

import Esri.ArcGISRuntime 100.7

import "../controls" as Controls

Pane {
    id: galleryDelegate

    property bool isOnline: app.isOnline
    property color imageBackgroundColor: app.baseTextColor
    property url url: url
    property bool needsUnpacking: false
    property bool isDownloaded:false

    //

    property string fontNameFallbacks: "Helvetica,Avenir"
    property string baseFontFamily: getAppProperty (app.baseFontFamily, fontNameFallbacks)
    property string titleFontFamily: getAppProperty (app.titleFontFamily, "")
    property string accentColor: getAppProperty(app.accentColor)
    property bool isDownloading:false

    //


    height: parent.cellHeight
    width: parent.cellWidth
    padding: 0

    signal clicked ()
    signal entered ()
    signal removeMapArea(var mapid,var mapareaId,var title)
    signal removeOfflineMap(var id,var needsUnpacking)



    Controls.Card {

        headerHeight: 0
        footerHeight: 0
        padding: 0
        highlightColor: "transparent"
        backgroundColor: "transparent"

        anchors {
            horizontalCenter: undefined
            fill: parent
            margins: 0.5 * app.defaultMargin
        }

        Material.elevation: hovered ? app.raisedElevation : app.baseElevation
        hoverEnabled: true

        content: Pane {
            anchors.fill: parent
            padding: 0

            RowLayout {
                id: cardContent

                anchors.fill: parent
                spacing: 0

                property int cardMargins: 3/4 * app.defaultMargin

                Image {
                    id: thumbnail

                    property real aspectRatio: (200/133)

                    Layout.preferredHeight: parseInt(parent.height) - 2 * cardContent.cardMargins
                    Layout.preferredWidth: parseInt(aspectRatio * Layout.preferredHeight)
                    Layout.margins: 0
                    Layout.leftMargin: cardContent.cardMargins
                    cache: true
                    fillMode: Image.PreserveAspectFit

                    Component.onCompleted: {
                        if(type == "maparea")
                        {
                            var storageBasePath = offlineMapAreaCache.fileFolder.path//app.rootUrl //AppFramework.resolvedUrl("./ArcGIS/AppStudio/cache")

                            var mapareapath = [storageBasePath,mapid].join("/")
                            if(Qt.platform.os === "windows")
                                url = "file:///" + mapareapath + "/" + id + "_thumbnail/" + thumbnailUrl
                            else
                                url = "file://" + mapareapath + "/" + id + "_thumbnail/" + thumbnailUrl


                        }
                        else
                        {

                            if (mmpkManager.hasOfflineMap() && offlineCache.hasFile(thumbnailUrl)) {
                                url = offlineCache.cache(thumbnailUrl, "", {"token": token})
                            } else {
                                url = onlineCache.cache(thumbnailUrl, "", {"token": token})
                                url += (isOnline && url.toString().startsWith("http") ? "?token=" + token : "")
                            }
                        }
                        source = url > "" ? url : "../images/default-thumbnail.png"
                    }

                    onStatusChanged: {
                        if (thumbnail.status === Image.Error) {
                            thumbnail.source = "../images/default-thumbnail.png"
                        }
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        running: thumbnail.status === Image.Loading
                    }

                    Rectangle {
                        id: thumbnailBackground

                        z: thumbnail.z - 1
                        anchors {
                            fill: parent
                            margins: app.units(1)
                        }
                        color: galleryDelegate.imageBackgroundColor
                    }

                    Image {
                        source: "../images/lock-badge.png"

                        width: 0.7 * app.iconSize
                        height: width
                        fillMode: Image.PreserveAspectFit
                        visible: access !== "public" && type !== "maparea"

                        anchors {
                            right: parent.right
                            top: parent.top
                        }
                    }
                }

                ColumnLayout {
                    Layout.preferredHeight: parent.height
                    Layout.alignment: Qt.AlignLeft
                    Layout.margins: 0
                    spacing: 0.5 * app.textSpacing

                    Controls.SpaceFiller {}

                    Controls.BaseText {
                        text: title
                        maximumLineCount: 2
                        Layout.topMargin: 0
                        Layout.leftMargin: cardContent.cardMargins
                        Layout.rightMargin: cardContent.cardMargins * 0.5
                        Layout.maximumHeight: (app.headerHeight * 3/2) - cardContent.cardMargins
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight

                    }

                    RowLayout{
                        spacing: 0
                        Layout.alignment: Qt.AlignLeft
                        Controls.BaseText {
                            text: {
                                var txt = ""



                                if (type === "maparea")
                                {

                                    txt = modifiedDate

                                }
                                else
                                    txt = new Date(modified).toLocaleDateString(Qt.locale(), Qt.DefaultLocaleShortDate)

                                return  txt
                            }
                            opacity: 0.7
                            maximumLineCount: 1
                            Layout.bottomMargin: 0
                            font.pointSize: Qt.platform.os === "windows" ? 0.7 * app.baseFontSize : app.textFontSize
                            Layout.leftMargin: cardContent.cardMargins
                            Layout.rightMargin:5 * scaleFactor
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                        }
                        Rectangle {
                            id:icon
                            visible:type === "Mobile Map Package" || type === "maparea"
                            Layout.preferredWidth: 4
                            Layout.preferredHeight:4
                            radius: 2
                            color: "grey"//getAppProperty(app.baseTextColor, Qt.lighter("#F7F8F8"))
                            //color: app.subTitleTextColor
                            Layout.alignment: Qt.AlignVCenter

                            Material.accent: accentColor
                        }
                        Controls.BaseText {
                            text: {
                                var txt = ""
                                if (type === "Mobile Map Package") {

                                    if (app.isOnline && portalItem.loadStatus === Enums.LoadStatusLoaded) {
                                        txt = (portalItem.size > -1 ? " %1MB".arg((portalItem.size/1000000).toFixed(1)) : "")
                                    } else {
                                        mmpkManager.getSize()
                                        txt = (mmpkManager.size > -1 ? " %1MB".arg((mmpkManager.size/1000000).toFixed(1)) : "")
                                    }
                                }
                                else if (type === "maparea")
                                {

                                    txt = size
                                }

                                return  txt
                            }
                            opacity: 0.7
                            maximumLineCount: 1
                            Layout.bottomMargin: 0
                            font.pointSize: Qt.platform.os === "windows" ? 0.7 * app.baseFontSize : app.textFontSize
                            Layout.leftMargin: 3 * scaleFactor//cardContent.cardMargins
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                        }
                    }

                    RowLayout{
                        id:maptype

                        spacing:0
                        Layout.topMargin: 0
                        Layout.leftMargin: cardContent.cardMargins
                        visible: isDownloaded && (tabView.model[tabBar.currentIndex] === "Offline Maps" || doesItContainMapArea())

                        Controls.Icon {
                            id: offlineicon
                            Layout.preferredHeight:mapTypeText.height
                            Layout.preferredWidth: height
                            imageHeight: parent.height
                            imageWidth: height
                            Layout.rightMargin: 0
                            imageSource: "../images/ic_offline_pin.png"
                            maskColor: "green"
                            Layout.alignment: Qt.AlignLeft
                        }

                        Item {
                            Layout.preferredWidth: 5 * scaleFactor
                        }


                        Controls.BaseText {
                            id: mapTypeText
                            text:tabView.model[tabBar.currentIndex] === "Offline Maps"?(type === "maparea"?"Offline area":"MMPK"):"Offline areas"
                            Layout.topMargin: 0
                            Layout.leftMargin:0
                            Layout.rightMargin: cardContent.cardMargins
                            font.pointSize: Qt.platform.os === "windows" ? 0.7 * app.baseFontSize : app.textFontSize
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                            opacity: 0.7
                        }
                    }


                    Controls.SpaceFiller {}
                }

                Rectangle {
                    id: actionBtnSpace

                    visible: actionBtn.visible
                    Layout.preferredHeight: actionBtn.height
                    Layout.preferredWidth: actionBtn.width
                    Layout.alignment: Qt.AlignVCenter
                    color: "transparent"
                }
            }
        }
    }

    function doesItContainMapArea()
    {
        var item = app.mapsWithMapAreas.filter(id => id === portalItem.itemId)
        if(item.length > 0)
            return true
        else
            return false

    }

    function getAppProperty (appProperty, fallback) {
        if (!fallback) fallback = ""
        try {
            return appProperty ? appProperty : fallback
        } catch (err) {
            return fallback
        }
    }

    PortalItem {
        id: portalItem

        itemId: id
        portal: app.portal

        Component.onCompleted: {
            if (!mmpkManager.hasOfflineMap()) {
                load()
            }
        }
    }

    Controls.MmpkManager {
        id: mmpkManager

        token: {
            try {
                return app.securedPortal.credential ? app.securedPortal.credential.token : ""
            } catch (err) {
                return ""
            }
        }
        itemId: id
        enabled: type === "Mobile Map Package"
        rootUrl: "%1/sharing/rest/content/items/".arg(app.portalUrl)
        subFolder: [app.appId, app.portalSearch.offlineFolder].join("/")

        onLoadStatusChanged: {
            if (loadStatus === 1) {
                galleryView.isDownloading = true
            } else {

                galleryView.isDownloading = false
                if (loadStatus === -1 || loadStatus === 2) {
                    app.messageDialog.standardButtons = Dialog.Ok
                    app.messageDialog.disconnectAllFromAccepted()
                    app.messageDialog.show(qsTr("Download Error"), errorText > "" ? "%1".arg(errorText) : qsTr("An error occurred during download. Please try again later."))
                }
            }
        }
    }



    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false

        onClicked: {
            galleryDelegate.clicked()
        }

        onEntered: {
            galleryDelegate.entered()
        }
    }

    Rectangle {
        id:mapareaactionBtn
        visible:type === "maparea"? true:false
        height: app.iconSize
        width: app.iconSize
        color: "transparent"

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: cardContent.cardMargins/2
        }
        Controls.Icon {
            id: mapareaMoreBtn
            visible:true
            anchors.fill: parent
            imageSource: "../images/more.png"
            maskColor: app.primaryColor
            onClicked: {
                more.open()
            }
        }
    }


    Rectangle {
        id: actionBtn

        visible: type === "maparea" || ((type === "Mobile Map Package" && !mmpkManager.offlineMapExist)  && isOnline) ||  (mmpkManager.hasOfflineMap()) //(((type === "Mobile Map Package" && !mmpkManager.offlineMapExist) && mmpkManager.loadStatus !== 1 && isOnline) ||  mmpkManager.hasOfflineMap()) && !galleryView.isDownloading
        height: app.iconSize
        width: app.iconSize
        color: "transparent"

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: cardContent.cardMargins/2
        }

        Controls.Icon {
            id: downloadBtn
            visible: (type === "Mobile Map Package" && !mmpkManager.offlineMapExist) && mmpkManager.loadStatus !== 1 && isOnline
            imageSource: "../images/download.png"
            anchors.fill: parent
            maskColor: app.primaryColor
            onClicked: {
                galleryDelegate.clicked()
            }
        }

        Controls.Icon {
            id: moreBtn
            visible:mmpkManager.hasOfflineMap() && mmpkManager.loadStatus !== 1
            anchors.fill: parent
            imageSource: "../images/more.png"
            maskColor: app.primaryColor
            onClicked: {
                more.open()
            }
        }
        BusyIndicator {
            id: busyIndicator

            visible: mmpkManager.loadStatus === 1
            Material.primary: app.primaryColor
            Material.accent: app.accentColor
            width: app.iconSize
            height: app.iconSize
            //anchors.centerIn: parent
            anchors.rightMargin: 15 * scaleFactor
        }


    }

    Controls.PopupMenu {
        id: more

        property string kRemove: qsTr("Remove")

        defaultMargin: app.defaultMargin
        backgroundColor: "#FFFFFF"
        highlightColor: Qt.darker(app.backgroundColor, 1.1)
        textColor: "red"//app.baseTextColor
        primaryColor: app.primaryColor

        menuItems: [
            {"itemLabel": kRemove}
        ]

        Material.primary: app.primaryColor
        Material.background: backgroundColor

        width: app.units(120)
        height: app.units(56)

        x: parent.width - width - app.baseUnit
        y: (parent.height - height)/2 //0 + app.baseUnit



        onMenuItemSelected: {
            switch (itemLabel) {
            case kRemove:
                if(type === "maparea")
                {
                    processDeleteMapArea(mapid,id,title)


                }

                else
                {

                    processDeleteOfflineMap(id)


                }
                break
            }
        }

    }

    Component {
        id: downloadMmpkDialog

        Controls.MessageDialog {
            id: downloadMmpk
            Material.primary: app.primaryColor
            Material.accent: app.accentColor
            pageHeaderHeight: app.headerHeight

            onCloseCompleted: {
                downloadMmpk.destroy()
            }
        }
    }

    onClicked: {
        if (type === "Mobile Map Package" && mmpkManager.loadStatus !== 1 && !mmpkManager.hasOfflineMap() && !galleryView.isDownloading && isOnline) {

            var downloadDialog = downloadMmpkDialog.createObject(app)

            if (networkConfig.isMobileData) {
                downloadDialog.addButton(app.kWaitForWifi, DialogButtonBox.RejectRole)
                downloadDialog.standardButtons = Dialog.Ok
            } else {
                downloadDialog.standardButtons = Dialog.Ok | Dialog.Cancel
            }

            downloadDialog.show("", networkConfig.isMobileData ? app.kUseMobileData.arg(title) : qsTr("Download the Mobile Map Package %1?").arg(title))
            downloadDialog.connectToAccepted(function () {
                downloadOfflineMap()
            })
        }
        else if(type === "maparea")
        {

            var furl = offlineMapAreaCache.fileFolder.path + "/" + mapid +"/" + id + "/p13/"


            app.openMap(app.localMapPackages.get(index),{"fileUrl":furl, "gdbpath":gdbpath, "basemaps":basemaps,"isMapArea":true,"title":title,"owner":owner,"modifiedDate":modifiedDate})



        }

        else if (mmpkManager.hasOfflineMap()) {
            app.openMap(app.localMapPackages.get(index), {"fileUrl": mmpkManager.fileUrl, "needsUnpacking": needsUnpacking,"isMapArea":false,"title":title})
        } else if (!isOnline) {
            app.messageDialog.standardButtons = Dialog.Ok
            app.messageDialog.show("", qsTr("Cannot download %1 because your device is offline.").arg(title))
        }
    }

    FileFolder {
        id: unpackedMmpkPath
        path: [offlineCache.fileFolder.path, mmpkManager.itemId].join("/")

        onExistsChanged: {
            if (exists) {
                needsUnpacking = true
                if (!unpackedMmpkPath.fileExists(".nomedia") && Qt.platform.os === "android") {
                    unpackedMmpkPath.writeFile(".nomedia", "")
                }
            }
        }
    }

    function isDirectReadSupported (onSupported, onNotSupported) {
        var callback = function () {
            if (MobileMapPackageUtility.isDirectReadSupportedStatus === Enums.TaskStatusCompleted) {
                if (MobileMapPackageUtility.isDirectReadSupportedResult) {
                    onSupported()
                } else {
                    onNotSupported()
                }
                MobileMapPackageUtility.isDirectReadSupportedStatusChanged.disconnect(callback)
            }
        }
        MobileMapPackageUtility.isDirectReadSupportedStatusChanged.connect(callback)
        MobileMapPackageUtility.isDirectReadSupported(mmpkManager.fileUrl)
    }

    function downloadOfflineMap () {
        // download, and unpack mmpk if needed
        galleryView.isDownloading = true
        isDownloading = true
        mmpkManager.downloadOfflineMap(function() {
            if (mmpkManager.hasOfflineMap()) {
                if (needsUnpacking) { unpackMmpk(processSuccessfulDownload)
                } else {
                    isDirectReadSupported(processSuccessfulDownload,
                                          function () {
                                              needsUnpacking = true
                                              unpackMmpk(processSuccessfulDownload)
                                          })
                }
            }


        })
    }

    function unpackMmpk (callback) {
        var unpackStatusCallback = function () {
            if (MobileMapPackageUtility.unpackStatus === Enums.TaskStatusCompleted) {
                if (callback) callback()
                MobileMapPackageUtility.unpackStatusChanged.disconnect(unpackStatusCallback)
            }
        }
        MobileMapPackageUtility.unpackStatusChanged.connect(unpackStatusCallback)
        MobileMapPackageUtility.unpack(mmpkManager.fileUrl, mmpkManager.fileUrl.toString().replace(".mmpk", ""))
    }

    function processSuccessfulDownload () {
        saveMapInfo()
        galleryView.isDownloading = false
        busyIndicator.visible = false
        Platform.stayAwake= false
        galleryDelegate.opacity = 0.5
        app.messageDialog.standardButtons = Dialog.Ok
        app.messageDialog.show("", galleryPage.kDownloadSuccessful)
        app.messageDialog.connectToAccepted(function () {
            app.portalSearch.refresh()
        })
    }

    function saveMapInfo (callback) {
        var fileName = "mapinfos.json"
        var fileContent = {"results": []}

        if (offlineCache.fileFolder.fileExists(fileName)) {
            fileContent = offlineCache.fileFolder.readJsonFile(fileName)
        }

        var item = {
            "id": id,
            "created": created,
            "modified": modified,
            "name": name,
            "title": title,
            "type": type,
            "description": typeof description !== "undefined" ? description : "",
            "snippet": typeof snippet !== "undefined" ? snippet : "",
            "thumbnail": thumbnail,
            "size": portalItem.loadStatus === Enums.LoadStatusLoaded ? portalItem.size : size,
            "token": token,
            "access": access,
            "thumbnailUrl": offlineCache.cache(thumbnailUrl, "", {"token": token}),
            "needsUnpacking": needsUnpacking
        }


        fileContent.results.push(item)
        offlineCache.fileFolder.writeJsonFile(fileName, fileContent)

        if (callback) callback()
    }



    function refresh (initialCount) {
        app.portalSearch.refresh()
        if (initialCount === 1 && (!app.onlineMapPackages.count)) {
            tabBar.currentIndex = 0
        }
    }





    function processDeleteMapArea(mapid,mapareaId,title) {
        removeMapArea(mapid,mapareaId,title)


    }



    function processDeleteOfflineMap(id)
    {
        removeOfflineMap(id,needsUnpacking)

    }

    function deleteOfflineMap () {
        deleteMapInfo()
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
    }

    function deleteMapInfo (callback) {
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

        if (callback) callback()
    }
}
