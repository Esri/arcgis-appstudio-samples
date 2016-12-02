import QtQuick 2.5
import QtQuick.Window 2.0

Item {
    property string sdkVersion: "QMLSDK (%1):1.0.1".arg(Qt.platform.os)

    property string os: Qt.platform.os
    property string osName: Qt.platform.os
    property string osVersion

    property string appVersion: Qt.application.version
    property string appId
    property string appPackageId
    readonly property string appVersionCode: formatVersion(appVersion, os)
    readonly property string appVersionName: formatVersion(appVersion, os, true)

    property var deviceLocale: Qt.locale()
    property string deviceLanguage: deviceLocale.name.substr(0, 2)
    property string deviceId: createUuid()
    property string deviceManufacturer: lookupDeviceManufacturer(os)
    property string deviceModel: lookupDeviceModel(os)
    property string deviceType: lookupDeviceType(os)

    property string userName
    property string userEmail

    property string sessionId
    property bool sessionIsFirst: false
    property bool sessionIsNew: true

    property string reportGroupKey: formatUuid(createUuid())

    property string token
    property url appsUrl: "https://rink.hockeyapp.net/api/2/apps/"
    property url trackUrl: "https://gate.hockeyapp.net/v2/track"

    property var availableUpdates: []

    property bool debug: true

    //--------------------------------------------------------------------------

    function readyCheck(action, requiresToken) {
        if (!enabled) {
            return false;
        }

        if (requiresToken && !(token > "")) {
            console.error("Undefined token:", action);
            return;
        }

        if (!(deviceId > "")) {
            console.error("Undefined deviceId:", action);
            return;
        }

        if (!(appId > "")) {
            console.error("Undefined appId:", action);
            return;
        }

        if (!(appPackageId > "")) {
            console.error("Undefined appPackage:", action);
            return;
        }

        if (!(appVersion > "")) {
            console.error("Undefined appVerision:", action);
            return;
        }

        return true;
    }

    //--------------------------------------------------------------------------

    function lookupDeviceManufacturer(os) {
        switch (os) {
        case "osx":
        case "ios":
            return "Apple";

        default:
            return "Unknown";
        }
    }

    function lookupDeviceModel(os) {
        return "Unknown";
    }

    function lookupDeviceType(os) {
        switch (os) {
        case "winphone":
            return "Phone";

        case "ios":
        case "android":
            return "Mobile";

        case "osx":
        case "windows":
        case "linux":
        case "unix":
            return "Desktop";

        default:
            return "Unknown";
        }
    }

    //--------------------------------------------------------------------------

    function formatVersion(ver, os, versionName) {
        var parts = ver.split(".");
        for (var i = parts.length; i < 4; i++) {
            parts[i] = "0";
        }

        var ver3 = "%1.%2.%3".arg(parts[0]).arg(parts[1]).arg(parts[2]);
        var verNum = (parts[0] * 1000000 + parts[1] * 1000 + Number(parts[2])).toFixed(0);

        switch (os) {
        case "android":
            return versionName ? ver3 : verNum;

        case "winphone":
        case "winrt":
            return "%1.%2".arg(ver3).arg(parts[3]);

        default:
            return ver3;
        }
    }

    //--------------------------------------------------------------------------

    function startSession(newSession) {
        if (newSession) {
            sessionId = createUuid();
        }

        sessionTimer.start();
    }

    Timer {
        id: sessionTimer

        interval: 100
        repeat: false

        onTriggered: {
            sendSessionState();
        }
    }

    function sendSessionState() {
        console.log("sendSessionState");
        if (!readyCheck(arguments.callee.name)) {
            return;
        }

        var sessionData = createTelemetryData(
                    "Microsoft.ApplicationInsights.SessionState",
                    "SessionStateData",
                    2);

        sessionData.data.baseData.state = 0;

        sendTelemetry(sessionData);
    }

    //--------------------------------------------------------------------------

    function trackEvent(name, properties, measurements) {
        if (!readyCheck(arguments.callee.name)) {
            return;
        }

        if (!(name > "")) {
            console.error("trackEvent: No name specified");
            return;
        }

        var eventData = createTelemetryData(
                    "Microsoft.ApplicationInsights.Event",
                    "EventData",
                    2);

        var baseData = eventData.data.baseData;

        baseData.name = name;

        if (properties) {
            baseData.properties = properties;
        }

        if (measurements) {
            baseData.measurements = measurements;
        }

        sendTelemetry(eventData);
    }

    //--------------------------------------------------------------------------

    function sendTelemetry(telemetryData) {
        if (debug) {
            console.log("sendTelemetry:", JSON.stringify(telemetryData, undefined, 2));
        }

        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (debug) {
                    console.log("sendTelemetry response:", request.responseText);
                }
            }
        }

        request.open("POST", trackUrl);
        request.send(JSON.stringify(telemetryData));

        return request;
    }

    //--------------------------------------------------------------------------

    function createTelemetryData(envelopeTypeName, dataTypeName, dataVersion) {
        if (!(sessionId > "")) {
            sessionId = createUuid();
        }

        var telemetryData = {
            "ver": 1,
            "name": envelopeTypeName,
            "time": new Date().toISOString(),
            "sampleRate": 100,
            "iKey": formatUuid(appId),
            "tags": {
                "ai.application.ver": "%2 (%1)".arg(appVersionCode).arg(appVersionName),
                "ai.internal.sdkVersion": sdkVersion,
                "ai.device.id": formatUuid(deviceId),
                "ai.device.language": deviceLanguage,
                "ai.device.locale": deviceLocale.name,
                "ai.device.model": deviceModel,
                "ai.device.oemName": deviceManufacturer,
                "ai.device.os": osName,
                "ai.device.osVersion": osVersion,
                "ai.device.screenResolution": "%1x%2".arg(Screen.width).arg(Screen.height),
                "ai.device.type": deviceType,
                "ai.session.id": formatUuid(sessionId),
                "ai.session.isFirst": sessionIsFirst.toString(),
                "ai.session.isNew": sessionIsNew.toString()
            },
            "data": {
                "baseType": dataTypeName,
                "baseData": {
                    "ver": dataVersion
                }
            }
        };

        var tags = telemetryData.tags;

        if (userEmail > "") {
            tags["ai.user.id"] = userEmail;
        }

        return telemetryData;
    }

    //--------------------------------------------------------------------------

    function reportCrash(log, description) {
        if (!readyCheck(arguments.callee.name)) {
            return;
        }

        var url = appsUrl + appId + "/crashes/js";


        var data = [];

        function addParameter(name, value) {
            data.push("%1: %2".arg(name).arg(value));
        }

        addParameter("Package", appPackageId);
        if (false) {
            addParameter("Version", appVersionCode);
        } else {
            addParameter("Version Name", appVersionName);
            addParameter("Version Code", appVersionCode);
        }
        addParameter("Language", deviceLanguage);
        addParameter("OS", osName);
        addParameter("Manufacturer", deviceManufacturer);
        addParameter("Model", deviceModel);
        addParameter("CrashReporter Key", reportGroupKey);

        data.push("");

        if (Array.isArray(log)) {
            data.push(log.join("\n"));
        } else {
            data.push(log.toString());
        }


        url += "?raw=" + escape(data.join("\n"));

        if (description > "") {
            url += "&description=" + escape(description);
        }

        if (userName > "") {
            url += "&userID=" + escape(userName);
        }

        if (userEmail > "") {
            url += "&contact=" + escape(userEmail);
        }

        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (debug) {
                    console.log("Crash report response:", request.responseText);
                }
            }
        }

        request.open("GET", url);
        request.send();
    }

    //--------------------------------------------------------------------------

    function reportError(error, description) {
        var log = [];

        log.push("%1: %2".arg(error.name).arg(error.message));

        error.stack.split("\n").forEach(function (stackItem) {
            var at = stackItem.match(/([\s\S]+)@([\s\S]+):([0-9]+)/);
            log.push("  at %1(%2:%3)".arg(at[1]).arg(at[2]).arg(at[3]));
        });

        reportCrash(log, description);
    }

    //--------------------------------------------------------------------------

    function checkForUpdates(allVersions) {
        if (!readyCheck(arguments.callee.name, true)) {
            return;
        }

        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                var versions = JSON.parse(request.responseText);
                if (debug) {
                    console.log(JSON.stringify(versions, undefined, 2));
                }
                var updates = [];

                if (versions.app_versions) {
                    versions.app_versions.forEach(function (appInfo) {
                        if (appInfo.download_url > "" && (allVersions || compareVersions(appInfo.shortversion, appVersion) > 0)) {
                            updates.push(appInfo);
                        }
                    });
                } else {
                    console.error("No versions returned");
                }

                availableUpdates = updates;

                if (debug) {
                    console.log("updates:", JSON.stringify(updates, undefined, 2));
                }
            }
        }

        var url = appsUrl + appId + "/app_versions";

        request.open("GET", url);
        request.setRequestHeader("X-HockeyAppToken", token);
        request.send();
    }

    //--------------------------------------------------------------------------

    function compareVersions(v1, v2, maxParts) {
        if (!maxParts) {
            maxParts = 3;
        }

        var ver1 = v1.split(".");
        var ver2 = v2.split(".");

        for (var i = v1.length; i < maxParts; i++) {
            ver1[i] = 0;
        }

        for (i = v2.length; i < maxParts; i++) {
            ver2[i] = 0;
        }

        var result = 0;

        for (i = 0; i < maxParts && result == 0; i++) {
            if (Number(ver1[i]) > Number(ver2[i])) {
                result = 1;
            } else if (Number(ver1[i]) < Number(ver2[i])) {
                result = -1;
            }
        }

        if (debug) {
            console.log("ver1:", JSON.stringify(ver1), "ver2:", JSON.stringify(ver2), "result:", result);
        }

        return result;
    }

    //--------------------------------------------------------------------------

    function sendFeedback(text, parameters) {
        if (!readyCheck(arguments.callee.name, true)) {
            return;
        }

        if (!parameters) {
            parameters = {};
        }

        if (!parameters.oem && deviceManufacturer > "") {
            parameters.oem = deviceManufacturer;
        }

        if (!parameters.model && deviceModel > "") {
            parameters.model = deviceModel;
        }

        if (!parameters.os_version && osVersion > "") {
            parameters.os_version = osVersion;
        }

        if (!parameters.lang) {
            parameters.lang = deviceLanguage;
        }

        if (!parameters.name && userName > "") {
            parameters.name = userName;
        }

        if (!parameters.email && userEmail > "") {
            parameters.email = userEmail;
        }

        if (!parameters.lang) {
            parameters.lang = deviceLanguage;
        }

        if (!parameters.bundle_version) {
            parameters.bundle_version = "%1 (%2)".arg(appVersionName).arg(appVersionCode)
        }

        if (!parameters.install_string) {
            parameters.install_string = deviceId;
        }

        var url = appsUrl + appId + "/feedback";

        function addParameter(name, value, first) {
            url += (first ? "?" : "&") + name + "=" + escape(value);
        }

        addParameter("text", text, true);

        Object.keys(parameters).forEach(function (key) {
            addParameter(key, parameters[key]);
        });

        var request = new XMLHttpRequest();

        request.onreadystatechange = function() {
            if (request.readyState === XMLHttpRequest.DONE) {
                if (debug) {
                    console.log("Feedback response:", request.responseText);
                }
            }
        }

        if (debug) {
            console.log("Feedback:", url);
        }

        request.open("POST", url);
        request.setRequestHeader("X-HockeyAppToken", token);
        request.send();
    }

    //--------------------------------------------------------------------------

    property var createUuid: function () {
        var uuid = '';

        for (var index = 0; index < 32; index++) {
            uuid += "0123456789abcdef".charAt(Math.floor(Math.random() * 16));
        }

        return uuid;
    }

    //--------------------------------------------------------------------------

    function formatUuid(uuid) {
        return "%1-%2-%3-%4-%5"
        .arg(uuid.substr(0, 8))
        .arg(uuid.substr(8, 4))
        .arg(uuid.substr(12, 4))
        .arg(uuid.substr(16, 4))
        .arg(uuid.substr(20, 12));
    }

    //--------------------------------------------------------------------------
}
