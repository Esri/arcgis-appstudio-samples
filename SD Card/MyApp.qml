/* Copyright 2021 Esri
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
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Networking 1.0

import "controls" as Controls

App {
    id: app
    width: 400
    height: 640

    Material.accent: Material.Teal

    function units(value) {
        return AppFramework.displayScaleFactor * value
    }

    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize: app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)
    property var internalStorage: AppFramework.standardPaths.standardLocations(StandardPaths.AppDataLocation);
    property string externalStorage
    property string sdCardPath
    property var mountedVols: []
    property string androidPackageName: (app.info.value("deployment", {}).android || {}).packageName
    property string dataPath: AppFramework.userHomeFolder.filePath("ArcGIS/AppStudio/Data")
    property string dataFile: "SanFrancisco.tpk"
    //    property string inputData : dataPath + "/" + dataFile
    property bool isRunningInPlayer: false
    property bool isSDCardPresent: false

    property string osName: AppFramework.osName

    property bool readComplete: false
    property bool writeComplete: false
    property bool copyComplete: false
    property bool downloadComplete: false
    property bool isOnline: Networking.isOnline

    Page {
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        // sample starts here ------------------------------------------------------------------
        contentItem: Rectangle {
            anchors.top: header.bottom

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                spacing: 5

                Row {
                    spacing: 10

                    Image {
                        width: 30
                        height: 30
                        source: "tick.png"
                        visible: !busyIndicatorRead.visible
                    }

                    BusyIndicator {
                        id: busyIndicatorRead
                        width: 30
                        height: width
                        visible: !readComplete
                        running: visible
                    }

                    Text {
                        font.pointSize: 20
                        color: busyIndicatorRead.running ? "gray" : "teal"
                        text: busyIndicatorRead.running ? "Reading..." : "Read complete"
                    }
                }

                Row {
                    spacing: 10

                    Image {
                        width: 30
                        height: 30
                        source: "tick.png"
                        visible: !busyIndicatorWrite.visible
                    }

                    BusyIndicator {
                        id: busyIndicatorWrite
                        width: 30
                        height: width
                        visible: !writeComplete
                        running: visible
                    }

                    Text {
                        font.pointSize: 20
                        color: busyIndicatorWrite.running ? "gray" : "teal"
                        text: busyIndicatorWrite.running ? "Writing..." : "Write complete"
                    }
                }

                Row {
                    spacing: 10

                    Image {
                        width: 30
                        height: 30
                        source: "tick.png"
                        visible: !busyIndicatorCopy.visible
                    }

                    BusyIndicator {
                        id: busyIndicatorCopy
                        width: 30
                        height: width
                        visible: !copyComplete
                        running: visible
                    }

                    Text {
                        font.pointSize: 20
                        color: busyIndicatorCopy.running ? "gray" : "teal"
                        text: busyIndicatorCopy.running ? "Copying..." : "Copy complete"
                    }
                }

                Row {
                    spacing: 10

                    Image {
                        width: 30
                        height: 30
                        source: "tick.png"
                        visible: !busyIndicatorDownload.visible
                    }

                    BusyIndicator {
                        id: busyIndicatorDownload
                        width: 30
                        height: width
                        visible: !downloadComplete
                        running: visible
                    }

                    Text {
                        font.pointSize: 20
                        color: isOnline ? busyIndicatorDownload.running ? "gray" : "teal" : "red"
                        text: isOnline ? busyIndicatorDownload.running ? "Downloading..." : "Download complete" : "Device is offline"
                    }
                }

                Button {
                    width: 200
                    text: qsTr("View Results")
                    highlighted: true
                    Material.background: Material.Orange
                    enabled: !busyIndicatorCopy.running && !busyIndicatorDownload.running && !busyIndicatorRead.running && !busyIndicatorWrite.running

                    onClicked: {
                        console.log("file:///"+AppFramework.resolvedPath(logFile.path))
                        Qt.openUrlExternally("file:///"+AppFramework.resolvedPath(logFile.path))
                    }
                }

                Button {
                    width: 200
                    text: qsTr("Send Diagnostics")
                    highlighted: true
                    Material.background: Material.Teal
                    enabled: !busyIndicatorCopy.running && !busyIndicatorDownload.running && !busyIndicatorRead.running && !busyIndicatorWrite.running

                    onClicked: {
                        var urlInfo = AppFramework.urlInfo("mailto:spillai@esri.com");
                        fileData.open(File.OpenModeReadWrite)

                        urlInfo.queryParameters = {
                            "subject": "Storage info for <device-name>",
                            "body": fileData.readAll()
                        };
                        fileData.close()
                        Qt.openUrlExternally(urlInfo.url);
                    }
                }
            }
        }
    }

    StorageInfo {
        id: storageInfo
    }

    Component.onCompleted: {

        var fs, dev, path

        logFile.path = internalStorage[internalStorage.length-1]

        if (logFile.fileExists("diagnostics.txt")) {
            logFile.removeFile("diagnostics.txt")
            logFile.removeFile("InternalMemory.txt")
            logFile.removeFile("appstudio.jpg")
            logFile.removeFile("SanFrancisco.tpk")
        }

        logFile.path = internalStorage[internalStorage.length-1] + "/diagnostics.txt"

        console.log("view diagnostics file at " + logFile.path)

        logFile.createSection("Diagnostics for storage")
        mountedVols = storageInfo.mountedVolumes

        logFile.logs(osName + " detected")
        logFile.logs("osVersion " + AppFramework.osVersion)
        logFile.logs("currentCpuArchitecture:" + AppFramework.currentCpuArchitecture)

        for (var i = 0; i < mountedVols.length; i++) {
            fs = mountedVols[i].fileSystemType

            if (fs === "sdcardfs" || fs === "fuse") {

                dev = mountedVols[i].device
                path = mountedVols[i].path

                if (fs === "fuse") {

                    if (dev === "/dev/fuse") {

                        if (path !== "/storage/emulated" &&
                            path !== "/storage/emulated/0" &&
                            path !== "/storage/emulated/0/Android/obb" &&
                            path !== "/storage/emulated/legacy" &&
                            path !== "/storage/emulated/legacy/Android/obb" &&
                            path !== "/storage/sdcard0" &&
                            path !== "/mnt/shell/emulated" &&
                            path !== "/storage/udisk1") {

                            isSDCardPresent = true
                            externalStorage = path;
                            logFile.logs("SD card detected")
                            logFile.logs("sd card path " + externalStorage)
                            logFile.logs("fileSystem : " + fs)

                            break;
                        }

                        if (path === "/storage/sdcard1")
                        {
                            isSDCardPresent = true
                            externalStorage = path;
                            logFile.logs("SD card detected")
                            logFile.logs("sd card path " + externalStorage)
                            logFile.logs("fileSystem : " + fs)

                            break;
                        }
                    }

                } else if (fs === "sdcardfs") {

                    if (dev.startsWith("/mnt")) {

                        isSDCardPresent = true;
                        externalStorage = path;
                        logFile.logs("SD card detected")
                        logFile.logs("sd card path " + externalStorage)
                        logFile.logs("fileSystem : " + fs)

                        break;
                    }

                } else {
                    continue;
                }

            } else {
                continue;
            }
        }

        // it is always the last one since the first one points to /data/user/0/<package-name>/files
        internalStorage = internalStorage[internalStorage.length-1]
        logFile.logs("internal storage path \n" + internalStorage)

        // Detect whether the app is running in player
        if (parent) {
            if (AppFramework.typeOf(parent, true) === "AppLoader") {
                logFile.logs("I appear to be running in the AppStudio player");
                isRunningInPlayer = true;
            } else {
                isRunningInPlayer = true;
                logFile.logs("I'm running in a different player or some sort of loader");
            }
        } else {
            isRunningInPlayer = false;
            logFile.logs("I'm running standalone or in AppRun/qmlscene");
        }


        if (isSDCardPresent) {
            if (isRunningInPlayer) {
                var playerID = internalStorage.substring(33,59)

                if (playerID === "com.esri.appstudio.player3") {
                    console.log("player3")
                    sdCardPath = externalStorage + "/Android/data/"+"com.esri.appstudio.player3"+"/files"
                } else {
                    console.log("player")
                    sdCardPath = externalStorage + "/Android/data/"+"com.esri.appstudio.player"+"/files"
                }

                logFile.logs("external storage path \n" + sdCardPath)
            } else {
                sdCardPath = externalStorage + "/Android/data/" + androidPackageName + "/files"
                logFile.logs("external storage path \n" + sdCardPath)
            }
        } else {
            logFile.logs("sd card not available")
        }

        writeFunctions()

        copyFunctions()

        downloadFunctions()
    }

    File {
        id: file
    }

    FileFolder {
        id: fileFolder
    }

    function copyLocalData(source, target) {
        return fileFolder.copyFile(source, target);
    }

    NetworkRequest {
        id: downloadNetworkRequest
        url: "http://appstudio.arcgis.com/images/index/introview.jpg"
        responsePath: pathPrefix +"/appstudio.jpg"
        property string pathPrefix

        onReadyStateChanged: {
            if ( readyState === NetworkRequest.DONE ) {
                logFile.logs("File downloaded at \n" + responsePath)
                downloadComplete = true
            }
        }
        onError: {
            logFile.log("error while downloading", errorText + ", " + errorCode)
            downloadComplete = true
        }
    }

    Controls.DescriptionPage {
        id: descPage
        visible: false
    }

    function copyFunctions() {

        logFile.createSection("Copy")

        var resourceFolder = AppFramework.fileFolder(app.folder.folder("data").path);
        if (!isSDCardPresent) {
            if (!fileFolder.fileExists(internalStorage + "/SanFrancisco.tpk")) {
                if (resourceFolder.copyFile(dataFile, internalStorage + "/SanFrancisco.tpk")) {
                    logFile.logs("File copied to \n" + internalStorage + "/SanFrancisco.tpk")
                }
            } else {
                logFile.logs("File already exists \n" + internalStorage + "/SanFrancisco.tpk")
            }
        } else {
            if (!fileFolder.fileExists(sdCardPath + "/SanFrancisco.tpk")) {
                if (resourceFolder.copyFile(dataFile, sdCardPath + "/SanFrancisco.tpk")) {
                    logFile.logs("File copied to \n" + sdCardPath + "/SanFrancisco.tpk")
                }
            } else {
                logFile.logs("File already exists \n" + sdCardPath + "/SanFrancisco.tpk")
            }
        }

        copyComplete = true
    }

    function readFunctions() {
        logFile.createSection("Read")

        if (!isSDCardPresent) {
            fileFolder.path = internalStorage
            if (!fileFolder.fileExists(internalStorage + "/InternalMemory.txt")) {
                logFile.logs("File not found at " + internalStorage)
            } else {
                logFile.logs("Reading contents from " + fileFolder.path+"/InternalMemory.txt")
                logFile.logs(fileFolder.readFile("InternalMemory.txt"))
            }
        } else {
            fileFolder.path = sdCardPath
            if (!fileFolder.fileExists(sdCardPath + "/ExternalMemory.txt")) {
                logFile.logs("File not found at " + sdCardPath)
            } else {
                logFile.logs("Reading contents from " + fileFolder.path+"/ExternalMemory.txt")
                logFile.logs(fileFolder.readFile("ExternalMemory.txt"))
            }
        }

        readComplete = true

        getStorageInfo()
    }

    function writeFunctions() {

        logFile.createSection("Write")

        if (!isSDCardPresent) {
            fileFolder.path = internalStorage
            fileFolder.writeFile("InternalMemory.txt", "AppStudio is awesome.")
            file.path = internalStorage + "/InternalMemory.txt"

            if (file.exists)
            {
                file.open(File.OpenModeReadWrite)
                file.writeLine("AppStudio is awesome")
                logFile.logs("Write operation complete " + internalStorage+"/InternalMemory.txt")
                file.close()
            }
        } else {
            fileFolder.path = sdCardPath
            if (fileFolder.makeFolder())
            {
                console.log("success")
            }

            if (!fileFolder.writeTextFile("ExternalMemory.txt", "AppStudio is awesome."))
            {
                console.log("error")
            }
            else
            {
                console.log("success")
            }

            file.path = sdCardPath + "/ExternalMemory.txt"

            if (file.exists)
            {
                file.open(File.OpenModeReadWrite)
                file.writeLine("AppStudio is awesome");
                logFile.logs("Write operation complete " + sdCardPath+"/ExternalMemory.txt")
                file.close();
            }
        }

        writeComplete = true
    }

    function downloadFunctions() {

        logFile.createSection("Download")

        if (isOnline) {
            if (!isSDCardPresent) {

                logFile.logs("Downloading file in internal storage")
                downloadNetworkRequest.pathPrefix = internalStorage
                downloadNetworkRequest.send({f:"json"});

                delay(5000, function() {
                    readFunctions()
                })

            } else {
                logFile.logs("Downloading file in external storage")
                downloadNetworkRequest.pathPrefix = sdCardPath
                downloadNetworkRequest.send({f:"json"});

                delay(5000, function() {
                    readFunctions()
                })

            }
        } else {
            logFile.logs("Device is offline")
            logFile.logs("Download Failed")
            downloadComplete = true

            delay(5000, function() {
                readFunctions()
            })

        }
    }

    function getStorageInfo() {
        console.log("inside")

        var basePath = "/storage";
        var paths = [];

        fileFolder.path = basePath;

        var basePathSubFolders = fileFolder.folderNames();

        for (var basePathSubFolder in basePathSubFolders) {

            var folderName = basePathSubFolders[basePathSubFolder];
            var pathToSearch = basePath + "/" + folderName + "/";
            console.log(pathToSearch)

        }

    }

    FileFolder {
        id: logFile
        property var logArray : []

        function logs(input) {
            if (input) {
                logArray.push(input.toString());
            }
            logFile.writeTextFile(logFile.path, logArray.join("\n"))
        }

        function createSection(section) {
            if (section) {
                logArray.push("\n------ " + section.toString() + " -------\n")
            }
            logFile.writeTextFile(logFile.path, logArray.join("\n"))
        }
    }

    Timer {
        id: timer

        onTriggered: {
            console.log("read complete")
        }
    }

    function delay(delayTime, cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    FileInfo {
        id: fileInfo
        filePath: logFile.path
    }

    File {
        id: fileData
        path: fileInfo.filePath
    }
}

