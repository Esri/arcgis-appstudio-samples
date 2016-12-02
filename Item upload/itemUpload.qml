//------------------------------------------------------------------------------

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0

Rectangle {
    id: myApp
    width: 500
    height: 400

    property string portalUrl: "http://www.arcgis.com"
    property string owningSystemUrl: ""
    property string tokenServicesUrl: ""
    property string token: ""
    property bool ssl: false
    property int expires: 0
    property string errorMessage
    property string portalName: "ArcGIS online"
    property var userItems
    property string username
    property string currentItemId: ""
    property string currentTitle
    property string sourcePath
    property string completeMessage

    Timer {
        id: timer
        interval: 100
        repeat: false
        running: true
        triggeredOnStart: true
        onTriggered: signInDialog.open()
    }

    Component.onCompleted: {
        infoNetworkRequest.submit();
        portalsSelfNetworkRequest.submit();
    }

    NetworkRequest {
        property bool busy: false
        id: infoNetworkRequest
        url: portalUrl + "/sharing/rest/info"
        responseType: "json"
        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                owningSystemUrl = response.owningSystemUrl;
                tokenServicesUrl = response.authInfo.tokenServicesUrl;
                busy = false;
            }
        }
        function submit() {
            busy = true;
            send( { "f": "json"} );
        }
    }

    NetworkRequest {
        property bool busy: false
        id: portalsSelfNetworkRequest
        url: portalUrl + "/sharing/rest/portals/self"
        responseType: "json"
        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                if (response.hasOwnProperty("portalName")) {
                    portalName = response.portalName;
                }
                busy = false;
            }
        }
        function submit() {
            busy = true;
            send( { "f": "json"} );
        }
    }

    NetworkRequest {
        property bool busy: false
        id: tokenNetworkRequest
        url: tokenServicesUrl
        responseType: "json"
        method: "POST"
        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                if (response) {
                    if (response.hasOwnProperty("error")) {
                        errorMessage = "Error " + response.error.code + " - " + response.error.message + "\n" + response.error.details.join("\n");
                    } else  if (response.hasOwnProperty("token") && response.hasOwnProperty("ssl") && response.hasOwnProperty("expires")) {
                        token = response.token;
                        ssl = response.ssl;
                        expires = response.expires;
                        signInDialog.close();
                        fileDialog.visible = true;
                    }
                }
                busy = false;
            }
        }
        function submit(username, password) {
            busy = true;
            errorMessage = "";
            token = "";
            ssl = false;
            expires = 0;
            myApp.username = username;
            send( { "f": "json", "username": username, "password": password, "referer": portalUrl } );
        }
    }

    NetworkRequest {
        property bool busy: false
        id: addItemNetworkRequest
        method: "POST"
        url: portalUrl + "/sharing/rest/content/users/" + username + "/addItem"
        responseType: "json"
        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                console.log(JSON.stringify(responseText, undefined, 2));
                if (response && response.id) {
                    currentItemId = response.id;
                    updateItemNetworkRequest.submit();
                }
                busy = false;
            }
        }
        function submit() {
            busy = true;
            var body = {
                "f": "json",
                "type": "Code Sample",
                "title" : currentTitle,
                "description": "Generating Item Id ...",
                "tags": "add item,sample",
                "token": token
            };
            send( body )
        }
    }

    NetworkRequest {
        property bool busy: false
        id: updateItemNetworkRequest
        method: "POST"
        url: portalUrl + "/sharing/rest/content/users/" + username + "/items/" + currentItemId + "/update"
        responseType: "json"
        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                console.log(JSON.stringify(responseText, undefined, 2));
                if (response && response.success) {
                    completeMessage = currentTitle + " uploaded!";
                }

                busy = false;
            }
        }
        function submit() {
            busy = true;
            var body = {
                "f": "json",
                "description" : "Item Added.",
                "file": uploadPrefix + sourcePath,
                "token": token
            };
            send( body )
        }
    }

    Text {
        id: statusText
        anchors {
            centerIn: parent
        }
    }

    Rectangle {
        anchors {
            fill: appTitleText
            margins: -appTitleText.anchors.margins
        }
        color: "#0079C1"
    }

    Text {
        id: appTitleText

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10 * AppFramework.displayScaleFactor
        }

        text: qsTr("Upload Item")
        color: "white"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        font {
            pointSize: 22
            bold: true
        }
    }

    Dialog {
        id: signInDialog

        property bool busy: infoNetworkRequest.busy || tokenNetworkRequest.busy

        title: qsTr("Sign in to ") + portalName

        contentItem: Rectangle {
            id: signInRectangle
            implicitWidth: Math.min(400 * AppFramework.displayScaleFactor, Screen.desktopAvailableWidth * 0.95)
            implicitHeight: Math.min(320 * AppFramework.displayScaleFactor, Screen.desktopAvailableHeight * 0.95)

            Rectangle {
                anchors {
                    fill: titleText
                    margins: -titleText.anchors.margins
                }
                color: "#0079C1"
            }

            Text {
                id: titleText

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 10 * AppFramework.displayScaleFactor
                }

                text: qsTr("Sign In")
                color: "white"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                font {
                    pointSize: 22
                    bold: true
                }
            }

            Column {
                width: Math.min(400 * AppFramework.displayScaleFactor, Screen.desktopAvailableWidth * 0.95) * 0.9
                spacing: 5 * AppFramework.displayScaleFactor

                anchors {
                    left: parent.left
                    top: titleText.bottom
                    topMargin: 50 * AppFramework.displayScaleFactor
                    margins: 10 * AppFramework.displayScaleFactor
                }

                Text {
                    id: usernameText
                    text: qsTr("Username")
                }

                TextField {
                    id: usernameTextField
                    placeholderText: usernameText.text
                    font.pixelSize: 15 * AppFramework.displayScaleFactor
                    width: parent.width
                    style: TextFieldStyle {
                        renderType: Text.QtRendering
                    }
                    onAccepted: {
                        passwordTextField.focus = true;
                    }
                }

                Text {
                    id: passwordText
                    text: qsTr("Password")
                }

                TextField {
                    id: passwordTextField
                    echoMode: TextInput.Password
                    placeholderText: passwordText.text
                    font: usernameTextField.font
                    width: usernameTextField.width
                    style: usernameTextField.style
                    onAccepted: {
                        acceptButton.submit();
                    }
                }

                Text {
                    id: messageText

                    text: errorMessage
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    color: "red"
                    font {
                        pointSize: 14
                        italic: true
                        bold: true
                    }
                }
            }

            Button {
                id: acceptButton
                text: qsTr("Sign In")
                focus: true
                enabled: !infoNetworkRequest.busy
                         && !tokenNetworkRequest.busy
                         && usernameTextField.text.length > 0
                         && passwordTextField.text.length > 0
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    margins: 10 * AppFramework.displayScaleFactor
                }
                onClicked: {
                    submit();
                }

                function submit() {
                    if (enabled) {
                        tokenNetworkRequest.submit(usernameTextField.text, passwordTextField.text);
                    }
                }
            }

            Button {
                id: rejectButton
                text: qsTr("Cancel")
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: 10 * AppFramework.displayScaleFactor
                }
                onClicked: {
                    Qt.quit();
                }

            }

            BusyIndicator {
                running: tokenNetworkRequest.busy
                anchors.centerIn: parent
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: qsTr("Select file to upload")
        selectExisting: true
        selectFolder: false
        onAccepted: {
            sourcePath = AppFramework.resolvedPath(fileUrl);
            currentTitle = sourcePath.replace(/.*[/]/, '');
            addItemNetworkRequest.submit();
        }
    }

    Rectangle {
        anchors {
            fill: progressColumn
            margins: -10 * AppFramework.displayScaleFactor
        }
        visible: progressColumn.visible
        color: "white"
        border {
            color: "#808080"
            width: 2 * AppFramework.displayScaleFactor
        }
        radius: 5 * AppFramework.displayScaleFactor
    }

    Column {
        id: progressColumn
        anchors {
            centerIn: parent
        }
        width: parent.width * 0.8
        visible: addItemNetworkRequest.busy || updateItemNetworkRequest.busy
        Text {
            text: addItemNetworkRequest.busy ? qsTr("Creating New Item") : qsTr("Uploading Item Content")
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
        ProgressBar {
            value: addItemNetworkRequest.busy ? addItemNetworkRequest.progress : updateItemNetworkRequest.progress
            width: parent.width
        }
        Text {
            text: Math.floor((addItemNetworkRequest.busy ? addItemNetworkRequest.progress : updateItemNetworkRequest.progress) * 100.0) + "%"
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
        Rectangle {
            width: parent.width
            height: cancelButton.height + 20 * AppFramework.displayScaleFactor
            Button {
                id: cancelButton
                anchors {
                    centerIn: parent
                }
                text: qsTr("Cancel")
                onClicked: {
                    if (addItemNetworkRequest.busy) {
                        addItemNetworkRequest.abort();
                    }
                    if (updateItemNetworkRequest.busy) {
                        updateItemNetworkRequest.abort();
                    }
                }
            }
        }
    }

    Rectangle {
        anchors {
            fill: completeColumn
            margins: -10 * AppFramework.displayScaleFactor
        }
        visible: completeColumn.visible
        color: "white"
        border {
            color: "#808080"
            width: 2 * AppFramework.displayScaleFactor
        }
        radius: 5 * AppFramework.displayScaleFactor
    }

    Column {
        id: completeColumn
        anchors {
            centerIn: parent
        }
        width: parent.width * 0.8
        visible: completeMessage
        Text {
            text: completeMessage
            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

