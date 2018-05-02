import QtQuick 2.7

import ArcGIS.AppFramework 1.0

Item {
    id: portal

    property alias timer: timer

    property string portalName: ""
    property string tag: ""
    property string name: ""
    readonly property url portalUrl: url // TODO: Legacy code workaround to be removed
    property url url: app.appPortalUrl
    property url tokenServicesUrl
    property url owningSystemUrl: portalUrl
    readonly property url restUrl: owningSystemUrl + "/sharing/rest"
    property string username
    property string password
    property string token
    property bool ssl
    property bool ignoreSslErrors: true
    property date expires
    readonly property bool signedIn: token > "" && info && user
    property int expiryMode: expiryModeRenew
    property bool isPortal
    property bool supportsOAuth: true

    property Settings settings
    readonly property string settingsGroup : tag

    property int expiryModeSignal: 0
    property int expiryModeSignOut: 1
    property int expiryModeSignIn: 2
    property int expiryModeRenew: 3
    property var info: null
    property var user: null
    property url userThumbnailUrl: user && user.thumbnail>""? restUrl + "/community/users/" + username + "/info/" + user.thumbnail + "?token=" + token : ""
    property string userFullName: user && user.fullName > "" ? user.fullName : ""

    signal expired()
    signal error(var error)

    property bool isBusy: false

    /*--------------------------------------------------------------------------*/

    property string clientID: ""
    property string refreshToken: ""
    property date lastLogin
    property date lastRenewed

    readonly property string keyRefreshToken: "/refreshToken"
    readonly property string keyDateSaved: "/dateSaved"
    readonly property string keyPortalURL: "/portalUrl"

    /*--------------------------------------------------------------------------*/

    property string userAgent

    Component.onCompleted: {
        userAgent = buildUserAgent(app);
        readSettings();
    }

    /*--------------------------------------------------------------------------*/

    function autoSignIn() {
        if (!settings) {
            return;
        }

        if (!supportsOAuth) {
            return;
        }

        var refreshToken = settings.value(settingsGroup + keyRefreshToken, "")

        var dateSaved = settings.value(settingsGroup + keyDateSaved, "")

        var url = settings.value(settingsGroup + keyPortalURL, "")

        if (url > "") {
            portal.url = url;
        }

        lastLogin = dateSaved > "" ? new Date(dateSaved) : new Date()

        if (clientID > "" && refreshToken > "") {
            getTokenFromRefreshToken(clientID, refreshToken);
        }
    }

    function writeSignedInState() {
        if (!settings) {
            return;
        }

        settings.setValue(settingsGroup + keyRefreshToken, portal.refreshToken);
        settings.setValue(settingsGroup + keyDateSaved, new Date().toString());
        settings.setValue(settingsGroup + keyPortalURL, portal.portalUrl);
    }

    function clearSignedInState() {
        if (!settings) {
            return;
        }

        settings.remove(settingsGroup + keyRefreshToken);
        settings.remove(settingsGroup + keyDateSaved);
        settings.remove(settingsGroup + keyPortalURL);
    }

    /*--------------------------------------------------------------------------*/

    function getTokenFromCode(client_id, redirect_uri, auth_code) {
        if (auth_code > "" && client_id > "") {
            portal.isBusy = true;
            portal.refreshToken = "";
            portal.clientID = client_id;

            var params = {};
            params.grant_type = "authorization_code";
            params.client_id = client_id;
            params.code = auth_code;
            params.redirect_uri = redirect_uri;
            timer.stop();

            oAuthAccessTokenFromAuthCodeRequest.headers.userAgent = portal.userAgent;
            oAuthAccessTokenFromAuthCodeRequest.send(params);
        }
    }

    function getTokenFromRefreshToken(client_id, refresh_token) {
        if (refresh_token > "" && client_id > "") {
            portal.isBusy = true;
            portal.refreshToken = refresh_token;
            portal.clientID = client_id;

            var params = {};
            params.grant_type = "refresh_token";
            params.client_id = client_id;
            params.refresh_token = refresh_token;
            timer.stop();

            oAuthAccessTokenFromAuthCodeRequest.headers.userAgent = portal.userAgent;
            oAuthAccessTokenFromAuthCodeRequest.send(params);
        }
    }

    NetworkRequest {
        id: oAuthAccessTokenFromAuthCodeRequest

        url: portalUrl + "/sharing/rest/oauth2/token"
        responseType: "json"
        ignoreSslErrors: portal.ignoreSslErrors

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                if(response.refresh_token) {
                    portal.refreshToken = response.refresh_token;
                }

                portal.username = response.username || "";
                portal.token = response.access_token || "";

                var now = new Date();
                portal.lastRenewed = now;
                portal.expires = new Date(now.getTime() + response.expires_in * 1000);

                timer.interval = portal.expires - Date.now() - 5000;
                timer.start();

                portal.isBusy = false;

                selfRequest.sendRequest();
                userRequest.sendRequest();
            }
        }

        onErrorTextChanged: {
            portal.isBusy = false;
        }
    }


    /*--------------------------------------------------------------------------*/

    function renew() {
        if (portal.refreshToken > "" && portal.clientID > "" && portal.supportsOAuth && signedIn) {
            getTokenFromRefreshToken(portal.clientID, portal.refreshToken)
        } else {
            signOut();
        }
    }


    function signIn(user, pass) {
        username = user;
        password = pass;

        if (tokenServicesUrl > "") {
            generateToken.generateToken(username, password);
        } else {
            infoRequest.headers.userAgent = portal.userAgent;
            infoRequest.send();
        }
    }

    function signOut() {
        token = "";
        user = null;
    }

    /*--------------------------------------------------------------------------*/

    onUrlChanged: {
    }

    onPortalUrlChanged: {
        tokenServicesUrl = "";
    }

    /*--------------------------------------------------------------------------*/

    Timer {
        id: timer

        onTriggered: {
            switch (expiryMode) {
            case expiryModeSignIn:
                signIn();
                break;

            case expiryModeSignOut:
                signOut();
                break;

            case expiryModeRenew:
                renew();
                break;

            default:
                expired();
                break;
            }
        }
    }

    NetworkRequest {
        id: infoRequest

        url: portalUrl + "/sharing/rest/info?f=json"
        responseType: "json"
        ignoreSslErrors: portal.ignoreSslErrors

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                tokenServicesUrl = response.authInfo.tokenServicesUrl;
                owningSystemUrl = response.owningSystemUrl;
                generateToken.generateToken(username, portal.password);
            }
        }

        onErrorTextChanged: {
            console.log("infoRequest error", errorText);
        }
    }

    NetworkRequest {
        id: generateToken

        url: tokenServicesUrl
        method: "POST"
        responseType: "json"
        uploadPrefix: ""
        ignoreSslErrors: portal.ignoreSslErrors

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                if (response.error) {
                    portal.error(response.error);
                } else if (response.token) {
                    token  = response.token;
                    expires = new Date(response.expires);
                    ssl = response.ssl;
                    timer.interval = expires - Date.now() - 5000;
                    timer.start();

                    selfRequest.sendRequest();
                    userRequest.sendRequest();
                }
            }
        }

        onErrorTextChanged: {
            portal.error( { message: errorText, details: "" });
        }

        function generateToken(username, password, expiration, referer) {

            if (!expiration) {
                expiration = 120;
            }
            if (!referer) {
                referer = portalUrl;
            }
            var formData = {
                "username": username,
                "password": password,
                "referer": referer,
                "expiration": expiration,
                "f": "json"
            };

            headers.userAgent = portal.userAgent;
            send(formData);
        }
    }

    NetworkRequest {
        id: selfRequest

        url: restUrl + "/portals/self"
        method: "POST"
        responseType: "json"
        ignoreSslErrors: portal.ignoreSslErrors

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                portal.info = response;
                portalName = response.name;
            }
        }

        onErrorTextChanged: {
            console.log("selfRequest error", errorText);
        }

        function sendRequest() {
            var formData = {
                f: "pjson"
            };

            if (portal.token > "") {
                formData.token = portal.token;
            }

            headers.userAgent = portal.userAgent;
            send(formData);
        }
    }

    NetworkRequest {
        id: userRequest

        url: restUrl + "/community/users/" + username
        method: "POST"
        responseType: "json"
        ignoreSslErrors: portal.ignoreSslErrors

        onReadyStateChanged: {
            if (readyState === NetworkRequest.ReadyStateComplete)
            {
                portal.user = response;
            }
        }

        onErrorTextChanged: {
            console.log("userRequest error", errorText);
        }

        function sendRequest() {
            var formData = {
                f: "pjson"
            };

            if (portal.token > "") {
                formData.token = portal.token;
            }

            headers.userAgent = portal.userAgent;
            send(formData);
        }
    }

    /*--------------------------------------------------------------------------*/

    function readSettings() {
        if (!settings) {
            return false;
        }

        url = settings.value(settingsGroup + "/url", url);
        name = settings.value(settingsGroup + "/name", "Assistant");
        ignoreSslErrors = settings.boolValue(settingsGroup + "/ignoreSslErrors", false);
        isPortal = settings.boolValue(settingsGroup + "/isPortal", false);
        supportsOAuth = settings.boolValue(settingsGroup + "/supportsOAuth", true);
        readUserSettings();

        return true;
    }

    function writeSettings() {
        if (!settings) {
            return false;
        }

        settings.setValue(settingsGroup + "/url", url);
        settings.setValue(settingsGroup + "/name", name);
        settings.setValue(settingsGroup + "/ignoreSslErrors", ignoreSslErrors);
        settings.setValue(settingsGroup + "/isPortal", isPortal);
        settings.setValue(settingsGroup + "/supportsOAuth", supportsOAuth);

        return true;
    }

    /*--------------------------------------------------------------------------*/

    function readUserSettings() {
        if (!settings) {
            return false;
        }

        username = settings.value(settingsGroup + "/username", "");

        return true;
    }

    function writeUserSettings() {
        if (!settings) {
            return false;
        }

        settings.setValue(settingsGroup + "/username", portal.username);
    }

    function clearUserSettings() {
        if (!settings) {
            return false;
        }

        settings.remove(settingsGroup + "/username");
        settings.remove(settingsGroup + "/password");
    }

    function rot13(s) {
        return s.replace(/[A-Za-z]/g, function (c) {
            return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".charAt(
                        "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm".indexOf(c)
                        );
        } );
    }

    /*--------------------------------------------------------------------------*/

    function buildUserAgent(app) {
        var userAgent = "";

        function addProduct(name, version, comments) {
            if (!(name > "")) {
                return;
            }

            if (userAgent > "") {
                userAgent += " ";
            }

            name = name.replace(/\s/g, "");
            userAgent += name;

            if (version > "") {
                userAgent += "/" + version.replace(/\s/g, "");
            }

            if (comments) {
                userAgent += " (";

                for (var i = 2; i < arguments.length; i++) {
                    var comment = arguments[i];

                    if (!(comment > "")) {
                        continue;
                    }

                    if (i > 2) {
                        userAgent += "; "
                    }

                    userAgent += arguments[i];
                }

                userAgent += ")";
            }

            return name;
        }

        function addAppInfo(app) {
            var deployment = app.info.value("deployment");

            if (!deployment || typeof deployment !== "object") {
                deployment = {};
            }

            var appName = deployment.shortcutName > ""
                    ? deployment.shortcutName
                    : app.info.title;

            var udid = app.settings.value("udid", "");

            if (!(udid > "")) {
                udid = AppFramework.createUuidString(2);
                app.settings.setValue("udid", udid);
            }

            appName = addProduct(appName, app.info.version, Qt.locale().name, AppFramework.currentCpuArchitecture, udid)

            return appName;
        }

        if (app) {
            addAppInfo(app);
        } else {
            addProduct(Qt.application.name, Qt.application.version, Qt.locale().name, AppFramework.currentCpuArchitecture, Qt.application.organization);
        }

        addProduct(Qt.platform.os, AppFramework.osVersion, AppFramework.osDisplayName);
        addProduct("AppFramework", AppFramework.version, "Qt " + AppFramework.qtVersion, AppFramework.buildAbi);
        addProduct(AppFramework.kernelType, AppFramework.kernelVersion);

        return userAgent;
    }
}
