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
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Networking 1.0
import ArcGIS.AppFramework.Authentication 1.0
import ArcGIS.AppFramework.WebView 1.0

import Esri.ArcGISRuntime 100.7


import "controls" as Controls
import "views" as Views


App {
    id: app

    height: 690
    width: 950 //420 //

    readonly property string appId: app.info.itemInfo.id
    readonly property real baseUnit: app.units(8)
    readonly property real defaultMargin: 2 * app.baseUnit
    readonly property real textSpacing: 0.5 * app.defaultMargin
    readonly property real iconSize: 5 * app.baseUnit
    readonly property real mapControlIconSize: 6 * app.baseUnit
    readonly property real headerHeight: 7 * app.baseUnit
    readonly property real preferredContentWidth: 75 * app.baseUnit
    readonly property real maxMenuWidth: 36 * app.baseUnit
    readonly property real baseElevation: 2
    readonly property real raisedElevation: 8
    readonly property real compactThreshold: app.units(496)
    readonly property real heightOffset: isIphoneX ? app.units(20) : 0
    readonly property real widthOffset: isIphoneX && isLandscape ? app.units(40) : 0
    property bool isIphoneX: false
    property bool isWindows7: false
    property bool isIphoneXAndLandscape: isNotchAvailable() && !isPortrait
    property bool isPortrait: app.width < app.height

    property real fontScale: app.isDesktop? 0.8 : 1


    readonly property real baseFontSize: fontScale * app.getProperty("baseFontSize", Qt.platform.os === "windows" ? 10 : 14)


    readonly property real subtitleFontSize: 1.5 * app.baseFontSize
    readonly property real titleFontSize: 2 * app.baseFontSize
    readonly property real textFontSize: 0.9 * app.baseFontSize
    readonly property real scaleFactor: AppFramework.displayScaleFactor

    property bool isOnline: Networking.isOnline
    readonly property bool isCompact: app.width <= app.compactThreshold
    readonly property bool isMidsized: (app.width > app.compactThreshold) && (app.width <= 800)
    readonly property bool isLarge: !app.isCompact && !app.isMidsized
    readonly property bool isLandscape: app.width > app.height
    readonly property bool isDebug: false

    // portal and security
    readonly property url portalUrl: app.getProperty("portalUrl", "https://www.arcgis.com")
    property bool supportSecuredMaps: app.getProperty("supportSecuredMaps", false) && isOnline
    property bool skipMmpkLogin: true
    property bool showPublishedMmpksOnly: true && !isSignedIn
    readonly property string mapTypes: app.getProperty("mapTypes", "showWebMapsOnly")
    readonly property bool showOfflineMapsOnly: mapTypes === "showOfflineMapsOnly"
    readonly property bool showAllMaps: mapTypes === "showBoth"
    readonly property bool showWebMapsOnly: mapTypes === "showWebMapsOnly"
    readonly property bool enableAnonymousAccess: app.getProperty("enableAnonymousAccess", false)
    readonly property string clientId: getClientId()

    readonly property color primaryColor: app.isDebug ? app.randomColor("primary") : app.getProperty("brandColor", "#166DB2")
    readonly property color backgroundColor: app.isDebug ? app.randomColor("background") : "#EFEFEF"
    readonly property color foregroundColor: app.isDebug ? app.randomColor("foreground") : "#22000000"
    readonly property color separatorColor: Qt.darker(app.backgroundColor, 1.2)
    readonly property color accentColor: Qt.lighter(app.primaryColor)
    readonly property color titleTextColor: app.backgroundColor
    readonly property color subTitleTextColor: Qt.darker(app.backgroundColor)
    readonly property color baseTextColor: Qt.darker(app.subTitleTextColor)
    readonly property color iconMaskColor: "transparent"
    readonly property color black_87: "#DE000000"
    readonly property color white_100: "#FFFFFFFF"
    readonly property url license_appstudio_icon: "./Images/appstudio.png"

    readonly property color darkIconMask: "#4c4c4c"

    readonly property bool canUseBiometricAuthentication: BiometricAuthenticator.supported && BiometricAuthenticator.activated
    property bool hasFaceID: isIphoneX

    // start page
    readonly property color startForegroundColor: app.foregroundColor
    readonly property color startBackgroundColor: app.backgroundColor
    readonly property url startBackground: app.folder.fileUrl(app.getProperty("startBackground"))

    // gallery page
    readonly property string searchQuery: app.getProperty("galleryMapsQuery")
    readonly property int maxNumberOfQueryResults: app.getProperty("maxNumberOfQueryResults", 20)

    readonly property string feedbackEmail: app.getProperty("feedbackEmail", "")

    readonly property bool hasDisclaimer: app.info.itemInfo.licenseInfo > ""
    property bool showDisclaimer: app.info.propertyValue("showDisclaimer", true)
    property bool disableDisclaimer: app.settings.boolValue("disableDisclaimer", false)
    property bool showMapUnits: true
    property bool showGrid: false
    property bool showGridLabel: false

    // menu
    property bool showBackToGalleryButton: true

    // Use mobile data strings
    readonly property string kUseMobileData: qsTr("Use your mobile data to download the Mobile Map Package %1")
    readonly property string kWaitForWifi: qsTr("Wait for Wi-Fi")

    // Check capabilities
    readonly property string locationAccessDisabledTitle: qsTr("Location access disabled")
    readonly property string locationAccessDisabledMessage: qsTr("Please enable Location access permission for %1 in the device Settings.")
    readonly property string ok_String: qsTr("OK")
    readonly property string storageAccessDisabledTitle: qsTr("Storage access disabled")
    readonly property string storageAccessDisabledMessage: qsTr("Please enable Storage access permission for %1 in the device Settings.")
    readonly property bool isDesktop: Qt.platform.os === "ios" || Qt.platform.os === "android" ? false:true
    property bool hasLocationPermission:false
    property bool isTablet: (Math.max(app.width, app.height) > 1000 * scaleFactor) || (AppFramework.systemInformation.family === "tablet")

    property string kBackToGallery:qsTr("Back to Gallery")
    property string kBack:qsTr("Back")

    // Offline Routing strings
    readonly property string offline_routing: qsTr("Offline Routing")
    readonly property string choose_starting_point: qsTr("Choose starting point")
    readonly property string choose_destination: qsTr("Choose destination")
    readonly property string directions: qsTr("Directions")
    readonly property string no_route_found: qsTr("No route found")
    readonly property string location_outside_extent: qsTr("Location is outside the extent of the offline map.")
    readonly property string current_location: qsTr("Current location")
    readonly property string search_a_place: qsTr("Search a place")
    readonly property string search_a_feature: qsTr("Search a feature")
    readonly property string choose_on_map: qsTr("Choose on map")
    readonly property string directions_not_available: qsTr("Directions not available for this route.")
    readonly property string kOfflineMapArea:qsTr("Offline map area")
    readonly property string kOfflineMapAreas_title:qsTr("Offline Map Areas")
    readonly property var mapsWithMapAreas:[]
    readonly property string kMapArea:qsTr("Map Area")


    signal populateGalleryTab()
    signal refreshGallery()

    //--------------------------------------------------------------------------


    function isNotchAvailable() {
        var unixName = AppFramework.systemInformation.unixMachine;

        if (unixName.match(/iPhone(10|\d\d)/)) {
            switch(unixName) {
            case "iPhone10,1":
            case "iPhone10,4":
            case "iPhone10,2":
            case "iPhone10,5":
                return false;
            default:
                return true;
            }
        }
        return false;
    }

    function deleteOfflineMapArea(mapid,mapareaId)
    {
        var fileName = "mapareasinfos.json"

        var mapAreaPath = offlineMapAreaCache.fileFolder.path + "/"+ mapid
        let mapAreafileInfo = AppFramework.fileInfo(mapAreaPath)
        //fileInfo.folder points to previous folder
        if (mapAreafileInfo.folder.fileExists(fileName)) {
            var   fileContent = mapAreafileInfo.folder.readJsonFile(fileName)
            var results = fileContent.results
           var existingmapareas = results.filter(item => item.id !== mapareaId)
            fileContent.results = existingmapareas

            //delete the folder
            var thumbnailFolder = mapareaId + "_thumbnail"
            var mapareacontentpath = [mapAreaPath,thumbnailFolder].join("/")
            let fileFolder= AppFramework.fileFolder(mapareacontentpath)
            var isthumbnaildeleted = fileFolder.removeFolder()
            var mapareacontents = [mapAreaPath,mapareaId].join("/")
            let mapareafileFolder = AppFramework.fileFolder(mapareacontents)
            var isdeleted = mapareafileFolder.removeFolder()
            if(isdeleted)
                mapAreafileInfo.folder.writeJsonFile(fileName, fileContent)

        }

        portalSearch.populateLocalMapPackages()
        refreshGallery()



    }


    onFontScaleChanged: {
        app.settings.setValue("fontScale", fontScale)
    }

    property alias baseFontFamily: baseFontFamily.name
    FontLoader {
        id: baseFontFamily

        source: app.folder.fileUrl(app.getProperty("regularFontTTF", ""))
    }

    property alias titleFontFamily: titleFontFamily.name
    FontLoader {
        id: titleFontFamily

        source:  app.folder.fileUrl(app.getProperty("mediumFontTTF", ""))
    }


    //--------------------------------------------------------------------------

    property alias tabNames: tabNames
    QtObject {
        id: tabNames

        property string kLegend: qsTr("LEGEND")
        property string kContent: qsTr("CONTENT")
        property string kInfo: qsTr("INFO")
        property string kBookmarks: qsTr("BOOKMARKS")
        property string kMapAreas: qsTr("MAPAREAS")
        property string kFeatures: qsTr("FEATURES")
        property string kPlaces: qsTr("PLACES")
        property string kBasemaps: qsTr("BASEMAPS")
        property string kMapUnits: qsTr("MAP UNITS")
        property string kOfflineMaps: qsTr("OFFLINE MAPS")
        property string kGraticules: qsTr("GRATICULES")
        property string kMedia: qsTr("MEDIA")
        property string kAttachments: qsTr("ATTACHMENTS")
        property string kRelatedRecords: qsTr("RELATED")
    }

    //--------------------------------------------------------------------------

    property alias stackView: stackView
    StackView {
        id: stackView

        anchors.fill: parent
        initialItem: startPage
    }

    function openMap (portalItem, mapProperties) {
       if (!mapProperties) mapProperties = {"fileUrl": "","isMapArea":false}
        stackView.push(mapPage, {destroyOnPop: true, "mapProperties": mapProperties, "portalItem": portalItem})
    }

    //--------------------------------------------------------------------------

    Component {
        id: startPage

        Views.StartPage {
            objectName: "startPage"
            onNext: {
                stackView.push(galleryPage, {destroyOnPop: true})
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: galleryPage



        Views.GalleryPage {
            objectName: "galleryPage"

            onPrevious: {
                stackView.pop()


            }



            Component.onCompleted: {
                if (app.showDisclaimer && app.hasDisclaimer && !app.disableDisclaimer) {
                    app.disclaimerDialog.open()
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: mapPage

        Views.MapPage {
            objectName: "mapPage"
            onPrevious: {
                stackView.pop()
                populateGalleryTab()
            }
        }
    }

    //--------------------------------------------------------------------------

    property alias aboutAppPage: aboutAppPage
    Views.AboutAppPage {
        id: aboutAppPage
    }

    //--------------------------------------------------------------------------

    Component {
        id: webPageComponent

        Controls.WebPage {

        }
    }


    Component {
        id: safariBrowserComponent

        BrowserView {

        }
    }




    function openUrlInternally(url) {
        var browserView;

        if (Qt.platform.os === "ios" || Qt.platform.os === "android") {
            browserView = safariBrowserComponent.
            createObject(null, {
                             url: url
                         });
            browserView.show();
        } else {
            browserView = webPageComponent.createObject(app);
            browserView.closed.connect(browserView.destroy)
            browserView.loadPage(url)
        }
    }

    Component {
        id: webComponent
        Controls.WebPage {

        }
    }

    function openUrlInternallyWithWebView (url) {
        var webPage = webComponent.createObject (app)
        webPage.closed.connect(webPage.destroy)
        webPage.loadPage (url)
    }


    //--------------------------------------------------------------------------

    property alias messageDialog: messageDialog
    Controls.MessageDialog {
        id: messageDialog

        Material.primary: app.primaryColor
        Material.accent: app.accentColor
        pageHeaderHeight: app.headerHeight
    }

    //--------------------------------------------------------------------------

    property alias disclaimerDialog: disclaimerDialog
    Views.DisclaimerView {
        id: disclaimerDialog
    }

    //--------------------------------------------------------------------------

    property alias networkConfig: networkConfig
    Controls.NetworkConfig {
        id: networkConfig
    }

    property alias parentCache: parentCache
    Controls.NetworkCacheManager {
        id: parentCache

        subFolder: portalSearch.subFolder
    }

    property alias onlineCache: onlineCache
    Controls.NetworkCacheManager {
        id: onlineCache

        subFolder: [portalSearch.subFolder, portalSearch.onlineFolder].join("/")
    }

    property alias offlineCache: offlineCache
    Controls.NetworkCacheManager {
        id: offlineCache

        subFolder: [portalSearch.subFolder, portalSearch.offlineFolder].join("/")
    }

    property alias offlineMapAreaCache: offlineMapAreaCache
    Controls.NetworkCacheManager {
        id: offlineMapAreaCache
        subFolder: [portalSearch.subFolder, portalSearch.offlineMapAreaFolder].join("/")

    }


    property alias portalSearch: portalSearch
    Controls.PortalSearch {
        id: portalSearch

        isOnline: app.isOnline
        subFolder: app.appId

        onUpdateModel: {
            portalSearch.populateSearcResultsModel(portalSearch.token)
        }

        onFindItemsResultsChanged: {
            //var token = securedPortal ? securedPortal.credential.token : ""
            portalSearch.populateSearcResultsModel(portalSearch.token)
        }

        function populateSearcResultsModel (token) {
            webMapsModel.clear()
            localMapPackages.clear()
            onlineMapPackages.clear()
            var flaggedForDeletion = app.settings.value("flaggedForDeletion", "")
            for (var i=0; i<findItemsResults.length; i++) {
                var itemJson = findItemsResults[i]
                if (!itemJson) continue
                switch (itemJson.type) {
                case "Web Map":
                    if (app.showAllMaps || !app.showOfflineMapsOnly) webMapsModel.append(itemJson)
                    break
                case "Mobile Map Package":
                    if (flaggedForDeletion.indexOf(itemJson.id) !== -1) continue
                    mmpkManager.itemId = itemJson.id
                    if (showPublishedMmpksOnly && !isPublishedMap(itemJson)) continue
                    if (mmpkManager.hasOfflineMap()) {
                        continue
                    } else {
                        if ((app.isSignedIn && (app.showAllMaps || !app.showWebMapsOnly)) || app.skipMmpkLogin) {
                            onlineMapPackages.append(itemJson)
                        }
                    }
                }
            }
            if (app.showAllMaps || !app.showWebMapsOnly) {
                updateLocalMaps()
                updateLocalMapAreas()
            }
        }

        function isPublishedMap (item) {
            return item.typeKeywords.indexOf("Published Map") !== -1
        }

        function populateLocalMapPackages()
        {
            localMapPackages.clear()
            updateLocalMaps()
            updateLocalMapAreas()
        }

        function updateLocalMaps () {
            var fileName = "mapinfos.json"


            if (offlineCache.fileInfo.folder.fileExists(fileName)) {
                var fileContent = offlineCache.fileInfo.folder.readJsonFile(fileName)


                localMapPackages.clear()
                for (var i=0; i<fileContent.results.length; i++) {
                    localMapPackages.append(fileContent.results[i])

                }
            }


        }

        function removeMapAreaFromLocal(mapareaid)
        {
            var indx = -1
            for(var k=0;k<localMapPackages.count;k++)
            {
                var item = localMapPackages.get(0)
                if(item.id === mapareaid)
                    indx = k
            }
                    if(indx > -1)
                    localMapPackages.remove(indx)
        }


        function updateLocalMapAreas () {
            var fileName = "mapareasinfos.json"
            //iterate through the subfolders


            if (offlineMapAreaCache.fileInfo.folder.fileExists(fileName)) {
                var fileContent = offlineMapAreaCache.fileFolder.readJsonFile(fileName)
               var indx = localMapPackages.count

                for (var i=0; i<fileContent.results.length; i++) {

                     var   basemaps =  fileContent.results[i].basemaps.join(",")
                    fileContent.results[i].basemaps = basemaps

                    localMapPackages.append(fileContent.results[i])

                }
            }
        }





    }
    function getFileSize(fileSizeInBytes)
    {
        var i = -1;
        var byteUnits = [qsTr("KB"), qsTr("MB"), qsTr("GB")];
        do {
            fileSizeInBytes = fileSizeInBytes / 1024;
            i++;
        } while (fileSizeInBytes > 1024);

       return "%1 %2".arg(Number(Math.max(fileSizeInBytes, 0.1).toFixed(1)).toLocaleString(Qt.locale(), "f", 0)).arg(byteUnits[i]);

    }

    property alias webMapsModel: webMapsModel
    ListModel {
        id: webMapsModel
    }

    property alias localMapPackages: localMapPackages
    ListModel {
        id: localMapPackages
    }

    property alias onlineMapPackages: onlineMapPackages
    ListModel {
        id: onlineMapPackages
    }

    property alias mmpkManager: mmpkManager
    Controls.MmpkManager {
        id: mmpkManager

        rootUrl: "%1/sharing/rest/content/items/".arg(portalUrl)
        subFolder: [app.appId, app.portalSearch.offlineFolder].join("/")
    }

    //---------------------------PORTAL-----------------------------------------

    property Portal portal: isSignedIn ? securedPortal : publicPortal
    property Portal securedPortal
    property Portal publicPortal

    property bool isSignedIn: app.securedPortal ? app.securedPortal.loadStatus === Enums.LoadStatusLoaded && app.securedPortal.credential.token > "" : false

    onIsSignedInChanged: {
        if (isSignedIn) {
            setRefreshToken()
            refreshTokenTimer.start()
        } else {
            if (!refreshTokenTimer.isRefreshing) {
                clearRefreshToken()
            }
            refreshTokenTimer.stop()
            loadPublicPortal()

        }
    }


    Connections {
        target: securedPortal

        onLoadStatusChanged: {
            switch (securedPortal.loadStatus) {
            case Enums.LoadStatusFailedToLoad:
                securedPortal.retryLoad()
                break
            case Enums.LoadStatusLoaded:
                portalSearch.clearResults()
                webMapsModel.clear()
                localMapPackages.clear()
                onlineMapPackages.clear()
                if(securedPortal.credential)
                {
                var promiseToFindPortalItems = credentialChanged(securedPortal.credential.token)
                promiseToFindPortalItems.then(function(token){
                    if (app.showAllMaps){
                        portalSearch.findItems(app.portalUrl, queryParametersMMPK, token)
                    }
                    portalSearch.findItems(app.portalUrl, queryParameters, token)

                    securedPortal.fetchBasemaps()
                }, function(err){
                    clearRefreshToken()
                    messageDialog.show(qsTr("Fetch Basemaps"),qsTr("Invalid Token"))

                }
                )
                }

                if (app.settings.value("useBiometricAuthentication", "") !== true &&
                        app.settings.value("useBiometricAuthentication", "") !== false &&
                        app.canUseBiometricAuthentication) {
                    biometricController.showBiometricDialog()
                }
                break
            }
        }
    }

    Connections {
        target: AppFramework.network
        onOnlineStateChanged: {
            if(!Networking.isOnline)
                toastMessage.show(qsTr("Your device is now offline."))

        }
    }

    Connections {
        target: publicPortal

        onLoadStatusChanged: {
            switch (publicPortal.loadStatus) {
            case Enums.LoadStatusFailedToLoad:
                publicPortal.retryLoad()
                break
            case Enums.LoadStatusLoaded:
                portalSearch.clearResults()
                webMapsModel.clear()
                localMapPackages.clear()
                onlineMapPackages.clear()
                if (app.showAllMaps){
                    portalSearch.findItems(app.portalUrl, queryParametersMMPK)
                }
                portalSearch.findItems(app.portalUrl, queryParameters)
                publicPortal.fetchBasemaps()
                break
            }
        }
    }



    function credentialChanged(token)
    {
        return new Promise(function(resolve,reject){
            if(token)
            {
                resolve(token)
            }
            else
                reject(new Error("invalid token"))
        }
        )
    }

    function signOut () {
        if (securedPortal) {
            securedPortal.destroy()
        }
        AuthenticationManager.credentialCache.removeAllCredentials()
        clearRefreshToken()
        loadPublicPortal ()
    }

    function getAutoSignInProps () {
        return {
            "oAuthRefreshToken": secureStorage.getContent("oAuthRefreshToken"),
            "tokenServiceUrl": app.settings.value("tokenServiceUrl", ""),
            "previousPortalUrl": app.settings.value("portalUrl", ""),
            "clientId": app.settings.value("clientId", "")
        }
    }

    function setRefreshToken () {
        secureStorage.setContent("oAuthRefreshToken", securedPortal.credential.oAuthRefreshToken)
        app.settings.setValue("tokenServiceUrl", securedPortal.credential.tokenServiceUrl)
        app.settings.setValue("portalUrl", securedPortal.url)
        app.settings.setValue("clientId", securedPortal.credential.oAuthClientInfo.clientId)
    }

    function clearRefreshToken () {
        secureStorage.clearContent("oAuthRefreshToken")
        app.settings.setValue("tokenServiceUrl", "")
        app.settings.setValue("portalUrl", "")
        app.settings.setValue("clientId", "")
        app.settings.setValue("useBiometricAuthentication", "")
    }

    function createCredential (clientId, oAuthRefreshToken, tokenServiceUrl) {
        var oAuthClientInfo = ArcGISRuntimeEnvironment.createObject("OAuthClientInfo", {oAuthMode: Enums.OAuthModeUser, clientId: clientId})
        var credential = ArcGISRuntimeEnvironment.createObject("Credential", {oAuthClientInfo: oAuthClientInfo})
        if (tokenServiceUrl && oAuthRefreshToken) {
            credential.oAuthClientInfo = oAuthClientInfo
            credential.oAuthRefreshToken = oAuthRefreshToken
            credential.tokenServiceUrl = tokenServiceUrl
        }
        return credential
    }

    function loadSecuredPortal (callback) {
        var autoSignInProps = getAutoSignInProps()
        var credential = createCredential(app.clientId, autoSignInProps.oAuthRefreshToken, autoSignInProps.tokenServiceUrl)
        app.securedPortal = ArcGISRuntimeEnvironment.createObject("Portal", {url: portalUrl, credential: credential, sslRequired: false})

        portalSearch.clearResults()
        app.securedPortal.load()

        if (callback) callback()
    }

    function loadPublicPortal () {
        if (publicPortal) publicPortal.destroy()
        portalSearch.clearResults()
        app.publicPortal = ArcGISRuntimeEnvironment.createObject("Portal", {url: portalUrl})
        app.publicPortal.load()
    }

    PortalQueryParametersForItems {
        id: queryParameters

        types: {
            if (app.showAllMaps) {
                return [Enums.PortalItemTypeWebMap]
            } else if (app.showOfflineMapsOnly) {
                return [Enums.PortalItemTypeMobileMapPackage]
            } else {
                return [Enums.PortalItemTypeWebMap]
            }
        }
        searchString: app.searchQuery
        sortOrder: Enums.PortalQuerySortOrderDescending
        sortField: "modified"
        limit: app.maxNumberOfQueryResults
    }

    PortalQueryParametersForItems {
        id: queryParametersMMPK

        types: {

            return [Enums.PortalItemTypeMobileMapPackage]

        }
        searchString: app.searchQuery ? app.searchQuery:"mmpk"
        sortOrder: Enums.PortalQuerySortOrderDescending
        sortField: "modified"
        limit: app.maxNumberOfQueryResults
    }

    function getThumbnailUrl (portalUrl, portalItem, token) {
        try {
            if (portalItem.thumbnailUrl) return portalItem.thumbnailUrl
        } catch (err) {}

        var imgName = portalItem.thumbnail
        if (!imgName) {
            return ""
        }
        var urlFormat = "%1/sharing/rest/content/items/%2/info/%3%4",
        prefix = ""
        if (token) {
            prefix = "?token=%1".arg(token)
        }
        return urlFormat.arg(portalUrl).arg(portalItem.id).arg(imgName).arg(prefix)
    }

    //--------------------------------------------------------------------------

    Controls.SecureStorageHelper {
        id: secureStorage
    }

    //------------------BIOMETRIC AUTHENTICATION--------------------------------

    Connections {
        id: biometricController

        property var biometricDialogs: []
        readonly property string kTouchIdFailed: qsTr("Unable to verify using Touch ID. Please sign in again.")
        readonly property string kFaceIdFailed: qsTr("Unable to verify using Face ID. Please sign in again.")

        target: BiometricAuthenticator

        onAccepted: {
            loadSecuredPortal()
        }

        onRejected: {
            signOut()
            clearRefreshToken()
            messageDialog.show("", app.hasFaceID ? biometricController.kFaceIdFailed : biometricController.kTouchIdFailed)
        }

        function showBiometricDialog () {
            biometricController.destroyBiometricDialogs()
            var biometricDialog = biometricDialogComponent.createObject(app)
            biometricDialog.open()
            biometricController.biometricDialogs.push(biometricDialog)
        }

        function destroyBiometricDialogs () {
            for (var i=0; i<biometricController.biometricDialogs.length; i++) {
                if (biometricController.biometricDialogs[i]) {
                    biometricController.biometricDialogs[i].destroy()
                }
            }
            biometricController.biometricDialogs = []
        }
    }

    Component {
        id: biometricDialogComponent

        Controls.MessageDialog {
            id: biometricDialog

            readonly property string kEnableTouchId: Qt.platform.os === "ios" || Qt.platform.os === "osx" ? qsTr("Enable Touch ID to sign in?") : qsTr("Enable Fingerprint Reader to sign in")
            readonly property string kEnableFaceId: qsTr("Enable Face ID to sign in?")
            readonly property string kTouchIdEnabled: qsTr("Touch ID enabled. Sign out to disable.")
            readonly property string kFaceIdEnabled: qsTr("Face ID enabled. Sign out to disable.")

            Material.primary: app.primaryColor
            Material.accent: app.accentColor
            title: app.hasFaceID ? kEnableFaceId : kEnableTouchId
            text: qsTr("Once enabled, the app will provide an easy and secured way to access your maps. You can always sign out at anytime to disable this feature.")
            standardButtons: Dialog.NoButton

            footer: DialogButtonBox {
                Button {
                    text: qsTr("Cancel")
                    Material.background: "transparent"
                    DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                }
                Button {
                    text: qsTr("Enable")
                    Material.background: "transparent"
                    DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                }
            }

            onAccepted: {
                app.settings.setValue("useBiometricAuthentication", true)
                toastMessage.show(app.hasFaceID ? kFaceIdEnabled : kTouchIdEnabled)
                biometricDialog.destroy()
            }

            onRejected: {
                app.settings.setValue("useBiometricAuthentication", false)
                biometricDialog.destroy()
            }
        }
    }

    //--------------------------------------------------------------------------

    Controls.ToastDialog {
        id: toastMessage
        enter: Transition {
                    NumberAnimation { property: "y"; from:parent.height; to:parent.height - 76 * scaleFactor}
                }
        exit:Transition {
            NumberAnimation { property: "y"; from:parent.height - 76 * scaleFactor; to:parent.height}
        }

        textColor: app.titleTextColor
    }



    //--------------------------------------------------------------------------

    property var signInPages: []
    Component {
        id: signInPageComponent

        Views.OAuth2View {
            id: signInPage

            portal: app.securedPortal
            iconSize: app.iconSize
            headerHeight: app.headerHeight

            onCloseButtonClickedChanged: {
                if (closeButtonClicked) {
                    signOut()
                }
            }

            onOpened: {
                loadSecuredPortal()
            }
        }
    }

    function hasVisibleSignInPage () {
        for (var i=0; i<signInPages.length; i++) {
            if (signInPages[i].visible) return true
        }
        return false
    }

    function createSignInPage () {
        var signInPage = signInPageComponent.createObject(app)
        signInPage.onClosed.connect(function () {
            destroySignInPage()
        })
        signInPages.push(signInPage)
        signInPage.open()
    }

    function destroySignInPage () {
        for (var i=0; i<signInPages.length; i++) {
            signInPages[i].visible = false
            signInPages[i].destroy()
        }
        signInPages = []
    }

    //--------------------------------------------------------------------------

    signal backButtonPressed ()

    focus: true

    Keys.onReleased: {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape){
            event.accepted = true
            backButtonPressed ()
        }
    }

    onBackButtonPressed: {
        if (aboutAppPage.visible) {
            aboutAppPage.close()
        } else if (hasVisibleSignInPage()) {
            destroySignInPage()
        }
    }

    //--------------------------------------------------------------------------

    property alias refreshTokenTimer: refreshTokenTimer
    Timer {
        id: refreshTokenTimer

        property bool isRefreshing: false
        property date lastRefreshed: new Date()

        signal tokenRefreshed ()

        onTokenRefreshed: {
            lastRefreshed = new Date()
        }

        interval: 1800000 // 30 minutes
        running: false
        repeat: true

        onTriggered: {
            refreshToken ()
        }

        function refreshToken () {
            isRefreshing = true
            getNewToken(function () {
                isRefreshing = false
                tokenRefreshed()
            })

        }

        function getNewToken(){
            var autoSignInProps = getAutoSignInProps()
            var credential = createCredential(app.clientId, autoSignInProps.oAuthRefreshToken, autoSignInProps.tokenServiceUrl)
            securedPortal.credential.oAuthRefreshToken = autoSignInProps.oAuthRefreshToken
            securedPortal.credential.tokenServiceUrl = credential.tokenServiceUrl
            securedPortal.credential.oAuthClientInfo.clientId = credential.oAuthClientInfo.clientId

            setRefreshToken()
        }
    }

    Connections {
        target: Qt.application

        onStateChanged: {
            switch (Qt.application.state) {
            case Qt.ApplicationActive:
                var autoSignInProps = getAutoSignInProps()
                if (autoSignInProps.oAuthRefreshToken && autoSignInProps.tokenServiceUrl && app.supportSecuredMaps) {
                    if (!refreshTokenTimer.isRefreshing && (new Date() - refreshTokenTimer.lastRefreshed >= refreshTokenTimer.interval)) {
                        refreshTokenTimer.refreshToken()
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        initialize()
    }

    function setSystemProps () {
        var sysInfo = typeof AppFramework.systemInformation !== "undefined" && AppFramework.systemInformation ? AppFramework.systemInformation : ""
        if (!sysInfo) return
        if (Qt.platform.os === "ios" && sysInfo.hasOwnProperty("unixMachine")) {
            if (sysInfo.unixMachine === "iPhone10,3" || sysInfo.unixMachine === "iPhone10,6") {
                app.isIphoneX = true
            }
        } else if (Qt.platform.os === "windows") {
            var kernelVersionPattern = /^6\.1/
            var osVersionPattern = /^7/
            isWindows7 = kernelVersionPattern.test(AppFramework.kernelVersion) && osVersionPattern.test(AppFramework.osVersion)
        }
    }

    function initialize () {
        setSystemProps()
        var autoSignInProps = getAutoSignInProps()
        if (app.isOnline)
        {
            if (autoSignInProps.oAuthRefreshToken && autoSignInProps.tokenServiceUrl && autoSignInProps.previousPortalUrl === app.portalUrl.toString() && app.supportSecuredMaps) {
                if (app.isOnline && app.settings.value("useBiometricAuthentication", false) && app.canUseBiometricAuthentication) {
                    if (Qt.platform.os === "osx") {
                        BiometricAuthenticator.message = qsTr("authenticate")
                    } else {
                        BiometricAuthenticator.message = qsTr("Please authenticate to proceed.")
                    }
                    BiometricAuthenticator.authenticate()
                } else {
                    loadSecuredPortal()
                }
            } else {
                loadPublicPortal()
            }
            if (app.supportSecuredMaps && (app.portalUrl.toString() !== app.settings.value("portalUrl") || autoSignInProps.clientId !== app.clientId)) {
                signOut()
                clearRefreshToken()
            }

        }


        app.fontScale = app.settings.value("fontScale", 1.0)

        if (!isOnline) {
            portalSearch.populateLocalMapPackages()

        }
    }

    //--------------------------------------------------------------------------

    function getProperty (name, fallback) {
        if (!fallback && typeof fallback !== "boolean") fallback = ""
        return app.info.propertyValue(name, fallback) || fallback
    }

    function getClientId (fallback) {
        if (!fallback) fallback = ""
        try {
            return app.info.json.deployment.clientId
        } catch (err) {
            return fallback
        }
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }

    //--------------------------------------------------------------------------

    function randomColor (colortype) {
        var types = {
            "primary": ["#4A148C", "#0D47A1", "#004D40", "#006064", "#1B5E20", "#827717", "#3E2723"],
            "background": ["#F5F5F5", "#EEEEEE"],
            "foreground": ["#22000000"],
            "accent": ["#FF9800", "yellow", "red"]
        },
        type = types[colortype]
        return type[Math.floor(Math.random() * type.length)]
    }

    //--------------------------------------------------------------------------
}
